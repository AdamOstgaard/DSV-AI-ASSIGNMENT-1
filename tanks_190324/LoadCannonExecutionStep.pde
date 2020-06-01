/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class LoadCannonExecutionStep extends ExecutionPlanStep {
    public LoadCannonExecutionStep(TankN tank){
        super(tank);
    }

    public boolean isValid(){
        return true;
    }

    public void execute(){
        tank.loadShot();
    }
    
    public boolean isFulfilled(){
        return tank.hasShot;
    }
}