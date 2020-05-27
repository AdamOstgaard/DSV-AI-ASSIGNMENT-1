
public class AStarRetreatExecutionStep extends ExecutionPlanStep {

    private StateFlag stateFlag = StateFlag.IDLE; 
    boolean retreatStarted;
    Stack<Node> retreatPath;
    private Node tempTarget;
    Grid known = new Grid(cols, rows, grid_size);

  public AStarRetreatExecutionStep(Tank tank){
        super(tank);
    }

    public boolean isValid(){
        return !tank.isImmobilized;
    }

    public void execute(){
        if(isFulfilled()){
            println("Fulfilled!!");
            tank.stopMoving();
            return;
        }
        // AStar
        if (retreatStarted){
            if(tempTarget != null && tempTarget == grid.getNearestNode(tank.position) && stateFlag == StateFlag.WANDERING){
                stateFlag = StateFlag.ARRIVED_MOVE;
            }
            switch(stateFlag){
                case IDLE:
                    stateFlag = StateFlag.WANDERING;
                    wander();
                    break;
                case WANDERING:
                    break;
                case ARRIVED_MOVE:
                    stateFlag = StateFlag.WANDERING;
                    wander();
                    break;

            }
            
        }
        else if (astar(grid.getNearestNode(tank.position), grid.nodes[1][1])){
            println("starting retreat!");
            retreatStarted = true;
            retreatPath = grid.getNearestNode(tank.startpos).getPath();
        }

    }
    
    public boolean isFulfilled(){
        return tank.isAtHomebase;
    }

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

    private void wander() {
        Node tempNode = retreatPath.pop();
        tank.moveTo(tempNode.position);
        tempTarget = tempNode;
    }
}

    

  