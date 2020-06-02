/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class ExecutionPlanner {
    private TankGR13 tank;

    public ExecutionPlanner(TankGR13 tank){
        this.tank = tank;
    }

    //Väljer plan som tanken ska följa beroende på tankens tillstånd.
    public ExecutionPlan generatePlan(){
        if(!tank.hasShot){
            return generateLoadCannonPlan();
        }

        if(tank.isImmobilized){
            return generateImmobilizedPlan();
        }

        if (tank.isRetreating){
            return generateRetreatPlan();
        }
        return generateNormalPlan();
    }

    //Retirerar till basen och rapporterar om sin kända karta till sina allierade.
    private ExecutionPlan generateRetreatPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new AStarRetreatExecutionStep(tank));
        steps.add(new PauseExecutionStep(tank, 3000));
        steps.add(new RadioUpdateTeamExecutionStep(tank));
        
        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    //Tanken vandrar till okända noder. Om den hittar en fiende så försöker den skjuta fienden och sen retirera.
    private ExecutionPlan generateNormalPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new AStarMoveExecutionStep(tank));
        steps.add(new LookAroundForEnemyExecutionStep(tank));
        steps.add(new FireCannonExecutionStep(tank));
        steps.add(new AStarRetreatExecutionStep(tank));
        steps.add(new PauseExecutionStep(tank, 3000));
        steps.add(new RadioUpdateTeamExecutionStep(tank));

        

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    //Laddar kanonen
    private ExecutionPlan generateLoadCannonPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new PauseExecutionStep(tank, 3000));
        steps.add(new LoadCannonExecutionStep(tank));
        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    //Tittar runt omkring sig efter en fiende att skjuta.
    private ExecutionPlan generateImmobilizedPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new LookAroundForEnemyExecutionStep(tank));
        steps.add(new FireCannonExecutionStep(tank));
        steps.add(new PauseExecutionStep(tank, 1000));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    //Skjuter kanonen och retirerar. Planen skapas direkt från updateLogic om den ser en fiende och har ett skott.
    public ExecutionPlan generateFireCannonPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new FireCannonExecutionStep(tank));
        steps.add(new AStarRetreatExecutionStep(tank));
        steps.add(new PauseExecutionStep(tank, 3000));
        steps.add(new RadioUpdateTeamExecutionStep(tank));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    //Går till slumpvald nod. Kallas när tanken kolliderar för att undvika att de fastnar.
    public ExecutionPlan generateWalkToRandomPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new WalkToRandomExecutionStep(tank));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }
}
