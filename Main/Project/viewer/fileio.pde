void writePerturbError(float samplesX, float samplesY, float largestX, float largestY, int perturbs, float pixelsOff){
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

void writeExactCheckersError(float samplesX, float samplesY, float largestX, float largestY){
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

void printGridError(float samplesX, float samplesY, float largestX, float largestY){
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

float getXCoordsDiff(float actx){
  float x = d(U(V(Agp, Bgp)), V(Agp,Gproj))/n(V(Agp, Bgp));
  return abs((actx - x));
}

float getYCoordsDiff(float acty){
  float y = d(U(V(Agp, Cgp)), V(Agp,Gproj))/n(V(Agp, Bgp));  //CHANGE TO Bgp FOR TRAP TODO FIX
  return abs((acty - y));
}

void perturbGs(float pixelsOff){
  float chg = random(pixelsOff * -1, pixelsOff);
  int change = (int) chg;
  Ag.x += getPixelOff(pixelsOff); Ag.y += getPixelOff(pixelsOff);
  Bg.x += getPixelOff(pixelsOff); Bg.y += getPixelOff(pixelsOff);
  Cg.x += getPixelOff(pixelsOff); Cg.y += getPixelOff(pixelsOff);
  Dg.x += getPixelOff(pixelsOff); Dg.y += getPixelOff(pixelsOff);  
}

float getPixelOff(float pixelsOff){
  float change = random(pixelsOff * -1, pixelsOff);
  change = round(change);
  return change *= 1.44;
}

void exactGuesses(){
  Ag = P(Ai);
  Bg = P(Bi);
  Cg = P(Ci);
  Dg = P(Di);
}







void writeErrorCsv() {
  String savePath = "JS/data/data2.csv";  // Opens file chooser
  if (savePath == null) {println("No output file was selected..."); return;}
  else println("writing to "+savePath);
  errorCsv(savePath);
}

void errorCsv(String fn) {
  float precision = 500;
  float origBp = bpP;
  float tmpBp = .5;
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
  

