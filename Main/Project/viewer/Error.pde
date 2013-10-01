public void findSingleWrongPoint(int fieldSize, int wrongPoint)
{
  int tmpMouseX = mouseX;
  int tmpMouseY = mouseY;
  float[][] errorField = new float[fieldSize*2+1][fieldSize*2+1];
  int p2Ds = new int[8];
  p2Ds[0] = convertX(Ai);
  p2Ds[1] = convertY(Ai);
  p2Ds[2] = convertX(Bi);
  p2Ds[3] = convertY(Bi);  
  p2Ds[4] = convertX(Ci);
  p2Ds[5] = convertY(Ci);
  p2Ds[6] = convertX(Di);
  p2Ds[7] = convertY(Di);    
  //A = 1
  //B = 2
  //C = 3
  //D = 4
  for(int i = fieldSize * -1; i <= fieldSize; i++){
    for(int j = fieldSize * -1; j <= fieldSize; j++){
      mouseX = p2Ds[0]; mouseY = p2Ds[1];
      if(wrongPoint == 1){
        mouseX = mouseX + i;
        mouseY = mouseY + j;
      }
      pt AAA = Pick();
      mouseX = p2Ds[2]; mouseY = p2Ds[3];
      if(wrongPoint == 2){
        mouseX = mouseX + i;
        mouseY = mouseY + j;
      }
      pt BBB = Pick();      
      mouseX = p2Ds[4]; mouseY = p2Ds[5];
      if(wrongPoint == 3){
        mouseX = mouseX + i;
        mouseY = mouseY + j;
      }
      pt CCC = Pick();      
      mouseX = p2Ds[6]; mouseY = p2Ds[7];
      if(wrongPoint == 4){
        mouseX = mouseX + i;
        mouseY = mouseY + j;
      }
      pt DDD = Pick();      
      errorField[i][j] = 
    }
  }
  
  if(wrontPoint == 1){
  }
  
  vec normVec = calcNormalVector();
  mouseX = tmpMouseX;
  mouseY = tmpMouseY;
}
//calcNewMethodError;
