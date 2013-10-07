public void calcAverageError(int fieldSize)
{
  int tmpMouseX = mouseX;
  int tmpMouseY = mouseY;
  int[] p2Ds = new int[8];
  p2Ds[0] = convertX(Ai);
  p2Ds[1] = convertY(Ai);
  p2Ds[2] = convertX(Bi);
  p2Ds[3] = convertY(Bi);  
  p2Ds[4] = convertX(Ci);
  p2Ds[5] = convertY(Ci);
  p2Ds[6] = convertX(Di);
  p2Ds[7] = convertY(Di);    
  float maxAngle = 0;
  float minAngle = 4000;
  float averageAngle = 0;
  int angleCount = 0;
  
  for(int ax = fieldSize *-1; ax < fieldSize; ax++){
     println(angleCount);   
     for(int ay = fieldSize *-1; ay < fieldSize; ay++){
          mouseX = p2Ds[0] + ax;
          mouseY = p2Ds[1] + ay;
          pt AAA = P(f,helpIs(Pick()));
          for(int bx = fieldSize *-1; bx < fieldSize; bx++){
             for(int by = fieldSize *-1; by < fieldSize; by++){
                  mouseX = p2Ds[2] + bx;
                  mouseY = p2Ds[3] + by;          
                  pt BBB = P(f,helpIs(Pick()));
                  for(int cx = fieldSize *-1; cx < fieldSize; cx++){
                     for(int cy = fieldSize *-1; cy < fieldSize; cy++){
                          mouseX = p2Ds[4] + cx;
                          mouseY = p2Ds[5] + cy;          
                          pt CCC = P(f,helpIs(Pick()));
                          for(int dx = fieldSize *-1; dx < fieldSize; dx++){
                             for(int dy = fieldSize *-1; dy < fieldSize; dy++){
                                  mouseX = p2Ds[6] + dx;
                                  mouseY = p2Ds[7] + dy;          
                                  pt DDD = P(f,helpIs(Pick()));
                                  //DDD.str();
                                  //println(mouseX + "," + mouseY);
                                  vec guessVec = getRectangleNorm(V(f,AAA),V(f, BBB),V(f,CCC),V(f,DDD));
                                  float errorAngle = angle(U(guessVec), U(V(N(Ix, Jx)))) * 180.0 / PI;
                                  //println(errorAngle);
                                  angleCount++;
                                  averageAngle += errorAngle;
                                  maxAngle = errorAngle > maxAngle ? errorAngle : maxAngle;
                                  minAngle = errorAngle < minAngle ? errorAngle : minAngle;
                             }
                         }                          
                     }
                 }                  
             }
         }
     }    
  }
  averageAngle = averageAngle / angleCount;
  println("max: " + maxAngle + " / min: " + minAngle + " / avg: " + averageAngle);
  mouseX = tmpMouseX;
  mouseY = tmpMouseY;
}

void monteCarloAvgError(float fieldSize, int samples){
  int tmpX = 0;
  int tmpY = 0;
  int[] p2Ds = new int[8];
  calcIs();
  p2Ds[0] = convertX(Ai);
  p2Ds[1] = convertY(Ai);
  p2Ds[2] = convertX(Bi);
  p2Ds[3] = convertY(Bi);  
  p2Ds[4] = convertX(Ci);
  p2Ds[5] = convertY(Ci);
  p2Ds[6] = convertX(Di);
  p2Ds[7] = convertY(Di);    
  float maxAngle = 0;
  float minAngle = 4000;
  float averageAngle = 0;
  int angleCount = 0;
  for(int i = 0; i < samples; i++){
          tmpX = p2Ds[0] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);
          tmpY = p2Ds[1] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);
          pt AAA = P(f,helpIs(Pick2(tmpX, tmpY)));
          testA = AAA;
          fill(green); stroke(green);
          tmpX = p2Ds[2] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);
          tmpY = p2Ds[3] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);
          pt BBB = P(f,helpIs(Pick2(tmpX, tmpY)));          
          testB = BBB;
          tmpX = p2Ds[4] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);
          tmpY = p2Ds[5] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);
          pt CCC = P(f,helpIs(Pick2(tmpX, tmpY)));          
          testC = CCC;          
          tmpX = p2Ds[6] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);
          tmpY = p2Ds[7] + (int)(random(1.0) * (fieldSize * 2 + 1) - fieldSize);          
          pt DDD = P(f,helpIs(Pick2(tmpX, tmpY)));       
          testD = DDD;          
          vec guessVec = getRectangleNorm(V(f,AAA),V(f, BBB),V(f,CCC),V(f,DDD));
          //guessVec.str();
          float errorAngle = calcNewMethodError(guessVec);
          if(abs(180 - errorAngle) < errorAngle)
             errorAngle = abs(180-errorAngle);
          angleCount++;
          averageAngle += errorAngle;
          maxAngle = errorAngle > maxAngle ? errorAngle : maxAngle;
          minAngle = errorAngle < minAngle ? errorAngle : minAngle;          
  }
  averageAngle = averageAngle / angleCount;
  println("max: " + maxAngle + " / min: " + minAngle + " / avg: " + averageAngle);
}
