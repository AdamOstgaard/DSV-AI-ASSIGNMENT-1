
/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/
enum StateFlag { IDLE, WANDERING, ROTATING, ARRIVED_MOVE, ARRIVED_ROTATE }

public class SearchForEnemyExecutionStep extends ExecutionPlanStep {
    private float target_rotation;
    private StateFlag stateFlag = StateFlag.IDLE; 
    private Node tempTarget;

    public SearchForEnemyExecutionStep(TankN tank){
        super(tank);
    }

    public boolean isValid(){
        return tank.isImmobilized;
    }

    public void execute(){
        if(isFulfilled()){
            println("Fulfilled!!");
            tank.stopMoving();
            tank.stopTurning();
            return;
        }

        if(!tank.isMoving && !tank.isRotating && stateFlag != StateFlag.ROTATING){
            stateFlag = StateFlag.IDLE;
        }

        if(tempTarget != null && tempTarget == grid.getNearestNode(tank.position) && stateFlag == StateFlag.WANDERING){
            stateFlag = StateFlag.ARRIVED_MOVE;
        }

        switch(stateFlag){
            case IDLE:
                stateFlag = StateFlag.WANDERING;
                wander();
                break;
            case WANDERING:
                break;
            case ARRIVED_ROTATE:
                stateFlag = StateFlag.WANDERING;
                wander();
                break;
            case ARRIVED_MOVE:
                println("START ROTATING");
                target_rotation = tank.heading - 270;
                tank.turnLeft();
                stateFlag = StateFlag.ROTATING;
                break;
            case ROTATING:
                if(round10(fixAngle(degrees(tank.heading))) == round10(fixAngle(degrees(target_rotation)))){
                    println("FINNISHED ROTATING");
                    stateFlag = StateFlag.ARRIVED_ROTATE;
                    break;
                }
                tank.turnLeft();
                break;
        }
    }

    public boolean isFulfilled(){
        Sensor s = tank.getSensor("VISUAL");
        SensorReading reading = s.readValue();

        if(reading != null && reading.obj.getName() == "tank"){
            Tank t = (Tank)reading.obj;
            return t.team != tank.team && t.health > 0; 
        }
        return false;
    }

    private void wander() {
        Node tempNode = grid.getNearestNode(grid.getRandomNodePosition());
        tank.moveTo(tempNode.position);
        tempTarget = tempNode;
    }
}