import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
GL gl; 
GLU glu; 

// ****************************** GLOBAL VARIABLEyeS FOR DISPLAY OPTIONS *********************************
int height=800, width=800;

int ERROR_MODE = 1;

Boolean showHelpText = false,
        showGraph    = true,
        showGraph2   = true,
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
void initViewZ() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,0,1000); U=V(0,1,0); } // declares the local frames
void initViewY() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(0,1000,0); U=V(0,0,1); } // declares the local frames
void initViewX() {Q=P(0,0,0); I=V(1,0,0); J=V(0,1,0); K=V(0,0,1); F = P(0,0,0); E = P(1000,0,0); U=V(0,1,0); } // declares the local frames
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
  float ap = 1, bpP = 1.2, cp = 0, dp = 0; 
  
  // a' b' c' d' or the distances from focal point to B' realative to focal point to Bi used by graph variables    
  float agp = 1, bgP = 1.2, cgp = 0, dgp = 0;
  
  // scales one of the sides of the trapezoid
  float trapScale = 1;
   
  // best guesses for b' value 
  float minB = -1;   float minG = -1;
  
  // sampling variables
  int resamples = 3;
  float smpStart = -0.5;
  float smpEnd = 2.5;     
  int samples  = 1000;
     
  pt Gproj=P();










void setup() {
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
  //picture = loadImage("data/tennis.jpg");   
  //  picture = loadImage("data/table1.jpgP");   
    picture = loadImage("data/rug.jpg"); 
  //    picture = loadImage("data/table2.JPG"); 
  //  picture = loadImage("data/checkers.jpg");   

  // -------------------------------------------------------------------------------
  // CALCULAGE INITIAL VALUES
  calcArs();
  calcIs();
  calcPPrimes(1.0);
}
  
  
  
  
  
  
  
  
  
   
void draw() {  
  
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
  vec Li=U(A(V(E,F),0.1*d(E,F),J));   // vec Li=U(A(V(E,F),-d(E,F),J)); 
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
    fill(ddmagenta); stroke(ddmagenta); show(Ai, 10); show(Bi, 10); show(Ci, 10); show(Di, 10);   
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
  if(!keyPressed&&mousePressed) {E=R(E,  PI*float(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*float(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
  if(keyPressed&&key=='D'&&mousePressed) {E=P(E,-float(mouseY-pmouseY),K); }  //   Moves E forward/backward
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
  scribeHeader((((-1.0*n2(V(Ap,Bp))+n2(V(Cp,Dp)))/n2(V(Ap,Bp)))*100) + 
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

void mousePressed() {
  curMouse = new pt2d(mouseX,mouseY);
}
  
void mouseDragged() {
}

void mouseReleased() {
    U.set(M(J)); // reset camera up vector
    pressed = false;
  }
  
void keyReleased() {
   released = true;
   if(key==' ') F=P(T);
   U.set(M(J)); // reset camera up vector
   pre = false;
   if(changeVec) changeVec = false; 
   }

void keyPressed() {
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
  if(key=='x') {moveVecIxz(); calcArs();} // drag real rectangle vertex
  if(key=='z') {moveVecIxy(); calcArs();} // drag real rectangle vertex
   
  if(key=='A') {}
  if(key=='B') {}
  if(key=='C') {}
  if(key=='D') {}
  if(key=='E') {println(calcError2(Ai,Bi,Ci,Di, bpP,1));}
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
  if(key=='1') {/*switchErrorMode();*/}  // switch to error mode
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
void switchErrorMode(){
  showGraph   = false;
  showDrawing = true;
  showPicture = false;
  showGuess   = false;
}
  
  
// MOVE ACTUAL RECTANGLE IN 3D STUFF
void moveVecIxy(){
  if(!changeVec){changeVec = true; tmpVec = Ix; curMouse = new pt2d(mouseX,mouseY);}
  Ix = A(tmpVec, V(mouseX-curMouse.x, mouseY-curMouse.y, 0));  Jx = normalizeVec(Ix, Jx);
}
void moveVecIxz(){
  if(!changeVec){changeVec = true; tmpVec = Ix; curMouse = new pt2d(mouseX,mouseY);}
  Ix = A(tmpVec, V(mouseX-curMouse.x, 0, mouseY-curMouse.y));  Jx = normalizeVec(Ix, Jx);
}
void moveVecJxy(){
  if(!changeVec){changeVec = true; tmpVec = Jx; curMouse = new pt2d(mouseX,mouseY);}
  Jx = A(tmpVec, V(mouseX-curMouse.x, mouseY-curMouse.y, 0));  Ix = normalizeVec(Jx, Ix);
}
void moveVecJxz(){
  if(!changeVec){changeVec = true; tmpVec = Jx; curMouse = new pt2d(mouseX,mouseY);}
  Jx = A(tmpVec, V(mouseX-curMouse.x, 0,mouseY-curMouse.y));  Ix = normalizeVec(Jx, Ix);
}

//print out how far from perfectly perpindicular the rectangle is
void checkRect(){
  System.out.println(d(U(Ix),U(Jx)));
}

  
  
  
  
  
  
// Snapping PICTURES of the screen
PImage myFace; // picture of author's face, read from file pic.jpg in data folder
int pictureCounter=0;
Boolean snapping=false; // used to hide some text whil emaking a picture
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); snapping=false;}

 

