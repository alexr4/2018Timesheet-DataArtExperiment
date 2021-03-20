class Line {
  PVector A;
  PVector B;
  PVector dir;
  boolean isFinished;

  Line(PVector A, PVector B) {
    this.A = A;
    this.B = B;
  }

  Line(PVector A, PVector B, PVector dir) {
    this.A = A;
    this.B = B;
    this.dir = dir;
  }


  void displayLine(PGraphics b) {
    b.line(A.x, A.y, B.x, B.y);
  }

  void displayRoots(PGraphics b) {
    b.noFill();
    b.stroke(0, 255, 0);
    b.ellipse(A.x, A.y, 4, 4);
    b.stroke(0, 0, 255);
    b.ellipse(B.x, B.y, 4, 4);
  }

  Line getNewlineDirection() {
    float rand = random(1.0);
    PVector root = PVector.lerp(A, B, rand);
    float theta =  (random(1.0) > 0.5) ? HALF_PI : -HALF_PI;
    float gammaOffset = HALF_PI / 100;
    float gamma = random(0.0, HALF_PI - gammaOffset);
    float orientation = round(random(-1.0, 1.0));
    PVector dir = PVector.sub(A, B).normalize().rotate(theta + gamma * orientation);
    return new Line(root, root.copy(), dir);
  }

}
