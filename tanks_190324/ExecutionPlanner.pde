public class ExecutionPlanner {
    private Tank tank;
    public ExecutionPlanner(Tank tank){
        this.tank = tank;
    }

    public ExecutionPlan generatePlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new SearchForEnemyExecutionStep(tank));
        steps.add(new FireCannonExecutionStep(tank));
        steps.add(new PauseExectutionStep(tank));
        steps.add(new LoadCannonExecutionStep(tank));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }
}
