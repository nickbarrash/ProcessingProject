import processing.core.*; 
import processing.xml.*; 

import processing.opengl.*; 
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class viewer extends PApplet {

                // load OpenGL libraries and utilities
 
 

GL gl; 
GLU glu; 

// ****************************** GLOBAL VARIABLEyeS FOR DISPLAY OPTIONS *********************************
int height=800, width=800;

int ERROR_MODE = 1;

Boolean showHelpText = false,
        showGraph    = true,
        showValueText = true,
        showDrawing = true,
        showRect     = true, 
        showPicture = false,
        showGuess = true;
        
Boolean moveBP = false;        
        
PImage picture;
        
pt2d[] imgPoints = {P2D(0,0),P2D(0,0),P2D(0,0),P2D(0,0)};     
/*
 * 0 - show picture and pick corners and "path"
 * 1 - show path
 *
 */
int viewMode = 1;
int updates = 0;
float focalLen = 1000;  
//DetectedRectangle worldRect = new DetectedRectangle(imgPoints[0],imgPoints[1],imgPoints[2],imgPoints[3], focalLen);

vec testV = V(0,0,0);

pt mousepick = P();

// ****************************** VIEW PARAMETERS *******************************************************
pt F = P(0,0,0); pt T = P(0,0,0); pt E = P(0,0,1000); vec U=V(0,1,0); float sampleDistance=1; pt sE = P(), sF = P(); vec sU=V(); //  view parameters (saved with 'j'  // focus  set with mouse when pressing ';', eye, and up vector
pt Q=P(0,0,0); vec I=V(1,0,0); vec J=V(0,1,0); vec K=V(0,0,1); // picked surface point Q and screen aligned vectors {I,J,K} set when picked
public void initViewZ() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1000); U=V(0,1,0); } // declares the local frames
public void initViewY() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,1000,0); U=V(0,0,1); } // declares the local frames
public void initViewX() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(1000,0,0); U=V(0,1,0); } // declares the local frames
// ******************************************************************************************************************* 

  
  //focal point and a point on the image plane
  pt f = P(0,0,focalLen);  pt img = P();
  
  //rectangle intersections with image plane
  pt Ai = P(), Bi = P(), Ci = P(), Di = P();
  
  // rectangle defined by point Ax and side vectors Ix, Jx
  pt Ax = P(); vec Ix = V(400,0,0); vec Jx = V(0,400,0);  

  // uses above rectangle definition to define real 3d rectangle coordinates
  pt Ar = P(), Br = P(), Cr = P(), Dr = P();
  
  // A' B' C' D' (calculated rectangle point)   
  pt Ap = P(), Bp = P(), Cp = P(), Dp = P();
     
  // Guesses
  pt Ag = P(), Bg = P(), Cg = P(), Dg = P(), Gg = P();
     
  // Guesses (used for graph)   
  pt Agp = P(), Bgp = P(), Cgp = P(), Dgp = P();     
     
  // Points to show guess dots when placing trapezoid corners   
  pt2d ag = P2D(), bg = P2D(), cg = P2D(), dg = P2D(),
       gg = P2D();  //<- dot for "rectangle plane coordinates" point
       
  // a' b' c' d' or the distances from focal point to B' realative to focal point to Bi     
  float ap = 1, bpP = 1.2f, cp = 0, dp = 0; 
  
  // a' b' c' d' or the distances from focal point to B' realative to focal point to Bi used by graph variables    
  float agp = 1, bgP = 1.2f, cgp = 0, dgp = 0;
  
  // scales one of the sides of the trapezoid
  float trapScale = 1;
   
  // best guesses for b' value 
  float minB = -1;   float minG = -1;
  
  // sampling variables
  int resamples = 3;
  float smpStart = 0.5f;
  float smpEnd = 1.5f;     
  int samples  = 500;
     
  pt Gproj=P();










