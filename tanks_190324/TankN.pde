enum StateFlag { RETREATING, WANDERING, ROTATING, ARRIVED_MOVE, ARRIVED_ROTATE, ROTATING_PARTIAL }

public class TankN extends Tank {
  boolean started;
  PVector destinationPos;
  ArrayList <Node> visitedNodes;
  ArrayList <PVector> tankPList;
  boolean seesEnemy;
  boolean seesTree;
  boolean seesFriend;
  int reportStartTime;
  boolean waitingToReport;
  Grid known;
  int heading2;

  float target_rotation;
  float last_rot = 0;

  StateFlag state;

  TankN(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    visitedNodes = new ArrayList <Node>();
    this.started = false;
    tankPList = new ArrayList<PVector>();
    known = new Grid(cols, rows, grid_size);
    state = StateFlag.ROTATING;
  }
  
  Tank[] getEnemyTanks() {
    Tank[] enemyTanks = new Tank[3];
    int j = 0;
    
    for (int i = 0; i < allTanks.length; i++)
    {
      Tank otherTank = allTanks[i]; 
      if(otherTank.team_id != team_id){
        enemyTanks[j++] = otherTank;
      }  
    }
    return enemyTanks;
  }

  Tank[] getFriendlyTanks(){
    Tank[] friendly = new Tank[2];
    friendly[0] = allTanks[1];
    friendly[1] = allTanks[2];
    return friendly;
  }  
  
  Tank[] getOtherTanks(){
    Tank[] otherTanks = new Tank[5];
    for (int i = 1; i < allTanks.length; i++)
    {
      Tank otherTank = allTanks[i]; 
      otherTanks[i] = otherTank;
    }  
    return otherTanks;
  }

  //Går till observerade noder som ej är besökta
  public void wander() {
    Node[] nodes = getNeighborNodes();
    Node node = null;

    int retries = 0;

    for (int i = (int)random(0,4); i < nodes.length + 4; i++){
      node = nodes[i % 4];
      if(node == null){
        continue;
      }
      if(isNodeTree(node)){
        Node nodeToUpdate = known.getNearestNode(node.position);
        nodeToUpdate.nodeContent = Content.TREE;
      }
      if(!visitedNodes.contains(node) && known.nodes[node.col][node.row].nodeContent == Content.EMPTY){
        moveTo(node.position);
        println("walk to: " + node.col + ", " + node.row + " - contains: " + known.nodes[node.col][node.row].nodeContent );
        return;
      }
    }

    for(int i = 0; i < grid.cols * grid.rows; i++){
      Node tempNode = grid.getNearestNode(grid.getRandomNodePosition());

      if(!visitedNodes.contains(tempNode) && known.nodes[tempNode.col][tempNode.row].nodeContent == Content.EMPTY) {
        node = tempNode;
        println("Random walk to known");
        break;
      }

      if(node == null){
        node = grid.getNearestNode(grid.getRandomNodePosition());
      }
    
    }
      println("Random walk");
      moveTo(node.position);
  }

  //Checking if node is a tree
  boolean isNodeTree(Node node){
    for (int i = 0; i < allTrees.length; i++) {
      Tree tree = allTrees[i];
      PVector distanceVect = PVector.sub(tree.position, node.position);

      // Calculate magnitude of the vector separating the tank and the tree
      float distanceVectMag = distanceVect.mag();

      // Minimum distance before they are touching
      float minDistance = grid.grid_size + tree.radius;

      if (distanceVectMag <= minDistance) {
        return true;
      }
    }
    return false;
  }

  //Hämtar grann-noder till nuvarande noden.
  Node[] getNeighborNodes(){
    Node currentNode = grid.getNearestNode(position);
    Node[] neighbors = new Node[4];
    
    if(currentNode.col >= 1){
      neighbors[0] = grid.nodes[currentNode.col - 1][currentNode.row];
    }

    if(currentNode.col < grid.cols - 1){
      neighbors[1] = grid.nodes[currentNode.col + 1][currentNode.row];
    }

    if(currentNode.row >= 1){
      neighbors[2] = grid.nodes[currentNode.col][currentNode.row -1];
    }

    if(currentNode.row < grid.rows - 1){
      neighbors[3] = grid.nodes[currentNode.col][currentNode.row + 1];
    }

    return neighbors;
  }

  public void arrived() {
    super.arrived();
    state = StateFlag.ARRIVED_MOVE;
    visitedNodes.add(grid.getNearestNode(position));
    println(visitedNodes.toString());
  }

  void arrivedRotation() {
    super.arrivedRotation();
    state = StateFlag.ROTATING_PARTIAL;
  }

