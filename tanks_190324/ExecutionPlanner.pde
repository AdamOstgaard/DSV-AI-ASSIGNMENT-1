public class ExecutionPlanner {
    private Tank tank;
    TankN tankN;
    public ExecutionPlanner(Tank tank){
        this.tank = tank;
        tankN = (TankN) tank;
    }

    public ExecutionPlan generatePlan(){
        
        if(!tank.hasShot){
            return generateLoadCannonPlan();
        }

        if(tank.isImmobilized){
            return generateImmobilizedPlan();
        }
        if(tankN.seesEnemy(tankN.reading) && tank.hasShot){
            return generateFireAndRetreatPlan();
        }
        if(tank.idle_state){
            println("ANTI-COLLISION");
            return generateRandomWalkPlan();
        }

        return generateNormalPlan();
    }

    private ExecutionPlan generateRandomWalkPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new WalkToRandomExecutionStep(tank));
        steps.add(new LookAroundForEnemyExecutionStep(tank));
        steps.add(new FireCannonExecutionStep(tank));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }
    private ExecutionPlan generateFireAndRetreatPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new FireCannonExecutionStep(tank));
        steps.add(new PauseExectutionStep(tank, 3000));
        steps.add(new AStarRetreatExecutionStep(tank));
        steps.add(new RadioUpdateTeamExecutionStep(tank));

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }
    private ExecutionPlan generateNormalPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new AStarMoveExecutionStep(tank));
        steps.add(new LookAroundForEnemyExecutionStep(tank));
        steps.add(new PauseExectutionStep(tank, 1000));
        

        ExecutionPlanStep[] itemsArray = new ExecutionPlanStep[steps.size()];
        itemsArray = steps.toArray(itemsArray);

        return new ExecutionPlan(itemsArray);
    }

    private ExecutionPlan generateLoadCannonPlan(){
        ArrayList<ExecutionPlanStep> steps = new ArrayList<ExecutionPlanStep>();
        steps.add(new LoadCannonExecutionStep(tank));
        steps.add(new PauseExectutionStep(tank, 1000));
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