public void setup() {
  size(800, 800, OPENGL); //  size(800, 800, P3D);    
  setColors(); sphereDetail(6);  PFont font = loadFont("GillSans-24.vlw"); textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  gl = pgl.beginGL();  pgl.endGL();
  initViewZ(); // declares the local frames for 3D GUI
  // ***************** Set view
  F=P(); E=P(0,0,500);
  initViewZ();

  // ------------------------------------------------------------------------------
  // LOAD IMAGE
  //  picture = loadImage("data/roomPic.JPG"); 
  //  picture = loadImage("data/tennis.jpg");   
  //  picture = loadImage("data/table1.jpgP");   
  picture = loadImage("data/table2.JPG"); 
  //  picture = loadImage("data/checkers.jpg");   

  // -------------------------------------------------------------------------------
  // CALCULAGE INITIAL VALUES
  calcArs();
  calcIs();
  calcPPrimes(1.0f);
}
  
  
  
  
  
  
  
  
  
   
public void draw() {  
  
  background(white);
  // -------------------------------------------------------- IMAGE STUFF ----------------------------------
    if(showPicture){
      image(picture, 0,0, picture.width*width/picture.width,picture.height * width/picture.width); 
      stroke(red); fill(blue);    show(ag, 5); stroke(blue); fill(blue);   show(bg, 5);
      stroke(green); fill(blue);  show(cg, 5); stroke(yellow); fill(blue); show(dg, 5);      
      stroke(black); fill(blue);  show(gg, 5);            
    }
     
  // -------------------------------------------------------- Help ----------------------------------
  if(showHelpText) {
    camera(); // 2D display to show cutout
    lights();
    fill(black); writeHelp();
    return;
    }
    
  // -------------------------------------------------------- Setup 3d ----------------------------------
  camera(E.x, E.y, E.z, F.x, F.y, F.z, U.x, U.y, U.z); // defines the view : eye, ctr, up
  vec Li=U(A(V(E,F),0.1f*d(E,F),J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
  directionalLight(255,255,255,Li.x,Li.y,Li.z); // direction of light: behind and above the viewer
  specular(255,255,0); shininess(5);
 
  // --------------------------------------------------------- DRAW 3D ---------------------------------------------------
  // draw image plane rectangle
  fill(black, 80); stroke(black); drawRectangle(P(-2000,-2000,0),P(-2000,2000,0),P(2000,-2000,0),P(2000,2000,0));  
  
  if(showDrawing){
    // draw real 3D rectangle
    fill(grey); stroke(yellow); drawRectangle(Ar,Br,Cr,Dr);        
    // draw actual points, image points and guess points and the line that passes through all of them
    fill(dred); stroke(dred);       show(f, Ar); show(f, Ai); show(f, Ap); show(Ap, 10); show(Ap, "A'", V(10,10,0));
    fill(dblue); stroke(dblue);     show(f, Br); show(f, Bi); show(f, Bp); show(Bp, 10); show(Bp, "B'", V(10,10,0));
    fill(dgreen); stroke(dgreen);   show(f, Cr); show(f, Ci); show(f, Cp); show(Cr, 10); show(Cp, "C'", V(10,10,0));
    fill(dyellow); stroke(dyellow); show(f, Dr); show(f, Di); show(f, Dp); show(Dp, 10); show(Dp, "D'", V(10,10,0));       
    // draw actual rectangle points
    fill(magenta); stroke(magenta); show(Ar, 10); show(Ar, "A", V(-30,-15,0)); show(Br, 10); show(Br, "B", V(15,-15,0));  show(Cr, 10); show(Cr, "C", V(-30,15,0)); show(Dr, 10); show(Dr, "D", V(15,15,0));         
    // draw rectangle corner projections on image plane 
    fill(black); stroke(black); show(Ai, 10); show(Bi, 10); show(Ci, 10); show(Di, 10);   
    // draw guess rectangle for real rectangle
    fill(cyan); stroke(cyan); drawRectangle(Ap,Bp,Cp,Dp);
  }
   
  // handles guessing and dragging guess rectangles
  if(keyPressed){
    if(key=='1') {Ag = P(f,helpIs(Pick())); ag = new pt2d(mouseX,mouseY); updateGs();}
    if(key=='2') {Bg = P(f,helpIs(Pick())); bg = new pt2d(mouseX,mouseY); updateGs();} 
    if(key=='3') {Cg = P(f,helpIs(Pick())); cg = new pt2d(mouseX,mouseY); updateGs();} 
    if(key=='4') {Dg = P(f,helpIs(Pick())); dg = new pt2d(mouseX,mouseY); updateGs();}  
    if(key=='5') {Gg = P(f,helpIs(Pick())); gg = new pt2d(mouseX,mouseY); calcGProj();} 
    if(key=='6') {printRectCoords();}    
    if(key=='m'){ bpP+=(float)(mouseX-pmouseX)/ (float)width; calcPPrimes(bpP); }
    if(key=='n'){ bgP+=(float)(mouseX-pmouseX)/ (float)width; calcGPrimes(bgP); }   
    if(key=='t'){ trapScale +=(float)(mouseX-pmouseX)/ (float)width; calcArs(); }       
  }   
  
  if(showGuess){
    // show 3D guess points
    fill(white); stroke(orange); drawRectangle(Ag,Bg,Cg,Dg);        
    stroke(orange); fill(orange); show(Ag, 10); show(Bg, 10); show(Cg, 10); show(Dg, 10); show(Gproj,10);      
    // show rectangle formed by guess on 3D guess points
    fill(magenta); stroke(magenta); drawRectangle(Agp,Bgp,Cgp,Dgp);        
    // if picture isnt showing show orange ball on mouse cursor
    if(!showPicture){ fill(orange); stroke(orange); mousepick = Pick(); show(mousepick, 10); }  
  }  
  
  // -------------------------------------------------------- graphic picking on surface and view control ----------------------------------   
  SetFrame(Q,I,J,K);  // showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
  // rotate view 
  if(!keyPressed&&mousePressed) {E=R(E,  PI*PApplet.parseFloat(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*PApplet.parseFloat(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
  if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-PApplet.parseFloat(mouseY-pmouseY),K); }  //   Moves E forward/backward
  if(keyPressed&&key=='t'){vec2d movePt = V2D(curMouse, new pt2d(mouseX,mouseY));}
  
  // -------------------------------------------------------- Disable z-buffer to display occluded silhouettes and other things ---------------------------------- 
  hint(DISABLE_DEPTH_TEST);  // show on top
  strokeWeight(2); stroke(red);
  camera(); // 2D view to write help text  
  hint(ENABLE_DEPTH_TEST); // show silouettes

  // -------------------------------------------------------- SNAP PICTURE ---------------------------------- 
  if(snapping) snapPicture(); // does not work for a large screen
  pressed=false;

  // -------------------------------------------------------- DRAW PICTURE OVER EVERYTHING ------------------------------------
  
  // ON SCREEN TEXT
  fill(dbrown); stroke(dbrown);
  if(showValueText){
  scribeHeader((((-1.0f*n2(V(Ap,Bp))+n2(V(Cp,Dp)))/n2(V(Ap,Bp)))*100) + 
  "\nAB:" + (int)n2(V(Ap,Bp)) + 
  "\nCD:" + (int)n2(V(Cp,Dp)) + 
  "\nguess b: " + bpP+ 
  "\nactual b: " + n(V(f,Br))/n(V(f,Bi)) + 
  "\nsample search b: " + minB + 
  "\ntrapezoid scale: " + trapScale +   
  "\n A-red, B-blue, C-green, D-Yellow");      
  }
  
  // DRAW GRAPH
  if(showGraph){
    drawGraph();
  }
}
 
 
 
 
 
 
 
 
 
 

Boolean pressed=false, released = true;
pt2d curMouse = new pt2d(mouseX,mouseY);
vec tmpVec = V(); // vector used to keep track of how far the mouse has dragged the real rectange points when it's being edited
boolean changeVec = false; // change vector is being drawn
float bptmp = bpP;
boolean pre = false;
float dis = 0;

public void mousePressed() {
  curMouse = new pt2d(mouseX,mouseY);
}
  
public void mouseDragged() {
}

public void mouseReleased() {
    U.set(M(J)); // reset camera up vector
    pressed = false;
  }
  
public void keyReleased() {
   released = true;
   if(key==' ') F=P(T);
   U.set(M(J)); // reset camera up vector
   pre = false;
   if(changeVec) changeVec = false; 
   }

public void keyPressed() {
  if(key=='a') {}
  if(key=='b') {}
  if(key=='d') {printGridError(5,5,1,1);} 
  if(key=='e') {writeExactCheckersError(5,5,1,1);}
  if(key=='f') {showValueText = !showValueText;}
  if(key=='g') {showGraph = !showGraph;}
  if(key=='h') {showDrawing = !showDrawing;}
  if(key=='i') {initViewX();}  // snap view to specific profile
  if(key=='j') {initViewY();}  // snap view to specific profile
  if(key=='k') {initViewZ();}  // snap view to specific profile
  if(key=='l') {}
  if(key=='m') {}
  if(key=='n') {}
  if(key=='o') {}
  if(key=='p') {}
  if(key=='q') {}
  if(key=='r') {writePerturbError(5, 5, 1, 1, 100, 5);}
  if(key=='s') {}
  if(key=='t') {}//trapezoid change 
  if(key=='u') {bpP = minB;}  // snap guess rectangle to "best" value
  if(key=='w') {}
  if(key=='y') {}
  
  if(key=='v') {moveVecJxz(); calcArs();}  // drag real rectangle vertex
  if(key=='c') {moveVecJxy(); calcArs();}  // drag real rectangle vertex
  if(key=='x') {moveVecIxz(); calcArs(); } // drag real rectangle vertex
  if(key=='z') {moveVecIxy(); calcArs(); } // drag real rectangle vertex
   
  if(key=='A') {}
  if(key=='B') {}
  if(key=='C') {}
  if(key=='D') {}
  if(key=='E') {}
  if(key=='F') {}
  if(key=='G') {showGuess = !showGuess;}
  if(key=='H') {}
  if(key=='I') {}
  if(key=='J') {}
  if(key=='K') {}
  if(key=='L') {}
  if(key=='M') {}
  if(key=='N') {}
  if(key=='O') {}
  if(key=='P') {showPicture = !showPicture;}
  if(key=='Q') {exit();}
  if(key=='R') {}
  if(key=='S') {calcMinG(smpStart, smpEnd, samples, resamples); calcGPrimes(minG); bgP = minG;}
  if(key=='T') {}
  if(key=='U') {}
  if(key=='V') {} 
  if(key=='W') {}
  if(key=='X') {}
  if(key=='Y') {}
  if(key=='Z') {}

  if(key=='~') {}
  if(key=='!') {snapping=true;}
  if(key=='@') {}
  if(key=='#') {}
  if(key=='$') {}
  if(key=='%') {}
  if(key=='&') {}
  if(key=='*') {sampleDistance*=2;}
  if(key=='(') {}
  if(key==')') {}
  if(key=='_') {}
  if(key=='+') {}
  if(key=='{') {}
  if(key=='}') {}
  if(key=='|') {}
  if(key=='[') {}
  if(key==']') {}
  if(key==':') {}
  if(key==';') {}
  if(key=='<') {}
  if(key=='>') {}
  if(key=='?') {showHelpText=!showHelpText;}
  if(key=='.') {}
  if(key==',') {}
  if(key=='^') {} 
  if(key=='/') {} 

  if(key=='~') {}  
  if(key=='`') {}  
  if(key=='1') {switchErrorMode();}  // switch to error mode
  if(key=='2') {} 
  if(key=='3') {} 
  if(key=='4') {} 
  if(key=='5') {}
  if(key=='6') {} 
  if(key=='7') {} 
  if(key=='8') {} 
  if(key=='9') {}     
  if(key=='0') {}
  if(key=='-') {}
  if(key=='=') {}  
}
  
// PROGRAM STATES
// ERROR_MODE
public void switchErrorMode(){
  showGraph   = false;
  showDrawing = true;
  showPicture = false;
  showGuess   = false;
}
  
  
// MOVE ACTUAL RECTANGLE IN 3D STUFF
public void moveVecIxy(){
  if(!changeVec){changeVec = true; tmpVec = Ix; curMouse = new pt2d(mouseX,mouseY);}
  Ix = A(tmpVec, V(mouseX-curMouse.x, mouseY-curMouse.y, 0));  Jx = normalizeVec(Ix, Jx);
}
public void moveVecIxz(){
  if(!changeVec){changeVec = true; tmpVec = Ix; curMouse = new pt2d(mouseX,mouseY);}
  Ix = A(tmpVec, V(mouseX-curMouse.x, 0, mouseY-curMouse.y));  Jx = normalizeVec(Ix, Jx);
}
public void moveVecJxy(){
  if(!changeVec){changeVec = true; tmpVec = Jx; curMouse = new pt2d(mouseX,mouseY);}
  Jx = A(tmpVec, V(mouseX-curMouse.x, mouseY-curMouse.y, 0));  Ix = normalizeVec(Jx, Ix);
}
public void moveVecJxz(){
  if(!changeVec){changeVec = true; tmpVec = Jx; curMouse = new pt2d(mouseX,mouseY);}
  Jx = A(tmpVec, V(mouseX-curMouse.x, 0,mouseY-curMouse.y));  Ix = normalizeVec(Jx, Ix);
}

//print out how far from perfectly perpindicular the rectangle is
public void checkRect(){
  System.out.println(d(U(Ix),U(Jx)));
}

  
  
  
  
  
  
// Snapping PICTURES of the screen
PImage myFace; // picture of author's face, read from file pic.jpg in data folder
int pictureCounter=0;
Boolean snapping=false; // used to hide some text whil emaking a picture
public void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); snapping=false;}

 

/*
 * update guesses stuff after the real values change
 */
public void updateGs(){
  calcGPrimes(bgP);
  calcMinG(smpStart, smpEnd, samples, resamples);
}

/*
 * calculate the real values of the rectangle's corners
 * (and update things like the 
 */
public void calcArs(){  
  Ar = Ax;
  Br = P(Ax, Ix);    
  Cr = P(Ax, Jx);  
  Dr = P(Br, V(trapScale,Jx));

  calcIs();  
  calcPPrimes(bpP);
  updates++;
  fill(black); 
  calcMin(smpStart, smpEnd, samples, resamples);
}

/*
 * calculates points on image plane from rectangle
 */
public void calcIs(){
  Ai = P(f, helpIs(Ar));  Bi = P(f, helpIs(Br));  Ci = P(f, helpIs(Cr));  Di = P(f, helpIs(Dr));  
}

/*
 * calculates the projection of any point onto the image plane
 */
public vec helpIs(pt Xr){
  vec dir = V(f,Xr);
  vec nrm = V(0,0,1);
  float t = d(V(f, img), nrm) / d(dir, nrm);
  return V(t, dir);
}

/*
 * calculate the error for the cyan rectangle
 */
public float calcError(){
  return calcErrorLogic(Ap, Bp, Cp, Dp);
}

/*
 * calculate the error for the magenta rectangle
 */
public float calcErrorG(){
  return calcErrorLogic(Agp, Bgp, Cgp, Dgp);
}

/*
 * given rectangle points calculate the difference
 * in side length between AB and CD
 */
public float calcErrorLogic(pt An, pt Bn, pt Cn, pt Dn){
  pt Ct;
  pt Dt;
  Ct = Cn;
  Dt = Dn;
  return abs(n2(V(An,Bn))-n2(V(Ct,Dt)));  
}

/*
 * given an interval (startB, endB) and a sampling
 * interval (points) and the number of times to
 * resample between the minimum values (recurses)
 * find the guess for B' that yields the constructed
 * rectangle or trapezoid with the least amount of error
 * and stores that B' value in minB
 */
public void calcMin(float startB, float endB, int points, int recurses){
  calcMinLogic(startB,endB,points,recurses,false);
}

/*
 * same as above but gets the minimum for the magenta
 * rectangle and it stores the minimum B' in minG
 */
public void calcMinG(float startB, float endB, int points, int recurses){
  calcMinLogic(startB,endB,points,recurses,true);
}

/*
 * actual logic for calculating optimal guess
 */
public void calcMinLogic(float startB, float endB, int points, int recurses, boolean isG){
  float origBp = 0;
  if(isG)
    origBp = bpP;
  else
    origBp = bgP;
  if(recurses > 0){
    float bestB = 0;
    float bestVal = 0;
    boolean first = true;
    float step = (1.0f / (float) points) * (endB - startB);
    for(int x = 0; x < points; x++){
      float tmpB = startB + x*step;
      if(isG)
        calcGPrimes(tmpB);
      else
        calcPPrimes(tmpB); 
      float tmpError = calcError();
      if(first || abs(tmpError) < bestVal){
        bestVal = abs(tmpError);
        bestB = tmpB;
        first = false;
      }
    }
    if(isG)
      minG = bestB;
    else
      minB = bestB;    
    calcMinLogic(bestB - step, bestB + step, points, recurses - 1, isG);
  }
  
  if(isG) {
    bgP=origBp;
    calcPPrimes(bgP);      
  } else {
    bpP=origBp;
    calcPPrimes(bpP);  
  }
}

/*
 * calculates the a' b' c' d' values based on
 * the b' guess (bpnew) and updates the A' B'
 * C' and D' actual points 
 */
public void calcPPrimes(float bpnew){
  ap = 1.0f; float bp = bpnew; cp = 0; dp = 0;
  pt Eye = f;
  Ap = Ai;
  Bp = P(Eye,V(bp,V(Eye,Bi)));
  //      -A'Eye * A'
  // c =  ---------
  //      EyeC * A'Bi
  cp = -1.0f * (d(V(Ap,Eye),V(Bp,Ap))) / d(V(Eye,Ci),V(Bp,Ap));
  Cp = P(Eye,V(cp,V(Eye,Ci)));
  //     B'Eye * AB'
  // d = ---------
  //      EyeD * AB'
  dp = -1.0f * (d(V(Bp,Eye),V(Ap,Bp))) / d(V(Eye,Di),V(Ap,Bp));
  Dp = P(Eye,V(dp,V(Eye,Di)));
}

/*
 * same as above except uses graph variables
 */
public void calcGPrimes(float bpnew){
  //Ai,Bi,Ci,Di,Eye
  agp = 1.0f; float bgp = bpnew; cgp = 0; dgp = 0;
  pt Eye = f;
  Agp = Ag;
  Bgp = P(Eye,V(bgp,V(Eye,Bg)));
  //      -A'Eye * A'
  // c =  ---------
  //      EyeC * A'Bi
  cgp = -1.0f * (d(V(Agp,Eye),V(Bgp,Agp))) / d(V(Eye,Cg),V(Bgp,Agp));
  Cgp = P(Eye,V(cgp,V(Eye,Cg)));
  //     B'Eye * AB'
  // d = ---------
  //      EyeD * AB'
  dgp = -1.0f * (d(V(Bgp,Eye),V(Agp,Bgp))) / d(V(Eye,Dg),V(Agp,Bgp));
  Dgp = P(Eye,V(dgp,V(Eye,Dg)));
  //System.out.println(d(V(Ap,Bp),V(Ap,Cp)) + " " + d(V(Ap,Bp),V(Bp,Dp)));
}

/*
 * calculate the projection of the guess point that is to be
 * converted into rectangle plane coordinates on the rectangle's plane
 */
public void calcGProj(){
  vec pl1 = V(Agp,Bgp);
  vec pl2 = V(Agp,Cgp);  
  vec plN = N(pl1, pl2);
  vec ptVec = V(f, Gg);
  float t = (-1*d(V(Agp,f), plN))/(d(ptVec,plN));
  Gproj = P(f, V(t, ptVec));  
}
//*********************************************************************
//**                      3D geeomtry tools                          **
//**       Jarek Rossignac, October 2010, updates Oct 2011           **   
//**                 (points, vectors, and more)                     **   
//*********************************************************************

// ===== vector class
class vec { float x=0,y=0,z=0; 
   vec () {}; 
   vec (float px, float py, float pz) {x = px; y = py; z = pz;};
   public vec set (float px, float py, float pz) {x = px; y = py; z = pz; return this;}; 
   public vec set (vec V) {x = V.x; y = V.y; z = V.z; return this;}; 
   public vec add(vec V) {x+=V.x; y+=V.y; z+=V.z; return this;};
   public vec add(float s, vec V) {x+=s*V.x; y+=s*V.y; z+=s*V.z; return this;};
   public vec sub(vec V) {x-=V.x; y-=V.y; z-=V.z; return this;};
   public vec mul(float f) {x*=f; y*=f; z*=f; return this;};
   public vec div(float f) {x/=f; y/=f; z/=f; return this;};
   public vec div(int f) {x/=f; y/=f; z/=f; return this;};
   public vec rev() {x=-x; y=-y; z=-z; return this;};
   public float norm() {return(sqrt(sq(x)+sq(y)+sq(z)));}; 
   public vec normalize() {float n=norm(); if (n>0.000001f) {div(n);}; return this;};
   public vec rotate(float a, vec I, vec J) {float x=d(this,I), y=d(this,J); float c=cos(a), s=sin(a); add(x*c-x-y*s,I); add(x*s+y*c-y,J); return this; }; // Rotate by a in plane (I,J)
   } ;
  
// ===== vector functions
public vec V() {return new vec(); };                                                                          // make vector (x,y,z)
public vec V(float x, float y, float z) {return new vec(x,y,z); };                                            // make vector (x,y,z)
public vec V(vec V) {return new vec(V.x,V.y,V.z); };                                                          // make copy of vector V
public vec A(vec A, vec B) {return new vec(A.x+B.x,A.y+B.y,A.z+B.z); };                                       // A+B
public vec A(vec U, float s, vec V) {return V(U.x+s*V.x,U.y+s*V.y,U.z+s*V.z);};                               // U+sV
public vec M(vec U, vec V) {return V(U.x-V.x,U.y-V.y,U.z-V.z);};                                              // U-V
public vec M(vec V) {return V(-V.x,-V.y,-V.z);};                                                              // -V
public vec V(vec A, vec B) {return new vec((A.x+B.x)/2.0f,(A.y+B.y)/2.0f,(A.z+B.z)/2.0f); }                      // (A+B)/2
public vec V(vec A, float s, vec B) {return new vec(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y),A.z+s*(B.z-A.z)); };      // (1-s)A+sB
public vec V(vec A, vec B, vec C) {return new vec((A.x+B.x+C.x)/3.0f,(A.y+B.y+C.y)/3.0f,(A.z+B.z+C.z)/3.0f); };  // (A+B+C)/3
public vec V(vec A, vec B, vec C, vec D) {return V(V(A,B),V(C,D)); };                                         // (A+B+C+D)/4
public vec V(float s, vec A) {return new vec(s*A.x,s*A.y,s*A.z); };                                           // sA
public vec V(float a, vec A, float b, vec B) {return A(V(a,A),V(b,B));}                                       // aA+bB 
public vec V(float a, vec A, float b, vec B, float c, vec C) {return A(V(a,A,b,B),V(c,C));}                   // aA+bB+cC
public vec V(pt P, pt Q) {return new vec(Q.x-P.x,Q.y-P.y,Q.z-P.z);};                                          // PQ
public vec U(vec V) {float n = V.norm(); if (n<0.000001f) return V(0,0,0); else return V(1.f/n,V);};            // V/||V||
public vec U(pt A, pt B) {return U(V(A,B));}
public vec N(vec U, vec V) {return V( U.y*V.z-U.z*V.y, U.z*V.x-U.x*V.z, U.x*V.y-U.y*V.x); };                  // UxV CROSS PRODUCT (normal to both)
public vec N(pt A, pt B, pt C) {return N(V(A,B),V(A,C)); };                                                   // normal to triangle (A,B,C), not normalized (proportional to area)
public vec B(vec U, vec V) {return U(N(N(U,V),U)); }                                                           // (UxV)xV unit normal to U in the plane UV
public vec R(vec V) {return V(-V.y,V.x,V.z);} // rotated 90 degrees in XY plane
public vec R(vec V, float a, vec I, vec J) {float x=d(V,I), y=d(V,J); float c=cos(a), s=sin(a); return A(V,V(x*c-x-y*s,I,x*s+y*c-y,J)); }; // Rotated V by a parallel to plane (I,J)


// ===== point class
class pt { float x=0,y=0,z=0; 
   pt () {}; 
   pt (float px, float py, float pz) {x = px; y = py; z = pz; };
   public pt set (float px, float py, float pz) {x = px; y = py; z = pz; return this;}; 
   public pt set (pt P) {x = P.x; y = P.y; z = P.z; return this;}; 
   public pt add(pt P) {x+=P.x; y+=P.y; z+=P.z; return this;};
   public pt add(vec V) {x+=V.x; y+=V.y; z+=V.z; return this;};
   public pt add(float s, vec V) {x+=s*V.x; y+=s*V.y; z+=s*V.z; return this;};
   public pt add(float dx, float dy, float dz) {x+=dx; y+=dy; z+=dz; return this;};
   public pt sub(pt P) {x-=P.x; y-=P.y; z-=P.z; return this;};
   public pt mul(float f) {x*=f; y*=f; z*=f; return this;};
   public pt mul(float dx, float dy, float dz) {x*=dx; y*=dy; z*=dz; return this;};
   public pt div(float f) {x/=f; y/=f; z/=f; return this;};
   public pt div(int f) {x/=f; y/=f; z/=f; return this;};
   public pt snap(float r) {float f=r/(sqrt(sq(x)+sq(y)+sq(z))); x*=f; y*=f; z*=f; return this;};
//   void projectOnCylinder(pt A, pt B, float r) {pt H = S(A,d(V(A,B),V(A,this))/d(V(A,B),V(A,B)),B); this.setTo(T(H,r,this));}
     public void str(){
       System.out.println("(" + x + "," + y + "," + z + ")");
     }
   }
//  void projectOnCylinder(pt A, pt B, float r) {pt H = S(A,d(V(A,B),V(A,this))/d(V(A,B),V(A,B)),B); this.setTo(T(H,r,this));}   
// =====  point functions
public pt P() {return new pt(); };                                            // point (x,y,z)
public pt P(float x, float y, float z) {return new pt(x,y,z); };                                            // point (x,y,z)
public pt P(pt A) {return new pt(A.x,A.y,A.z); };                                                           // copy of point P
public pt P(pt A, float s, pt B) {return new pt(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y),A.z+s*(B.z-A.z)); };        // A+sAB
public pt P(pt A, pt B) {return P((A.x+B.x)/2.0f,(A.y+B.y)/2.0f,(A.z+B.z)/2.0f); }                             // (A+B)/2
public pt P(pt A, pt B, pt C) {return new pt((A.x+B.x+C.x)/3.0f,(A.y+B.y+C.y)/3.0f,(A.z+B.z+C.z)/3.0f); };     // (A+B+C)/3
public pt P(pt A, pt B, pt C, pt D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4
public pt P(float s, pt A) {return new pt(s*A.x,s*A.y,s*A.z); };                                            // sA
public pt A(pt A, pt B) {return new pt(A.x+B.x,A.y+B.y,A.z+B.z); };                                         // A+B
public pt P(float a, pt A, float b, pt B) {return A(P(a,A),P(b,B));}                                        // aA+bB 
public pt P(float a, pt A, float b, pt B, float c, pt C) {return A(P(a,A),P(b,B,c,C));}                     // aA+bB+cC 
public pt P(float a, pt A, float b, pt B, float c, pt C, float d, pt D){return A(P(a,A,b,B),P(c,C,d,D));}   // aA+bB+cC+dD
public pt P(pt P, vec V) {return new pt(P.x + V.x, P.y + V.y, P.z + V.z); }                                 // P+V
public pt P(pt P, float s, vec V) {return new pt(P.x+s*V.x,P.y+s*V.y,P.z+s*V.z);}                           // P+sV
public pt P(pt O, float x, vec I, float y, vec J) {return P(O.x+x*I.x+y*J.x,O.y+x*I.y+y*J.y,O.z+x*I.z+y*J.z);}  // O+xI+yJ
public pt P(pt O, float x, vec I, float y, vec J, float z, vec K) {return P(O.x+x*I.x+y*J.x+z*K.x,O.y+x*I.y+y*J.y+z*K.y,O.z+x*I.z+y*J.z+z*K.z);}  // O+xI+yJ+kZ
public pt R(pt P, float a, vec I, vec J, pt G) {float x=d(V(G,P),I), y=d(V(G,P),J); float c=cos(a), s=sin(a); return P(P,x*c-x-y*s,I,x*s+y*c-y,J); }; // Rotated P by a around G in plane (I,J)
public void makePts(pt[] C) {for(int i=0; i<C.length; i++) C[i]=P();} // fills array C with points initialized to (0,0,0)
public pt Predict(pt A, pt B, pt C) {return P(B,V(A,C)); };     // B+AC, parallelogram predictor
public void v(pt P) {vertex(P.x,P.y,P.z);} // rendering


// ===== mouse tools
public pt Mouse() {return P(mouseX,mouseY,0);};                                          // current mouse location
public pt Pmouse() {return P(pmouseX,pmouseY,0);};
public vec MouseDrag() {return V(mouseX-pmouseX,mouseY-pmouseY,0);};                     // vector representing recent mouse displacement

// ===== measures
public float d(vec U, vec V) {return U.x*V.x+U.y*V.y+U.z*V.z; };                                            //U*V dot product
public float d(pt P, pt Q) {return sqrt(sq(Q.x-P.x)+sq(Q.y-P.y)+sq(Q.z-P.z)); };                            // ||AB|| distance
public float d2(pt P, pt Q) {return sq(Q.x-P.x)+sq(Q.y-P.y)+sq(Q.z-P.z); };                                 // AB^2 distance squared
public float m(vec U, vec V, vec W) {return d(U,N(V,W)); };                                                 // (UxV)*W  mixed product, determinant
public float m(pt E, pt A, pt B, pt C) {return m(V(E,A),V(E,B),V(E,C));}                                    // det (EA EB EC) is >0 when E sees (A,B,C) clockwise
public float n2(vec V) {return sq(V.x)+sq(V.y)+sq(V.z);};                                                   // V*V    norm squared
public float n(vec V) {return sqrt(n2(V));};                                                                // ||V||  norm
public float area(pt A, pt B, pt C) {return n(N(A,B,C))/2; };                                               // area of triangle 
public float volume(pt A, pt B, pt C, pt D) {return m(V(A,B),V(A,C),V(A,D))/6; };                           // volume of tet 
public boolean parallel (vec U, vec V) {return n(N(U,V))<n(U)*n(V)*0.00001f; }                               // true if U and V are almost parallel
public float angle(vec U, vec V) {return acos(d(U,V)/n(V)/n(U)); };                                         // angle(U,V)
public boolean cw(vec U, vec V, vec W) {return m(U,V,W)>=0; };                                              // (UxV)*W>0  U,V,W are clockwise
public boolean cw(pt A, pt B, pt C, pt D) {return volume(A,B,C,D)>=0; };                                    // tet is oriented so that A sees B, C, D clockwise 

// ===== rotate 

// ===== render
public void normal(vec V) {normal(V.x,V.y,V.z);};                                          // changes normal for smooth shading
public void vertex(pt P) {vertex(P.x,P.y,P.z);};                                           // vertex for shading or drawing
public void vTextured(pt P, float u, float v) {vertex(P.x,P.y,P.z,u,v);};                          // vertex with texture coordinates
public void show(pt P, pt Q) {line(Q.x,Q.y,Q.z,P.x,P.y,P.z); };                       // draws edge (P,Q)
public void show(pt P, vec V) {line(P.x,P.y,P.z,P.x+V.x,P.y+V.y,P.z+V.z); };          // shows edge from P to P+V
public void show(pt P, float d , vec V) {line(P.x,P.y,P.z,P.x+d*V.x,P.y+d*V.y,P.z+d*V.z); }; // shows edge from P to P+dV
public void show(pt A, pt B, pt C) {beginShape(); vertex(A);vertex(B); vertex(C); endShape(CLOSE);};                      // volume of tet 
public void show(pt A, pt B, pt C, pt D) {beginShape(); vertex(A); vertex(B); vertex(C); vertex(D); endShape(CLOSE);};                      // volume of tet 
public void show(pt P, float r) {pushMatrix(); translate(P.x,P.y,P.z); sphere(r); popMatrix();}; // render sphere of radius r and center P
public void show(pt P, float s, vec I, vec J, vec K) {noStroke(); fill(yellow); show(P,5); stroke(red); show(P,s,I); stroke(green); show(P,s,J); stroke(blue); show(P,s,K); }; // render sphere of radius r and center P
public void show(pt P, String s) {text(s, P.x, P.y, P.z); }; // prints string s in 3D at P
public void show(pt P, String s, vec D) {text(s, P.x+D.x, P.y+D.y, P.z+D.z);  }; // prints string s in 3D at P+D

// ==== curve
public void bezier(pt A, pt B, pt C, pt D) {bezier(A.x,A.y,A.z,B.x,B.y,B.z,C.x,C.y,C.z,D.x,D.y,D.z);} // draws a cubic Bezier curve with control points A, B, C, D
public void bezier(pt [] C) {bezier(C[0],C[1],C[2],C[3]);} // draws a cubic Bezier curve with control points A, B, C, D
public pt bezierPoint(pt[] C, float t) {return P(bezierPoint(C[0].x,C[1].x,C[2].x,C[3].x,t),bezierPoint(C[0].y,C[1].y,C[2].y,C[3].y,t),bezierPoint(C[0].z,C[1].z,C[2].z,C[3].z,t)); }
public vec bezierTangent(pt[] C, float t) {return V(bezierTangent(C[0].x,C[1].x,C[2].x,C[3].x,t),bezierTangent(C[0].y,C[1].y,C[2].y,C[3].y,t),bezierTangent(C[0].z,C[1].z,C[2].z,C[3].z,t)); }
public void PT(pt P0, vec T0, pt P1, vec T1) {float d=d(P0,P1)/3;  bezier(P0, P(P0,-d,U(T0)), P(P1,-d,U(T1)), P1);} // draws cubic Bezier interpolating  (P0,T0) and  (P1,T1) 
public void PTtoBezier(pt P0, vec T0, pt P1, vec T1, pt [] C) {float d=d(P0,P1)/3;  C[0].set(P0); C[1].set(P(P0,-d,U(T0))); C[2].set(P(P1,-d,U(T1))); C[3].set(P1);} // draws cubic Bezier interpolating  (P0,T0) and  (P1,T1) 
public vec vecToCubic (pt A, pt B, pt C, pt D, pt E) {return V( (-A.x+4*B.x-6*C.x+4*D.x-E.x)/6, (-A.y+4*B.y-6*C.y+4*D.y-E.y)/6, (-A.z+4*B.z-6*C.z+4*D.z-E.z)/6);}
public vec vecToProp (pt B, pt C, pt D) {float cb=d(C,B);  float cd=d(C,D); return V(C,P(B,cb/(cb+cd),D)); };  

// ==== perspective
public pt Pers(pt P, float d) { return P(d*P.x/(d+P.z) , d*P.y/(d+P.z) , d*P.z/(d+P.z) ); };

public pt InverserPers(pt P, float d) { return P(d*P.x/(d-P.z) , d*P.y/(d-P.z) , d*P.z/(d-P.z) ); };

// ==== intersection
public boolean intersect(pt P, pt Q, pt A, pt B, pt C, pt X)  {return intersect(P,V(P,Q),A,B,C,X); } // if (P,Q) intersects (A,B,C), return true and set X to the intersection point

public boolean intersect(pt E, vec T, pt A, pt B, pt C, pt X) { // if ray from E along T intersects triangle (A,B,C), return true and set X to the intersection point
  vec EA=V(E,A), EB=V(E,B), EC=V(E,C), AB=V(A,B), AC=V(A,C); 
  boolean s=cw(EA,EB,EC), sA=cw(T,EB,EC), sB=cw(EA,T,EC), sC=cw(EA,EB,T); 
  if ( (s==sA) && (s==sB) && (s==sC) ) return false;
  float t = m(EA,AC,AB) / m(T,AC,AB);
  X.set(P(E,t,T));
  return true;
  }
  
public boolean rayIntersectsTriangle(pt E, vec T, pt A, pt B, pt C) { // true if ray from E with direction T hits triangle (A,B,C)
  vec EA=V(E,A), EB=V(E,B), EC=V(E,C); 
  boolean s=cw(EA,EB,EC), sA=cw(T,EB,EC), sB=cw(EA,T,EC), sC=cw(EA,EB,T); 
  return  (s==sA) && (s==sB) && (s==sC) ;}
  
public boolean edgeIntersectsTriangle(pt P, pt Q, pt A, pt B, pt C)  {
  vec PA=V(P,A), PQ=V(P,Q), PB=V(P,B), PC=V(P,C), QA=V(Q,A), QB=V(Q,B), QC=V(Q,C); 
  boolean p=cw(PA,PB,PC), q=cw(QA,QB,QC), a=cw(PQ,PB,PC), b=cw(PA,PQ,PC), c=cw(PQ,PB,PQ); 
  return (p!=q) && (p==a) && (p==b) && (p==c);
  }
  
public float rayParameterToIntersection(pt E, vec T, pt A, pt B, pt C) {vec AE=V(A,E), AB=V(A,B), AC=V(A,C); return - m(AE,AC,AB) / m(T,AC,AB);}
   
public float angleDraggedAround(pt G) {  // returns angle in 2D dragged by the mouse around the screen projection of G
   pt S=P(screenX(G.x,G.y,G.z),screenY(G.x,G.y,G.z),0);
   vec T=V(S,Pmouse()); vec U=V(S,Mouse());
   return atan2(d(R(U),T),d(U,T));
   }

public float toRad(float a) {return(a*PI/180);}      
public int toDeg(float a) {return PApplet.parseInt(a*180/PI);}  

public void showShrunkOffset(pt A, pt B, pt C, float e, float h) {vec N=U(N(V(A,B),V(A,C))); showShrunk(P(A,h,N),P(B,h,N),P(C,h,N),e);} // offset by h along normal

public void showShrunk(pt A, pt B, pt C, float e) { // shrink by e
   vec AB = U(V(A,B)), BC = U(V(B,C)), CA = U(V(C,A));
   float a = e/n(N(CA,AB)), b = e/n(N(AB,BC)), c = e/n(N(BC,CA));
   float d = max(d(A,B)/3,d(B,C)/3,d(C,A)/3);
   a=min(a,d); b=min(b,d); c=min(c,d);
   pt As=P(A,a,AB,-a,CA), Bs=P(B,b,BC,-b,AB), Cs=P(C,c,CA,-c,BC);
   beginShape(); vertex(As); vertex(Bs); vertex(Cs); endShape(CLOSE);
   } 
   
public float scaleDraggedFrom(pt G) {pt S=P(screenX(G.x,G.y,G.z),screenY(G.x,G.y,G.z),0); return d(S,Mouse())/d(S,Pmouse()); }
 
// INTERPOLATING CURVE
public void drawCurve(pt A, pt B, pt C, pt D) {float d=d(A,B)+d(B,C)+d(C,D); beginShape(); for(float t=0; t<=1; t+=0.025f) vertex(P(A,B,C,D,t*d)); endShape(); }
public void drawSamplesOnCurve(pt A, pt B, pt C, pt D, float r) {float d=d(A,B)+d(B,C)+d(C,D); for(float t=0; t<=1; t+=0.025f) show(P(A,B,C,D,t*d),r);}
public pt P(pt A, pt B, pt C, pt D, float t) {return P(0,A,d(A,B),B,d(A,B)+d(B,C),C,d(A,B)+d(B,C)+d(C,D),D,t);}
public pt P(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float t) {
   pt E = P(A,(t-a)/(b-a),B), F = P(B,(t-b)/(c-b),C), G = P(C,(t-c)/(d-c),D), 
                 H = P(E,(t-a)/(c-a),F), I = P(F,(t-b)/(d-b),G);
                            return P(H,(t-a)/(d-a),I);
  }

public pt NUBS(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float e, float t) {
  pt E = P(A,(a+b+t*c)/(a+b+c),B), F = P(B,(b+t*c)/(b+c+d),C), G = P(C,(t*c)/(c+d+e),D), 
                 H = P(E,(b+t*c)/(b+c),F),         I = P(F,(t*c)/(c+d),G),
                            J = P(H,t,I);
  return J;
  }

// Linear
public pt L(pt A, pt B, float t) {return P(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y),A.z+t*(B.z-A.z));}

