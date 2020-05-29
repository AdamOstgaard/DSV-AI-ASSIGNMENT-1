/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/

public class TankN extends Tank {
  ArrayList <Node> visitedNodes;
  Grid known;
  boolean isRetreating;
  Stack<Node> retreatPath;
  Stack<Node> movePath;
  ExecutionPlanner planner;
  ExecutionPlan currentPlan = null;

  TankN(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    planner = new ExecutionPlanner(this);
    visitedNodes = new ArrayList <Node>();
    known = new Grid(cols, rows, grid_size);
    isRetreating = false;
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
    //known.getNearestNode(position).nodeContent = Content.EMPTY;
    println("ARRIVED AT: " + known.getNearestNode(position).nodeContent);
  }

    // Tanken meddelas om kollision med trädet.
  public void message_collision(Tree other) {
    println("*** Tank["+ this.getId() + "].collision(Tree)");
    currentPlan = planner.generateWalkToRandomPlan();
    //println("Tank.COLLISION");
  }

  // Tanken meddelas om kollision med den andra tanken.
  public void message_collision(Tank other) {
    println("*** Tank["+ this.getId() + "].collision(Tank)");
    currentPlan = planner.generateWalkToRandomPlan();
    //println("Tank.COLLISION");
  }

  //Lagt till uppdatering av states, tanken roterar ett varv efter dan anlänt till en ny nod.
  public void updateLogic() {
    super.updateLogic();

    Sensor s = getSensor("VISUAL");
    SensorReading reading = s.readValue();

    updateKnownObjects(reading);
    updateKnownNodes(s, reading);



    // Det här kan användas sen för att kapa ner antalet steg från astar.
    // SensorVisuals sv = (SensorVisuals) s;
    // boolean nodeInFront = sv.isNodeInFront(node n, reading);

    // Testmetoder
   
    // if (id == 2){
    //   // printKnownNodes();
    //   // displayKnownNodes();
    // }

    isEnemyInfront = seesEnemy(reading);
    if (isEnemyInfront && hasShot){
      currentPlan = planner.generateFireCannonPlan();
    }
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
        neighbour.nodeContent == Content.OBSTACLE ||
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

  boolean seesEnemy(SensorReading reading){
      //Sensor s = getSensor("VISUAL");
      //SensorReading reading = s.readValue();

      if(reading != null && reading.obj.getName() == "tank"){
          Tank t = (Tank)reading.obj;
          return team != t.team && t.health > 0; 
      }
      return false;
  }

  //Om SensorReading har ett objekt så läggs det till i known.
  void updateKnownObjects(SensorReading sr){
    if (sr == null){
      return;
    }
    else{
      Sprite sprite = sr.obj();
      Node node = known.getNearestNode(sprite.position);
        switch (sprite.getName()){
            case "tree":
                ArrayList<Node> nodes = known.getNeighbours(node.col, node.row);
                for (Node n : nodes){
                    known.nodes[n.col][n.row].nodeContent = Content.OBSTACLE;
                }
                known.nodes[node.col][node.row].nodeContent = Content.OBSTACLE;
                break;
            case "tank":
                Tank otherTank = (Tank)sprite;
                if (team != otherTank.team && otherTank.health > 0){
                    known.nodes[node.col][node.row].nodeContent = Content.ENEMY;
                }
                else if(team == otherTank.team && otherTank.health > 0){
                    known.nodes[node.col][node.row].nodeContent = Content.FRIEND;
                }
                else{
                    known.nodes[node.col][node.row].nodeContent = Content.OBSTACLE;
                }
                break;
        }
    }
  }

  //Noder som tanken kan se markeras som empty.
  void updateKnownNodes(Sensor s, SensorReading sr){
    SensorVisuals sensorVisuals = (SensorVisuals)s;
    for (int col = 0; col < known.nodes.length; col++){
      for (int row = 0; row < known.nodes[col].length; row++){
        boolean inFront = sensorVisuals.isNodeInFront(known.nodes[col][row], sr);
        if (inFront){
          if (known.nodes[col][row].nodeContent != Content.OBSTACLE)
            known.nodes[col][row].nodeContent = Content.EMPTY;
        }
      }
    }
  }

  //testmetod för att printa ut info om noder som tanken känner till
  void printKnownNodes(){
    for (int col = 0; col < known.nodes.length; col++){
      for (int row = 0; row < known.nodes[col].length; row++){
        System.out.println("Col: " + col + " Row: " + row + " nodeContent: " + known.nodes[col][row].nodeContent + "\n");
      }
    }
  }

  //testmetod för att färglägga noder som tanken känner till 
  void displayKnownNodes() {
    pushMatrix();
    Node n = null;
    for(int col = 0; col < known.nodes.length; col++){
      for (int row = 0; row < known.nodes[col].length; row++){
        n = known.nodes[col][row];
        ellipse(n.position.x, n.position.y, 40, 40);
        switch(n.nodeContent){
        case ENEMY:
          fill(0,0,255,100);
          break;
        case FRIEND:
          fill(255,0,0,100);
          break;
        case OBSTACLE:
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
    
    

    popMatrix();
  }


}

int round10(float n) {
  return (round(n) + 5) / 10 * 10;
}

float getAngle(float pX1,float pY1, float pX2,float pY2){
  return atan2(pY2 - pY1, pX2 - pX1);
}