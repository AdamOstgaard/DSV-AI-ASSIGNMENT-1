public class TankN extends Tank {
  boolean started;
  PVector destinationPos;
  ArrayList <PVector> visitedNodes;
  ArrayList <PVector> tankPList;
  boolean seesEnemy;

  TankN(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    visitedNodes = new ArrayList <PVector>();
    this.started = false;
    tankPList = new ArrayList<PVector>();
  }
  
  Tank[] getEnemyTanks() {
    Tank[] enemyTanks = new Tank[3];
    int j = 0;
    
    for (int i = 0; i < allTanks.length; i++)
    {
      Tank otherTank = allTanks[i]; 
      if(otherTank.team_id != team_id){
        enemyTanks[j++] = otherTank;
      }  
    }
    return enemyTanks;
  }
  
  Tank[] getFriendlyTanks(){
    Tank[] friendly = new Tank[3];
    for (int i = 1; i < allTanks.length; i++)
    {
      Tank otherTank = allTanks[i]; 
      if(otherTank.team_id == team_id){
        friendly[friendly.length + 1] = otherTank;
      }  
    }
    return friendly;
  }
  
  
  Tank[] getOtherTanks(){
    Tank[] otherTanks = new Tank[5];
    for (int i = 1; i < allTanks.length; i++)
    {
      Tank otherTank = allTanks[i]; 
      otherTanks[i] = otherTank;
    }  
  return otherTanks;
  }

  public void wander() {
    destinationPos = grid.getRandomNodePosition();
    moveTo(destinationPos);
  }

  public void arrived() {
    super.arrived();
    visitedNodes.add(destinationPos);
    println(visitedNodes.toString());
    wander();
  }

  public void retreat() {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].retreat()");
    ArrayList <PVector> pathBack = pathBack(this.position);
    for (PVector p : pathBack) {
      moveTo(p);
    }
    //moveTo(grid.getRandomNodePosition()); // Slumpmässigt mål.
  }

  private ArrayList<PVector> pathBack(PVector start) {
    ArrayList <PVector> path = shortestPath(start, new ArrayList<PVector>());
    return path;
  }

  private ArrayList <PVector> shortestPath(PVector start, ArrayList<PVector> pathBack) {

    int min = Integer.MAX_VALUE;
    PVector nodeToAdd = start;
    if (start == this.startpos)
      return pathBack;
    for (PVector p : visitedNodes) {
      if ((start.x - p.x) + (start.y - p.y) < min) {
        nodeToAdd = p;
      }
    }
    pathBack.add(nodeToAdd);
    shortestPath(nodeToAdd, pathBack);
    return null;
  }

  //*******************************************************
  // Reterera i motsatt riktning (ej implementerad!)
  public void retreat(Tank other) {
    //println("*** Team"+this.team_id+".Tank["+ this.getId() + "].retreat()");
    //moveTo(grid.getRandomNodePosition());
    retreat();
  }

  public void message_collision(Tree other) {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].collision(Tree)");
    wander();
  }

  public void message_collision(Tank other) {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].collision(Tank)");

    //moveTo(new PVector(int(random(width)),int(random(height))));
    //println("this.getName());" + this.getName()+ ", this.team_id: "+ this.team_id);
    //println("other.getName());" + other.getName()+ ", other.team_id: "+ other.team_id);

    if ((other.getName() == "tank") && (other.team_id != this.team_id)) {
      if (this.hasShot && (!other.isDestroyed)) {
        println("["+this.team_id+":"+ this.getId() + "] SKJUTER PÅ ["+ other.team_id +":"+other.getId()+"]");
        fire();
      } else {
        retreat(other);
      }

      rotateTo(other.position);
      //wander();
    } else {
      wander();
    }
  }

  public void updateLogic() {
    super.updateLogic();

    view();

    if (!started) {
      started = true;
      moveTo(grid.getRandomNodePosition());
    }

    if (!this.userControlled) {

      //moveForward_state();
      if (this.stop_state) {
        //rotateTo()
        wander();
      }

      if (this.idle_state) {
        wander();
      }
    }
  }

  float getAngle(float pX1,float pY1, float pX2,float pY2){
  return atan2(pY2 - pY1, pX2 - pX1);
}

  void view () {
    seesEnemy = isEnemyInFront();
  
    pushMatrix();
    translate(position.x, position.y);
    rotate(velocity.heading());
    
    if(seesEnemy){
      // println("SEES ENEMY!");
      fill(255,0,0);
      stroke(255,0,0);
    }
    line(0, 0, 500, 0);
    popMatrix();
  
  }

  boolean isEnemyInFront(){
    Tank[] enemyTanks = getEnemyTanks();
    
    for(int i = 0; i < enemyTanks.length; i++){
      Tank t = enemyTanks[i];
        // A vector that points to another boid and that angle
        PVector comparison = PVector.sub(t.position, position);
        
        // How far is it
        float d = PVector.dist(position, t.getRealPosition());

        // What is the angle between the other boid and this one's current direction
        float diff = getAngle(position.x, position.y, t.position.x, t.position.y);
        
        float a = radius;
        float angleDiff = atan(a / d);
       
        heading = velocity.heading();

        pushMatrix();
        translate(position.x, position.y);
        rotate(diff - angleDiff);
        stroke(100,50,0);
        line(0, 0, 500, 0);
        rotate(angleDiff * 2);
        line(0, 0, 500, 0);
        stroke(0,0,0);
        popMatrix();
        
        if(heading > diff - angleDiff && heading < diff + angleDiff){
          return true;
        }
    }
    return false;
  }

  ////Saxat från nature of code
  //PVector view () {
  //  // How far can it see?
  //  float sightDistance = 100;
  //  float periphery = PI/4;
  //  println(otherTanks);

  //  //Just nu så är tankN allTanks[0]
  //  for (int i = 1; i < otherTanks.length; i++) {
  //    Tank otherTank = otherTanks[i];
  //    if(otherTank.team_id != team_id){
      
  //      // A vector that points to another boid and that angle
  //      PVector comparison = PVector.sub(allTanks[i].getRealPosition(), position);

  //      // How far is it
  //      float d = PVector.dist(position, allTanks[i].getRealPosition());

  //      // What is the angle between the other boid and this one's current direction
  //      float diff = PVector.angleBetween(comparison, velocity);

  //      // If it's within the periphery and close enough to see it
  //      if (diff < periphery && d > 0 && d < sightDistance) {
  //        retreat();
  //      }
  //    }
  //  }


  //  // Debug Drawing
  //  float currentHeading = velocity.heading();


  //  return new PVector();
  //}
}
