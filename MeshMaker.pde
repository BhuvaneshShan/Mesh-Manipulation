String [] samples=  {"bunny.vts","horse.vts","torus.vts","tet.vts","fandisk.vts","squirrel.vts","venus.vts"};
int sampleLen=samples.length; 
int radius = 10; //vertex radius
class MeshMaker{
  int MAX_VERTICES = 20000;
  int MAX_TRIANGLES = 20000;
  int MAX_CORNERS = 60000;
  int C[];
  int S[];
  boolean X[];  //Visibility of a triangle
  int nt=0, nv = 0, nc = 0; //triangles, vertices and corners count
  pt G[];  //Geometry of a vertex
  
  boolean showTriangles = true, showVertices = true, showCorners = true, showEdges = false;
  int cur_sample=0; //Current mesh to show
  int cur_corner=0; //Current corner to show
  
  //PRIMARY FUNCTIONS
  int addVertex(float x, float y, float z){
    //print("In addVertex. nv:"+nv+" x,y,z:"+x+","+y+","+z);
    G[nv] = P(x,y,z);
    nv++;
    return nv-1;
  }
  int addTriangle(int a, int b, int c){
    updateStable(a,nc);
    updateStable(b,nc+1);
    updateStable(c,nc+2);
    nc += 3;
    X[nt] = true;
    tNormals[nt] = triNormalFromPts(G[a],G[b],G[c]);
    nt++;
    return nt-1;
  }
  void updateStable(int v, int c){
    if(C[v] ==-1){
      //first corner
      C[v] = c;
      S[c] = negVrep(v);
    }else{
      //add corner to swing table
      int s_c_at_a = C[v];
      int oldindex = s_c_at_a;
      while(s_c_at_a>=0){
        oldindex = s_c_at_a;
        s_c_at_a = S[s_c_at_a];
      }
     S[c] = S[oldindex];
     S[oldindex] = c;
    }
  }
  void correctSTable(){
    for(int i=0;i<nv;i++)
      correctSTable(i);
  }
  void correctSTable(int v){
    int firstCorner = C[v];
    if(firstCorner!=-1 && S[firstCorner]>0){
      //print("\n\nGoing in for vertex "+v);
      ArrayList<Integer> corners = new ArrayList<Integer>();
      int c = firstCorner;
      int temp = 0;
      while(c>=0){
        corners.add(c);
        c = S[c];
      }
      //print("\nCorners:");
      //printIntList(corners);
      
      ArrayList<Integer> paired= new ArrayList<Integer>();
      ArrayList<Integer> nonpaired= new ArrayList<Integer>();
      
      ArrayList<Integer> nVertices = new ArrayList<Integer>();
      ArrayList<Integer> pVertices = new ArrayList<Integer>();
      for(int index = 0;index<corners.size();index++){
        int cor = corners.get(index);
        //print(";collecting nv for "+cor);
        nVertices.add(v(n(cor)));
        //print(";collecting pv for "+cor);
        pVertices.add(v(p(cor)));
      }
      //print("\nNvertices:");
      //printIntList(nVertices);
      //print("\nPvertices:");
      //printIntList(pVertices);
      int corner = 0;
      for(int index = 0;index<corners.size();index++){
        corner = corners.get(index);
        int pVertex = pVertices.get(index);
        int pair = getRightSwingCorner(corner, pVertex, corners, nVertices);
        if(pair!=-1){
          S[corner]=pair;
          paired.add(corner);
        }else{
          S[corner]=-1;
          nonpaired.add(corner);
        }
      }
      //print("\nPaired:");
      //printIntList(paired);
      //print("\nNonpaired:");
      //printIntList(nonpaired);
      int cor = corners.get(0);
      while(cor>=0){
        int val = S[cor];
        //if cor doesnt have a pair
        if(val<0){
          //remove cor from nonpaired list before selecting its next val in swing
          for(int i=0;i<nonpaired.size();i++){
            if(cor==nonpaired.get(i)){
              nonpaired.remove(i);
              break;
            }
          }
          if(paired.size()>0){
            S[cor] = paired.get(0);
            paired.remove(0);
            val = S[cor];
          }else if(nonpaired.size()>0){
            S[cor] = nonpaired.get(0);
            nonpaired.remove(0);
            val = S[cor];
          }else{
            val = negVrep(v);
          }
        }else{
          //remove cor from the paired list before proceeding
          for(int i=0;i<paired.size();i++){
            if(cor==paired.get(i)){
              paired.remove(i);
              break;
            }
          }
          if(val==firstCorner){
            S[cor] = negVrep(v);
            val = negVrep(v);
          }
        }
        cor = val;
      }
      //print("\nArranged! Swing of "+v+":");
      //printSwingOfVertex(v);
    }
  }
  int getRightSwingCorner(int c, int pVertex, ArrayList<Integer> cors, ArrayList<Integer> nVertices){
    for(int i=0;i<cors.size();i++){
      if( pVertex == nVertices.get(i))
        return cors.get(i);
    }
    return -1;
  }
  //Corner functions
  //swing of a corner. returns corner index
  int s(int c){
    int swing = c;
    do{
      swing = S[swing];
      if(swing<0){
        int vertex = -swing-1;
        swing = C[vertex];
      }
    }while(X[t(swing)]==false);
    return swing;
  }
  //unswing of a corner. returns corner index
  int u(int c){
    return n(s(n(c)));
  }
  //vertex id of a corner. return vertex index
  int v(int c){
    int swing = S[c];
    while(swing>=0){
      swing = S[swing];
    }
    return -swing-1;
  }
  //triangle id of a corner. return triangle index
  int t(int c){
    return floor(c/3);
  }
  //first corner in a vertex. return vertex index
  int cv(int v){
    return C[v];
  }
  //first corner in a triangle. return corner index.
  int ct(int t){
    return t*3;
  }
  //next of a corner. returns corner index
  int n(int c){
    int next = (c+1)%3 + ct(t(c));
    return next;
  }
  //prev or a corner. returns corner index
  int p(int c){
    int prev = n(n(c));
    return prev;
  }
  //is a corner border corner or not
  boolean bs(int c){
    int s = s(c);
    if( v(p(c)) == v(n(s)) )
      return false;
    else
      return true;
  }
  //ADVANCE 1 : REGIONAL SMOOTHING
  