  //Vi lyckades inte få retreat att fungera
  public void retreat() {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].retreat()");
    //Stack<Node> path = known.nodes[0][0].getPath(new Stack<Node>());
    //   System.out.println(path.size());
    //   while (!path.empty()){
    //     moveTo(path.pop());
    //   }
  }
  

  //*******************************************************
  // Reterera i motsatt riktning (ej implementerad!)
  public void retreat(Tank other) {
    retreat();
  }

  public void message_collision(Tree other) {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].collision(Tree)");
    wander();
  }

  public void message_collision(Tank other) {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].collision(Tank)");
    // retreat(); retreat fungerar ej
    wander();
  }

  //Lagt till uppdatering av states, tanken roterar ett varv efter dan anlänt till en ny nod.
  public void updateLogic() {
    super.updateLogic();
    grid.display();

    if (!started) {
      started = true;
      wander();
      return;
    }

    view();

    switch(state){
      case WANDERING:
        break;
      case ARRIVED_ROTATE:
        state = StateFlag.WANDERING;
        wander();
        break;
      case ARRIVED_MOVE:
      println("START ROTATING");
        target_rotation = heading - 270;
        last_rot = heading + 90;
        turnRight();
        state = StateFlag.ROTATING;
        break;
      case ROTATING:
        if(round10(fixAngle(degrees(heading))) == round10(fixAngle(degrees(target_rotation)))){
          println("FINNISHED ROTATING");
          state = StateFlag.ARRIVED_ROTATE;
        }
        turnLeft();
        break;
      case ROTATING_PARTIAL:
      println("PARTIAL");
        rotateTo(radians(last_rot+=90));
        state = StateFlag.ROTATING;
        break;

      
    }
  }

  float getAngle(float pX1,float pY1, float pX2,float pY2){
  return atan2(pY2 - pY1, pX2 - pX1);
}

  int round10(float n) {
    return (round(n) + 5) / 10 * 10;
  }

  //Hanterar tankens vy och vad den kan observera.
  void view () {
    seesEnemy = false;
    seesTree = false;
    seesFriend = false;
    Content currentSpriteContent = Content.UNKNOWN;
    boolean seesNode = false;
    Tank[] enemyTanks = getEnemyTanks();
    Tank[] friendlyTanks = getFriendlyTanks();
    float closest = Float.MAX_VALUE;
    Sprite closestSprite = null;
    for (int i = 0; i < enemyTanks.length; i++){
      float distance = PVector.dist(position, enemyTanks[i].getRealPosition());
      if (inEnemyBase(position) && isSpriteInFront(enemyTanks[i]) && distance < closest){
        closest = distance;
        closestSprite = enemyTanks[i];
        seesEnemy = true;
        currentSpriteContent = Content.ENEMY;
      }
    }
    for (int i = 0; i < friendlyTanks.length; i++){
      float distance = PVector.dist(position, friendlyTanks[i].getRealPosition());
      if (isSpriteInFront(friendlyTanks[i]) && distance < closest){
        closest = distance;
        closestSprite = friendlyTanks[i];
        seesEnemy = false;
        seesFriend = true;
        currentSpriteContent = Content.FRIEND;
      }
    }
    for (int i = 0; i < allTrees.length; i++){
      float distance = PVector.dist(position, allTrees[i].getRealPosition());
      if (isSpriteInFront(allTrees[i]) && distance < closest){
        closest = distance;
        closestSprite = allTrees[i];
        seesEnemy = false;
        seesFriend = false;
        seesTree = true;
        currentSpriteContent = Content.TREE;
      }
    }
    for (int i = 0; i < grid.nodes.length; i++){
      for (int j = 0; j < grid.nodes[i].length; j++){
        Node n = grid.nodes[i][j];
        seesNode = isNodeInFront(n);
        float distance = PVector.dist(position, n.position);
        if ((seesNode && distance < closest && !nodeInEnemyBase(n)) ||
          (seesNode && distance < closest && nodeInEnemyBase(n) && inEnemyBase(position))) {
          if (closestSprite == null){
            Node nodeToUpdate = known.getNearestNode(n.position);
            if(nodeToUpdate.nodeContent != Content.TREE){
              nodeToUpdate.nodeContent = currentSpriteContent;
            }
            nodeToUpdate.nodeContent = Content.EMPTY;
          }
          else if (grid.getNearestNode(closestSprite.position()) != grid.nodes[i][j]){
            Node nodeToUpdate = known.getNearestNode(n.position);
            if(nodeToUpdate.nodeContent != Content.TREE){
              nodeToUpdate.nodeContent = currentSpriteContent;
            }
            nodeToUpdate.nodeContent = Content.EMPTY;
          }
        }
      }
    }
    if (closestSprite != null){
      Node nodeToUpdate = known.getNearestNode(closestSprite.position);
      if(nodeToUpdate.nodeContent != Content.TREE){
      nodeToUpdate.nodeContent = currentSpriteContent;
      }
    }
  }

  boolean inEnemyBase(PVector v){
    Team enemyTeam = teams[1];
    return 
      v.x > enemyTeam.homebase_x && 
      v.x < enemyTeam.homebase_x + enemyTeam.homebase_width &&
      v.y > enemyTeam.homebase_y &&
      v.y < enemyTeam.homebase_y + enemyTeam.homebase_height;
  }

  boolean nodeInEnemyBase(Node n){
    return inEnemyBase(n.position);
  }

  boolean isNodeInFront(Node n){
    
    //Inspirerat av The Nature of Code exercise_6_17_view
    float d = PVector.dist(position, n.position);

    float diff = getAngle(position.x, position.y, n.position.x, n.position.y);
    
    float a = radius;
    float angleDiff = atan(a / d);
    
    heading2 = round(fixAngle(degrees(heading)));
    
    return heading2 > round(fixAngle(degrees( diff - angleDiff))) && heading2 < round(fixAngle(degrees(diff + angleDiff)));
  }

  boolean isSpriteInFront(Sprite t){

    //Inspirerat av The Nature of Code exercise_6_17_view
    float d = PVector.dist(position, t.position);

    
    float diff = getAngle(position.x, position.y, t.position.x, t.position.y);
    
    float a = t.radius;
    float angleDiff = atan(a / d);
    
    heading2 = round(fixAngle(degrees(velocity.heading())));

    pushMatrix();
    translate(position.x, position.y);
    rotate(diff - angleDiff);
    stroke(100,50,0);
    line(0, 0, 500, 0);
    rotate(angleDiff * 2);
    line(0, 0, 500, 0);
    stroke(0,0,0);
    popMatrix();
    
    return heading2> round(fixAngle(degrees(diff - angleDiff))) && heading2 < round(fixAngle(degrees(diff + angleDiff)));
  }

  void displayKnown(Node n) {

    ellipse(n.position.x, n.position.y - known.grid_size, 40, 40);

    switch(n.nodeContent){
      case ENEMY:
          fill(0,0,255,100);
          break;
      case FRIEND:
          fill(255,0,0,100);
          break;
      case TREE:
          fill(0,255,0,100);
          break;
      case EMPTY:
          fill(255,255,255,100);
          break;
      case UNKNOWN:
          fill(0,0,0,100);
          break;
    }

  }

