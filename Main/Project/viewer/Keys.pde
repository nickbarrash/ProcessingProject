void keyPressed() {
  if(key=='b') {}
  if(key=='e') {doErrorStuff();}
  if(key=='f') {showValueText = !showValueText;}
  if(key=='g') {showGraph = !showGraph;}
  if(key=='h') {showDrawing = !showDrawing;}
  if(key=='i') {initViewX();}  // snap view to specific profile
  if(key=='j') {initViewY();}  // snap view to specific profile
  if(key=='k') {initViewZ();}  // snap view to specific profile
  if(key=='l') {}
  if(key=='m') {showMagGlass = !showMagGlass;}
  if(key=='n') {calcMagGlass = true;}
  if(key=='o') {}
  if(key=='p') {}
  if(key=='q') {showRectanglePoints = !showRectanglePoints;}
  if(key=='r') {writePerturbError(5, 5, 1, 1, 100, 5);}
  if(key=='t') {}//trapezoid change 
  if(key=='u') {bpP = minB;}  // snap guess rectangle to "best" value
  if(key=='w') {println(mouseX + ", " + mouseY);}
  if(key=='y') {}
  
  if(key=='a') {moveAX(); calcVals();}
  if(key=='s') {moveAY(); calcVals();}
  if(key=='d') {moveAZ(); calcVals();} 
  
  if(key=='v') {moveVecJxz(); calcVals();}  // drag real rectangle vertex
  if(key=='c') {moveVecJxy(); calcVals();}  // drag real rectangle vertex
  if(key=='x') {moveVecIxz(); calcVals();} // drag real rectangle vertex
  if(key=='z') {moveVecIxy(); calcVals();} // drag real rectangle vertex
   
  if(key=='A') {}
  if(key=='B') {}
  if(key=='C') {}
  if(key=='D') {}
  if(key=='E') {println(calcError2(Ai,Bi,Ci,Di, bpP,1));}
  if(key=='F') {}
  if(key=='G') {showGuess = !showGuess;}
  if(key=='H') {}
  if(key=='I') {showImagePlane = !showImagePlane;}
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
  if(key=='8') {monteCarlo = true;} 
  if(key=='9') {calcAverageError(2);}     
  if(key=='0') {}
  if(key=='-') {}
  if(key=='=') {}  
}
