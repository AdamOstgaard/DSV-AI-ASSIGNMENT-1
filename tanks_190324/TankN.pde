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

  public void retreat() {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].retreat()");
    //ArrayList <PVector> pathBack = pathBack(this.position);
    /*
    println(visitedNodes.toString());
    for (PVector p : pathBack) {
      moveTo(p);
    }
    */
    //moveTo(grid.getRandomNodePosition()); // Slumpmässigt mål.
  }

/*
   private ArrayList<PVector> pathBack(PVector start) {
     
    ArrayList <PVector> openPath = visitedNodes;
    Collections.sort(openPath, new DistanceComparator(this.startpos));
    println(openPath.toString());
    ArrayList <PVector> closedPath = new ArrayList <PVector>();
    return openPath;
    
    //return shortestPath(openPath, closedPath);
  }
*/
  
  private ArrayList <PVector> shortestPath(PVector start, ArrayList<PVector> pathBack) {
/*
    int min = Integer.MAX_VALUE;
    PVector nodeToAdd = start;
    if (start == this.startpos)
      return pathBack;
    for (Node p : visitedNodes) {
      if ((start.x - p.x) + (start.y - p.y) < min) {
        nodeToAdd = p;
      }
    }
    pathBack.add(nodeToAdd);
    shortestPath(nodeToAdd, pathBack);*/
    return null;
  }

  //*******************************************************
  // Reterera i motsatt riktning (ej implementerad!)
  public void retreat(Tank other) {
    //println("*** Team"+this.team_id+".Tank["+ this.getId() + "].retreat()");
    //moveTo(grid.getRandomNodePosition());
    retreat();
  }

  public void message_collision(Tree other) {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].collision(Tree)");
    // boolean foundPath = astar(known.getNearestNode(position), known.nodes[0][0]);
    // System.out.println("foundPath: " + foundPath);
    // if (foundPath){
    //   Stack<Node> path = known.nodes[0][0].getPath(new Stack<Node>());
    //   System.out.println(path.size());
    //   while (!path.empty()){
    //     Node n = path.pop();
    //     System.out.println("row: " + n.row + " col: " + n.col);
    //   }
    // }
    wander();
  }

  public void message_collision(Tank other) {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].collision(Tank)");
    // for (int i = 0; i < known.nodes.length; i++){
    //   for (int j = 0; j < known.nodes[i].length; j++){
    //     Node n = known.nodes[i][j];
    //     System.out.println("row: " + n.row + " col: " + n.col + " content: " + n.nodeContent);
    //   }
    // }
    wander();
  }

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
        turnLeft();
        state = StateFlag.ROTATING;
        // spin(0.5);
        break;
      case ROTATING:
        if(round10(fixAngle(degrees(heading))) == round10(fixAngle(degrees(target_rotation)))){
          println("FINNISHED ROTATING");
          state = StateFlag.ARRIVED_ROTATE;
        }
        //println(round10(fixAngle(degrees(heading)))  + " - " + round10(fixAngle(degrees(target_rotation))));
        turnLeft();
        break;
      case ROTATING_PARTIAL:
      println("PARTIAL");
        rotateTo(radians(last_rot+=90));
        state = StateFlag.ROTATING;
        break;

      
    }

    if (!this.userControlled) {

      //moveForward_state();
      if (this.stop_state) {
        //rotateTo()
        //wander();
        return;
      }

      if (this.idle_state) {
        //wander();
        return;
      }
    }
  }

  float getAngle(float pX1,float pY1, float pX2,float pY2){
  return atan2(pY2 - pY1, pX2 - pX1);
}

  int round10(float n) {
    return (round(n) + 5) / 10 * 10;
  }

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
        // System.out.println("current position: " + position.toString());
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
      // System.out.println("Node row: " + nodeToUpdate.row + " col: " + nodeToUpdate.col + " is now: " + currentSpriteContent);
    }
  
    // pushMatrix();
    // translate(position.x, position.y);
    // rotate(velocity.heading());
    
    // if(seesEnemy){
    //   println("SEES ENEMY!");
    //   fill(255,0,0);
    //   stroke(255,0,0);
    // }
    // if(seesFriend){
    //   println("SEES Friend");
    //   fill(0,0,255);
    //   stroke(0,0,255);
    // }
    // if(seesTree){
    //   println("SEES Tree!");
    //   fill(0,255,0);
    //   stroke(0,255,0);
    // }
    // line(0, 0, 500, 0);
    // popMatrix();
    // pushMatrix();
    // translate(0,0);
    //     for (int i = 0; i < known.nodes.length; i++){
          
    //   for (int j = 0; j < known.nodes[i].length; j++){
    //     displayKnown(known.nodes[i][j]);
    //   }
    // }
    // popMatrix();
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
    
        // A vector that points to another boid and that angle
        // PVector comparison = PVector.sub(n.position, position);
        
        // How far is it
    float d = PVector.dist(position, n.position);

    // What is the angle between the other boid and this one's current direction
    float diff = getAngle(position.x, position.y, n.position.x, n.position.y);
    
    float a = radius;
    float angleDiff = atan(a / d);
    
    heading = velocity.heading();

    // pushMatrix();
    // translate(position.x, position.y);
    // rotate(diff - angleDiff);
    // stroke(100,50,0);
    // line(0, 0, 500, 0);
    // rotate(angleDiff * 2);
    // line(0, 0, 500, 0);
    // stroke(0,0,0);
    // popMatrix();
    
    return heading > diff - angleDiff && heading < diff + angleDiff;
  }

  boolean isSpriteInFront(Sprite t){

    // A vector that points to another boid and that angle
    // PVector comparison = PVector.sub(t.position, position);
    
    // How far is it
    float d = PVector.dist(position, t.position);

    // What is the angle between the other boid and this one's current direction
    float diff = getAngle(position.x, position.y, t.position.x, t.position.y);
    
    float a = t.radius;
    float angleDiff = atan(a / d);
    
    heading = velocity.heading();

    pushMatrix();
    translate(position.x, position.y);
    rotate(diff - angleDiff);
    stroke(100,50,0);
    line(0, 0, 500, 0);
    rotate(angleDiff * 2);
    line(0, 0, 500, 0);
    stroke(0,0,0);
    popMatrix();
    
    return heading > diff - angleDiff && heading < diff + angleDiff;
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
