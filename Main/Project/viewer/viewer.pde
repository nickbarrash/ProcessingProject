import processing.opengl.*;                // load OpenGL libraries and utilities
import javax.media.opengl.*; 
import javax.media.opengl.glu.*; 
import java.nio.*;
GL gl; 
GLU glu; 

// ****************************** GLOBAL VARIABLEyeS FOR DISPLAY OPTIONS *********************************
//int width=800, height=(int)((2448.0/3264.0)*width);
int width=1040, height=780;
//int width=2000, height=800;

int ERROR_MODE = 1;

Boolean showHelpText = false,
        showGraph    = false,
        showGraph2   = false,
        showValueText = true,
        showDrawing = true,
        showRect     = true, 
        showPicture = false,
        showGuess = false,
        showCrossMethod = true,
        showImagePlane = false,
        showErrorPointPickMode = false,
        showMagGlass = true, calcMagGlass = true,
        showRectanglePoints = true;
        
        
        pt[] errorCornerPicks = new pt[40];
        
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

  int pickedPoints = 0;
  
  //focal point and a point on the image plane
  pt f = P(0,0,focalLen);  pt img = P(); pt Orig = P();
  
  //rectangle intersections with image plane
  pt Ai = P(), Bi = P(), Ci = P(), Di = P();
  
  // rectangle defined by point Ax and side vectors Ix, Jx
  pt Ax = P(); vec Ix = V(520,0,0); vec Jx = V(0,520,0);  

  // uses above rectangle definition to define real 3d rectangle coordinates
  pt Ar = P(), Br = P(), Cr = P(), Dr = P();
  
  // normal plane vector
  vec planeNorm = V(), planeNormGuess = V(0,0,1);
  
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
  float trapScale = 0.8;
   
  // best guesses for b' value 
  float minB = -1;   float minG = -1;
  
  // sampling variables
  int resamples = 3;
  float smpStart = -0.5;
  float smpEnd = 2.5;     
  int samples  = 1000;
     
  pt Gproj=P();










