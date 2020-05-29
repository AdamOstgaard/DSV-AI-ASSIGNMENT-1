public class FireCannonExecutionStep extends ExecutionPlanStep {
    public FireCannonExecutionStep(TankN tank){
        super(tank);
    }

    public boolean isValid(){
        return tank.hasShot && tank.isEnemyInfront;
    }

    public void execute(){
        tank.stopMoving_state();
        tank.fire();
    }
    
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