  boolean selectedTriangles[];
  void expandSelectedTriangles(){
    ArrayList<Integer> sts = new ArrayList<Integer>();
    for(int i=0;i<nt;i++){
      if(selectedTriangles[i]==true){
        sts.add(i);
      } 
    }
    for(int i=0;i<sts.size();i++){
      int st = sts.get(i);
      int cor1 = ct(st);
      int cor2 = n(cor1);
      int cor3 = n(cor2);
      int sc1 = s(cor1);
      int sc2 = s(cor2);
      int sc3 = s(cor3);
      selectedTriangles[t(sc1)] = true;
      selectedTriangles[t(sc2)] = true;
      selectedTriangles[t(sc3)] = true;
    }
  }
  void detailSelectedTriangles(){
    ArrayList<pt> newVert = new ArrayList<pt>();
    ArrayList<Integer> newVertIds = new ArrayList<Integer>();
    for(int i=0;i<nt;i++){
      if(selectedTriangles[i]==true){
        selectedTriangles[i]=false;
        int cor = ct(i);
        int a = v(cor);
        int b = v(n(cor));
        int c = v(p(cor));
        X[i] = false; //Make visible false
        //delTriangles[i] = true; //Mark as deleted
        pt ab = M(G[a],G[b]);
        pt bc = M(G[b],G[c]);
        pt ca = M(G[c],G[a]);
        int abid = isInList(ab,newVert, newVertIds);
        int bcid = isInList(bc,newVert, newVertIds);
        int caid = isInList(ca,newVert, newVertIds);
        //print("\n");
        if(abid==-1){
          abid = addVertex(ab.x,ab.y,ab.z);
          //printPoint(ab);
          newVert.add(ab);
          newVertIds.add(abid);
        }
        if(bcid==-1){
          bcid = addVertex(bc.x,bc.y,bc.z);
          //printPoint(bc);
          newVert.add(bc);
          newVertIds.add(bcid);
        }
        if(caid==-1){
          caid = addVertex(ca.x,ca.y,ca.z);
          //printPoint(ca);
          newVert.add(ca);
          newVertIds.add(caid);
        }
        addTriangle(a,caid,abid);
        addTriangle(abid,caid,bcid);
        addTriangle(b,abid,bcid);
        addTriangle(bcid,caid,c);
      }
    }
  }
  int isInList(pt newv,ArrayList<pt> newVerts, ArrayList<Integer> newVertsIds){
    for(int i=0;i<newVerts.size();i++){
      pt temp = newVerts.get(i);
      if(almostEquals(newv.x,temp.x,0.01))
        if(almostEquals(newv.y,temp.y,0.01))
          if(almostEquals(newv.z,temp.z,0.01)){
            //print("Vertex same as "+newVertsIds.get(i));
            return newVertsIds.get(i);
          }
    }
    return -1;
  }
  boolean almostEquals(float a, float b, float range){
    if(abs(a-b)<0.01)
      return true;
     return false;
  }
  
