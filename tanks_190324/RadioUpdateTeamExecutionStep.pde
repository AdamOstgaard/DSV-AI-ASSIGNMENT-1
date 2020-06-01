public class RadioUpdateTeamExecutionStep extends ExecutionPlanStep {
    
    boolean updated = false;

    public RadioUpdateTeamExecutionStep(TankN tank){
        super(tank);
    }

    public boolean isValid(){
        return tank.isAtHomebase;
    }

    //Rapporterar om sin kända värld till sitt lag.
    public void execute(){
        for (Tank t : teams[0].tanks){
            TankN tN = (TankN) t;
            tN.known.updateContent(tank.known);
        }
        updated = true;
    }
    
    public boolean isFulfilled(){
        println("RADIO UPDATED");
        return updated;
    }
}