public class FireCannonExecutionStep extends ExecutionPlanStep {
    public FireCannonExecutionStep(Tank tank){
        super(tank);
    }

    public boolean isValid(){
        return tank.hasShot;
    }

    public void execute(){
        tank.fire();
    }
    
    public boolean isFulfilled(){
        return !tank.hasShot;
    }
}