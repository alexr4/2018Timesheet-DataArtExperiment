class Node {
  private PVector location;
  private PVector acceleration;
  private PVector velocity;
  private float maxSpeed, maxForce;

  private float radius;
  private int modDay;

  Node(PVector location, float radius, float max, int modDay) {
    this.acceleration = new PVector();
    this.location = location;
    this.velocity = PVector.random2D();
    this.radius = radius;
    this.maxSpeed = max;
    this.maxForce = max;
    this.modDay = modDay;
  }

  private void addForce(PVector force) {
    this.acceleration.add(force);
  }

  private void update() {
    this.velocity.add(this.acceleration);
    this.location.add(this.velocity);
    this.acceleration.mult(0);
  }

  private void display() {
    this.display(g);
  }

  private void display(PGraphics buffer) {
    float nDay = 1.0 - (modDay / 7.0);
    nDay = nDay * 0.9 + 0.1;
    buffer.noFill();
    buffer.stroke(50 + 200 * nDay);
    //buffer.noStroke();
   // buffer.fill(0);
    buffer.ellipse(this.location.x, this.location.y, this.radius * 2.0, this.radius * 2.0);
  }

  private void checkEdge(float minx, float maxx, float miny, float maxy) {
    if (this.location.x - this.radius < minx) {
      this.location.x = this.radius + minx;
    } else if (this.location.x+this.radius > width - maxx) {
      this.location.x = width - this.radius - maxx;
    }
    if (this.location.y-this.radius < miny) {
      this.location.y = this.radius + miny;
    } else if (this.location.y+this.radius > height - maxy) {
      this.location.y = height - this.radius - maxy;
    }
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
    } else {
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
    } else {
    }
  }
}
