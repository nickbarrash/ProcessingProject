class DetectedRectangle{
  
/*  
 *
 *     C _____ D
 *      /     \
 *     /_______\
 *   A           B
 */
  pt2d picA, picB, picC, picD;
  
  int trackPts = 0;
  pt[] tracks = new pt[20];
  
  // edge 1 is parallel to AB
  // edge 2 is parallel to AC
//  vec rectEdge1, rectEdge2;
  vec normalVec;
  
  // angles
  float pitch, roll, yaw;
  
  // same as pic
  pt worldA=P(); pt worldB=P(); pt worldC=P(); pt worldD=P();
  // 3d points of rectangle
  pt derivedA=P();  pt derivedB=P();  pt derivedC=P();  pt derivedD=P();
  
  // camera focal length
  float focalLen;
  
  DetectedRectangle(pt2d pA, pt2d pB, pt2d pC, pt2d pD, float focal){
    float[] angles = solveAngles(pA.x, pA.y, pB.x, pB.y, pC.x, pC.y, pD.x, pD.y, focal);
    pitch = angles[0];
    roll = angles[1];
    yaw = angles[2];    
    // orient rect edge vectors
    normalVec = V(P(0,0,0), quatTransform(P(0,1,0), yaw, pitch, roll));
    normalVec = U(normalVec);
  }  

  void drawWorldRect(){
  //  pt A = P(0,0,-300);
    //pt B = P(P(0,0,-300), worldRect.rectEdge1);
    //pt C = P(P(0,0,-300), worldRect.rectEdge2);
    //pt D = P(P(P(0,0,-300),worldRect.rectEdge1),worldRect.rectEdge2);  
  //  drawRectangle(A,B,C,D);
    
  }
  
  void drawWorldRectZero(){
    calcDerived();
    //System.out.print("A: "); tmpA.str();
    //System.out.print("B: "); tmpB.str();
    //System.out.print("C: "); tmpC.str();    
    
    drawRectangle(derivedA,derivedB,derivedC,derivedD);
   
   if(showRect){
    //show(P(), V(300,normalVec)); 
 
     //draw image rays
     stroke(cyan); fill(cyan);
     show(f, worldA);   
     show(f, worldB);
     show(f, worldC);
     show(f, worldD);  
     stroke(orange); fill(orange);
     show(f, derivedA);   
     show(f, derivedB);
     show(f, derivedC);
     show(f, derivedD);     
   }
  }
  
  void drawTrackZero(){
    for(int index = 0; index < trackPts; index++){ 
    }
  }
  
  void calcDerived(){
    pt tmpA = worldA;                               derivedA = tmpA;
    pt tmpB = planeIntersect(V(f, worldB), tmpA);   derivedB = tmpB;
    pt tmpC = planeIntersect(V(f, worldC), tmpA);   derivedC = tmpC;
    pt tmpD = planeIntersect(V(f, worldD), tmpA);   derivedD = tmpD;    
  }
  
  void updateRect(pt A, pt B, pt C, pt D){
    worldA = A; worldB = B; worldC = C; worldD = D;
    calcDerived();    
  }
  
  pt planeIntersect(vec ray, pt A){
    //3d space focal point
    ray = U(ray);
    float t = d(V(f, A), normalVec) / d(ray, normalVec);
   // System.out.println("   " + d(V(f, A), normalVec) + ", " + d(ray, normalVec) + ", " + t);
    return P(f, V(t, ray));
  }
  
  void addPoint(pt A){
    if(trackPts < 20){
      tracks[trackPts] = A;
      trackPts++;
    } else {
      tracks[19] = A;
    }
  }
 
  void printWorldPointPosition(pt A){
    // 
    vec rectPos = V(derivedA, planeIntersect(V(f, A), derivedA));
    // unit rectangle sides for dot product
    vec unitAB = U(V(derivedA, derivedB));
    vec unitAC = U(V(derivedA, derivedC));
    // distance down side AB and side AC
    float ABdist = d(unitAB, rectPos)/ n(V(derivedA, derivedB));
    float ACdist = d(unitAC, rectPos)/ n(V(derivedA, derivedC));    
    // coordinates in terms of rectangle sides (t * AB being 1 and U * AC being 1)
    System.out.println("Rectangle Coordinates: (" + ABdist + "," + ACdist + ")"); 
    // 3D point on the rectangle plane correspondin to the clicked 'P'    
    pt newA = P(P(derivedA, V(ABdist,V(derivedA, derivedB))),V(ACdist, V(derivedA, derivedC)));
    //pt newA =  planeIntersect(V(f, A), derivedA);    
    pt projPt = P(f, helpIs(newA));    
    System.out.println("New: (" + projPt.x + ", " + projPt.y + ") / Old: (" + A.x + ", " + A.y + ")");
  }
  
}

/////////////////////////////////////////////
// 
//  RECTANGLE FUNCTIONS
//
/////////////////////////////////////////////

pt[] sharpenRect(pt A, pt B, pt C, pt D){
  float a = n(V(A, B));
  float b = n(V(A, C));
  B = P(A, V(100.0/a, V(A,B)));
  C = P(A, V(200.0/b, V(A,C)));  
  D = P(P(A, V(A,B)), V(A,C));
  return new pt[] {A,B,C,D};
}

vec[] orthoNormalBasis(pt A, pt B, pt C, pt D, int iterations){
  vec AB = V(A,B);
  vec AC = V(A,C);
  AB = U(AB);
  AC = U(AC);  
  vec n = N(AB,AC);
  n = U(n);    
  
  // normalize iterations
  for(int i = 0; i < iterations; i++){
    vec[] basis = iterateBasis(AB, AC, n);
    AB = basis[0]; AC = basis[1]; n = basis[2];
    float a = d(AB, AC);
    float b = d(n, AB);
    float c = d(n, AC);  
    //float c = d(V(B, D));
    //System.out.println("dot AB/AC: " + a + ", dot n/AB " + b + " dot n/AC " + c);    
  }
  
  isRectangle(A,B,C,D);
  return new vec[] {AB,AC,n};
}
//dot AB/AC: 4.4703484E-8, dot n/AB 4.4703484E-8
//2.4414062E-4 0.0012207031
vec[] iterateBasis(vec T, vec U, vec V){
  vec Vp = N(T,U);
  vec Up = N(T,V);
  vec Tp = N(U,V);  
  Tp = U(Tp); Up = U(Up); Vp = U(Vp);    
  return new vec[] {Tp,Up,Vp};
}

vec normalizeVec(vec a, vec b){
  vec nb = V();
  float magnitudeB = n(b);
  nb = M(b, V(d(a,b)/d(a,a), a));  
  nb = V(magnitudeB/n(nb), nb);
  return nb;
}

boolean isRectangle(pt a, pt b, pt c, pt d){
  //System.out.println("d(ab,ac): " + d(V(a,b), V(a,c)) + ", d(db,dc): " + d(V(d,b), V(d,c)));
  if(d(V(a,b), V(a,c)) < 0.001 && d(V(d,b), V(d,c)) < 0.001){
    return true;
  }
  return false;
}

/*
 *  A
 *  |
 *  |____ 
 * B      C
 */
float getAngle(pt a, pt b, pt c){
  vec BA = V(b, a);
  vec BC = V(b, c);
  System.out.print("A: "); a.str();
  System.out.print("B: "); b.str();
  System.out.print("C: "); c.str();  
  return getAngle(BA,BC);
}

float getAngle(vec a, vec b){
  return acos(d(a,b)/(n(a)*n(b)) );  
}
