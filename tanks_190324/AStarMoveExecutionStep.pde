
public class AStarMoveExecutionStep extends ExecutionPlanStep {

    private StateFlag stateFlag = StateFlag.IDLE; 
    boolean moveStarted = false;
    Stack<Node> movePath;
    private float target_rotation = -1;
    private Node goalNode;
    Node currentNode, previousNode, currentGoalNode;
    


  public AStarMoveExecutionStep(TankN tank){
        super(tank);
        goalNode = tank.known.getRandomUnknownNode();
        movePath = new Stack<Node>();
    }

    public boolean isValid(){
        return (!tank.isImmobilized || movePath.isEmpty());
    }

    public void execute(){
        if(isFulfilled()){
            println("Fulfilled!!");
            tank.isMoving = false;
            tank.stopMoving();
            return;
        }
        // AStar
        if (moveStarted){
            if(currentGoalNode != null && currentGoalNode == tank.known.getNearestNode(tank.position) && stateFlag == StateFlag.WANDERING){
                stateFlag = StateFlag.ARRIVED_MOVE;
            }

            if(!tank.isMoving && !tank.isRotating){
                stateFlag = StateFlag.IDLE;
            }

            switch(stateFlag){
                case IDLE:
                    stateFlag = StateFlag.WANDERING;
                    wander();
                    break;
                case ARRIVED_ROTATE:
                    stateFlag = StateFlag.IDLE;
                    break;
                case WANDERING:
                    if (furtherNodeinFront()){
                        wander();
                    }
                    break;
                case ARRIVED_MOVE:
                    stateFlag = StateFlag.ROTATING;
                    break;
                case ROTATING:
                    if(round10(fixAngle(degrees(tank.heading))) == round10(fixAngle(degrees(target_rotation)))){
                        //round10(fixAngle(degrees(tank.heading))) != round10(fixAngle(degrees(target_rotation)));
                        println("FINNISHED ROTATING");
                        stateFlag = StateFlag.ARRIVED_ROTATE;
                        break;
                    }
                    tank.turnLeft();
                    break;

            }
            
        }
        Node targetNode;
        ArrayList<Node> targetNeighbours;
        if (!moveStarted){
            println("starting move!");
            moveStarted = true;
            targetNode = tankN.known.getRandomEnemy();
            if(targetNode != null){
                targetNeighbours = tankN.known.getNeighbours(targetNode.col, targetNode.row);
                targetNode = targetNeighbours.get(new Random().nextInt(targetNeighbours.size()));
            }
            
            Node randomUnknown = tankN.known.getNearestNode(tankN.known.getRandomNodePosition());
            while(randomUnknown.nodeContent != Content.UNKNOWN){
                randomUnknown = tankN.known.getNearestNode(tankN.known.getRandomNodePosition());
            }
            if (targetNode == null) {
                targetNode = randomUnknown;
            }
            if (targetNode != null){
                astar(grid.getNearestNode(tank.position), targetNode);
                tankN.movePath = targetNode.getPath();
            }
            println("ASTAR TARGET: " + targetNode.position);
            tankN.movePath.pop();
            movePath = tankN.movePath;
            
        }

    }
    
    public boolean isFulfilled(){
        return grid.getNearestNode(tank.position) == grid.getNearestNode(goalNode.position);
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

  boolean furtherNodeinFront(){
      if (movePath.isEmpty()){
          return false;
      }
      else{
            boolean result = false;
            Sensor s = tank.getSensor("VISUAL");
            SensorReading reading = s.readValue();
            SensorVisuals sv = (SensorVisuals) s;
            currentNode = movePath.pop();
            while (sv.isNodeInFront(currentNode, reading) && !movePath.isEmpty()){
                result = true;
                previousNode = currentNode;
                currentNode = movePath.pop();
            }
            movePath.push(currentNode);
            return result;
      }
  }

  private void wander() {
      if (!movePath.isEmpty()){
          currentGoalNode = movePath.pop();
          tank.moveTo(currentGoalNode.position);
      }
  }

    // private void wander() {
    //     /*println("waypoints: ");
    //     while(!movePath.isEmpty()){
    //         println(movePath.pop());
    //     }*/
    //     Sensor s = tank.getSensor("VISUAL");
    //     SensorReading reading = s.readValue();
        
    //     SensorVisuals sv = (SensorVisuals) s;

    //     if(!movePath.isEmpty()){
    //         currentNode = movePath.pop();
    //         while (sv.isNodeInFront(currentNode, reading) && !movePath.isEmpty()){
    //             previousNode = currentNode;
    //             currentNode = movePath.pop();
    //         }
    //         if (!sv.isNodeInFront(currentNode, reading)){
    //             if(previousNode != null){
    //                 tank.moveTo(previousNode.position);
    //                 goalNode = previousNode;
    //                 previousNode = null;
    //                 return;
    //             } else {
    //                 tank.moveTo(currentNode.position);
    //                 goalNode = currentNode;
    //                 return;
    //             }
                
    //         }
    //     }
    //     if(currentNode != null){
    //         tank.moveTo(currentNode.position);
    //         goalNode = currentNode;
    //     }

    //     /*if(!tank.movePath.isEmpty()){
    //         tempNode = tank.movePath.pop();
    //         println("POPPED: " + tempNode.position);
    //         tank.moveTo(tempNode.position);
    //         goalNode = tempNode;
    //         return;
    //     }*/
    //     println("stack empty");
    // }
}

    

  