  //ADV -2 
  vec tNormals[];
  vec sU;
  pt sA;
  pt sB;
  vec sV;
  int magnitude = 100;
  boolean showSwirlValues = false;
  ArrayList<Integer> sVertices;
  vec Axis;
  float angle;
  pt fixedPt;
  float timeUnit = 0;
  void swirl(){
    sVertices = new ArrayList<Integer>();
    //Addition of all normals
    sU = V(0,0,0);
    for(int i=0;i<nt;i++){
      if(selectedTriangles[i] == true){
        sU.add(tNormals[i]); 
        int cor1 = ct(i);
        addToSVertices(v(cor1),v(n(cor1)),v(p(cor1)));
      }
    }
    //sA = average of all the vertices
    sA = getAverage(sVertices);
    sU = U(sU);
    
    sV = R(sU,PI/4,V(0,1,0));
    sV = U(sV);
    sB = T(sA,magnitude,sU);
    calcValues();
    //Choosing the border vertices alone
    print("Getting border vertices");
    ArrayList<Integer> sbVertices = new ArrayList<Integer>(); //sb - swirl border
    ArrayList<Integer> siVertices = new ArrayList<Integer>();//si - swirl interior
    for(int i=0;i<sVertices.size();i++){
      if(isOuterVertexOfSelection(sVertices.get(i)))
        sbVertices.add(sVertices.get(i));
      else
        siVertices.add(sVertices.get(i));
    }
    
    //Reordering to walk along the border
    sbVertices = reOrderBorderVertices(sbVertices);
    
    //Direction from center swirl path to every vertex
    print("Dir to every vertex");
    ArrayList<vec> sbVertDir = new ArrayList<vec>();
    for(int i=0;i<sbVertices.size();i++){
        sbVertDir.add(V(sA,G[sbVertices.get(i)]));
    }
    ArrayList<vec> siVertDir = new ArrayList<vec>();
    for(int i=0;i<siVertices.size();i++){
        siVertDir.add(V(sA,G[siVertices.get(i)]));
    }
    //Adding new vertices along the swirl
    print("Adding new vertices");
    ArrayList<Integer> sbVertSuccessor = new ArrayList<Integer>(sbVertices);
    sbVertSuccessor.add(sbVertices.get(0));//Adding first element as last element
    
    ArrayList<Integer> siVertSuccessor = new ArrayList<Integer>(siVertices);
    
    int zeroPredecssor=sbVertices.get(0);
    for(float ti=0;ti<=1.0;ti=ti+0.2){
      pt newpoint = S(fixedPt,R(V(fixedPt,sA),angle*ti,Axis));
      float strength = pow(2.71,-ti);
      //border vertices in the swirl selection
      for(int i=0;i<sbVertDir.size();i++){
        pt newvert = S(newpoint,S(strength,sbVertDir.get(i)));
        int newvertid = addVertex(newvert.x,newvert.y,newvert.z);
        int j = i+1;
        if(j>=sbVertSuccessor.size())
          j = 0;
        addTriangle(newvertid,sbVertSuccessor.get(j),sbVertSuccessor.get(i));
        j=i-1;
        if(j>=0)
          addTriangle(sbVertSuccessor.get(j),newvertid,sbVertSuccessor.get(i));
        if(i==sbVertDir.size()-1){
          //draw the last completing triangle for zero
          addTriangle(newvertid,sbVertSuccessor.get(0),zeroPredecssor);
        }
        sbVertSuccessor.set(i,newvertid);
      }
      zeroPredecssor = sbVertSuccessor.get(0);
      sbVertSuccessor.set(sbVertSuccessor.size()-1,sbVertSuccessor.get(0));
      //sbVertSuccessor.add(sbVertSuccessor.get(0));
      if(ti==1.0){
        //Interior vertices at the end point of the swirl
        for(int i=0;i<siVertDir.size();i++){
          pt newvert = S(newpoint,S(strength,siVertDir.get(i)));
          int ivertid = addVertex(newvert.x,newvert.y,newvert.z);
          siVertSuccessor.set(i,ivertid);
        }
      }
    }
    print("\nDrawing upper cover");
    //Draw upper cover
    for(int i=0;i<nt;i++){
      if(selectedTriangles[i]==true){
        int c1 = ct(i);
        int a = v(c1);
        int b = v(n(c1));
        int c = v(p(c1));
        print("\nabc:"+a+","+b+","+c);
        int aInd=0,bInd=0,cInd=0;
        int aList =0, bList=0, cList =0; //if 1 = sb list 2 = si list
        for(int j=0;j<sbVertices.size();j++){
          if(sbVertices.get(j)==a){aInd = j;aList = 1;}
          else if(sbVertices.get(j)==b){bInd = j;bList = 1;}
          else if(sbVertices.get(j)==c){cInd = j;cList = 1;}
        }
        for(int j=0;j<siVertices.size();j++){
          if(siVertices.get(j)==a){aInd = j;aList = 2;}
          else if(siVertices.get(j)==b){bInd = j;bList = 2;}
          else if(siVertices.get(j)==c){cInd = j;cList = 2;}
        }
        int aid=0,bid=0,cid=0;
        if(aList==1){aid = sbVertSuccessor.get(aInd);}else{aid = siVertSuccessor.get(aInd);}
        if(bList==1){bid = sbVertSuccessor.get(bInd);}else{bid = siVertSuccessor.get(bInd);}
        if(cList==1){cid = sbVertSuccessor.get(cInd);}else{cid = siVertSuccessor.get(cInd);}
        addTriangle(aid,bid,cid);
        print("added triangle of id:"+i+" a,b,c id:"+aid+","+bid+","+cid);
      }
    }
    
    //make selected triangles invisible
    switchOffSelectedTriangles();
  }
  
