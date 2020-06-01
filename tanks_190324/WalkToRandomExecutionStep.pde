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

    //Steget är fullbordat när tanken har nått noden.
    public boolean isFulfilled(){
        if(tempTarget != null && tempTarget == grid.getNearestNode(tank.position)){
            return true;
        }
        return false;
        
    }

    //Går till en slumpvald nod.
    private void wander() {
        Node tempNode = grid.getNearestNode(grid.getRandomNodePosition());
        tank.moveTo(tempNode.position);
        tempTarget = tempNode;
    }
}