/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
public class LookAroundForEnemyExecutionStep extends ExecutionPlanStep {
    private float target_rotation = -1;
    private boolean isTurning = false;

    public LookAroundForEnemyExecutionStep(TankGR13 tank){
        super(tank);
    }

    public boolean isValid(){
        return !isTurning || round10(fixAngle(degrees(tank.heading))) != round10(fixAngle(degrees(target_rotation)));
    }

    public void execute(){
        if(isFulfilled()){
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