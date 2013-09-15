/*color cursorColor = color(0,0,150);

void updateMouseColor(){
  cursorColor = pixels[mouseY*width + mouseX];
}

    show(test, 20);*/
    
int glassSize = 30;    
int magnifyingFactor = 10;
color[][] magnifyingGlass = new color[glassSize][glassSize];

public void showMagnifyingGlass(){
  //if(calcMagGlass){
    populateMagnifyingGlass(mouseX, mouseY);
    //calcMagGlass = false;
  //}
  displayMagnifyingGlass();
}

public void populateMagnifyingGlass(int tmpX, int tmpY){
  loadPixels();
  if(tmpX < glassSize/2){
    tmpX = glassSize/2;
  }
  if(tmpX > width - glassSize/2){
    tmpX = width -glassSize/2;
  }
  if(tmpY < glassSize/2){
    tmpY = glassSize/2;
  }
  if(tmpY > height - glassSize/2){
    tmpY = height - glassSize/2;
  }
  for(int i = 0; i <  glassSize-1; i++){
    for(int j = 0; j < glassSize-1; j++){
      magnifyingGlass[i][j] = pixels[(width * (tmpY + j-glassSize/2)) + tmpX + i-glassSize/2];
    }
  }
}

public void displayMagnifyingGlass(){
  loadPixels();
  for(int i = 0; i <  glassSize-1; i++){
    for(int j = 0; j < glassSize-1; j++){
      for(int k = 0; k < magnifyingFactor; k++){
        for(int l = 0; l < magnifyingFactor; l++){
         pixels[(width - magnifyingFactor*glassSize + magnifyingFactor*i+k) + width*(magnifyingFactor*j+l)] = magnifyingGlass[i][j];
        }
      }
    }
  }
 // reticle
 for(int i = 0; i < glassSize-1; i++){
    if(i == glassSize/2-4){
      i+=3;
    }
    if(i == glassSize/2){
      i+=3;
    }
    for(int j = 0; j < magnifyingFactor; j++){
      for(int k = 0; k < magnifyingFactor; k++){
        pixels[(width - glassSize * magnifyingFactor + i * magnifyingFactor + j) + width * ((glassSize-1)/2 * magnifyingFactor + k)] = red;
        pixels[(width - glassSize * magnifyingFactor + (glassSize-1)/2 * magnifyingFactor + k) + width * (i * magnifyingFactor + j)] = red;
      }
    }
 }
  updatePixels();
}