  void switchOffSelectedTriangles(){
    for(int i=0;i<nt;i++)
      if(selectedTriangles[i]==true){
        selectedTriangles[i] = false;
        X[i]=false;
      }
  }
  ArrayList<Integer> reOrderBorderVertices(ArrayList<Integer> sb){
    ArrayList<Integer> newlist = new ArrayList<Integer>();
    //newlist.add(sb.get(0));
    int cor = C[sb.get(0)];
    print("corn:"+cor);
    while(selectedTriangles[t(cor)]==true){
      cor = S[cor];
     // if(cor<0){cor = C[-cor-1];}
    }
    print("corn1:"+cor);
    while(sb.size()>0){
      while(selectedTriangles[t(cor)]==false){
        cor = S[cor];
        if(cor<0) cor = C[-cor-1];
      }
      int pcor = p(cor);
      int vid = v(pcor);
      int index = isInVIDList(vid,sb);
      if(index>=0){
        newlist.add(vid);
        sb.remove(index);
        cor = pcor;
      }else{
        cor = S[cor];
        if(cor<0) cor = C[-cor-1];
      }
    }
    return newlist;
  }
  int isInVIDList(int vid,ArrayList<Integer> sb){
    for(int i=0;i<sb.size();i++){
      if(sb.get(i)==vid)
        return i;
    }
    return -1;
  }
  int getFirstSelectedTriangleCorner(int cor){
    do{
    if(selectedTriangles[t(cor)]==true)
      return cor;
    cor = S[cor];
    if(cor<=0){cor = C[-cor-1];}
    }while(cor>=0);
    return -1;
  }
  boolean isOuterVertexOfSelection(int a){
    int swing = C[a];
    while(swing>=0){
      if(selectedTriangles[t(swing)]==false)
        return true;
      swing = S[swing];
    }
    return false;
  }
  void calcValues(){
    vec UxV = cross(sU,sV);
    print("\nUxV:"+UxV.x+","+UxV.y+","+UxV.z);
    //UxV = U(UxV);
    vec BA = V(sB,sA);
    print("\nBA:"+BA.x+","+BA.y+","+BA.z);
    Axis = U(cross(BA,UxV));
    print("\nAxis:"+Axis.x+","+Axis.y+","+Axis.z);
    angle = angle(sU,sV);
    print("\nang:"+angle);
    fixedPt = S(M(sA,sB),S(1.f/(2*tan(angle/2)),cross(Axis,BA)));
    print("\nfixedPt:"+fixedPt.x+","+fixedPt.y+","+fixedPt.z);
  }
  pt getAverage(ArrayList<Integer> vids){
    pt a = P(0,0,0);
    for(int i=0;i<vids.size();i++){
      a = M(a,G[vids.get(i)]);
    }
    return a;
  }
  void addToSVertices(int v1,int v2, int v3){
    boolean v1found = false, v2found = false, v3found = false;
    for(int i=0;i<sVertices.size();i++){
      if(sVertices.get(i)==v1)  v1found = true;
      else if(sVertices.get(i)==v2)  v2found = true;
      else if(sVertices.get(i)==v3)  v3found = true;
    }
    if(v1found==false) sVertices.add(v1);
    if(v2found==false) sVertices.add(v2);
    if(v3found==false) sVertices.add(v3);
  }
  void translateSelectedTriangles(vec t){
    
  }
  
