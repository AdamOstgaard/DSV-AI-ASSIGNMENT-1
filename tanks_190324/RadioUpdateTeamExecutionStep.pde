/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class RadioUpdateTeamExecutionStep extends ExecutionPlanStep {
    
    boolean updated = false;

    public RadioUpdateTeamExecutionStep(TankGR13 tank){
        super(tank);
    }

    public boolean isValid(){
        return tank.isAtHomebase;
    }

    //Rapporterar om sin kända värld till sitt lag.
    public void execute(){
        for (Tank t : teams[0].tanks){
            TankGR13 tN = (TankGR13) t;
            tN.known.updateContent(tank.known);
        }
        updated = true;
    }
    
    public boolean isFulfilled(){
        println("RADIO UPDATED");
        return updated;
    }
}