public class ExecutionPlanner {
    private Tank tank;

    public ExecutionPlanner(Tank tank){
        this.tank = tank;
    }

    public ExecutionPlan generatePlan(){
        if(!tank.hasShot){
            return generateLoadCannonPlan();
        }

        if(tank.isImmobilized){
            return generateImmobilizedPlan();
        }

        return generateNormalPlan();
    }

    private ExecutionPlan generateRetreatPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new AStarRetreatExecutionStep(tank));
        steps.add(new AStarRetreatExecutionStep(tank));

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
        steps.add(new RadioUpdateTeamExecutionStep(tank));
        steps.add(new PauseExectutionStep(tank, 1000));
        

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    private ExecutionPlan generateLoadCannonPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new LoadCannonExecutionStep(tank));
        steps.add(new PauseExectutionStep(tank, 3000));
        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    private ExecutionPlan generateImmobilizedPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new LookAroundForEnemyExecutionStep(tank));
        steps.add(new FireCannonExecutionStep(tank));
        steps.add(new PauseExectutionStep(tank, 1000));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }
}
