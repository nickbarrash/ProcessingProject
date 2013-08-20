class quat{
  float[] q;
}

pt quatTransform(pt a, float theta, float phi, float eps){
  float[] z    = {0,a.x,a.y,a.z};
  float[] q    = angleToQuaternion(theta,phi,eps).q;
  float[][] rq = new float[4][4];
  // Creating Rq(q) - 4x4 matrix
  rq[0][0] = 1; 
  rq[0][1] = 0; rq[0][2] = 0; rq[0][3] = 0;
  rq[1][0] = 0; rq[2][0] = 0; rq[3][0] = 0; 
  // Rq the 3x3 defined in the paper: 
  //r1
  rq[1][1] = q[0]*q[0]+q[1]*q[1]-q[2]*q[2]-q[3]*q[3];
  rq[1][2] = 2.0*q[1]*q[2] + 2.0*q[0]*q[3];
  rq[1][3] = 2.0*q[1]*q[3] - 2.0*q[0]*q[2];
  //r2
  rq[2][1] = 2.0*q[1]*q[2] - 2.0*q[0]*q[3];
  rq[2][2] = q[0]*q[0]-q[1]*q[1]+q[2]*q[2]-q[3]*q[3];  
  rq[2][3] = 2.0*q[2]*q[3] + 2.0*q[0]*q[1];
  //r3
  rq[3][1] = 2.0*q[1]*q[3] + 2.0*q[0]*q[2];  
  rq[3][2] = 2.0*q[2]*q[3] - 2.0*q[0]*q[1];    
  rq[3][3] = q[0]*q[0]-q[1]*q[1]-q[2]*q[2]+q[3]*q[3];    
  // solve for translated point
  pt B = P(0,0,0);
  B.x = z[1]*rq[1][1]+z[2]*rq[1][2]+z[3]*rq[1][3];
  B.y = z[1]*rq[2][1]+z[2]*rq[2][2]+z[3]*rq[2][3];
  B.z = z[1]*rq[3][1]+z[2]*rq[3][2]+z[3]*rq[3][3];  
  return B;
}

quat angleToQuaternion(float theta, float phi, float eps){
  float[] q = new float[4];
  q[0] =        cos(phi/2.0) * cos(eps/2.0) * cos(theta/2.0)   +   sin(phi/2.0) * sin(eps/2.0) * sin(theta/2.0);
  q[1] = -1.0 * cos(phi/2.0) * sin(eps/2.0) * sin(theta/2.0)   +   cos(eps/2.0) * cos(theta/2.0) * sin(phi/2.0);
  q[2] =        cos(phi/2.0) * cos(theta/2.0) * sin(eps/2.0)   +   sin(phi/2.0) * cos(eps/2.0) * sin(theta/2.0);  
  q[3] =        cos(phi/2.0) * cos(eps/2.0) * sin(theta/2.0)   -   sin(phi/2.0) * cos(theta/2.0) * sin(eps/2.0);  
  quat qu = new quat();
  qu.q = q;
  return qu;
}


