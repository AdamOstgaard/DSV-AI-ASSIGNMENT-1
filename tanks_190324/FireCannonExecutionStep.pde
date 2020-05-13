public class FireCannonExecutionStep extends ExecutionPlanStep {
    public FireCannonExecutionStep(Tank tank){
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
        return !tank.hasShot;
    }
}