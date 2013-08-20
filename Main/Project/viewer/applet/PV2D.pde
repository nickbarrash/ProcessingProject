//*****************************************************************************
// TITLE:         GEOMETRY UTILITIES OF THE GSB TEMPLATE  
// DESCRIpt2dION:   Classes and functions for manipulating points, vec2dtors, and frames in the Geometry SandBox Geometry (GSB)  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  Sept2dember 2009
// EDITS:         Simplified July 2012
//*****************************************************************************

//************************************************************************
//**** Functions
//************************************************************************

// P: create or copy vec2dtors and points 
vec2d V2D(vec2d V) {return new vec2d(V.x,V.y); };                                                             // make copy of vec2dtor V
vec2d V2D(vec2d U,vec2d V) {return new vec2d(U.x+V.x,U.y+V.y); };                                               // make copy of vec2dtor V
vec2d V2D(float x, float y) {return new vec2d(x,y); };                                                      // make vec2dtor (x,y)
vec2d V2D(pt2d P, pt2d Q) {return new vec2d(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vec2dtor Q-P from P to Q
vec2d U(vec2d V) {float n = n(V); if (n==0) return new vec2d(0,0); else return new vec2d(V.x/n,V.y/n);};      // V/||V|| (Unit vec2dtor : normalized version of V)
vec2d V2D(float s,vec2d V) {return new vec2d(s*V.x,s*V.y);};                                                  // sV

pt2d P2D() {return P2D(0,0); };                                                                            // make point (0,0)
pt2d P2D(float x, float y) {return new pt2d(x,y); };                                                       // make point (x,y)
pt2d P2D(pt2d P) {return P2D(P.x,P.y); };                                                                    // make copy of point A
pt2d P2D(float s, pt2d A) {return new pt2d(s*A.x,s*A.y); };                                                  // sA
pt2d P2D(pt2d P, vec2d V) {return P2D(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vec2dtor V)
pt2d P2D(pt2d P, float s, vec2d V) {return P2D(P,V2D(s,V)); }                                                    //  P+sV (P transalted by sV)
pt2d P2D(pt2d A, float s, pt2d B) {return P2D(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y)); };                             // A+sAB
pt2d P2D(pt2d A, pt2d B) {return P2D((A.x+B.x)/2,(A.y+B.y)/2); };                                              // (A+B)/2
pt   to3D(pt2d A){return P(A.x, A.y, 0);}
pt2d P2D(pt A){return P2D(A.x, A.y);}
  
  
// ----------------- <MY CODE>

pt2d H(pt2d A, pt2d B, pt2d C) {          //gets the point at t = 1/2 (A = 0, B = 1, C = 2)
    pt2d P=P2D(A,1.5,B); 
    pt2d Q=P2D(B,1.5-1.0,C); 
    return P2D(P,1.5/2.0,Q);
}

// four point subdivision
pt2d P2D(pt2d A, pt2d B, pt2d C, pt2d D){
  return P2D(H(A,B,C), H(D,C,B));
}

// ----------------- </MY CODE>

// show points, edges, triangles, and quads
void show(pt2d P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                              // draws circle of center r around P
void show(pt2d P) {ellipse(P.x, P.y, 6,6);};                                                            // draws small circle around point
void show(pt2d P, pt2d Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
void v(pt2d P) {vertex(P.x,P.y);};                                                                      // vertex for drawing polygons between beginShape() and endShape()
void label(pt2d P, String S) {text(S, P.x-4,P.y+6.5); }                                                 // writes string S next to P on the screen ( for example label(P[i],str(i));)
void label(pt2d P, vec2d V, String S) {text(S, P.x-3.5+V.x,P.y+7+V.y); }                                  // writes string S at P+V

// Input points: mouse & canvas 
pt2d Mouse2D() {return P2D(mouseX,mouseY);};                                                                 // returns point at current mouse location
pt2d Pmouse2D() {return P2D(pmouseX,pmouseY);};                                                              // returns point at previous mouse location
pt2d ScreenCenter() {return P2D(width/2,height/2);}                                                        //  point in center of  canvas
void drag(pt2d P) { P.x+=mouseX-pmouseX; P.y+=mouseY-pmouseY; }                                          // adjusts P by mouse drag vec2dtor

// <MY CODE>

vec2d R(vec2d U){
  return new vec2d(U.y * -1, U.x);
}

/**
* rotate 
*/
vec2d R(vec2d U, double angle){
  float d = n(U);
  vec2d rot = new vec2d(new Double(Math.cos(angle)).floatValue(), new Double(Math.sin(angle)).floatValue() );
  return V2D(d, rot);
 }

float dotP2D(vec2d U, vec2d V){
  return U.x * V.x + U.y * V.y;
}

float crossP2D(vec2d U, vec2d V){
  return U.x * V.y * -1.0 + U.y * V.x;
}

float X(pt2d A, pt2d B, pt2d P){
  vec2d AB = V2D(A, B);
  vec2d AP = V2D(A, P);
  return crossP2D(AP, AB) / (n(AB) * n(AB));
}

float Y(pt2d A, pt2d B, pt2d P){
  vec2d AB = V2D(A, B);
  vec2d AP = V2D(A, P);
  return dotP2D(AP, AB) / (n(AB) * n(AB));
}

pt2d T(pt2d A, pt2d B, pt2d P, pt2d S, pt2d E){
  vec2d SE = V2D(S, E);
  float x = X(A, B, P);
  float y = Y(A, B, P);
  return P2D( P2D(S, y, SE), x, R(SE)); 
}

// </MY CODE>

// measure points (equality, distance)
float n(vec2d V) {return sqrt(sq(V.x)+sq(V.y));};                                                       // n(V): ||V|| (norm: length of V)
float d(pt2d P, pt2d Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| (Distance)
float d2(pt2d P, pt2d Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

//************************************************************************
//****  CLASSES
//************************************************************************
// points
class pt2d { float x=0,y=0; 
  pt2d (float px, float py) {x = px; y = py;};
  pt2d (pt2d P) {x = P.x; y = P.y;};
  pt2d setTo(float px, float py) {x = px; y = py; return this;};  
  pt2d setTo(pt2d P) {x = P.x; y = P.y; return this;}; 
  pt2d moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY;  return this;}; 
  pt2d translateTowards(float s, pt2d P) {x+=s*(P.x-x);  y+=s*(P.y-y);  return this;};    
  pt2d add(float u, float v) {x += u; y += v; return this;}                       
  pt2d add(pt2d P) {x += P.x; y += P.y; return this;};        
  pt2d add(float s, pt2d P)   {x += s*P.x; y += s*P.y; return this;};   
  pt2d add(vec2d V) {x += V.x; y += V.y; return this;}                              
  pt2d add(float s, vec2d V) {x += s*V.x; y += s*V.y; return this;}                 
  pt2d show() {ellipse(x,y,3,3); return this;}                 
  pt2d v() {vertex(x,y); return this;}                 
  } // end of pt2d class

// vec2dtors
class vec2d { float x=0,y=0; 
  vec2d (float px, float py) {x = px; y = py;};
   } // end vec2d class
 


