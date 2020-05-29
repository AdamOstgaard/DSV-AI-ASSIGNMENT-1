
public class AStarRetreatExecutionStep extends ExecutionPlanStep {

    private StateFlag stateFlag = StateFlag.IDLE; 
    boolean retreatStarted = false;
    Stack<Node> retreatPath;
    private Node currentGoalNode;
    boolean pathExists = true;

    Node currentNode;
    Node previousNode;
    

  public AStarRetreatExecutionStep(TankN tank){
        super(tank);
        retreatPath = new Stack<Node>();
    }

    public boolean isValid(){
        return !tank.isImmobilized && pathExists;
    }

    public void execute(){
        if(isFulfilled()){
            println("Fulfilled!!");
            tank.isRetreating = false;
            tank.stopMoving();
            return;
        }
        // AStar
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
                            System.out.println("replanning");
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
            println("starting retreat!");
            retreatStarted = true;
            replan();
            }

    }
    
    public boolean isFulfilled(){
        return tank.isAtHomebase;
    }

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
            println("END REACHED");
            return true;
        }
        neighbours = tank.known.getNeighbours(current.col, current.row);
        for (Node neighbour : neighbours){
            if (neighbour.nodeContent == Content.ENEMY ||
            neighbour.nodeContent == Content.OBSTACLE ||
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

  boolean furtherNodeinFront(){
      if (retreatPath.isEmpty()){
          return false;
      }
      else{
            boolean result = false;
            Sensor s = tank.getSensor("VISUAL");
            SensorReading reading = s.readValue();
            SensorVisuals sv = (SensorVisuals) s;
            currentNode = retreatPath.pop();
            while (sv.isNodeInFront(currentNode, reading) && !retreatPath.isEmpty()){
                result = true;
                previousNode = currentNode;
                currentNode = retreatPath.pop();
            }
            retreatPath.push(currentNode);
            return result;
      }
  }

    void replan(){
        stateFlag = StateFlag.IDLE; 
        // boolean moveStarted = false;
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

//     private void wander() {
//         /*println("waypoints: ");
//         while(!retreatPath.isEmpty()){
//             println(retreatPath.pop());
//         }*/
//         Sensor s = tank.getSensor("VISUAL");
//         SensorReading reading = s.readValue();
        
//         SensorVisuals sv = (SensorVisuals) s;

//         if(!tank.retreatPath.isEmpty()){
//             currentNode = tank.retreatPath.pop();
//             while (sv.isNodeInFront(currentNode, reading) && !tank.retreatPath.isEmpty()){
//                 previousNode = currentNode;
//                 currentNode = tank.retreatPath.pop();
//             }
//             if (!sv.isNodeInFront(currentNode, reading)){
//                 if(previousNode != null){
//                     tank.moveTo(previousNode.position);
//                     currentGoalNode = previousNode;
//                     previousNode = null;
//                     return;
//                 } else {
//                     tank.moveTo(currentNode.position);
//                     currentGoalNode = currentNode;
//                     return;
//                 }
                
//             }
//         }
//         if(currentNode != null){
//             tank.moveTo(currentNode.position);
//             currentGoalNode = currentNode;
//         }

//         /*if(!tank.retreatPath.isEmpty()){
//             tempNode = tank.retreatPath.pop();
//             println("POPPED: " + tempNode.position);
//             tank.moveTo(tempNode.position);
//             currentGoalNode = tempNode;
//             return;
//         }*/
//         println("stack empty");
//     }
}

    

  