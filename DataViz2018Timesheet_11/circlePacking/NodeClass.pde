class Node {
  private PVector location;
  private PVector acceleration;
  private PVector velocity;

  private float radius;
  private float maxForce, maxSpeed;
  private int neiCount;
  private float rand;

  Node(PVector location, float radius) {
    this.acceleration = new PVector();
    this.location = location;
    this.velocity = PVector.random2D();
    this.radius = radius;
    this.maxForce = random(1.0, 2.0);
    this.maxSpeed = random(1.0, 2.0);
    this.rand = random(1.0) * 0.5 + 0.5;
  }

  private void addForce(PVector force) {
    this.acceleration.add(force);
  }

  private void update() {
    this.velocity.add(this.acceleration);
    this.location.add(this.velocity);
    this.acceleration.mult(0);
  }

  private void display(PGraphics b) {
    b.noFill();
    b.stroke(255);// * rand);
    //b.strokeWeight(2);
    b.ellipse(this.location.x, this.location.y, this.radius * 2.0, this.radius * 2.0);
  }

  private void separate(ArrayList<Node> nodes) {
    PVector sum = new PVector();
    int count = 0;
    for (Node node : nodes) {
      float d = PVector.dist(this.location, node.location);
      float mind = this.radius + node.radius;
      if (d <= mind && d != 0) {
        PVector diff = PVector.sub(this.location, node.location);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }

    if (count > 0) {
      sum.setMag(maxSpeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      addForce(steer);
    }else{
    }
  }
  
  private void stopIfNoNeighbors(ArrayList<Node> nodes, float minSpace) {
    int count = 0;
    for (Node node : nodes) {
      float d = PVector.dist(this.location, node.location);
      float mind = this.radius + node.radius;
      if (d <= mind + minSpace && node != this) {
        count++;
      }
    }

    if (count <= 0) {
      this.velocity.mult(0);
    }else{
    }
    neiCount = count;
  }
}
