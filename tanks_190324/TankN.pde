/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/

public class TankN extends Tank {
  ArrayList <Node> visitedNodes;
  Grid known;

  ExecutionPlanner planner;
  ExecutionPlan currentPlan = null;

  TankN(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    planner = new ExecutionPlanner(this);
    visitedNodes = new ArrayList <Node>();
    known = new Grid(cols, rows, grid_size);
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
  }

  //Lagt till uppdatering av states, tanken roterar ett varv efter dan anlänt till en ny nod.
  public void updateLogic() {
    super.updateLogic();

    this.isEnemyInfront = seesEnemy();
    // grid.display();

    if(currentPlan == null || !currentPlan.hasMoreSteps() || !currentPlan.isValid()){
      println("replan!");
      currentPlan = planner.generatePlan();
    }

    currentPlan.execute();
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

  boolean seesEnemy(){
      Sensor s = getSensor("VISUAL");
      SensorReading reading = s.readValue();

      if(reading != null && reading.obj.getName() == "tank"){
          Tank t = (Tank)reading.obj;
          return team != t.team && t.health > 0; 
      }
      return false;
  }
}

int round10(float n) {
  return (round(n) + 5) / 10 * 10;
}