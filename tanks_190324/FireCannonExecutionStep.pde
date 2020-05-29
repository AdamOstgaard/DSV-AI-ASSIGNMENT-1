public class FireCannonExecutionStep extends ExecutionPlanStep {
    public FireCannonExecutionStep(TankN tank){
        super(tank);
    }

    public boolean isValid(){
        return tank.hasShot && tank.isEnemyInfront || tank.ball.isVisible;
    }

    public void execute(){

        tank.stopMoving_state();
        tank.fire();
    }
    
    public boolean isFulfilled(){
        return tank.ball.isExploding;
    }
}