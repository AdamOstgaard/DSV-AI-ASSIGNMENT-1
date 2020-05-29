public abstract class ExecutionPlanStep {
    TankN tank;

    public ExecutionPlanStep(TankN tank){
        this.tank = tank;
    }
    // if step is not valid a rfeplanning is triggered
    abstract boolean isValid();
    
    // do the step
    abstract void execute();

    // Is the goal of the step fulfilled?
    abstract boolean isFulfilled();
}