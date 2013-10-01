public int convert(float x3D, boolean isX, float depth){
  if(isX)
    return (int)(round(x3D * 675.32 / depth)) + width/2;
  else
    return (int)(round(x3D * 675.32 / depth)) + height/2;
}

public int convertX(pt p3D){
  return convert(p3D.x, true p3D.z);
}

public int convertY(pt p3D){
  return convert(p3D.y, false p3D.z);
}

