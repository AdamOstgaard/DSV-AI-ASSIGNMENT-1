
public class AStarRetreatExecutionStep extends ExecutionPlanStep {

    private StateFlag stateFlag = StateFlag.IDLE; 
    boolean retreatStarted = false;
    Stack<Node> retreatPath;
    private Node tempTarget;
    TankN tankN;

    Node currentNode;
    Node previousNode;
    

  public AStarRetreatExecutionStep(Tank tank){
        super(tank);
        tankN = (TankN)tank;
    }

    public boolean isValid(){
        return (!tank.isImmobilized || tankN.retreatPath != null && !tankN.retreatPath.isEmpty());
    }

    public void execute(){
        if(isFulfilled()){
            println("Fulfilled!!");
            tankN.isRetreating = false;
            tank.stopMoving();
            return;
        }
        // AStar
        if (retreatStarted){
            if(tempTarget != null && tempTarget == grid.getNearestNode(tank.position) && stateFlag == StateFlag.WANDERING){
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
                    break;
                case ARRIVED_MOVE:
                    stateFlag = StateFlag.IDLE;
                    wander();
                    break;

            }
            
        }
        if (!retreatStarted){
            println("starting retreat!");
            retreatStarted = true;
            astar(grid.getNearestNode(tank.position), grid.getNearestNode(tank.startpos));
            tankN.retreatPath = //tankN.known.getNearestNode(tank.position).getPath();
            tankN.known.getNearestNode(tank.startpos).getPath();
            retreatPath = tankN.retreatPath;
            retreatPath.pop();
        }

    }
    
    public boolean isFulfilled(){
        return tank.isAtHomebase || tankN.retreatPath != null && tankN.retreatPath.isEmpty();
    }

    boolean astar(Node start, Node end) {
        tankN.known.resetPathVariables();
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
            println("END REACHED");
            return true;
        }
        neighbours = tankN.known.getNeighbours(current.col, current.row);
        for (Node neighbour : neighbours){
            if (neighbour.nodeContent == Content.FRIEND ||
            neighbour.nodeContent == Content.ENEMY ||
            neighbour.nodeContent == Content.OBSTACLE ||
            closed.contains(neighbour)){
              continue;
            }
            if (!closed.contains(neighbour) || 
                current.g + PVector.dist(current.position, neighbour.position) < neighbour.g){
                if (neighbour.nodeContent == Content.UNKNOWN){
                    neighbour.g = current.g + PVector.dist(current.position, neighbour.position) * 2;
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

    private void wander() {
        /*println("waypoints: ");
        while(!retreatPath.isEmpty()){
            println(retreatPath.pop());
        }*/
        Sensor s = tank.getSensor("VISUAL");
        SensorReading reading = s.readValue();
        
        SensorVisuals sv = (SensorVisuals) s;

        if(!tankN.retreatPath.isEmpty()){
            currentNode = tankN.retreatPath.pop();
            while (sv.isNodeInFront(currentNode, reading) && !tankN.retreatPath.isEmpty()){
                previousNode = currentNode;
                currentNode = tankN.retreatPath.pop();
            }
            if (!sv.isNodeInFront(currentNode, reading)){
                if(previousNode != null){
                    tank.moveTo(previousNode.position);
                    tempTarget = previousNode;
                    previousNode = null;
                    return;
                } else {
                    tank.moveTo(currentNode.position);
                    tempTarget = currentNode;
                    return;
                }
                
            }
        }
        if(currentNode != null){
            tank.moveTo(currentNode.position);
            tempTarget = currentNode;
        }

        /*if(!tankN.retreatPath.isEmpty()){
            tempNode = tankN.retreatPath.pop();
            println("POPPED: " + tempNode.position);
            tank.moveTo(tempNode.position);
            tempTarget = tempNode;
            return;
        }*/
        println("stack empty");
    }
}

    

  