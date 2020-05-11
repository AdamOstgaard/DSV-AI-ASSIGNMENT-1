class SensorVisuals extends Sensor {
  SensorVisuals(Tank t) {
    super(t);
  }

    public SensorReading readValue(){
        Tank[] enemyTanks = tank.getEnemyTanks();
        Tank[] friendlyTanks = tank.getFriendlyTanks();
        PVector position = tank.position;

        float closest = Float.MAX_VALUE;
        Sprite closestSprite = null;
        for (int i = 0; i < enemyTanks.length; i++){
            float distance = PVector.dist(position, enemyTanks[i].getRealPosition());
            if (inEnemyBase(position) && isSpriteInFront(enemyTanks[i]) && distance < closest){
                closest = distance;
                closestSprite = enemyTanks[i];
            }
        }
        for (int i = 0; i < friendlyTanks.length; i++){
            float distance = PVector.dist(position, friendlyTanks[i].getRealPosition());
            if (isSpriteInFront(friendlyTanks[i]) && distance < closest){
                closest = distance;
                closestSprite = friendlyTanks[i];
            }
        }
        for (int i = 0; i < allTrees.length; i++){
            float distance = PVector.dist(position, allTrees[i].getRealPosition());
            if (isSpriteInFront(allTrees[i]) && distance < closest){
                closest = distance;
                closestSprite = allTrees[i];
            }
        }

        if(closestSprite == null){
            return null;
        }

        float heading = round(fixAngle(degrees(getAngle(tank.position.x, tank.position.y, closestSprite.position.x, closestSprite.position.y))));

        return new SensorReading(closestSprite, closest, heading);
    }


    boolean isSpriteInFront(Sprite t){
        PVector position = tank.position;
        //Inspirerat av The Nature of Code exercise_6_17_view
        float d = PVector.dist(position, t.position);

        
        float diff = getAngle(position.x, position.y, t.position.x, t.position.y);
        
        float a = t.radius;
        float angleDiff = atan(a / d);
        
        float heading2 = round(fixAngle(degrees(tank.heading)));

        pushMatrix();
        translate(position.x, position.y);
        rotate(diff - angleDiff);
        stroke(100,50,0);    
        line(0, 0, 500, 0);
        rotate(angleDiff * 2);
        line(0, 0, 500, 0);
        stroke(0,0,0);
        popMatrix();
        
        return heading2> round(fixAngle(degrees(diff - angleDiff))) && heading2 < round(fixAngle(degrees(diff + angleDiff)));
    }
        
    boolean inEnemyBase(PVector v){
        Team enemyTeam = teams[1];

        return 
        v.x > enemyTeam.homebase_x && 
        v.x < enemyTeam.homebase_x + enemyTeam.homebase_width &&
        v.y > enemyTeam.homebase_y &&
        v.y < enemyTeam.homebase_y + enemyTeam.homebase_height;
    }
  
    boolean nodeInEnemyBase(Node n){
        return inEnemyBase(n.position);
    }

    float getAngle(float pX1,float pY1, float pX2,float pY2){
        return atan2(pY2 - pY1, pX2 - pX1);
    }

    boolean isNodeInFront(Node n){
        //Inspirerat av The Nature of Code exercise_6_17_view
        float d = PVector.dist(tank.position, n.position);

        float diff = getAngle(tank.position.x, tank.position.y, n.position.x, n.position.y);
        
        float a = tank.radius;
        float angleDiff = atan(a / d);
        
        float  heading2 = round(fixAngle(degrees(tank.heading)));
        
        return heading2 > round(fixAngle(degrees( diff - angleDiff))) && heading2 < round(fixAngle(degrees(diff + angleDiff)));
    }
}
