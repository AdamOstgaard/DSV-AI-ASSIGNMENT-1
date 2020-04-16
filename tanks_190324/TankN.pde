public class TankN extends Tank {
  boolean started;
  PVector destinationPos;
  ArrayList <Node> visitedNodes;
  ArrayList <PVector> tankPList;
  boolean seesEnemy;

  TankN(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    visitedNodes = new ArrayList <Node>();
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
    Node[] nodes = getNeighborNodes();
    Node node = null;

    int retries = 0;

    for (int i = 0; i < nodes.length; i++){
      if(nodes[i] != null && !visitedNodes.contains(nodes[i]) && !isNodeTree(nodes[i])){
        node = nodes[i];
        moveTo(node.position);
        println("Short walk");
        return;
      }
    }


    for(int i = 0; i < grid.cols * grid.rows; i++){
      Node tempNode = grid.getNearestNode(grid.getRandomNodePosition());
      if(!visitedNodes.contains(tempNode) && !isNodeTree(tempNode)){
        node = tempNode;
        println("Random walk to known");
        break;
      }

      if(node == null){
        node = grid.getNearestNode(grid.getRandomNodePosition());
      }
    
    }
          println("Random walk");
      moveTo(node.position);
  }

  boolean isNodeTree(Node node){
    for (int i = 0; i < allTrees.length; i++) {
      Tree tree = allTrees[i];
      PVector distanceVect = PVector.sub(tree.position, node.position);

      // Calculate magnitude of the vector separating the tank and the tree
      float distanceVectMag = distanceVect.mag();

      // Minimum distance before they are touching
      float minDistance = grid.grid_size + tree.radius;

      if (distanceVectMag <= minDistance) {
        return true;
      }
    }
    return false;
  }

  Node[] getNeighborNodes(){
    Node currentNode = grid.getNearestNode(position);
    Node[] neighbors = new Node[4];
    
    if(currentNode.col >= 1){
      neighbors[0] = grid.nodes[currentNode.col - 1][currentNode.row];
    }

    if(currentNode.col < grid.cols - 1){
      neighbors[1] = grid.nodes[currentNode.col + 1][currentNode.row];
    }

    if(currentNode.row >= 1){
      neighbors[2] = grid.nodes[currentNode.col][currentNode.row -1];
    }

    if(currentNode.row < grid.rows - 1){
      neighbors[3] = grid.nodes[currentNode.col][currentNode.row + 1];
    }

    return neighbors;
  }

  public void arrived() {
    super.arrived();
    visitedNodes.add(grid.getNearestNode(position));
    println(visitedNodes.toString());
    wander();
  }

  public void retreat() {
    println("*** Team"+this.team_id+".Tank["+ this.getId() + "].retreat()");
    //ArrayList <PVector> pathBack = pathBack(this.position);
    /*
    println(visitedNodes.toString());
    for (PVector p : pathBack) {
      moveTo(p);
    }
    */
    //moveTo(grid.getRandomNodePosition()); // Slumpmässigt mål.
  }

/*
   private ArrayList<PVector> pathBack(PVector start) {
     
    ArrayList <PVector> openPath = visitedNodes;
    Collections.sort(openPath, new DistanceComparator(this.startpos));
    println(openPath.toString());
    ArrayList <PVector> closedPath = new ArrayList <PVector>();
    return openPath;
    
    //return shortestPath(openPath, closedPath);
  }
*/
  
  private ArrayList <PVector> shortestPath(PVector start, ArrayList<PVector> pathBack) {
/*
    int min = Integer.MAX_VALUE;
    PVector nodeToAdd = start;
    if (start == this.startpos)
      return pathBack;
    for (Node p : visitedNodes) {
      if ((start.x - p.x) + (start.y - p.y) < min) {
        nodeToAdd = p;
      }
    }
    pathBack.add(nodeToAdd);
    shortestPath(nodeToAdd, pathBack);*/
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
    wander();
  }

  public void updateLogic() {
    super.updateLogic();
    grid.display();
    view();

    if (!started) {
      started = true;
      wander();
      return;
    }

    if (!this.userControlled) {

      //moveForward_state();
      if (this.stop_state) {
        //rotateTo()
        //wander();
        return;
      }

      if (this.idle_state) {
        //wander();
        return;
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