  //NECESSARY FUNCTIONS
  void init(){
    loadMesh();
    //generateMesh(5);
    correctSTable();
  }
  int negVrep(int a){
    return (-a-1);
  }
  void reconstruct(){
    int tTV[][] = new int[MAX_TRIANGLES][3];
    int tTVind = 0;
    for(int i=0;i<nt;i++){
      if(X[i]){
        int cor = ct(i);
        tTV[tTVind][0] = v(cor);
        tTV[tTVind][1] = v(n(cor));
        tTV[tTVind][2] = v(p(cor));
        tTVind++;
      }
    }
    resetCTable();
    resetTriNormals();
    nt=0;
    nc=0;
    for(int i=0;i<tTVind;i++){
      addTriangle(tTV[i][0],tTV[i][1],tTV[i][2]);  
    }
    //correctSTable();
  }
  void resetCTable(){
    for(int i=0;i<nv;i++)
      C[i] = -1;
  }
  void resetSTable(){
    for(int i=0;i<nc;i++)
      S[i] = -1;
  }
  void  resetTriNormals(){
    for(int i=0;i<nt;i++)
      tNormals[i] = V(0,0,0);
  }
  
  MeshMaker(){
    G = new pt[MAX_VERTICES];
    for(int i=0;i<MAX_VERTICES;i++){
      G[i] = P(0,0,0);
    }
    C = new int[MAX_VERTICES];
    for(int i=0;i<MAX_VERTICES;i++){
      C[i] = -1;
    }
    S = new int[MAX_CORNERS];
    for(int i=0;i<MAX_CORNERS;i++){
      S[i] = -1;
    }
    X = new boolean[MAX_TRIANGLES];
    for(int i=0;i<MAX_TRIANGLES;i++){
      X[i] = false;
    }
    print("C,S,G,X initialized");
    selectedTriangles = new boolean[MAX_TRIANGLES];
    for(int i=0;i<MAX_TRIANGLES;i++){
      selectedTriangles[i] = false;
    }
    tNormals = new vec[MAX_TRIANGLES];
    for(int i=0;i<MAX_TRIANGLES;i++){
      tNormals[i] = V(0,0,0);
    }
  }
  void generateMesh(int size){
    pt point = P(0,0,0);
    for(int i=0;i<size;i++){
      point.y = 0;
      for(int j=0;j<size;j++){
        addVertex(point.x,point.y,point.z);
        point.y += 100;
      }
      point.x = point.x+100;
    }
    for(int i=0;i<size-1;i++){
      for(int j=0;j<size-1;j++){
        int pos = i*size+j;
        addTriangle(pos,pos+1,pos+size);
        addTriangle(pos+size,pos+1,pos+size+1);
      }
    }
  }
  void solve(){
    if(showSwirlValues){
      if(timeUnit>1.0)
        timeUnit = 0;
      else
        timeUnit = timeUnit+0.01;
      //pt ball = S(fixedPt,R(V(fixedPt,sA),angle*timeUnit,Axis));
      //fill(orange);
      //ball.show(3);
    }
  }
  void display(){
    solve();
    //drawReferenceBalls();
    if(showVertices){
      noStroke();
      fill(dblue);
      dispVertices();
    }
    if(showTriangles){
      noStroke();
      fill(cyan);
      dispTriangles();
    }
    if(showCorners){
      noStroke();
      fill(red);
      dispCurCorner();
    }
    if(showSwirlValues){
      noStroke();
      fill(orange);
      sA.show(2);
      fill(metal);
      sB.show(2);
      stroke(blue);
      strokeWeight(2);
      showLineFrom(sA,sU,10);
      showLineFrom(sB,sV,10);
    }
  }
  void dispCurCorner(){
    int a = v(cur_corner);
    int b = v(n(cur_corner));
    int c = v(p(cur_corner));
    pt ab = S(G[a],0.2,G[b]); pt ac = S(G[a],0.2,G[c]); pt bc = M(G[b],G[c]);
    pt a1 = S(G[a],0.1,bc);
    pt b1 = S(ac,0.1,G[b]);
    pt c1 = S(ab,0.1,G[c]);
    drawTriangle(a1,b1,c1);
  }
  void dispVertices(){
    for(int i=0;i<nv;i++){
        G[i].show(radius);
      }
  }
  void dispTriangles(){
    for(int i=0;i<nt;i++){
        if(selectedTriangles[i]==true)
          fill(green);
        else
          fill(60,200,125);
        if(X[i]==true){
          int corner = ct(i);
          int a = v(corner);
          int b = v(corner+1);
          int c = v(corner+2);
          drawTriangle(a,b,c);
        }
      }
  }
  void drawTriangle(int a, int b, int c){
    beginShape(TRIANGLE);
    vertex(G[a].x,G[a].y,G[a].z);
    vertex(G[b].x,G[b].y,G[b].z);
    vertex(G[c].x,G[c].y,G[c].z);
    endShape();
  }
  void drawTriangle(pt a, pt b, pt c){
    beginShape(TRIANGLE);
    vertex(a.x,a.y,a.z);
    vertex(b.x,b.y,b.z);
    vertex(c.x,c.y,c.z);
    endShape();
  }
  void loadMesh() {
    println("Loading samples["+cur_sample+"]: "+samples[cur_sample]); 
    String [] ss = loadStrings(samples[cur_sample]);
    String subpts;
    int s=0;   int comma1, comma2;   float x, y, z;   int a, b, c; int vid, tid;
    int TotalVertices = int(ss[s++]);
    print("nv="+TotalVertices);
    for(int k=0; k<TotalVertices; k++) {int i=k+s; 
      comma1=ss[i].indexOf(',');   
      x=float(ss[i].substring(0, comma1));
      String rest = ss[i].substring(comma1+1, ss[i].length());
      comma2=rest.indexOf(',');   
      y=float(rest.substring(0, comma2)); 
      z=float(rest.substring(comma2+1, rest.length()));
      //G[k].setTo(x,y,z);
      vid = this.addVertex(x,y,z);
    };
    s=TotalVertices+1;
    int TotalTriangles = int(ss[s]); 
    int TotalCorners = 3*TotalTriangles;
    println(", nt="+TotalTriangles);
    s++;
    for(int k=0; k<TotalTriangles; k++) {int i=k+s;
        comma1=ss[i].indexOf(',');   
        a=int(ss[i].substring(0, comma1));  
        String rest = ss[i].substring(comma1+1, ss[i].length()); comma2=rest.indexOf(',');  
        b=int(rest.substring(0, comma2)); 
        c=int(rest.substring(comma2+1, rest.length()));
        //V[3*k]=a;  V[3*k+1]=b;  V[3*k+2]=c;
        tid = this.addTriangle(a,b,c);
      }
  }
  void drawReferenceBalls(){
    noStroke();
    fill(yellow);
    sphere(20);
    pushMatrix();
    translate(100,0,0);
    fill(dblue);
    sphere(20);
    popMatrix();
    pushMatrix();
    translate(0,100,0);
    fill(dgreen);
    sphere(20);
    popMatrix();
    pushMatrix();
    translate(0,0,100);
    fill(dred);
    sphere(20);
    popMatrix();
 }
 void printPoint(pt p){
   print(":"+p.x+","+p.y+","+p.z);
 }
 void printSwingOfVertex(int v){
    int c = C[v];
    while(c>=0){
      print(","+S[c]);
      c = S[c];
    }
    print(","+c);
  }
 void printIntList(ArrayList<Integer> list){
   for(int i=0;i<list.size();i++)
     print(","+list.get(i));
 }
 //Triangle hitting
 pt g(int c){
   int v = v(c);
   return P(G[v].x,G[v].y,G[v].z);
 }
 void hitTriangle() {
   //prevc=cur_corner;       // save for geodesic 
   float smallestDepth=10000000;
  boolean hit=false;
  for (int t=0; t<nt; t++) {
    if (rayHitTri(eye,mark,g(3*t),g(3*t+1),g(3*t+2))) {
      hit=true;
      float depth = rayDistTriPlane(eye,mark,g(3*t),g(3*t+1),g(3*t+2));
      if ((depth>0)&&(depth<smallestDepth)) {smallestDepth=depth;  cur_corner=3*t;};
      }; 
    };
  if (hit) {
    pt X = eye.make(); X.addScaledVec(smallestDepth,eye.vecTo(mark));
    mark.setToPoint(X);
    float distance=X.disTo(g(cur_corner));
    int b=cur_corner;
    if (X.disTo(g(n(cur_corner)))<distance) {b=n(cur_corner); distance=X.disTo(g(b)); };
    if (X.disTo(g(p(cur_corner)))<distance) {b=p(cur_corner);};
    cur_corner=b;
    //println("c="+cur_corner+", pc="+prevc+", t(pc)="+t(prevc));
    };
  }
 //For Camera Display
 pt Cbox = new pt(width/2,height/2,0);                   // mini-max box center
 float Rbox=1000;                                        // Radius of enclosing ball
 void computeBox() {
  pt Lbox =  G[0].make();  pt Hbox =  G[0].make();
  for (int i=1; i<nv; i++) { 
    Lbox.x=min(Lbox.x,G[i].x); Lbox.y=min(Lbox.y,G[i].y); Lbox.z=min(Lbox.z,G[i].z);
    Hbox.x=max(Hbox.x,G[i].x); Hbox.y=max(Hbox.y,G[i].y); Hbox.z=max(Hbox.z,G[i].z); 
    }
  Cbox.setToPoint(midPt(Lbox,Hbox));  Rbox=Cbox.disTo(Hbox);
  }
}