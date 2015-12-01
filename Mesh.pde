MeshMaker M =new MeshMaker();

void setup(){
  size(700,700,P3D);
  setColors();
  sphereDetail(6);
  PFont font = loadFont("Courier-14.vlw"); 
  textFont(font, 12);  // font for writing labels on screen
  //M.generatePlane();
  M.init();
  initView(M);
}

void draw(){
  background(white);
  perspective(PI/2.0,width/height,1.0,6.0*Rbox); 
  if (showHelpText) {
    camera(); translate(-290,-290,0); scale(1.7,1.7,1.0); showHelp(); 
  }
  lights(); directionalLight(0,0,128,0,1,0); directionalLight(0,0,128,0,0,1);
  translate(float(height)/2, float(height)/2, 0.0);     // center view wrt window  
  if ((!keyPressed)&&(mousePressed)) {C.pan(); C.pullE(); };
  if ((keyPressed)&&(mousePressed)) {updateView();}; 
  C1.track(C);  C2.track(C1);   C2.apply();
  M.display();
}

//***      KEY ACTIONS (details in keys tab)
void keyPressed() { keys(); };
void mousePressed() {C.anchor(); C.pose();  };   // record where the cursor was when the mouse was pressed
void mouseReleased() {C.anchor(); C.pose(); };  // reset the view if any key was pressed when mouse was released
void mouseDragged(){ if(M.curveSelection==true){ 
                        //print("\nhitting "+mouseX+","+mouseY);
                        C.setMark();
                        M.hitTriangle();
                        //print("curcor:"+M.cur_corner);
                        M.selectedTriangles[M.t(M.cur_corner)]=true;
                      }
                    }