void drawGraph(){
  int yMax = 300000;
  int dataPoints = 2000;
  drawAxes(smpStart, smpEnd, 0, yMax, 5, 10); 
 // plotVals(smpStart, smpEnd, dataPoints);
  plot(smpStart, smpEnd, 0, yMax, showGuess, showDrawing);
}

void plot(float xMin, float xMax, int yMin, int yMax, boolean isG, boolean isR){
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
void plotVals(float startB, float endB, int points, boolean isG){
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
    float step = (1.0 / (float) points) * (endB - startB);
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

void drawAxes(float xMin, float xMax, int yMin, int yMax, int xTicks, int yTicks){
  //Y axis
  show(P2D(100,50), P2D(100, height - 40));
  float step = (1.0/ (float)yTicks) * (height - 100);
  float stepYVal = (1.0/ (float)yTicks) * ((float)yMax - (float)yMin);
  for(int yoff = 0; yoff <= yTicks; yoff++){
    label(P2D(10,50+ step*((float)yTicks - (float)(yoff))), "" + (yMin + stepYVal * (float) (yoff)));
    show(P2D(95,50+ step*(float)yoff), P2D(105,50+ step*(float)yoff));
  }
  //X axis
  show(P2D(90, height - 50), P2D(width-50, height-50));
  step = (1.0/ (float)xTicks) * (width - 150);
  float stepXVal = (1.0/ (float)xTicks) * ((float)xMax - (float)xMin);
  for(int xoff = 0; xoff <= xTicks; xoff++){
    label(P2D(90+ step*((float)(xoff)), height-30), "" + (xMin + stepXVal * (float) (xoff)));
    show(P2D(100+ step*(float)xoff, height - 55), P2D(100+ step*(float)xoff, height - 45));
  }  
}
