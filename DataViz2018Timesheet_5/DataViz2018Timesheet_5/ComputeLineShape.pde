float thickness = 20;
ArrayList<PVector> pointsList = new  ArrayList<PVector>(); //original Point List
ArrayList<PVector> normalLineList = new  ArrayList<PVector>(); //normal per ligne
ArrayList<PVector> tangentLineList = new  ArrayList<PVector>(); //normal per ligne
ArrayList<PVector> normalTangentLineList = new  ArrayList<PVector>(); //normal to tange per ligne
ArrayList<PVector> earlyVertList = new  ArrayList<PVector>(); //Early Shape using normal per ligne
ArrayList<PVector> earlyVertList2 = new  ArrayList<PVector>(); //Early Shape using tangent normal per ligne
ArrayList<PVector> vertList = new  ArrayList<PVector>();
int headResolution = 10;

//---------------------------
//Computation
//---------------------------
ArrayList<PVector> computeShape(ArrayList<PVector> pointsList, float thickness_)
{
  vertList.clear();
  normalLineList.clear();
  tangentLineList.clear();
  normalTangentLineList.clear();
  earlyVertList.clear();
  earlyVertList2.clear();
  for (int i=0; i<pointsList.size(); i++)
  {
    float noise = noise(i) * 2.0 - 1.0;
    thickness = sin(norm(i, 0, pointsList.size())* PI) * thickness_;//
    float thickness2 = thickness;//norm(i+1, 0, pointsList.size()) * 25;
    float waveThick = sin(norm(i, 0, pointsList.size())* PI) * thickness;

    //define indices of p0, p1 and p2
    int i0 = i;
    int i1 = i;
    int i2 = i;
    int i3 = i;

    if (i>0)
    {
      i0 = i-1;
    } else
    {
      i0 = 0;
    }

    if (i<pointsList.size()-1)
    {
      i2 = i+1;
    } else
    {
      i2 = pointsList.size()-1;
    }

    if (i<pointsList.size()-2)
    {
      i3 = i+2;
    } else
    {
      i3 = pointsList.size()-1;
    }

    //get points p0, p1 and p2
    PVector p0 = pointsList.get(i0); //previous Point
    PVector p1 = pointsList.get(i1); //Point 0
    PVector p2 = pointsList.get(i2); //Point 1
    PVector p3 = pointsList.get(i3); //Next Point

    //Find vectors p0p1, p1p2 and p0p2
    PVector p0p1 = PVector.sub(p1, p0).normalize();//Previous Line
    PVector p1p2 = PVector.sub(p2, p1).normalize();//Our line
    PVector p2p3 = PVector.sub(p3, p2).normalize();//next line

    //Find Normal to p1p2
    PVector rotationVector = PVector.sub(new PVector(), p1).normalize();

    PVector p1p2Normal = new PVector(-p1p2.y, p1p2.x).normalize(); //2D
    //PVector p1p2Normal = p1p2.cross(rotationVector).normalize(); //3D

    //Stock normal line
    normalLineList.add(new PVector(p1.x - p1p2Normal.x * thickness, p1.y - p1p2Normal.y * thickness, p1.z - p1p2Normal.z * thickness));
    normalLineList.add(new PVector(p1.x + p1p2Normal.x * thickness, p1.y + p1p2Normal.y * thickness, p1.z + p1p2Normal.z * thickness));
    normalLineList.add(new PVector(p2.x + p1p2Normal.x * thickness, p2.y + p1p2Normal.y * thickness, p2.z + p1p2Normal.z * thickness));
    normalLineList.add(new PVector(p2.x - p1p2Normal.x * thickness, p2.y - p1p2Normal.y * thickness, p2.z - p1p2Normal.z * thickness));

    //Draw early shape, line is cutted
    earlyVertList.add(new PVector(p1.x + p1p2Normal.x * thickness, p1.y + p1p2Normal.y * thickness, p1.z + p1p2Normal.z * thickness));
    earlyVertList.add(new PVector(p2.x + p1p2Normal.x * thickness, p2.y + p1p2Normal.y * thickness, p2.z + p1p2Normal.z * thickness));
    earlyVertList.add(new PVector(p1.x - p1p2Normal.x * thickness, p1.y - p1p2Normal.y * thickness, p1.z - p1p2Normal.z * thickness));
    earlyVertList.add(new PVector(p1.x - p1p2Normal.x * thickness, p1.y - p1p2Normal.y * thickness, p1.z - p1p2Normal.z * thickness));
    earlyVertList.add(new PVector(p2.x - p1p2Normal.x * thickness, p2.y - p1p2Normal.y * thickness, p2.z - p1p2Normal.z * thickness));
    earlyVertList.add(new PVector(p2.x + p1p2Normal.x * thickness, p2.y + p1p2Normal.y * thickness, p2.z + p1p2Normal.z * thickness));

    //In order to create a uncutted line we need to compute the cross-section of the joint from the mitter
    //Find tangents to both point p1 p2
    PVector tangent1 = p0p1.copy();
    tangent1.add(p1p2.copy().normalize());
    tangent1.normalize();

    PVector tangent2 = p2p3.copy();
    tangent2.add(p1p2.copy().normalize());
    tangent2.normalize(); 

    tangentLineList.add(new PVector(p1.x + tangent1.x * thickness, p1.y + tangent1.y * thickness, p1.z + tangent1.z * thickness));
    tangentLineList.add(new PVector(p1.x - tangent1.x * thickness, p1.y - tangent1.y * thickness, p1.z - tangent1.z * thickness));
    tangentLineList.add(new PVector(p2.x + tangent2.x * thickness, p2.y + tangent2.y * thickness, p2.z + tangent2.z * thickness));
    tangentLineList.add(new PVector(p2.x - tangent2.x * thickness, p2.y - tangent2.y * thickness, p2.z - tangent2.z * thickness));

    //Find the normal of the tangents 2D
    PVector normTangent1 = new PVector(-tangent1.y, tangent1.x);
    PVector normTangent2 = new PVector(-tangent2.y, tangent2.x);
    //Find the normal of the tangents 3D
    //PVector rtangent1 = PVector.sub(new PVector(), p0p1).normalize();
    //PVector rtangent2 = PVector.sub(new PVector(), p2p3).normalize();
    // PVector normTangent1 = tangent1.cross(rtangent1).normalize(); //3D
    //PVector normTangent2 = tangent2.cross(rtangent2).normalize(); //3D
    // PVector K1 = computeAxis(new PVector(), tangent1);
    //PVector K2 = computeAxis(new PVector(), tangent2);
    //PVector normTangent1 = computeRodrigueRotation(K1, tangent1, HALF_PI);
    //PVector normTangent2 = computeRodrigueRotation(K2, tangent2, HALF_PI);


    normalTangentLineList.add(new PVector(p1.x + normTangent1.x * thickness, p1.y + normTangent1.y * thickness, p1.z + normTangent1.z * thickness));
    normalTangentLineList.add(new PVector(p1.x - normTangent1.x * thickness, p1.y - normTangent1.y * thickness, p1.z - normTangent1.z * thickness));
    normalTangentLineList.add(new PVector(p2.x + normTangent2.x * thickness, p2.y + normTangent2.y * thickness, p2.z + normTangent2.z * thickness));
    normalTangentLineList.add(new PVector(p2.x - normTangent2.x * thickness, p2.y - normTangent2.y * thickness, p2.z - normTangent2.z * thickness));

    //early shape 2, thickness is not the same    
    earlyVertList2.add(new PVector(p1.x + normTangent1.x * thickness, p1.y + normTangent1.y * thickness, p1.z + normTangent1.z * thickness));
    earlyVertList2.add(new PVector(p2.x + normTangent2.x * thickness, p2.y + normTangent2.y * thickness, p2.z + normTangent2.z * thickness));
    earlyVertList2.add(new PVector(p1.x - normTangent1.x * thickness, p1.y - normTangent1.y * thickness, p1.z - normTangent1.z * thickness));
    earlyVertList2.add(new PVector(p1.x - normTangent1.x * thickness, p1.y - normTangent1.y * thickness, p1.z + normTangent1.z * thickness));
    earlyVertList2.add(new PVector(p2.x - normTangent2.x * thickness, p2.y - normTangent2.y * thickness, p2.z - normTangent2.z * thickness));
    earlyVertList2.add(new PVector(p2.x + normTangent2.x * thickness, p2.y + normTangent2.y * thickness, p2.z + normTangent2.z * thickness));

    //find length of the line by projecting it on one normal
    float length1 = thickness / p1p2Normal.dot(normTangent1);
    float length2 = thickness2 / p1p2Normal.dot(normTangent2);

    //find the final vertex position
    PVector v0 = p1.copy().add(normTangent1.copy().mult(length1));
    PVector v1 = p2.copy().add(normTangent2.copy().mult(length2));
    PVector v2 = p1.copy().sub(normTangent1.copy().mult(length1));
    PVector v3 = p2.copy().sub(normTangent2.copy().mult(length2));

    vertList.add(v0);
    vertList.add(v2);
    vertList.add(v1);

    vertList.add(v1);    
    vertList.add(v2);
    vertList.add(v3);
  }
  
  return vertList;
}

