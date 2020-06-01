class SensorVisuals extends Sensor {
  SensorVisuals(Tank t) {
    super(t);
  }

    //Kollar efter sprites inom tankens line of sight. Returnerar en SensorReading med närmsta sprite eller null.
    public SensorReading readValue(){
        TankN tankN = (TankN) tank;
        Tank[] enemyTanks = tankN.getEnemyTanks();
        Tank[] friendlyTanks = tankN.getFriendlyTanks();
        PVector position = tankN.position;

        float closest = Float.MAX_VALUE;
        Sprite closestSprite = null;
        for (int i = 0; i < enemyTanks.length; i++){
            float distance = PVector.dist(position, enemyTanks[i].getRealPosition());
            if (isSpriteInFront(enemyTanks[i]) && distance < closest){
                if(!inBase(enemyTanks[i].position, enemyTanks[i].team) || inBase(position, enemyTanks[i].team)){
                closest = distance;
                closestSprite = enemyTanks[i];
                } 
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



        float heading = round(fixAngle(degrees(getAngle(tankN.position.x, tankN.position.y, closestSprite.position.x, closestSprite.position.y))));

        return new SensorReading(closestSprite, closest, heading);
    }

    //True om sprite är inom tankens LoS, false annars.
    boolean isSpriteInFront(Sprite t){
        TankN tankN = (TankN) tank;
        PVector position = tankN.position;
        //Inspirerat av The Nature of Code exercise_6_17_view
        float d = PVector.dist(position, t.position);

        
        float diff = getAngle(position.x, position.y, t.position.x, t.position.y);
        
        float a = t.radius;
        float angleDiff = atan(a / d);
        
        float heading = tankN.heading;
        float heading2 = round(fixAngle(degrees(tankN.heading)));

        // pushMatrix();
        // translate(position.x, position.y);
        // rotate(diff - angleDiff);
        // stroke(100,50,0);    
        // line(0, 0, 500, 0);
        // rotate(angleDiff * 2);
        // line(0, 0, 500, 0);
        // stroke(0,0,0);
        // popMatrix();

        
        
        return (heading2> round(fixAngle(degrees(diff - angleDiff))) && heading2 < round(fixAngle(degrees(diff + angleDiff))))
        || (heading > diff - angleDiff && heading < diff + angleDiff);
    }
        

    //True om v är inom team
    boolean inBase(PVector v, Team team){
        return 
        v.x > team.homebase_x && 
        v.x < team.homebase_x + team.homebase_width &&
        v.y > team.homebase_y &&
        v.y < team.homebase_y + team.homebase_height;
    }
  
    //True om n är inom team
    boolean nodeinBase(Node n, Team team){
        return inBase(n.position, team);
    }

    float getAngle(float pX1,float pY1, float pX2,float pY2){
        return atan2(pY2 - pY1, pX2 - pX1);
    }

    //Kollar om en nod är inom tankens synfält. Tanken kan inte se bakom sprites eller in i fiendebasen om den inte själv är där inne.
    boolean isNodeInFront(Node n, SensorReading sr){
        TankN tankN = (TankN) tank;
        //Inspirerat av The Nature of Code exercise_6_17_view
        Tank[] enemyTanks = tankN.getEnemyTanks();
        Team enemyTeam = enemyTanks[0].team;
        PVector position = tankN.position;
        //Inspirerat av The Nature of Code exercise_6_17_view
        float d = PVector.dist(position, n.position);

        
        float diff = getAngle(position.x, position.y, n.position.x, n.position.y);
        
        float a = n.radius;
        float angleDiff = atan(a / d);
        
        float heading = tankN.heading;
        float heading2 = round(fixAngle(degrees(tankN.heading)));


        float srDistance = 0;
        if (sr != null){
            Sprite tempSprite = sr.obj();
            Node tempNode = grid.getNearestNode(tempSprite.position);
            srDistance = PVector.dist(tankN.position, tempNode.position);
        }

        if (sr != null) {
            if(heading > diff - angleDiff && heading < diff + angleDiff && d < srDistance 
            && ( (!inBase(tankN.position, enemyTeam) && !inBase(n.position, enemyTeam) ) || inBase(tankN.position, enemyTeam) )){
                return true;
            }
        }
            else if(heading > diff - angleDiff && heading < diff + angleDiff 
            && ( (!inBase(tankN.position, enemyTeam) && !inBase(n.position, enemyTeam) ) || inBase(tankN.position, enemyTeam) ) ){
                return true;
            }
        if (heading2> round(fixAngle(degrees(diff - angleDiff))) && heading2 < round(fixAngle(degrees(diff + angleDiff)))){
            if (sr != null) {
                if(d < srDistance && ( (!inBase(tankN.position, enemyTeam) && !inBase(n.position, enemyTeam) ) || inBase(tankN.position, enemyTeam) )){
                return true;
                }
            }
            else if( ( !inBase(tankN.position, enemyTeam) && !inBase(n.position, enemyTeam) ) || inBase(tankN.position, enemyTeam)) {
                return true;
            }
        }
        return false;
    }


}
