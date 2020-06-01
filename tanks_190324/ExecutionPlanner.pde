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

    private ExecutionPlan generateRetreatPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new AStarRetreatExecutionStep(tank));
        steps.add(new PauseExecutionStep(tank, 3000));
        steps.add(new RadioUpdateTeamExecutionStep(tank));
        
        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }
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

    private ExecutionPlan generateLoadCannonPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new PauseExecutionStep(tank, 3000));
        steps.add(new LoadCannonExecutionStep(tank));
        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    private ExecutionPlan generateImmobilizedPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new LookAroundForEnemyExecutionStep(tank));
        steps.add(new FireCannonExecutionStep(tank));
        steps.add(new PauseExecutionStep(tank, 1000));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

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

    public ExecutionPlan generateWalkToRandomPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new WalkToRandomExecutionStep(tank));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }
}
