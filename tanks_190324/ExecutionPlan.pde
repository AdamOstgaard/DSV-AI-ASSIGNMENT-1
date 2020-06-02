/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/

public class ExecutionPlan {
    private ExecutionPlanStep[] steps;

    private int currentStepIndex = 0;


    public ExecutionPlan(ExecutionPlanStep[] steps){
        this.steps = steps;
    }

    //Hämtar nästa steg som tanken ska utföra.
    private ExecutionPlanStep getNextStep() {
        return steps[currentStepIndex];

    }

    //Kontrollerar om nuvarande steg är giltigt.
    public boolean isValid() {
        return getNextStep().isValid();
    }

    //Utför nuvarnde steg. Om steget är fullbordat så går planen fram ett steg.
    public void execute(){
        ExecutionPlanStep step = getNextStep();
        step.execute();

        if(step.isFulfilled()) {
            advance();
        }
    }

    //Flyttar fram planen ett steg.
    private void advance() {
        currentStepIndex++;
    } 

    //Kontrollerar om det finns fler steg i planen.
    public boolean hasMoreSteps(){
        return currentStepIndex < steps.length;
    }
}