// Interpolation non-uniform (Neville's algorithm)
public pt I(float a, pt A, float b, pt B, float t) {return L(A,B,(t-a)/(b-a));}                               // P(a)=A, P(b)=B
public pt I(float a, pt A, float b, pt B, float c, pt C, float t) {pt P=I(a,A,b,B,t); pt Q=I(b,B,c,C,t); return I(a,P,c,Q,t);} // P(a)=A, P(b)=B, P(c)=C
public pt I(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float t) {pt P=I(a,A,b,B,c,C,t); pt Q=I(b,B,c,C,d,D,t); return I(a,P,d,Q,t);} // P(a)=A, P(b)=B, P(c)=C, P(d)=D
public pt I(float a, pt A, float b, pt B, float c, pt C, float d, pt D, float e, pt E, float t) {pt P=I(a,A,b,B,c,C,d,D,t); pt Q=I(b,B,c,C,d,D,e,E,t); return I(a,P,e,Q,t);}
// Interpolation proportional to Distance
public pt D(pt A, pt B, pt C, float t) {float a=0, b=d(A,B), c=b+d(B,C); return I(a,A,b,B,c,C,a+t*(c-a));}
public pt D(pt A, pt B, pt C, pt D, float t) {float a=0, b=d(A,B), c=b+d(B,C), d=c+d(C,D); return I(a,A,b,B,c,C,d,D,a+t*(d-a));}
public pt D(pt A, pt B, pt C, pt D, pt E, float t) {float a=0, b=d(A,B), c=b+d(B,C), d=c+d(C,D), e=d+d(D,E); return I(a,A,b,B,c,C,d,D,e,E,a+t*(e-a));}


