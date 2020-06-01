/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class FireCannonExecutionStep extends ExecutionPlanStep {
    public FireCannonExecutionStep(TankN tank){
        super(tank);
    }

    //isValid if tank has a shot loaded and an enemy in its sights
    public boolean isValid(){
        return tank.hasShot && tank.isEnemyInfront;
    }

    //Stops moving and fires
    public void execute(){
        tank.stopMoving_state();
        tank.fire();
    }
    
    //is fullfilled if tank has spent its shot
    public boolean isFulfilled(){
        if (!tank.hasShot){
            tank.isRetreating = true;
            return true;
        }
        else {
            return false;
        }
    }
}