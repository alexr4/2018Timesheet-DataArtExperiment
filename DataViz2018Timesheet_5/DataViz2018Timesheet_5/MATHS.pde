PVector computeRodrigueRotation(PVector k, PVector v, float theta)
{
  // Olinde Rodrigues formula : Vrot = v* cos(theta) + (k x v) * sin(theta) + k * (k . v) * (1 - cos(theta));
  PVector kcrossv = k.cross(v);
  float kdotv = k.dot(v);

  float x = v.x * cos(theta) + kcrossv.x * sin(theta) + k.x * kdotv * (1 - cos(theta));
  float y = v.y * cos(theta) + kcrossv.y * sin(theta) + k.y * kdotv * (1 - cos(theta));
  float z = v.z * cos(theta) + kcrossv.z * sin(theta) + k.z * kdotv * (1 - cos(theta));

  return new PVector(x, y, z);
}

PVector computeAxis(PVector target, PVector location) {
  PVector delta = PVector.sub(target, location);

  //compute angle between two vectors
  PVector v0 = new PVector(0, -1, 0);
  PVector v1 = delta.copy().normalize();

  float v0Dotv1 = PVector.dot(v0, v1);
  float angle = acos(v0Dotv1) * -1;
  return v0.cross(v1).mult(-1);
}