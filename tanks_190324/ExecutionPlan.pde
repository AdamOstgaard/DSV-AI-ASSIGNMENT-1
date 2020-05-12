public class ExecutionPlan {
    private ExecutionPlanStep[] steps;

    private int currentStepIndex = 0;

    private ExecutionPlanStep getNextStep() {
        return steps[currentStepIndex];

    }

    public ExecutionPlan(ExecutionPlanStep[] steps){
        this.steps = steps;
    }

    public boolean isValid() {
        return getNextStep().isValid();
    }

    public void execute(){
        ExecutionPlanStep step = getNextStep();
        step.execute();

        if(step.isFulfilled()) {
            advance();
        }
    }

    private void advance() {
        currentStepIndex++;
    } 

    public boolean hasMoreSteps(){
        return currentStepIndex < steps.length;
    }
}