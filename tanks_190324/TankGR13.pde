/* Group 13
Authors:
Adam Östgaard
Sebastian Kappelin
Niklas Friberg
*/

public class TankGR13 extends Tank {
  ArrayList <Node> visitedNodes;
  Grid known;
  boolean isRetreating;
  Stack<Node> retreatPath;
  Stack<Node> movePath;
  ExecutionPlanner planner;
  ExecutionPlan currentPlan = null;

  TankGR13(int id, Team team, PVector startpos, float diameter, CannonBall ball) {
    super(id, team, startpos, diameter, ball);
    planner = new ExecutionPlanner(this);
    visitedNodes = new ArrayList <Node>();
    known = new Grid(cols, rows, grid_size);
    isRetreating = false;
  }



    // Tanken meddelas om kollision med trädet. När detta händer så går tanken till en random Node för att undvika att de fastnar någonstans.
  public void message_collision(Tree other) {
    println("*** Tank["+ this.getId() + "].collision(Tree)");
    currentPlan = planner.generateWalkToRandomPlan();
    //println("Tank.COLLISION");
  }

  // Tanken meddelas om kollision med den andra tanken. När detta händer så går tanken till en random Node för att undvika att de fastnar någonstans.
  public void message_collision(Tank other) {
    println("*** Tank["+ this.getId() + "].collision(Tank)");
    currentPlan = planner.generateWalkToRandomPlan();
    //println("Tank.COLLISION");
  }

  //Tanken tittar för att kunna uppdatera sin karta och avgöra om den ska skjuta.
  //Om tankens nuvarande plan är färdig eller inte genomförbar så skapas en ny plan.
  public void updateLogic() {
    super.updateLogic();

    Sensor s = getSensor("VISUAL");
    SensorReading reading = s.readValue();

    updateKnownObjects(reading);
    updateKnownNodes(s, reading);


    // Testmetoder
    // if (id == 2){
    //   // printKnownNodes();
    //   // displayKnownNodes();
    // }

    isEnemyInfront = seesEnemy(reading);
    if (isEnemyInfront && hasShot){
      currentPlan = planner.generateFireCannonPlan();
    }


    if(currentPlan == null || !currentPlan.hasMoreSteps() || !currentPlan.isValid()){
      println("replan!");
      currentPlan = planner.generatePlan();
    }

    currentPlan.execute();
  }

//Inspirerat av https://github.com/SebLague/Pathfinding/blob/master/Episode%2001%20-%20pseudocode/Pseudocode
//Använder A* algoritmen för att ta fram den kortaste vägen till målet. Pathen hämtas genom Node.getPath på målnoden.


  //Returnerar true om en fiende är framför tanken.
  boolean seesEnemy(SensorReading reading){
      //Sensor s = getSensor("VISUAL");
      //SensorReading reading = s.readValue();

      if(reading != null && reading.obj.getName() == "tank"){
          Tank t = (Tank)reading.obj;
          return team != t.team && t.health > 0; 
      }
      return false;
  }

  //Om SensorReading har ett objekt så läggs det till i known.
  void updateKnownObjects(SensorReading sr){
    if (sr == null){
      return;
    }
    else{
      Sprite sprite = sr.obj();
      Node node = known.getNearestNode(sprite.position);
        switch (sprite.getName()){
            case "tree":
                ArrayList<Node> nodes = known.getNeighbours(node.col, node.row);
                for (Node n : nodes){
                    known.nodes[n.col][n.row].nodeContent = Content.OBSTACLE;
                }
                known.nodes[node.col][node.row].nodeContent = Content.OBSTACLE;
                break;
            case "tank":
                Tank otherTank = (Tank)sprite;
                if (team != otherTank.team && otherTank.health > 0){
                    known.nodes[node.col][node.row].nodeContent = Content.ENEMY;
                }
                else if(team == otherTank.team && otherTank.health > 0){
                    known.nodes[node.col][node.row].nodeContent = Content.FRIEND;
                }
                else{
                    known.nodes[node.col][node.row].nodeContent = Content.OBSTACLE;
                }
                break;
        }
    }
  }

  //Noder som tanken kan se markeras som empty.
  void updateKnownNodes(Sensor s, SensorReading sr){
    SensorVisuals sensorVisuals = (SensorVisuals)s;
    for (int col = 0; col < known.nodes.length; col++){
      for (int row = 0; row < known.nodes[col].length; row++){
        boolean inFront = sensorVisuals.isNodeInFront(known.nodes[col][row], sr);
        if (inFront){
          if (known.nodes[col][row].nodeContent != Content.OBSTACLE)
            known.nodes[col][row].nodeContent = Content.EMPTY;
        }
      }
    }
  }

  //testmetod för att printa ut info om noder som tanken känner till
  void printKnownNodes(){
    for (int col = 0; col < known.nodes.length; col++){
      for (int row = 0; row < known.nodes[col].length; row++){
        System.out.println("Col: " + col + " Row: " + row + " nodeContent: " + known.nodes[col][row].nodeContent + "\n");
      }
    }
  }

  //testmetod för att färglägga noder som tanken känner till 
  void displayKnownNodes() {
    pushMatrix();
    Node n = null;
    for(int col = 0; col < known.nodes.length; col++){
      for (int row = 0; row < known.nodes[col].length; row++){
        n = known.nodes[col][row];
        ellipse(n.position.x, n.position.y, 40, 40);
        switch(n.nodeContent){
        case ENEMY:
          fill(0,0,255,100);
          break;
        case FRIEND:
          fill(255,0,0,100);
          break;
        case OBSTACLE:
          fill(0,255,0,100);
          break;
        case EMPTY:
          fill(255,255,255,100);
          break;
        case UNKNOWN:
          fill(0,0,0,100);
          break;
    }
      }
    }
    
    

    popMatrix();
  }

  //Skapar en array med alla motståndartanks.
  public Tank[] getEnemyTanks() {
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

  //Skapar en array med alla vänliga tanks.
  public Tank[] getFriendlyTanks(){
    Tank[] friendlyTanks = new Tank[2];
    int j = 0;
    
    for (int i = 0; i < allTanks.length; i++)
    {
      Tank otherTank = allTanks[i]; 
      if(otherTank.team_id == team_id && id != otherTank.id){
        friendlyTanks[j++] = otherTank;
      }  
    }
    return friendlyTanks;
  }  


}



int round10(float n) {
  return (round(n) + 5) / 10 * 10;
}

float getAngle(float pX1,float pY1, float pX2,float pY2){
  return atan2(pY2 - pY1, pX2 - pX1);
}