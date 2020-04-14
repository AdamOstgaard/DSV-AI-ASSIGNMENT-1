public class TankN extends Tank {
  boolean started;
  PVector destinationPos;
  ArrayList <PVector> visitedNodes;
  ArrayList <PVector> tankPList;
  TankN(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    visitedNodes = new ArrayList <PVector>();
    this.started = false;
    tankPList = new ArrayList<PVector>();
  }

  public void wander() {
    destinationPos = grid.getRandomNodePosition();
    moveTo(destinationPos);
    view();
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

  //Saxat från nature of code
  PVector view () {
    tankPList.clear();
    Collections.addAll(tankPList, otherTanks);
    // How far can it see?
    float sightDistance = 50;
    float periphery = PI/4;
    println(otherTanks);

    //Just nu så är tankN allTanks[0]
    for (int i = 1; i < allTanks.length; i++) {
      // A vector that points to another boid and that angle
      PVector comparison = PVector.sub(allTanks[i].getRealPosition(), position);

      // How far is it
      float d = PVector.dist(position, allTanks[i].getRealPosition());

      // What is the angle between the other boid and this one's current direction
      float diff = PVector.angleBetween(comparison, velocity);

      // If it's within the periphery and close enough to see it
      if (diff < periphery && d > 0 && d < sightDistance) {
        retreat();
      }
    }


    // Debug Drawing
    float currentHeading = velocity.heading();
    pushMatrix();
    translate(position.x, position.y);
    rotate(currentHeading);
    fill(0, 100);
    arc(0, 0, sightDistance*2, sightDistance*2, -periphery, periphery);
    popMatrix();

    return new PVector();
  }
}