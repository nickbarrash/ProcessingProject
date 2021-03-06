/*
 * update guesses stuff after the real values change
 */
void updateGs(){
  calcGPrimes(bgP);
  calcMinG(smpStart, smpEnd, samples, resamples);
}

/*
 * calculate the real values of the rectangle's corners
 * (and update things like the 
 */
void calcArs(){  
  Ar = Ax;
  Br = P(Ax, Ix);    
  Cr = P(Ax, Jx);  
  Dr = P(Br, V(trapScale,Jx));

  calcIs();  
  calcPPrimes(bpP);
  updates++;
  fill(black); 
  calcMin(smpStart, smpEnd, samples, resamples);
}

/*
 * calculates points on image plane from rectangle
 */
void calcIs(){
  Ai = P(f, helpIs(Ar));  Bi = P(f, helpIs(Br));  Ci = P(f, helpIs(Cr));  Di = P(f, helpIs(Dr));  
}

/*
 * calculates the projection of any point onto the image plane
 */
vec helpIs(pt Xr){
  vec dir = V(f,Xr);
  vec nrm = V(0,0,1);
  float t = d(V(f, img), nrm) / d(dir, nrm);
  return V(t, dir);
}

/*
 * calculate the error for the cyan rectangle
 */
float calcError(){
  return calcErrorLogic(Ap, Bp, Cp, Dp);
}

/*
 * calculate the error for the magenta rectangle
 */
float calcErrorG(){
  return calcErrorLogic(Agp, Bgp, Cgp, Dgp);
}

/*
 * given rectangle points calculate the difference
 * in side length between AB and CD
 */
float calcErrorLogic(pt An, pt Bn, pt Cn, pt Dn){
  pt Ct;
  pt Dt;
  Ct = Cn;
  Dt = Dn;
  return abs(n2(V(An,Bn))-n2(V(Ct,Dt)));  
}

/*
 * given an interval (startB, endB) and a sampling
 * interval (points) and the number of times to
 * resample between the minimum values (recurses)
 * find the guess for B' that yields the constructed
 * rectangle or trapezoid with the least amount of error
 * and stores that B' value in minB
 */
void calcMin(float startB, float endB, int points, int recurses){
  calcMinLogic(startB,endB,points,recurses,false);
}

/*
 * same as above but gets the minimum for the magenta
 * rectangle and it stores the minimum B' in minG
 */
void calcMinG(float startB, float endB, int points, int recurses){
  calcMinLogic(startB,endB,points,recurses,true);
}

/*
 * actual logic for calculating optimal guess
 */
void calcMinLogic(float startB, float endB, int points, int recurses, boolean isG){
  float origBp = 0;
  if(isG)
    origBp = bpP;
  else
    origBp = bgP;
  if(recurses > 0){
    float bestB = 0;
    float bestVal = 0;
    boolean first = true;
    float step = (1.0 / (float) points) * (endB - startB);
    for(int x = 0; x < points; x++){
      float tmpB = startB + x*step;
      if(isG)
        calcGPrimes(tmpB);
      else
        calcPPrimes(tmpB); 
      float tmpError = calcError();
      if(first || abs(tmpError) < bestVal){
        bestVal = abs(tmpError);
        bestB = tmpB;
        first = false;
      }
    }
    if(isG)
      minG = bestB;
    else
      minB = bestB;    
    calcMinLogic(bestB - step, bestB + step, points, recurses - 1, isG);
  }
  
  if(isG) {
    bgP=origBp;
    calcPPrimes(bgP);      
  } else {
    bpP=origBp;
    calcPPrimes(bpP);  
  }
}

/*
 * calculates the a' b' c' d' values based on
 * the b' guess (bpnew) and updates the A' B'
 * C' and D' actual points 
 */
void calcPPrimes(float bpnew){
  ap = 1.0; float bp = bpnew; cp = 0; dp = 0;
  pt Eye = f;
  Ap = Ai;
  Bp = P(Eye,V(bp,V(Eye,Bi)));
  //      -A'Eye * A'
  // c =  ---------
  //      EyeC * A'Bi
  cp = -1.0 * (d(V(Ap,Eye),V(Bp,Ap))) / d(V(Eye,Ci),V(Bp,Ap));
  Cp = P(Eye,V(cp,V(Eye,Ci)));
  //     B'Eye * AB'
  // d = ---------
  //      EyeD * AB'
  dp = -1.0 * (d(V(Bp,Eye),V(Ap,Bp))) / d(V(Eye,Di),V(Ap,Bp));
  Dp = P(Eye,V(dp,V(Eye,Di)));
}

/*
 * same as above except uses graph variables
 */
void calcGPrimes(float bpnew){
  //Ai,Bi,Ci,Di,Eye
  agp = 1.0; float bgp = bpnew; cgp = 0; dgp = 0;
  pt Eye = f;
  Agp = Ag;
  Bgp = P(Eye,V(bgp,V(Eye,Bg)));
  //      -A'Eye * A'
  // c =  ---------
  //      EyeC * A'Bi
  cgp = -1.0 * (d(V(Agp,Eye),V(Bgp,Agp))) / d(V(Eye,Cg),V(Bgp,Agp));
  Cgp = P(Eye,V(cgp,V(Eye,Cg)));
  //     B'Eye * AB'
  // d = ---------
  //      EyeD * AB'
  dgp = -1.0 * (d(V(Bgp,Eye),V(Agp,Bgp))) / d(V(Eye,Dg),V(Agp,Bgp));
  Dgp = P(Eye,V(dgp,V(Eye,Dg)));
  //System.out.println(d(V(Ap,Bp),V(Ap,Cp)) + " " + d(V(Ap,Bp),V(Bp,Dp)));
}

/*
 * calculate the projection of the guess point that is to be
 * converted into rectangle plane coordinates on the rectangle's plane
 */
void calcGProj(){
  vec pl1 = V(Agp,Bgp);
  vec pl2 = V(Agp,Cgp);  
  vec plN = N(pl1, pl2);
  vec ptVec = V(f, Gg);
  float t = (-1*d(V(Agp,f), plN))/(d(ptVec,plN));
  Gproj = P(f, V(t, ptVec));  
}