void setup() {
  size(width, height, OPENGL); //  size(800, 800, P3D);    
  setColors(); sphereDetail(6);  PFont font = loadFont("GillSans-24.vlw"); textFont(font, 20);  // font for writing labels on //  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12); 
  // ***************** OpenGL and View setup
  glu= ((PGraphicsOpenGL) g).glu;  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  gl = pgl.beginGL();  pgl.endGL();
  initViewZ(); // declares the local frames for 3D GUI
  // ***************** Set view
  F=P(); E=P(0,0,500);
  initViewZ();

  // ------------------------------------------------------------------------------
  // LOAD IMAGE
  // picture = loadImage("data/roomPic.JPG"); 
  // picture = loadImage("data/tennis.jpg");   
  // picture = loadImage("data/table1.jpgP");   
  // picture = loadImage("data/rug.jpg"); 
  // picture = loadImage("data/table2.JPG"); 
  //picture = loadImage("PICTURES/checkers1.JPG");   
   picture = loadImage("PICTURES/checkers2.JPG");   

  // -------------------------------------------------------------------------------
  // CALCULAGE INITIAL VALUES
  calcIs();
  calcPPrimes(1.0);
  calcVals();
}
  
  
  
  
  
  
  
  
  
   
void draw() {  
  
  background(white);
  // -------------------------------------------------------- 2D / IMAGE STUFF ----------------------------------
    if(showPicture){
      image(picture, 0,0, picture.width*(float)width/picture.width,picture.height * (float)width/picture.width); 
// image(picture, 0,0, picture.width/5,picture.height /5); 
      noFill();
      stroke(red);   show(ag, 5); stroke(blue);  show(bg, 5);
      stroke(green); show(cg, 5); stroke(yellow); show(dg, 5);      
      stroke(black); show(gg, 5);            
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
  //if(showImagePlane){
    fill(white, 80); stroke(white); drawRectangle(P(-4000,-4000,0),P(-4000,4000,0),P(4000,-4000,0),P(4000,4000,0));  
  //}  
  
  if(showDrawing){
    // draw real 3D rectangle
    fill(grey); stroke(black); drawRectangle(Ar,Br,Cr,Dr);        
    // draw actual points, image points and guess points and the line that passes through all of them
    fill(dred); stroke(dred);       show(f, Ar); show(f, Ai); show(Ai, "A", V(-25,-15,0));
    fill(dblue); stroke(dblue);     show(f, Br); show(f, Bi); show(Bi, "B", V(15,-10,0));
    fill(dgreen); stroke(dgreen);   show(f, Cr); show(f, Ci); show(Ci, "C", V(-25,25,0));
    fill(dyellow); stroke(dyellow); show(f, Dr); show(f, Di); show(Di, "D", V(15,25,0));          
    // draw actual rectangle points
    // fill(magenta); stroke(magenta); show(Ar, 10); show(Ar, "A", V(-30,-15,0)); show(Br, 10); show(Br, "B", V(15,-15,0));  show(Cr, 10); show(Cr, "C", V(-30,15,0)); show(Dr, 10); show(Dr, "D", V(15,15,0));         
    // draw rectangle corner projections on image plane 
    if(showRectanglePoints){
        fill(ddmagenta); stroke(ddmagenta); show(Ai, 10); show(Bi, 10); show(Ci, 10); show(Di, 10);   
        fill(dcyan); stroke(dcyan); show(Ar, 10); show(Br, 10); show(Cr, 10); show(Dr, 10);   
    }
    // draw guess rectangle for real rectangle
    // fill(cyan); stroke(cyan); drawRectangle(Ap,Bp,Cp,Dp);
  }

   
  if(showCrossMethod){
    if(showRectanglePoints){
      // draw plane norm
      fill(dyellow); stroke(dyellow);
      show(Ax, P(Ax, planeNorm));
      show(P(Ax, planeNorm), 5);
      fill(dred); stroke(dred);
      show(Ax, P(Ax,  V(150,U(V(N(Ix, Jx))))));
      show(P(Ax,  V(150,U(V(N(Ix, Jx))))), 5);
      
      // draw prime points
      fill(magenta); stroke(magenta);
      show(Ap, 15); show(Bp, 15); show(Cp, 15); show(Dp, 15);
    }
    fill(dred); stroke(dred); show(f, Ap);
    fill(dblue); stroke(dblue); show(f, Bp);
    fill(dgreen); stroke(dgreen); show(f, Cp);
    fill(dyellow); stroke(dyellow); show(f, Dp);      
    
    // draw prime rectangle
    //fill(magenta); stroke(magenta); drawRectangle(Ap,Bp,Cp,Dp);
  } 
   
  // handles guessing and dragging guess rectangles
  if(keyPressed){
    if(key=='1') {Ag = P(f,helpIs(Pick())); /*ag = new pt2d(mouseX,mouseY);*/ updateGs();}
    if(key=='2') {Bg = P(f,helpIs(Pick())); bg = new pt2d(mouseX,mouseY); updateGs();} 
    if(key=='3') {Cg = P(f,helpIs(Pick())); cg = new pt2d(mouseX,mouseY); updateGs();} 
    if(key=='4') {Dg = P(f,helpIs(Pick())); dg = new pt2d(mouseX,mouseY); updateGs();}  
    if(key=='5') {Gg = P(f,helpIs(Pick())); gg = new pt2d(mouseX,mouseY); calcGProj();} 
    if(key=='6') {printRectCoords();}    
    if(key=='m'){ bpP+=(float)(mouseX-pmouseX)/ (float)width; calcPPrimes(bpP); }
    if(key=='n'){ bgP+=(float)(mouseX-pmouseX)/ (float)width; calcGPrimes(bgP); }   
    if(key=='t'){ trapScale +=(float)(mouseX-pmouseX)/ (float)width; calcVals(); }       
  }   
  
  if(showGuess){
    // show 3D guess points
   // fill(white); stroke(orange); drawRectangle(Ag,Bg,Cg,Dg);        
   // stroke(orange); fill(orange); show(Ag, 10); show(Bg, 10); show(Cg, 10); show(Dg, 10); show(Gproj,10);      
    // show rectangle formed by guess on 3D guess points
    fill(white); stroke(orange); drawRectangle(Agp,Bgp,Cgp,Dgp);        
    // if picture isnt showing show orange ball on mouse cursor
    if(!showPicture){ fill(orange); stroke(orange); mousepick = Pick(); show(mousepick, 10); }
    //show guess plane norm
    fill(dorange); stroke(dorange);
    show(Ax, P(Ax,  V(175,U(planeNormGuess))));
    show(P(Ax,  V(175,U(planeNormGuess))),5);
    
  }  
  
  // -------------------------------------------------------- graphic picking on surface and view control ----------------------------------   
  SetFrame(Q,I,J,K);  // showFrame(Q,I,J,K,30);  // sets frame from picked points and screen axes
  // rotate view 
  if(!keyPressed&&mousePressed&&!showErrorPointPickMode) {E=R(E,  PI*float(mouseX-pmouseX)/width,I,K,F); E=R(E,-PI*float(mouseY-pmouseY)/width,J,K,F); } // rotate E around F 
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
  fill(dgreen); stroke(dgreen);
  if(showValueText){
  scribeHeader(
  "\ntrapezoid scale: " + trapScale +   
  "\nA-red, B-blue, C-green, D-Yellow" + 
  "\nExact Norm Angle Error: " + calcNewMethodError() +       
  "\nGuess Norm Angle Error: " + calcNewMethodErrorGuess() + 
  "\nRectangle Coords: " + printRectCoords() +
  "\nRectangle Squares: " +   printRectCoordsSquare());
  }
  
  if(showErrorPointPickMode){
    if(pickedPoints%4 == 0){
      scribeAtMouse("    pick A (" + (errorCornerPicks.length - pickedPoints)+")");
    }
    if(pickedPoints%4 == 1){
      scribeAtMouse("    pick B (" + (errorCornerPicks.length - pickedPoints)+")");
    }
    if(pickedPoints%4 == 2){
      scribeAtMouse("    pick C (" + (errorCornerPicks.length - pickedPoints)+")");
    }
    if(pickedPoints%4 == 3){
      scribeAtMouse("    pick D (" + (errorCornerPicks.length - pickedPoints)+")");
    }
  }
  // DRAW GRAPH
  if(showGraph){
    drawGraph();
  }
  
   // scribeAtMouse("(" + mouseX + "," + mouseY + ")  /  (" + round(picking.x) + "," + round(picking.y) + "," + round(picking.z) + ") / (" + convert(picking.x, true) + "," + convert(picking.y, false) + ")");
  
  if(showMagGlass){
    showMagnifyingGlass();
  }
}
 
 
 
 
 
 
 
 
 
 

Boolean pressed=false, released = true;
pt2d curMouse = new pt2d(mouseX,mouseY);
vec tmpVec = V(); // vector used to keep track of how far the mouse has dragged the real rectange points when it's being edited
pt tmpA = P();
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
    if(showErrorPointPickMode){
      errorCornerPicks[pickedPoints] = P(f,helpIs(Pick()));
      pickedPoints++;
    }
    if(pickedPoints == errorCornerPicks.length){
      showErrorPointPickMode = false;
      calcMinMaxErrors();
    }
  }
  
