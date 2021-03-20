class Veneation {
  //Growth Node
  ArrayList<Node> nodeList;
  ArrayList<Node> fractureNodeList;
  int nbOfNodes, nbOfFractureNode;

  //Root
  Branch root;

  //Branches
  ArrayList<Branch> branchList;

  //veneation
  float maxRadius;
  float maxDist = 75;
  float minDist = 5;
  float oMinDist = 10;
  float oMaxDist = 15;
  boolean found;
  Branch current;

  Veneation(int nbOfNodes, int nbOfFractureNode) {
    this.nbOfNodes = nbOfNodes;
    this.nbOfFractureNode = nbOfFractureNode;

    //growth node
    nodeList = new ArrayList<Node>();
    fractureNodeList = new ArrayList<Node>();
    branchList = new ArrayList<Branch>();

    initNodes();
    initRoot();
  }

  void initNodes() {
    nodeList.clear();

    float margin = 10;
    float hyp = sqrt(width * width + height * height);
    maxRadius = width * 0.45;
    float incTheta = TWO_PI/8760;

    int nbEdge = 3;
    float incRadius = TWO_PI / float(nbEdge);
    //modulate the distance to define the shape
    for (int i=0; i<this.nbOfNodes; i++) {

      // float theta = incTheta * i;//random(TWO_PI);
      // float sinRadius = sin(theta * 2) * 0.5 + 0.5;
      // float variationRadius = (maxRadius * 0.5) *  sinRadius;
      //float radius = random(variationRadius + maxRadius * 0.1, maxRadius);
      //float radius = random(maxRadius * 0.25, maxRadius * 0.5 + variationRadius);
      // float radius = random(variationRadius + maxRadius * 0.25, variationRadius + maxRadius * 0.25 * 2);

      // float radius = random(10, maxRadius);
      //float radius = random(maxRadius * 0.5, maxRadius);
      // float x = cos(theta) * radius + width * 0.5;
      //float y = sin(theta) * radius + height * 0.5;
      /* 
       //define x;y along distance
       float dist = dist(x, y, width*0.5, height*0.5);
       float d = cos(floor(0.5 + theta/incRadius) * incRadius - theta) * dist;
       //d = (d >= width * 0.15) ? 0.0 : 1.0;
       d /= maxRadius;
       d = 1.0 - d;
       x = cos(theta) * radius * d + width * 0.5;    
       y = sin(theta) * radius * d + height * 0.5;
       */
      float x = random(margin, width-margin);
      float y = random(margin, height-margin);


      /*
    float randomX = random(1.0);
       float randomY = random(1.0);
       
       if (randomY < 0.25) {
       x = random(100, 300);
       y = random(100, height-100);
       } else if (randomY > 0.75) {
       x = random(width - 300, width - 100.00);
       y = random(100, height-100);
       } else {
       x = random(100, width - 300);
       if (randomX < 0.5) {
       y = random(100, 300);
       } else {
       y = random(width - 300, height-100);
       }
       }
       */
      /*  float x = random(width);
       float y = random(height);*/

      PVector position = new PVector(x, y);
      nodeList.add(new Node(position));
    }

    for (int i=0; i<this.nbOfFractureNode; i++) {
      float x = random(margin, width-margin);
      float y = random(margin, height-margin);

      PVector position = new PVector(x, y);
      fractureNodeList.add(new Node(position));
    }
  }

  void initRoot() {
    branchList.clear();
    //root
    float radius = 0.0;//random(maxRadius * 0.5);//maxRadius;//
    float theta = random(TWO_PI);
    float x = cos(theta) * radius + width * 0.5;
    float y = sin(theta) * radius + height * 0.5;
    root = new Branch(null, new PVector(x, y), new PVector(random(-1, 1), random(-1, 1)), 5);

    //branches
    branchList.add(root);
    current = root;

    while (!found) {
      // check if any growthing point are close to the branch
      for (Node node : nodeList) {
        float d = PVector.dist(current.position, node.position);
        if (d < maxDist) {
          found = true;
        }
      }

      //if not create a new branch following the parent direction
      if (!found) {
        Branch next = current.next();
        current = next;
        branchList.add(current);
      }
    }
  }

  void grow() { 

    for (Node node : nodeList) {
      //mind dist variation on distance
      float noise = noise(node.position.x * 0.1, node.position.y * 0.1) * 2.0 - 1.0;
      float rd = PVector.dist(node.position, root.position);
      float nd = rd / maxRadius;
      float nminDist = minDist;
      nminDist = map(nd, 0.0, 1.0, oMaxDist, oMinDist);
      nminDist += noise * 4.0;

      Branch closest = null;
      float recordDist = 100000;
      for (Branch branch : branchList) {
        float d = PVector.dist(branch.position, node.position);

        if (d <= nminDist) {
          node.reached = true;
          closest = null;
          break;
        } else if (d > maxDist) {
        } else if (closest == null || d < recordDist) {
          closest = branch;
          recordDist = d;
        }
      }

      if (closest != null) {

        //deviate the direction
        PVector seek = PVector.sub(node.position, closest.position);
        /* 
         //noise test
         float eta = 1.0;
         float culrLen = 20.0;
         float noisex = noise(closest.noised.y * eta, closest.noised.x * eta) * 2.0 - 1.0;
         float noisey = noise(closest.noised.x * eta, closest.noised.y * eta) * 2.0 - 1.0;
         
         closest.noised.x += noisex;
         closest.noised.y += noisey;
         
         closest.noised.normalize();
         closest.noised.mult(culrLen);
         
         seek.add(closest.noised);
         */
        PVector randSeek = PVector.random2D();
        randSeek.mult(nminDist * 0.5);

        seek.add(randSeek);
        seek.normalize();

        closest.direction.add(seek);
        closest.count ++;
      }
    }

    //remove the reached growth node
    Iterator<Node> itNode = nodeList.iterator();
    while (itNode.hasNext()) {
      Node node = itNode.next();
      if (node.reached) {
        itNode.remove();
      }
    }

    //Change branch direction
    for (int i=0; i<branchList.size(); i++) {
      Branch branch = branchList.get(i);
      if (branch.count > 0) {
        //average the direction
        branch.direction.div(branch.count + 1);
        /*
      //create new branch
         PVector nextPosition = PVector.add(branch.position, branch.direction);
         Branch next = new Branch(branch, nextPosition, branch.direction.copy());
         */
        //get the next branch
        branchList.add(branch.next());
      }
      branch.reset();
    }
  }


  void debugPoint(PGraphics b, ArrayList<Node> list, float size) {
    b.noStroke();
    PVector center = new PVector(width * 0.5, height*0.5);
    for (Node node : list) {
      float gamma= atan2(node.position.y - center.y, node.position.x - center.x) + PI;

      b.fill(gamma, 1.0, 1.0);
      b.ellipse(node.position.x, node.position.y, size, size);
    }
  }


  void debugBranch(PGraphics b, ArrayList<Branch> list) {
    b.strokeWeight(2);
    b.strokeCap(ROUND);
    randomSeed(1000);
    int i=0;
    for (Branch branch : list) {
      float normIndex = float(i) / float(list.size());
      
      float fminDist = sqrt(b.width * b.width + b.height * b.height);
      for (Node node : fractureNodeList) {
        float d = PVector.dist(branch.position, node.position);
        if (d < fminDist) {
          fminDist = d;
        }
      }

      if (branch.parent != null) {
        float noise = noise(branch.position.x * 0.025, branch.position.y * 0.025);
        if (fminDist > noise * minDist * 2.0) {
          b.strokeWeight(noise * 3);
          b.stroke(0, 0.0, 1.0);
          b.line(branch.parent.position.x, branch.parent.position.y, branch.position.x, branch.position.y);
        }
      }
      i++;
    }
  }

  void exportSVG(String name, int w, int h) {
    String exportName = name+".svg";
    PGraphics pg = createGraphics(w, h, SVG, exportName);
    pg.beginDraw();
    pg.strokeWeight(2);
    pg.strokeCap(ROUND);
    randomSeed(1000);
    int i=0;
    for (Branch branch : branchList) {
      float normIndex = float(i) / float(branchList.size());
      float fminDist = sqrt(pg.width * pg.width + pg.height * pg.height);
      for (Node node : fractureNodeList) {
        float d = PVector.dist(branch.position, node.position);
        if (d < fminDist) {
          fminDist = d;
        }
      }

      if (branch.parent != null) {
        float noise = noise(branch.position.x * 0.025, branch.position.y * 0.025);
        if (fminDist > noise * minDist * 2.0) {
          pg.strokeWeight(noise * 3);
          pg.stroke(0, 0.0, 1.0);
          pg.beginShape(LINES);
          pg.vertex(branch.parent.position.x, branch.parent.position.y);
          pg.vertex(branch.position.x, branch.position.y);
          pg.endShape();
        }
      }
      i++;
    }
    pg.endDraw();
    pg.dispose();
    println(" saved.");
  }
}

//fractureNodeList
