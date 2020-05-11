/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
enum StateFlag { RETREATING, WANDERING, ROTATING, ARRIVED_MOVE, ARRIVED_ROTATE, ROTATING_PARTIAL }

public class TankN extends Tank {
  boolean started;
  PVector destinationPos;
  ArrayList <Node> visitedNodes;
  ArrayList <PVector> tankPList;
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

      if(!visitedNodes.contains(tempNode) && known.nodes[tempNode.col][tempNode.row].nodeContent == Content.UNKNOWN) {
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
view(); 
    super.updateLogic();
    grid.display();
    if (!started) {
      started = true;
      wander();
      return;
    }

    

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

  int round10(float n) {
    return (round(n) + 5) / 10 * 10;
  }

  //Hanterar tankens vy och vad den kan observera.
  void view () {
    Sensor s = getSensor("VISUAL");

    SensorReading reading = s.readValue();
if (reading != null )
    println(reading.obj.getName());

    if (reading != null && reading.obj.getName() == "tree"){
      Node nodeToUpdate = known.getNearestNode(reading.obj.position);
      nodeToUpdate.nodeContent = Content.TREE;
      
    }

    if (reading != null && reading.obj.getName() == "tank"){
      Tank t = (Tank)reading.obj;
      Node nodeToUpdate = known.getNearestNode(reading.obj.position);
      if(t.team == team){
        nodeToUpdate.nodeContent = Content.FRIEND;
      } else {
        nodeToUpdate.nodeContent = Content.ENEMY;
      }
    }
    //displayKnown();
  }



  void displayKnown() {
    for(int i = 0; i < known.nodes.length; i++){
      for(int j = 0; j < known.nodes[i].length; j++){
      Node n = known.nodes[i][j];
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