// TRIANGLE DRAWING STUFF

public void drawTriangle(pt a, pt b, pt c){
  beginShape(); vertex(a); vertex(b); vertex(c);  endShape(CLOSE);
}

public void drawRectangle(pt a, pt b, pt c, pt d){
  drawTriangle(a,b,c); drawTriangle(b,c,d);
}

public void rotPitch(vec P, float angle){
    float y = -1 * P.y * cos(angle) + P.z * sin(angle);  
    float z = P.y * sin(angle) + P.z * cos(angle);  
    P.y = y;
    P.z = z;
}
public void rotYaw(vec P, float angle){
    float x = P.x * cos(angle) - P.z * sin(angle);  
    float z = P.x * sin(angle) + P.z * cos(angle);  
    P.x = x;
    P.z = z;
}
public void rotRoll(vec P, float angle){
    float x = P.x * cos(angle) - P.y * sin(angle);  
    float y = P.x * sin(angle) + P.y * cos(angle);  
    P.x = x;
    P.y = y;
}

public void drawPlane2(float theta, float tilt, float eps){
  pt A = P(-100, 0, 100);
  pt B = P(100, 0, 100);
  pt C = P(-100, 0, -100);
  pt D = P(100, 0, -100);  
  A = quatTransform(A, theta, tilt, eps);
  B = quatTransform(B, theta, tilt, eps);
  C = quatTransform(C, theta, tilt, eps);
  D = quatTransform(D, theta, tilt, eps);   
  drawRectangle(A,B,C,D);  
}
// SOLVERS

