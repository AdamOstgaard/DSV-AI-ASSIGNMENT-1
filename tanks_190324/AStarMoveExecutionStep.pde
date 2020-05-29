public class AStarMoveExecutionStep extends ExecutionPlanStep {
    
    private StateFlag stateFlag = StateFlag.IDLE; 
    private Node tempTarget = null;
    TankN tankN;
    boolean moveStarted = false;
    Stack<Node> movePath;
    private float target_rotation;

    Node currentNode;
    Node previousNode;

    public AStarMoveExecutionStep(Tank tank){
        super(tank);
        tankN = (TankN)tank;
    }

    public boolean isValid(){
        return !tank.isImmobilized;
    }

    public void execute(){
        
        if(isFulfilled()){
            println("Fulfilled!!");
            tank.stopMoving();
            moveStarted = false;
            return;
        }
        // AStar
        if (moveStarted){
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
                case ARRIVED_ROTATE:
                    stateFlag = StateFlag.WANDERING;
                    wander();
                    break;
                case WANDERING:
                    break;
                case ARRIVED_MOVE:
                    stateFlag = StateFlag.IDLE;
                    wander();
                    break;
                case ROTATING:
                    if(round10(fixAngle(degrees(tank.heading))) == round10(fixAngle(degrees(target_rotation)))){
                        println("FINNISHED ROTATING");
                        stateFlag = StateFlag.ARRIVED_ROTATE;
                        break;
                    }
                    tank.turnLeft();
                    break;
            }
            
        }
        Node targetNode;
        if (!moveStarted){
            println("starting move!");
            moveStarted = true;
            
            targetNode = tankN.known.getFirstEnemy();
            
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
            
            movePath = tankN.movePath;
            movePath.pop();
        }
        
    }
    

    public boolean isFulfilled(){
        if (movePath != null)
            return movePath.isEmpty();
        /*if(tempTarget != null && tempTarget == grid.getNearestNode(tank.position)){
            tankN.known.getNearestNode(tank.position).nodeContent = Content.EMPTY;
            return true;
        }*/
        return false;
    }

    private void wander() {

        Sensor s = tank.getSensor("VISUAL");
        SensorReading reading = s.readValue();
        Node tempNode;
        
        SensorVisuals sv = (SensorVisuals) s;

        if(!tankN.movePath.isEmpty()){
                currentNode = tankN.movePath.pop();
            while (sv.isNodeInFront(currentNode, reading) && !tankN.movePath.isEmpty()){
                previousNode = currentNode;
                currentNode = tankN.movePath.pop();
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
}