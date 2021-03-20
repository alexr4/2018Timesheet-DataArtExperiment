class Branch {
  PVector position;
  PVector direction;
  PVector basedDirection;
  boolean additionalHour;
  
 // PVector noised;
  Branch parent;
  int count;
  float len;

  Branch(Branch parent, PVector position, PVector direction, float len) {
    this.parent = parent;
    this.position = position;
    this.direction = direction;
    this.basedDirection = this.direction.copy();
    this.len = len;
    //this.noised = PVector.random2D();
  }

  Branch next() {
    PVector nextDirection = PVector.mult(this.direction, this.len);
    PVector nextPosition = PVector.add(this.position, nextDirection);
    return new Branch(this, nextPosition, this.direction.copy(), this.len);
  }

  void reset() {
    this.direction = this.basedDirection.copy();
    this.count = 0;
  }
}
