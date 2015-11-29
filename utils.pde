float angle(vec U, vec V) {return acos(d(U,V)/n(V)/n(U)); };  
vec R(vec V, float a, vec A) { // Rotate V about Axis A by angle a
  A.normalize();
  vec Va = S(d(V,A),A);
  vec Vp = V(V.x-Va.x,V.y-Va.y,V.z-Va.z); //magnitude is |Vp|
  vec VpI = cross(Vp,A);  //same magnitude because A is unit vector
  //return Va.add();
  return S(2,M(Va,S(2,M(S(sin(a),VpI),S(cos(a),Vp)))));
}