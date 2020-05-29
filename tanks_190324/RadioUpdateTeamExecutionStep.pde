public class RadioUpdateTeamExecutionStep extends ExecutionPlanStep {
    
    boolean updated = false;

    public RadioUpdateTeamExecutionStep(TankN tank){
        super(tank);
    }

    public boolean isValid(){
        return tank.isAtHomebase;
    }

    public void execute(){
        for (Tank t : teams[0].tanks){
            TankN tN = (TankN) t;
            tN.known.updateContent(tank.known);
        }
        updated = true;
        tank.isRetreating = false;
    }
    
    public boolean isFulfilled(){
        println("RADIO UPDATED");
        return updated;
    }
}