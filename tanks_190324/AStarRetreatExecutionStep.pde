/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class AStarRetreatExecutionStep extends ExecutionPlanStep {

    private StateFlag stateFlag = StateFlag.IDLE; 
    boolean retreatStarted = false;
    Stack<Node> retreatPath;
    private Node currentGoalNode;
    boolean pathExists = true;

    Node currentNode;

  public AStarRetreatExecutionStep(TankGR13 tank){
        super(tank);
        retreatPath = new Stack<Node>();
    }

    //is valid as long as tank is not immobilized and pathExists is true
    public boolean isValid(){
        return !tank.isImmobilized && pathExists;
    }

    //Called continuously until isFulfilled() or no longer isValid()
    //Executes different code dependent on stateFlag
    public void execute(){
        if(isFulfilled()){
            tank.isRetreating = false;
            tank.stopMoving();
            return;
        }
        if (retreatStarted){
            if(currentGoalNode != null && currentGoalNode == tank.known.getNearestNode(tank.position) && stateFlag == StateFlag.WANDERING){
                stateFlag = StateFlag.ARRIVED_MOVE;
            }

            if(!tank.isMoving && !tank.isRotating && stateFlag != StateFlag.ROTATING){
                stateFlag = StateFlag.IDLE;
            }

            switch(stateFlag){
                case IDLE:
                    stateFlag = StateFlag.WANDERING;
                    wander();
                    break;
                case WANDERING:
                    if (!nodeInFront(currentGoalNode)){
                        if (tank.id == 2){
                        }
                        replan();
                    }
                    else if (furtherNodeinFront()){
                        wander();
                    }
                    break;
                case ARRIVED_MOVE:
                    stateFlag = StateFlag.IDLE;
                    break;

            }
            
        }
        if (!retreatStarted){
            retreatStarted = true;
            replan();
            }

    }
    
    //is fulfilled when the tank is at its homebase
    public boolean isFulfilled(){
        return tank.isAtHomebase;
    }

    //Inspirerat av https://github.com/SebLague/Pathfinding/blob/master/Episode%2001%20-%20pseudocode/Pseudocode
    //Använder A* algoritmen för att ta fram den kortaste vägen till målet. Pathen hämtas genom Node.getPath på målnoden.
    boolean astar(Node start, Node end) {
        tank.known.resetPathVariables();
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
        neighbours = tank.known.getNeighbours(current.col, current.row);
        for (Node neighbour : neighbours){
            if (neighbour.nodeContent == Content.ENEMY ||
            closed.contains(neighbour)){
              continue;
            }
            if (!closed.contains(neighbour) || 
                current.g + PVector.dist(current.position, neighbour.position) < neighbour.g){
                if (neighbour.nodeContent == Content.UNKNOWN){
                    neighbour.g = current.g + PVector.dist(current.position, neighbour.position) * 2;
                }
                else if (neighbour.nodeContent == Content.FRIEND){
                    neighbour.g = current.g + PVector.dist(current.position, neighbour.position) * 10;
                } 
                else if (neighbour.nodeContent == Content.OBSTACLE) {
                    //if neighbour is obstacle assign weight to the node and neighbouring nodes
                    neighbour.g = current.g + PVector.dist(current.position, neighbour.position) * 20;
                    ArrayList<Node> neighboursToObstacle = tank.known.getNeighbours(neighbour.col, neighbour.row);
                    for (Node n : neighboursToObstacle){
                        n.g = current.g + PVector.dist(current.position, n.position) * 10;
                    }
                }
              else{
                neighbour.g = current.g + PVector.dist(current.position, neighbour.position);
              }
              neighbour.parent = current;
              if (!open.contains(neighbour)){
                open.add(neighbour);
          }
        }
      }
    }
    return false;
  }

    boolean nodeInFront(Node n){
        Sensor s = tank.getSensor("VISUAL");
        SensorReading reading = s.readValue();
        SensorVisuals sv = (SensorVisuals) s;
        if (reading == null){
            return true;
        }
        return sv.isNodeInFront(n, reading);
  }

    //Pops nodes from movepath until currentNode is not in front then pushes currentNode back on the stack
    //returns false if the first node on the stack is not in front of the tank
  boolean furtherNodeinFront(){
      if (retreatPath.isEmpty()){
          return false;
      } 
      else 
      {
            boolean result = false;
            Sensor s = tank.getSensor("VISUAL");
            SensorReading reading = s.readValue();
            SensorVisuals sv = (SensorVisuals) s;
            currentNode = retreatPath.pop();
            while (sv.isNodeInFront(currentNode, reading) && !retreatPath.isEmpty()){
                result = true;
                currentNode = retreatPath.pop();
            }
            retreatPath.push(currentNode);
            return result;
      }
    }

    //If a path is found get path from goalNode and store in movePath then pop one node (the tanks postition)
    void replan(){
        stateFlag = StateFlag.IDLE; 
        if (astar(tank.known.getNearestNode(tank.position), tank.known.getNearestNode(tank.startpos))){
            retreatPath = tank.known.getNearestNode(tank.startpos).getPath();
            if (!retreatPath.isEmpty())
                retreatPath.pop();
            }
            else
                pathExists = false;
  }

  private void wander() {
      if (!retreatPath.isEmpty()){
          currentGoalNode = retreatPath.pop();
          tank.moveTo(currentGoalNode.position);
      }
    }
}

    

  