//---------------------------
//Display
//---------------------------
void displayShape()
{ 
  stroke(127, 150);
  fill(127, 100);
  beginShape(TRIANGLES);
  for (PVector v : vertList)
  {
    vertex(v.x, v.y, v.z);
  }
  endShape();
}

void displayShapeWithHead()
{ 
  stroke(127, 150);
  fill(127, 100);
  beginShape(TRIANGLES);
  //body
  for (PVector v : vertList)
  {
    vertex(v.x, v.y, v.z);
  }
  endShape();


  //head
  PVector center = pointsList.get(pointsList.size() - 1);
  PVector lastVertex = vertList.get(vertList.size() - 7);
  PVector centerToLastVertex = PVector.sub(lastVertex, center);
  beginShape(TRIANGLE_FAN);
  vertex(center.x, center.y);
  for (int i=0; i<headResolution; i++)
  {
    float theta = norm(i, 0, headResolution) * PI;
    float gamma = norm(i+1, 0, headResolution) * PI;
    PVector v0 = centerToLastVertex.copy().rotate(theta);
    PVector v1 = centerToLastVertex.copy().rotate(gamma);
    v0.add(center);
    v1.add(center);

    vertex(v0.x, v0.y);
    vertex(v1.x, v1.y);
  }
  endShape();
}

//---------------------------
//DEBUG
//---------------------------
void displayNormalLine()
{
  beginShape(LINES);
  noFill();
  stroke(255, 0, 255); 
  for (PVector v : normalLineList)
  {
    vertex(v.x, v.y, v.z);
  }
  endShape();
}

void displayTangentLine()
{
  beginShape(LINES);
  noFill();
  stroke(255, 127, 0); 
  for (PVector v : tangentLineList)
  {
    vertex(v.x, v.y, v.z);
  }
  endShape();
}

void displayNormalTangentLine()
{
  beginShape(LINES);
  noFill();
  stroke(0, 127, 255); 
  for (PVector v : normalTangentLineList)
  {
    vertex(v.x, v.y, v.z);
  }
  endShape();
}

void displayEarlyShape1()
{
  stroke(255, 100, 0);
  noFill();
  beginShape(TRIANGLES);
  for (PVector v : earlyVertList)
  {
    vertex(v.x, v.y, v.z);
  }
  endShape();
}

void displayEarlyShape2()
{
  stroke(0, 100, 255);
  noFill();
  beginShape(TRIANGLES);
  for (PVector v : earlyVertList2)
  {
    vertex(v.x, v.y, v.z);
  }
  endShape();
}