//Inspirerat av https://github.com/SebLague/Pathfinding/blob/master/Episode%2001%20-%20pseudocode/Pseudocode
//Använder A* algoritmen för att ta fram den kortaste vägen till målet. Pathen hämtas genom Node.getPath på målnoden.
  boolean astar(Node start, Node end) {
    known.resetPathVariables();
    ArrayList<Node> open = new ArrayList<Node>();
    start.g = 0;
    open.add(start);
    ArrayList<Node> closed = new ArrayList<Node>();
    ArrayList<Node> neighbours;
    while (open.size() > 0){
      float lowest = Float.MAX_VALUE;
      Node current = null;
      for (Node n : open){
        if (n.g + PVector.dist(n.position, end.position) < lowest){
          lowest = n.g + PVector.dist(n.position, end.position);
          current = n;
        }
      }
      open.remove(current);
      closed.add(current);
      if (current == end){
        return true;
      }
      neighbours = known.getNeighbours(current.col, current.row);
      for (Node neighbour : neighbours){
        if (neighbour.nodeContent == Content.FRIEND ||
        neighbour.nodeContent == Content.ENEMY ||
        neighbour.nodeContent == Content.TREE ||
        closed.contains(neighbour)){
          continue;
        }
        if (!closed.contains(neighbour) || 
        current.g + PVector.dist(current.position, neighbour.position) < neighbour.g){
          if (neighbour.nodeContent == Content.UNKNOWN)
            neighbour.g = current.g + PVector.dist(current.position, neighbour.position) * 2;
          else
            neighbour.g = current.g + PVector.dist(current.position, neighbour.position);
          neighbour.parent = current;
          if (!open.contains(neighbour)){
            open.add(neighbour);
          }
        }
      }
    }
    return false;
  }

  boolean isReportDone(){
    if (reportStartTime - remainingTime >= 3)
      return true;
    else
      return false;
  }
}
