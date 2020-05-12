/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/


public class TankN extends Tank {
  int tankHits;
  int friendlyHits;

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
  ExecutionPlanner planner;
  ExecutionPlan currentPlan = null;

  TankN(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    planner = new ExecutionPlanner(this);
    visitedNodes = new ArrayList <Node>();
    this.started = false;
    tankPList = new ArrayList<PVector>();
    known = new Grid(cols, rows, grid_size);
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
    visitedNodes.add(grid.getNearestNode(position));
    println(visitedNodes.toString());
  }

  void arrivedRotation() {
    super.arrivedRotation();
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
    // wander();
  }

  public void message_collision(Tank other) {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].collision(Tank)");
    // retreat(); retreat fungerar ej
    // wander();
  }

  //Lagt till uppdatering av states, tanken roterar ett varv efter dan anlänt till en ny nod.
  public void updateLogic() {
    super.updateLogic();
    // grid.display();

    if(currentPlan == null || !currentPlan.hasMoreSteps()){
      currentPlan = planner.generatePlan();
    }

    currentPlan.execute();
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

  int round10(float n) {
    return (round(n) + 5) / 10 * 10;
  }