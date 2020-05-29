
// Good for debugging and waiting for reload
public class PauseExecutionStep extends ExecutionPlanStep {
    int start = -1;
    int millisecs;
    public PauseExecutionStep(TankN tank, int millisecs){
        super(tank);
        this.millisecs = millisecs;
    }

    public boolean isValid(){
        return true;
    }

    public void execute(){
        if(start == -1){
            start = millis();
        }
    }
    
    public boolean isFulfilled(){
        return start < millis() - millisecs;
    }
}