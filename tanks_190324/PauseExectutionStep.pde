
// Good for debugging and waiting for reload
public class PauseExectutionStep extends ExecutionPlanStep {
    int start = -1;
    public PauseExectutionStep(Tank tank){
        super(tank);
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
        return start < millis() - 1000*3;
    }
}