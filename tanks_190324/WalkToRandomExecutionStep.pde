public class WalkToRandomExecutionStep extends ExecutionPlanStep {
    private Node tempTarget = null;

    public WalkToRandomExecutionStep(TankN tank){
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
        if(tempTarget == null || !isFulfilled() && tank.idle_state){
            wander(); 
        }
    }

    public boolean isFulfilled(){
        if(tempTarget != null && tempTarget == grid.getNearestNode(tank.position)){
            tank.known.getNearestNode(tank.position).nodeContent = Content.EMPTY;
            return true;
        }
        return false;
        
    }

    private void wander() {
        Node tempNode = grid.getNearestNode(grid.getRandomNodePosition());
        tank.moveTo(tempNode.position);
        tempTarget = tempNode;
    }
}