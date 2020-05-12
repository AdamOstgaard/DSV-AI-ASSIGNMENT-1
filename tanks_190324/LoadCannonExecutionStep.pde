public class LoadCannonExecutionStep extends ExecutionPlanStep {
    public LoadCannonExecutionStep(Tank tank){
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