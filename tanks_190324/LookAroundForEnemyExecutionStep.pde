public class LookAroundForEnemyExecutionStep extends ExecutionPlanStep {
    private float target_rotation = -1;
    private boolean isTurning = false;

    public LookAroundForEnemyExecutionStep(TankN tank){
        super(tank);
    }

    public boolean isValid(){
        return !isTurning || round10(fixAngle(degrees(tank.heading))) != round10(fixAngle(degrees(target_rotation)));
    }

    public void execute(){
        if(isFulfilled()){
            println("Fulfilled!!");
            tank.stopTurning();
            tank.stopMoving();
            return;
        }

        if(!isTurning){
            target_rotation = tank.heading - 270;
            isTurning = true;
        }

        tank.turnLeft();
    }

    public boolean isFulfilled(){
        return tank.isEnemyInfront;
    }
}