void keyReleased() {
   released = true;
   if(key==' ') F=P(T);
   U.set(M(J)); // reset camera up vector
   pre = false;
   if(changeVec) changeVec = false; 
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

void moveAX(){
  if(!changeVec){changeVec = true; tmpA = Ax;  curMouse = new pt2d(mouseX,mouseY);}
  Ax = P(tmpA, V(mouseX-curMouse.x, 0, 0));
}
void moveAY(){
  if(!changeVec){changeVec = true; tmpA = Ax;  curMouse = new pt2d(mouseX,mouseY);}
  Ax = P(tmpA, V(0, mouseY-curMouse.y, 0));
}
void moveAZ(){
  if(!changeVec){changeVec = true; tmpA = Ax;  curMouse = new pt2d(mouseX,mouseY);}
  Ax = P(tmpA, V(0, 0, mouseX-curMouse.x));
}


//print out how far from perfectly perpindicular the rectangle is
void checkRect(){
  System.out.println(d(U(Ix),U(Jx)));
}

String printRectCoords(){
  float x = d(U(V(Agp, Bgp)), V(Agp,Gproj))/n(V(Agp, Bgp));  
  float y = d(U(V(Agp, Cgp)), V(Agp,Gproj))/n(V(Agp, Cgp));  //CHANGE TO Bgp FOR TRAP TODO FIX
  return ("("+x+","+y+")");
}
  
String printRectCoordsSquare(){
  float x = d(U(V(Agp, Bgp)), V(Agp,Gproj))/n(V(Agp, Bgp));  
  float y = d(U(V(Agp, Cgp)), V(Agp,Gproj))/n(V(Agp, Cgp));  //CHANGE TO Bgp FOR TRAP TODO FIX
  return ("("+(x*8.0)+","+(y*8.0)+")");
}
  
void doErrorStuff(){
  showErrorPointPickMode = true;
  pickedPoints = 0;
  errorCornerPicks = new pt[40];
}

void calcMinMaxErrors(){
  float largestAngle = -1;
  float smallestAngle = 361;
  for(int i = 0; i < 10; i++){
    for(int j = 0; j < 10; j++){
      for(int k = 0; k < 10; k++){
        for(int l = 0; l < 10; l++){
          vec tmpNorm = calcNormalVector(errorCornerPicks[i*4], errorCornerPicks[j*4+1], errorCornerPicks[k*4+2], errorCornerPicks[l*4+3]);
          float tmpAngle = calcNewMethodError(tmpNorm);
          largestAngle = tmpAngle > largestAngle ? tmpAngle : largestAngle;
          smallestAngle = tmpAngle < smallestAngle ? tmpAngle : smallestAngle;
        }
      }
    }
  }
  largestAngle = largestAngle > 90 ? abs(180 - largestAngle) : largestAngle;
  smallestAngle = smallestAngle > 90 ? abs(180 - smallestAngle) : smallestAngle;
  System.out.println(largestAngle + " " + smallestAngle);
}

  
  
// Snapping PICTURES of the screen
PImage myFace; // picture of author's face, read from file pic.jpg in data folder
int pictureCounter=0;
Boolean snapping=false; // used to hide some text whil emaking a picture
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); snapping=false;}

 

