/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class WalkToRandomExecutionStep extends ExecutionPlanStep {
    private Node tempTarget = null;

    public WalkToRandomExecutionStep(TankGR13 tank){
        super(tank);
    }

    public boolean isValid(){
        return !tank.isImmobilized;
    }

    public void execute(){
        pushMatrix();
        ellipse(tank.position.x, tank.position.y, 40, 40);
        fill(255,0,255,100);
        popMatrix();
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