public class RadioUpdateTeamExecutionStep extends ExecutionPlanStep {
    
    TankN tankN;
    boolean updated = false;

    public RadioUpdateTeamExecutionStep(Tank tank){
        super(tank);
        tankN = (TankN) tank;
    }

    public boolean isValid(){
        return tank.isAtHomebase;
    }

    public void execute(){
        for (Tank t : teams[0].tanks){
            TankN tN = (TankN) t;
            tN.known.updateContent(tankN.known);
        }
        updated = true;
    }
    
    public boolean isFulfilled(){
        println("RADIO UPDATED");
        return updated;
    }
}