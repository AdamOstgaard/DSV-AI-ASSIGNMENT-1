/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class AStarMoveExecutionStep extends ExecutionPlanStep {

    private StateFlag stateFlag = StateFlag.IDLE; 
    boolean moveStarted = false;
    Stack<Node> movePath;
    private Node goalNode;
    Node currentGoalNode;
    boolean pathExists = true;
    
    //Walks to the first enemy it gets or a random unknown node
    public AStarMoveExecutionStep(TankGR13 tank){
        super(tank);
        goalNode = tank.known.getRandomEnemyNode();
        if (goalNode == null){
            goalNode = tank.known.getRandomUnknownNode();
        }
        movePath = new Stack<Node>();
    }

    //is valid as long as tank is not immobilized and pathExists is true
    public boolean isValid(){
        return !tank.isImmobilized && pathExists;
    }

    //Called continuously until isFulfilled() or no longer isValid()
    //Executes different code dependent on stateFlag
    public void execute(){
        if(isFulfilled()){
            tank.isMoving = false;
            tank.stopMoving();
            return;
        }
        if (moveStarted){
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
                    // if (tank.id == 0){
                    //     displayPath();
                    // }
                    if (!nodeInFront(currentGoalNode) && !tank.isRotating){
                        replan();
                    }
                    // else if (furtherNodeinFront()){
                    //     wander();
                    // }
                    break;
                case ARRIVED_MOVE:
                    stateFlag = StateFlag.IDLE;
                    break;

            }
            
        }
        if (!moveStarted){
            moveStarted = true;
            replan();
        }

    }
    
    //is fulfilled when the tanks closest node is the goalNode
    public boolean isFulfilled(){
        return grid.getNearestNode(tank.position) == grid.getNearestNode(goalNode.position);
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
        neighbours = tank.known.getNeighboursAStar(current.col, current.row);
        for (Node neighbour : neighbours){
            if ((neighbour.nodeContent == Content.ENEMY && neighbour != goalNode) ||
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

    //If a path is found get path from goalNode and store in movePath then pop one node (the tanks postition)
  void replan(){
        stateFlag = StateFlag.IDLE;
        if (astar(tank.known.getNearestNode(tank.position), goalNode)){
            movePath = tank.known.getNearestNode(goalNode.position).getPath();
            if (!movePath.isEmpty())
                movePath.pop();
            }
            else
                pathExists = false;
  }

  void displayPath(){
    pushMatrix();
    for (Node n : movePath){
        ellipse(n.position.x, n.position.y, 40, 40);
        fill(255,0,255,100);
    }
    popMatrix();
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
      if (movePath.isEmpty()){
          return true;
      }
      else{
            Node currentNode = null;
            Node previousNode = null;
            boolean result = false;
            Sensor s = tank.getSensor("VISUAL");
            SensorReading reading = s.readValue();
            SensorVisuals sv = (SensorVisuals) s;
            currentNode = movePath.pop();
            while (sv.isNodeInFront(currentNode, reading) && !movePath.isEmpty()){
                result = true;
                currentNode = movePath.pop();
            }
            movePath.push(currentNode);
            if (previousNode != null){
                movePath.push(previousNode);
            }
            return result;
      }
  }

  private void wander() {
      if (!movePath.isEmpty()){
          currentGoalNode = movePath.pop();
          tank.moveTo(currentGoalNode.position);
      }
  }
}

    

  