public float[] solveAngles(float x1, float z1, float x2, float z2, float x3, float z3, float x4, float z4, float f){
  float[] angles = new float[3];  
  if( (f* ((x1-x3)*(z2-z4) - (x2-x4)*(z1-z3)) ) == 0){
    angles[0] = 0;
    angles[1] = 0;
  } else {
    angles[0] = atan( ((x2 * z4 - x4 * z2) * (z1 - z3) - (x1 * z3 - x3 * z1) * (z2 - z4) )/
                  (f* ((x1-x3)*(z2-z4) - (x2-x4)*(z1-z3)) ));
    angles[1] = atan( cos(angles[0]) * ( (x1 * z3 - x3 * z1) * (x2 - x4) -  (x2 * z4 - x4 * z2) * (x1 - x3))/
                  (f* ((x1-x3)*(z2-z4) - (x2-x4)*(z1-z3)) ));  
  }
  
  float E = f*((x1 - x3)*(z2 - z4) - (x2 - x4)*(z1 - z3));
  float F = f*((x1 - x2)*(z3 - z4) - (x3 - x4)*(z1 - z2));
  float A = (x2*z4 - x4*z2)/E;
  float B = (x1*z3 - x3*z1)/E;
  float C = (x3*z4 - x4*z3)/F;
  float D = (x1*z2 - x2*z1)/F;
  if(E == 0 || F == 0 ||  (A*(x1-x3) - B*(x2-x4) - C*(x1-x2) + D*(x3-x4)) == 0){
    angles[2] = 0;
  } else {
    angles[2] = -1.0f * atan((A*(z1-z3) - B*(z2-z4) - C*(z1-z2) + D*(z3-z4))/
                     (A*(x1-x3) - B*(x2-x4) - C*(x1-x2) + D*(x3-x4)));
  }
  
 // System.out.println("Pitch " + angles[0] + ",  Roll: " + angles[1] + ",  Yaw: " + angles[2]);  

  return angles;
}
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
public vec2d V2D(vec2d V) {return new vec2d(V.x,V.y); };                                                             // make copy of vec2dtor V
public vec2d V2D(vec2d U,vec2d V) {return new vec2d(U.x+V.x,U.y+V.y); };                                               // make copy of vec2dtor V
public vec2d V2D(float x, float y) {return new vec2d(x,y); };                                                      // make vec2dtor (x,y)
public vec2d V2D(pt2d P, pt2d Q) {return new vec2d(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vec2dtor Q-P from P to Q
public vec2d U(vec2d V) {float n = n(V); if (n==0) return new vec2d(0,0); else return new vec2d(V.x/n,V.y/n);};      // V/||V|| (Unit vec2dtor : normalized version of V)
public vec2d V2D(float s,vec2d V) {return new vec2d(s*V.x,s*V.y);};                                                  // sV

public pt2d P2D() {return P2D(0,0); };                                                                            // make point (0,0)
public pt2d P2D(float x, float y) {return new pt2d(x,y); };                                                       // make point (x,y)
public pt2d P2D(pt2d P) {return P2D(P.x,P.y); };                                                                    // make copy of point A
public pt2d P2D(float s, pt2d A) {return new pt2d(s*A.x,s*A.y); };                                                  // sA
public pt2d P2D(pt2d P, vec2d V) {return P2D(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vec2dtor V)
public pt2d P2D(pt2d P, float s, vec2d V) {return P2D(P,V2D(s,V)); }                                                    //  P+sV (P transalted by sV)
public pt2d P2D(pt2d A, float s, pt2d B) {return P2D(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y)); };                             // A+sAB
public pt2d P2D(pt2d A, pt2d B) {return P2D((A.x+B.x)/2,(A.y+B.y)/2); };                                              // (A+B)/2
public pt   to3D(pt2d A){return P(A.x, A.y, 0);}
public pt2d P2D(pt A){return P2D(A.x, A.y);}
  
  
// ----------------- <MY CODE>

public pt2d H(pt2d A, pt2d B, pt2d C) {          //gets the point at t = 1/2 (A = 0, B = 1, C = 2)
    pt2d P=P2D(A,1.5f,B); 
    pt2d Q=P2D(B,1.5f-1.0f,C); 
    return P2D(P,1.5f/2.0f,Q);
}

// four point subdivision
public pt2d P2D(pt2d A, pt2d B, pt2d C, pt2d D){
  return P2D(H(A,B,C), H(D,C,B));
}

// ----------------- </MY CODE>

// show points, edges, triangles, and quads
public void show(pt2d P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                              // draws circle of center r around P
public void show(pt2d P) {ellipse(P.x, P.y, 6,6);};                                                            // draws small circle around point
public void show(pt2d P, pt2d Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
public void v(pt2d P) {vertex(P.x,P.y);};                                                                      // vertex for drawing polygons between beginShape() and endShape()
public void label(pt2d P, String S) {text(S, P.x-4,P.y+6.5f); }                                                 // writes string S next to P on the screen ( for example label(P[i],str(i));)
public void label(pt2d P, vec2d V, String S) {text(S, P.x-3.5f+V.x,P.y+7+V.y); }                                  // writes string S at P+V

// Input points: mouse & canvas 
public pt2d Mouse2D() {return P2D(mouseX,mouseY);};                                                                 // returns point at current mouse location
public pt2d Pmouse2D() {return P2D(pmouseX,pmouseY);};                                                              // returns point at previous mouse location
public pt2d ScreenCenter() {return P2D(width/2,height/2);}                                                        //  point in center of  canvas
public void drag(pt2d P) { P.x+=mouseX-pmouseX; P.y+=mouseY-pmouseY; }                                          // adjusts P by mouse drag vec2dtor

// <MY CODE>

public vec2d R(vec2d U){
  return new vec2d(U.y * -1, U.x);
}

/**
* rotate 
*/
public vec2d R(vec2d U, double angle){
  float d = n(U);
  vec2d rot = new vec2d(new Double(Math.cos(angle)).floatValue(), new Double(Math.sin(angle)).floatValue() );
  return V2D(d, rot);
 }

public float dotP2D(vec2d U, vec2d V){
  return U.x * V.x + U.y * V.y;
}

public float crossP2D(vec2d U, vec2d V){
  return U.x * V.y * -1.0f + U.y * V.x;
}

public float X(pt2d A, pt2d B, pt2d P){
  vec2d AB = V2D(A, B);
  vec2d AP = V2D(A, P);
  return crossP2D(AP, AB) / (n(AB) * n(AB));
}

public float Y(pt2d A, pt2d B, pt2d P){
  vec2d AB = V2D(A, B);
  vec2d AP = V2D(A, P);
  return dotP2D(AP, AB) / (n(AB) * n(AB));
}

public pt2d T(pt2d A, pt2d B, pt2d P, pt2d S, pt2d E){
  vec2d SE = V2D(S, E);
  float x = X(A, B, P);
  float y = Y(A, B, P);
  return P2D( P2D(S, y, SE), x, R(SE)); 
}

// </MY CODE>

// measure points (equality, distance)
public float n(vec2d V) {return sqrt(sq(V.x)+sq(V.y));};                                                       // n(V): ||V|| (norm: length of V)
public float d(pt2d P, pt2d Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| (Distance)
public float d2(pt2d P, pt2d Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

//************************************************************************
//****  CLASSES
//************************************************************************
// points
class pt2d { float x=0,y=0; 
  pt2d (float px, float py) {x = px; y = py;};
  pt2d (pt2d P) {x = P.x; y = P.y;};
  public pt2d setTo(float px, float py) {x = px; y = py; return this;};  
  public pt2d setTo(pt2d P) {x = P.x; y = P.y; return this;}; 
  public pt2d moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY;  return this;}; 
  public pt2d translateTowards(float s, pt2d P) {x+=s*(P.x-x);  y+=s*(P.y-y);  return this;};    
  public pt2d add(float u, float v) {x += u; y += v; return this;}                       
  public pt2d add(pt2d P) {x += P.x; y += P.y; return this;};        
  public pt2d add(float s, pt2d P)   {x += s*P.x; y += s*P.y; return this;};   
  public pt2d add(vec2d V) {x += V.x; y += V.y; return this;}                              
  public pt2d add(float s, vec2d V) {x += s*V.x; y += s*V.y; return this;}                 
  public pt2d show() {ellipse(x,y,3,3); return this;}                 
  public pt2d v() {vertex(x,y); return this;}                 
  } // end of pt2d class

// vec2dtors
class vec2d { float x=0,y=0; 
  vec2d (float px, float py) {x = px; y = py;};
   } // end vec2d class
 


class quat{
  float[] q;
}

public pt quatTransform(pt a, float theta, float phi, float eps){
  float[] z    = {0,a.x,a.y,a.z};
  float[] q    = angleToQuaternion(theta,phi,eps).q;
  float[][] rq = new float[4][4];
  // Creating Rq(q) - 4x4 matrix
  rq[0][0] = 1; 
  rq[0][1] = 0; rq[0][2] = 0; rq[0][3] = 0;
  rq[1][0] = 0; rq[2][0] = 0; rq[3][0] = 0; 
  // Rq the 3x3 defined in the paper: 
  //r1
  rq[1][1] = q[0]*q[0]+q[1]*q[1]-q[2]*q[2]-q[3]*q[3];
  rq[1][2] = 2.0f*q[1]*q[2] + 2.0f*q[0]*q[3];
  rq[1][3] = 2.0f*q[1]*q[3] - 2.0f*q[0]*q[2];
  //r2
  rq[2][1] = 2.0f*q[1]*q[2] - 2.0f*q[0]*q[3];
  rq[2][2] = q[0]*q[0]-q[1]*q[1]+q[2]*q[2]-q[3]*q[3];  
  rq[2][3] = 2.0f*q[2]*q[3] + 2.0f*q[0]*q[1];
  //r3
  rq[3][1] = 2.0f*q[1]*q[3] + 2.0f*q[0]*q[2];  
  rq[3][2] = 2.0f*q[2]*q[3] - 2.0f*q[0]*q[1];    
  rq[3][3] = q[0]*q[0]-q[1]*q[1]-q[2]*q[2]+q[3]*q[3];    
  // solve for translated point
  pt B = P(0,0,0);
  B.x = z[1]*rq[1][1]+z[2]*rq[1][2]+z[3]*rq[1][3];
  B.y = z[1]*rq[2][1]+z[2]*rq[2][2]+z[3]*rq[2][3];
  B.z = z[1]*rq[3][1]+z[2]*rq[3][2]+z[3]*rq[3][3];  
  return B;
}

public quat angleToQuaternion(float theta, float phi, float eps){
  float[] q = new float[4];
  q[0] =        cos(phi/2.0f) * cos(eps/2.0f) * cos(theta/2.0f)   +   sin(phi/2.0f) * sin(eps/2.0f) * sin(theta/2.0f);
  q[1] = -1.0f * cos(phi/2.0f) * sin(eps/2.0f) * sin(theta/2.0f)   +   cos(eps/2.0f) * cos(theta/2.0f) * sin(phi/2.0f);
  q[2] =        cos(phi/2.0f) * cos(theta/2.0f) * sin(eps/2.0f)   +   sin(phi/2.0f) * cos(eps/2.0f) * sin(theta/2.0f);  
  q[3] =        cos(phi/2.0f) * cos(eps/2.0f) * sin(theta/2.0f)   -   sin(phi/2.0f) * cos(theta/2.0f) * sin(eps/2.0f);  
  quat qu = new quat();
  qu.q = q;
  return qu;
}


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

  public void drawWorldRect(){
  //  pt A = P(0,0,-300);
    //pt B = P(P(0,0,-300), worldRect.rectEdge1);
    //pt C = P(P(0,0,-300), worldRect.rectEdge2);
    //pt D = P(P(P(0,0,-300),worldRect.rectEdge1),worldRect.rectEdge2);  
  //  drawRectangle(A,B,C,D);
    
  }
  
  public void drawWorldRectZero(){
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
  
  public void drawTrackZero(){
    for(int index = 0; index < trackPts; index++){ 
    }
  }
  
  public void calcDerived(){
    pt tmpA = worldA;                               derivedA = tmpA;
    pt tmpB = planeIntersect(V(f, worldB), tmpA);   derivedB = tmpB;
    pt tmpC = planeIntersect(V(f, worldC), tmpA);   derivedC = tmpC;
    pt tmpD = planeIntersect(V(f, worldD), tmpA);   derivedD = tmpD;    
  }
  
  public void updateRect(pt A, pt B, pt C, pt D){
    worldA = A; worldB = B; worldC = C; worldD = D;
    calcDerived();    
  }
  
  public pt planeIntersect(vec ray, pt A){
    //3d space focal point
    ray = U(ray);
    float t = d(V(f, A), normalVec) / d(ray, normalVec);
   // System.out.println("   " + d(V(f, A), normalVec) + ", " + d(ray, normalVec) + ", " + t);
    return P(f, V(t, ray));
  }
  
  public void addPoint(pt A){
    if(trackPts < 20){
      tracks[trackPts] = A;
      trackPts++;
    } else {
      tracks[19] = A;
    }
  }
 
  public void printWorldPointPosition(pt A){
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

public pt[] sharpenRect(pt A, pt B, pt C, pt D){
  float a = n(V(A, B));
  float b = n(V(A, C));
  B = P(A, V(100.0f/a, V(A,B)));
  C = P(A, V(200.0f/b, V(A,C)));  
  D = P(P(A, V(A,B)), V(A,C));
  return new pt[] {A,B,C,D};
}

public vec[] orthoNormalBasis(pt A, pt B, pt C, pt D, int iterations){
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
public vec[] iterateBasis(vec T, vec U, vec V){
  vec Vp = N(T,U);
  vec Up = N(T,V);
  vec Tp = N(U,V);  
  Tp = U(Tp); Up = U(Up); Vp = U(Vp);    
  return new vec[] {Tp,Up,Vp};
}

public vec normalizeVec(vec a, vec b){
  vec nb = V();
  float magnitudeB = n(b);
  nb = M(b, V(d(a,b)/d(a,a), a));  
  nb = V(magnitudeB/n(nb), nb);
  return nb;
}

public boolean isRectangle(pt a, pt b, pt c, pt d){
  //System.out.println("d(ab,ac): " + d(V(a,b), V(a,c)) + ", d(db,dc): " + d(V(d,b), V(d,c)));
  if(d(V(a,b), V(a,c)) < 0.001f && d(V(d,b), V(d,c)) < 0.001f){
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
public float getAngle(pt a, pt b, pt c){
  vec BA = V(b, a);
  vec BC = V(b, c);
  System.out.print("A: "); a.str();
  System.out.print("B: "); b.str();
  System.out.print("C: "); c.str();  
  return getAngle(BA,BC);
}

public float getAngle(vec a, vec b){
  return acos(d(a,b)/(n(a)*n(b)) );  
}
// color utilities in RBG color mode
int red, yellow, green, cyan, blue, magenta, dred, dyellow, dgreen, dcyan, dblue, dmagenta, white, black, orange, grey, grey2, metal, dorange, brown, dbrown;
public void setColors() {
   red = color(250,0,0);        dred = color(150,0,0);
   magenta = color(250,0,250);  dmagenta = color(150,0,150); 
   blue = color(0,0,250);     dblue = color(0,0,150);
   cyan = color(0,250,250);     dcyan = color(0,150,150);
   green = color(0,250,0);    dgreen = color(0,150,0);
   yellow = color(250,250,0);    dyellow = color(150,150,0);  
   orange = color(250,150,0);    dorange = color(150,50,0);  
   brown = color(150,150,0);     dbrown = color(50,50,0);
   white = color(255,255,255); black = color(0,0,0); grey = color(100,100,80); grey2 = color(200,150,200); metal = color(150,150,250);
  }
 public int ramp(int v, int mv) {return color(PApplet.parseInt(PApplet.parseFloat(255)*v/mv),100,PApplet.parseInt(PApplet.parseFloat(255)*(mv-v)/mv)) ; }
public void writePerturbError(float samplesX, float samplesY, float largestX, float largestY, int perturbs, float pixelsOff){
  exactGuesses();
  bgP = minG;
  calcGPrimes(bgP);
  String [] fileText = new String [(int)(2*(samplesX+1))+2];   
  float[][] xerrors = new float [(int)(samplesX+1)][(int)(samplesY+1)];    
  float[][] yerrors = new float [(int)(samplesX+1)][(int)(samplesY+1)];    
  // add x error
  for(int p = 0; p < perturbs; p++){
    exactGuesses();
    //println("   " + Ag.x + " " + Ag.y);
    perturbGs(pixelsOff);
    calcMin(smpStart, smpEnd, samples, resamples);    
    bgP = minB;    
    calcGPrimes(bgP);
    calcPPrimes(bgP);    
    for(int x = 0; x <= samplesX; x++){
      for(int y = 0; y <= samplesY; y++){
          Gg = P(f,helpIs(P(P(Ar, V((x/samplesX)*largestX, Ix)), V((y/samplesY)*largestY, V(n(Ix),U(Jx)))))); 
          calcGProj();        
          xerrors[x][y] += getXCoordsDiff((x/samplesX)*largestX)/((float)(perturbs));
      }
    }
    // add y error
    for(int x = 0; x <= samplesX; x++){
      for(int y = 0; y <= samplesY; y++){
          Gg = P(f,helpIs(P(P(Ar, V((x/samplesX)*largestX, Ix)), V((y/samplesY)*largestY, V(n(Ix),U(Jx)))))); 
          calcGProj();        
          yerrors[x][y] += getYCoordsDiff((y/samplesY)*largestY)/((float)(perturbs));
      }
    }
  }
  fileText[0] = "X difference from actual";
  fileText[(int)(samplesX+2)] = "Y difference from actual";
  for(int x = 0; x < samplesX+1; x++){
      fileText[x+1] = "";
      fileText[(int)(x+samplesX+3)] = "";
    for(int y = 0; y < samplesY+1; y++){
      fileText[x+1] += xerrors[x][y]+","; 
      fileText[(int)(x+samplesX+3)] += yerrors[x][y]+",";
    }
  }
  saveStrings("data/perturbError.csv",fileText);
  println("writing perturb error file");
}

public void writeExactCheckersError(float samplesX, float samplesY, float largestX, float largestY){
  exactGuesses();
  bgP = minB;
  calcGPrimes(bgP);
  String [] fileText = new String [(int)(3*(samplesX+1)+3)];     
  // add x error
  fileText[0] = "X difference from actual";
  for(int x = 0; x <= samplesX; x++){
    fileText[x+1] = "";
    for(int y = 0; y <= samplesY; y++){
        Gg = P(f,helpIs(P(P(Ar, V((x/samplesX)*largestX, Ix)), V((y/samplesY)*largestY, V(n(Ix),U(Jx)))))); 
        calcGProj();        
        fileText[x+1] += getXCoordsDiff((x/samplesX)*largestX)+",";
    }
  }
  // add y error
    fileText[(int)(samplesX+2)] = "Y difference from actual";
  for(int x = 0; x <= samplesX; x++){
    fileText[(int)((samplesX+3)+x)] = "";
    for(int y = 0; y <= samplesY; y++){
        Gg = P(f,helpIs(P(P(Ar, V((x/samplesX)*largestX, Ix)), V((y/samplesY)*largestY, V(n(Ix),U(Jx)))))); 
        calcGProj();        
        fileText[(int)((samplesX+3)+x)] += getYCoordsDiff((y/samplesY)*largestY)+",";
    }
  }
  // add actual point distances
  fileText[(int)(2*samplesX+4)] = "Y something";  
  for(int x = 0; x <= samplesX; x++){
    fileText[(int)(2*(samplesX)+5+x)] = "";
    for(int y = 0; y <= samplesY; y++){
        Gg = P(f,helpIs(P(P(Ar, V((x/samplesX)*largestX, Ix)), V((y/samplesY)*largestY, V(n(Ix),U(Jx)))))); 
        calcGProj();        
        fileText[(int)(2*(samplesX)+5+x)] += getYCoordsDiff((y/samplesY)*largestY)+",";
    }
  }
  saveStrings("data/exactError.csv",fileText);
  println("writing exact error file");
}

public void printGridError(float samplesX, float samplesY, float largestX, float largestY){
  exactGuesses();
  bgP = minB;
  calcGPrimes(bgP);
  // add x error
  for(int x = 0; x <= samplesX; x++){
    for(int y = 0; y <= samplesY; y++){
        Gg = P(f,helpIs(P(P(Ar, V((x/samplesX)*largestX, Ix)), V((y/samplesY)*largestY, Jx)))); 
        calcGProj();        
        print("("+getXCoordsDiff((x/samplesX)*largestX)+","+getYCoordsDiff((y/samplesY)*largestY)+")  ");
    }
    println();
  }
}

public void printRectCoords(){
  float x = d(U(V(Agp, Bgp)), V(Agp,Gproj))/n(V(Agp, Bgp));  
  float y = d(U(V(Agp, Cgp)), V(Agp,Gproj))/n(V(Agp, Bgp));  //CHANGE TO Bgp FOR TRAP TODO FIX
  println("("+x+","+y+")");
}

public float getXCoordsDiff(float actx){
  float x = d(U(V(Agp, Bgp)), V(Agp,Gproj))/n(V(Agp, Bgp));
  return abs((actx - x));
}

public float getYCoordsDiff(float acty){
  float y = d(U(V(Agp, Cgp)), V(Agp,Gproj))/n(V(Agp, Bgp));  //CHANGE TO Bgp FOR TRAP TODO FIX
  return abs((acty - y));
}

public void perturbGs(float pixelsOff){
  float chg = random(pixelsOff * -1, pixelsOff);
  int change = (int) chg;
  Ag.x += getPixelOff(pixelsOff); Ag.y += getPixelOff(pixelsOff);
  Bg.x += getPixelOff(pixelsOff); Bg.y += getPixelOff(pixelsOff);
  Cg.x += getPixelOff(pixelsOff); Cg.y += getPixelOff(pixelsOff);
  Dg.x += getPixelOff(pixelsOff); Dg.y += getPixelOff(pixelsOff);  
}

public float getPixelOff(float pixelsOff){
  float change = random(pixelsOff * -1, pixelsOff);
  change = round(change);
  return change *= 1.44f;
}

public void exactGuesses(){
  Ag = P(Ai);
  Bg = P(Bi);
  Cg = P(Ci);
  Dg = P(Di);
}







public void writeErrorCsv() {
  String savePath = "JS/data/data2.csv";  // Opens file chooser
  if (savePath == null) {println("No output file was selected..."); return;}
  else println("writing to "+savePath);
  errorCsv(savePath);
}

public void errorCsv(String fn) {
  float precision = 500;
  float origBp = bpP;
  float tmpBp = .5f;
  float wfactor = 1;
  String [] inpp2dts = new String [(int)precision+1];     
  inpp2dts[0] = "\"b\",\"MixedProduct\",\"SideLength\"";
  int index = 1; 
  for(float x = 0; x < precision; x++){
    float inc = x/precision * wfactor;
    calcPPrimes(tmpBp + inc);
    float e1 = m(V(Ap,Cp),V(Ap,Bp),V(Bp,Dp));
    //float e2 = d(V(Ap,Cp),V(Cp,Dp));
    float e3 = n2(V(Ap,Bp))-n2(V(Cp,Dp));  
    //float e3 = -n2(V(Cp,Dp));      
    inpp2dts[index]=(tmpBp + inc)+","+(e1/800000)+","+e3;
    index++;
  }
  bpP = origBp;
  calcPPrimes(bpP);
  saveStrings(fn,inpp2dts);
}
  

public void drawGraph(){
  int yMax = 300000;
  int dataPoints = 2000;
  drawAxes(smpStart, smpEnd, 0, yMax, 5, 10); 
 // plotVals(smpStart, smpEnd, dataPoints);
  plot(smpStart, smpEnd, 0, yMax, showGuess, showDrawing);
}

public void plot(float xMin, float xMax, int yMin, int yMax, boolean isG, boolean isR){
  plotVals(smpStart, smpEnd, samples, false);  
  if(isG){  
    plotVals(smpStart, smpEnd, samples, true);    
  }
  
  for(int i = 0; i < pointBs.length-2; i++){
    if(isG){
      fill(dbrown); stroke(dbrown);         
      int x = (int)(90 + (width - 140) * (pointBsG[i] - xMin)/(xMax - xMin));
      int y = 50 + (height - 90) - (int)(50 + (height - 90) * (pointValsG[i] - yMin)/(yMax - yMin));
      show(P2D(x,y));
    }
    if(isR){
      fill(black); stroke(black);          
      int x = (int)(90 + (width - 140) * (pointBs[i] - xMin)/(xMax - xMin));
      int y = 50 + (height - 90) - (int)(50 + (height - 90) * (pointVals[i] - yMin)/(yMax - yMin));
      show(P2D(x,y));
    }
  }
  if(isG){
  fill(dgreen); stroke(dgreen);      
    int xG = (int)(90 + (width - 140) * (pointBsG[pointBs.length-2] - xMin)/(xMax - xMin));
    int yG = 50 + (height - 90) - (int)(50 + (height - 90) * (pointValsG[pointBsG.length-2] - yMin)/(yMax - yMin));
    show(P2D(xG,yG),8);        
  }
  if(isR){
  fill(green); stroke(green);      
    int x = (int)(90 + (width - 140) * (pointBs[pointBs.length-2] - xMin)/(xMax - xMin));
    int y = 50 + (height - 90) - (int)(50 + (height - 90) * (pointVals[pointBs.length-2] - yMin)/(yMax - yMin));
    show(P2D(x,y),8);         
  }
  if(isG){
    int x = (int)(90 + (width - 140) * (pointBsG[pointBsG.length-1] - xMin)/(xMax - xMin));
    int y = 50 + (height - 90) - (int)(50 + (height - 90) * (pointValsG[pointBsG.length-1] - yMin)/(yMax - yMin));
    fill(dred); stroke(dred);
    show(P2D(x,y));  
  }
  if(isR){
    int x = (int)(90 + (width - 140) * (pointBs[pointBs.length-1] - xMin)/(xMax - xMin));
    int y = 50 + (height - 90) - (int)(50 + (height - 90) * (pointVals[pointBs.length-1] - yMin)/(yMax - yMin));
    fill(red); stroke(red);
    show(P2D(x,y));  
  }  
  fill(black); stroke(black);
}

float[] pointBsG;
float[] pointValsG;
float[] pointBs;
float[] pointVals;
public void plotVals(float startB, float endB, int points, boolean isG){
    float origBp = bpP;
    if(isG){
      origBp = bgP;
    }     
    if(isG){
      pointBsG = new float[points+2];
      pointValsG = new float[points+2];      
    } else {
      pointBs = new float[points+2];
      pointVals = new float[points+2];         
    }
    float step = (1.0f / (float) points) * (endB - startB);
    for(int x = 0; x < points; x++){
      float tmpB = startB + x*step;
      if(isG)
        calcGPrimes(tmpB);      
      else
        calcPPrimes(tmpB);
      float tmpError = calcError();              
      if(isG){
        tmpError = calcErrorG();              
        pointBsG[x] = tmpB;
        pointValsG[x] = calcErrorG();  
      } else {
        pointBs[x] = tmpB;
        pointVals[x] = calcError();        
      }
    }
    if(isG){
      bgP = minG;
      calcGPrimes(bgP);      
      pointValsG[pointValsG.length-2] = calcErrorG();   
      pointBsG[pointValsG.length-2] = bgP;      
      bgP = origBp;
      calcGPrimes(bgP);      
      pointValsG[pointValsG.length-1] = calcErrorG();   
      pointBsG[pointValsG.length-1] = bgP;   
    } else {      
      bpP = minB;
      calcPPrimes(bpP);      
      pointVals[pointVals.length-2] = calcError();   
      pointBs[pointVals.length-2] = bpP;      
      bpP = origBp;
      calcPPrimes(bpP);      
      pointVals[pointVals.length-1] = calcError();   
      pointBs[pointVals.length-1] = bpP;      
    }  
}

public void drawAxes(float xMin, float xMax, int yMin, int yMax, int xTicks, int yTicks){
  //Y axis
  show(P2D(100,50), P2D(100, height - 40));
  float step = (1.0f/ (float)yTicks) * (height - 100);
  float stepYVal = (1.0f/ (float)yTicks) * ((float)yMax - (float)yMin);
  for(int yoff = 0; yoff <= yTicks; yoff++){
    label(P2D(10,50+ step*((float)yTicks - (float)(yoff))), "" + (yMin + stepYVal * (float) (yoff)));
    show(P2D(95,50+ step*(float)yoff), P2D(105,50+ step*(float)yoff));
  }
  //X axis
  show(P2D(90, height - 50), P2D(width-50, height-50));
  step = (1.0f/ (float)xTicks) * (width - 150);
  float stepXVal = (1.0f/ (float)xTicks) * ((float)xMax - (float)xMin);
  for(int xoff = 0; xoff <= xTicks; xoff++){
    label(P2D(90+ step*((float)(xoff)), height-30), "" + (xMin + stepXVal * (float) (xoff)));
    show(P2D(100+ step*(float)xoff, height - 55), P2D(100+ step*(float)xoff, height - 45));
  }  
}
public void writeHelp () {fill(dblue);
    int i=0;
    scribe("3D VIEWER 2012 (Jarek Rossignac)",i++);
    scribe("CURVE t:show, s:move XY, a:move XZ , v:move all XY, b:move all XZ, A;archive, C.load",i++);
    scribe("MESH L:load, .:pick corner, Y:subdivide, E:smoothen, W:write, N:next, S.swing ",i++);
    scribe("VIEW space:pick focus, [:reset, ;:on mouse, E:save, e:restore ",i++);
    scribe("SHOW ):silhouette, B:backfaces, |:normals, -:edges, c:curvature, g:Gouraud/flat, =:translucent",i++);
    scribe("",i++);

   }
public void writeFooterHelp () {fill(dbrown);
    scribeFooter("Nick Barrash ?:help",1);
  }
public void scribeHeader(String S) {text(S,500,30);} // writes on screen at line i
public void scribeHeaderRight(String S) {text(S,width-S.length()*15,20);} // writes on screen at line i
public void scribeFooter(String S) {text(S,10,height-10);} // writes on screen at line i
public void scribeFooter(String S, int i) {text(S,10,height-10-i*20);} // writes on screen at line i from bottom
public void scribe(String S, int i) {text(S,10,i*30+20);} // writes on screen at line i
public void scribeAtMouse(String S) {text(S,mouseX,mouseY);} // writes on screen near mouse
public void scribeAt(String S, int x, int y) {text(S,x,y);} // writes on screen pixels at (x,y)
public void scribe(String S, float x, float y) {text(S,x,y);} // writes at (x,y)
public void scribe(String S, float x, float y, int c) {fill(c); text(S,x,y); noFill();}
;
// ************************ Graphic pick utilities *******************************

// returns 3D point under mouse     
public pt Pick() { 
  ((PGraphicsOpenGL)g).beginGL(); 
  int viewport[] = new int[4]; 
  double[] proj=new double[16]; 
  double[] model=new double[16]; 
  gl.glGetIntegerv(GL.GL_VIEWPORT, viewport, 0); 
  gl.glGetDoublev(GL.GL_PROJECTION_MATRIX,proj,0); 
  gl.glGetDoublev(GL.GL_MODELVIEW_MATRIX,model,0); 
  FloatBuffer fb=ByteBuffer.allocateDirect(4).order(ByteOrder.nativeOrder()).asFloatBuffer(); 
  gl.glReadPixels(mouseX, height-mouseY, 1, 1, GL.GL_DEPTH_COMPONENT, GL.GL_FLOAT, fb); 
  fb.rewind(); 
  double[] mousePosArr=new double[4]; 
  glu.gluUnProject((double)mouseX,height-(double)mouseY,(double)fb.get(0), model,0,proj,0,viewport,0,mousePosArr,0); 
  ((PGraphicsOpenGL)g).endGL(); 
  return P((float)mousePosArr[0],(float)mousePosArr[1],(float)mousePosArr[2]);
  }

// sets Q where the mouse points to and I, J, K to be aligned with the screen (I right, J up, K towards thre viewer)
public void SetFrame(pt Q, vec I, vec J, vec K) { 
     glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  
     float modelviewm[] = new float[16]; gl = pgl.beginGL(); gl.glGetFloatv(GL.GL_MODELVIEW_MATRIX, modelviewm, 0); pgl.endGL();
     Q.set(Pick()); 
     I.set(modelviewm[0],modelviewm[4],modelviewm[8]);  J.set(modelviewm[1],modelviewm[5],modelviewm[9]); K.set(modelviewm[2],modelviewm[6],modelviewm[10]);   // println(I.x+","+I.y+","+I.z);
     noStroke();
     }
     

// ********************** frame display ****************************
public void showFrame(pt Q, vec I, vec J, vec K, float s) {  // sets the matrix and displays the second model (here the axes as blocks)
  pushMatrix();
  applyMatrix( I.x,    J.x,    K.x,    Q.x,
               I.y,    J.y,    K.y,    Q.y,
               I.z,    J.z,    K.z,    Q.z,
               0.0f,    0.0f,    0.0f,    1.0f      );
  showAxes(s); // replace this (showing the axes) with code for showing your second model
  popMatrix();
  }
  
public void showAxes(float s) { // shows three orthogonal axes as red, green, blue blocks aligned with the local frame coordinates
  noStroke();
  pushMatrix(); 
  pushMatrix(); fill(red);  scale(s,1,1); box(2); popMatrix();
  pushMatrix(); fill(green);  scale(1,s,1); box(2); popMatrix();
  pushMatrix(); fill(blue);  scale(1,1,s); box(2); popMatrix();  
  popMatrix();  
  }
  

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "viewer" });
  }
}
