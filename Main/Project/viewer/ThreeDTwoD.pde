public int convert(float x3D, boolean isX, float depth){
  //println(depth);
  //return round(x3D);
  if(isX)
    return (int)(round(x3D * 708.844 / depth)) + width/2;
  else
    return (int)(round(x3D * 708.844 / depth)) + height/2;
}

public int convertX(pt p3D){
  return convert(p3D.x-73, true, focalLen - p3D.z);
//  return convert(p3D.x, true, focalLen - p3D.z);  
}

public int convertY(pt p3D){
  return convert(p3D.y-55, false, focalLen - p3D.z);
//  return convert(p3D.y, false, focalLen - p3D.z);  
}

