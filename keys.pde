boolean showHelpText=false;
void showHelp() {
  fill(yellow,50); rect(0,0,height,height); pushMatrix(); translate(20,20); fill(0);
  text("B",0,0); translate(0,20);
  translate(0,20);
  text("Click in this window. Press SPACE to show/hide this help text  ",0,0); translate(0,20);
  text("CORNER OPS: c - pick corner of selected traingle, n - next, p - prev, s - swing, u - unswing",0,0); translate(0,20);
  text("TRIANGLE OPS: x-hide/reveal triangle, t - select triangle, e- expand selection, d-deselect all",0,0); translate(0,20);
  text("ADV1 SUBSURFACE SMOOTHING: D (Shift+d) - to refine and smooth a selected region of triangles",0,0); translate(0,20);
  text("ADV2 SWIRL A REGION: S - To swirl selected region, M - increase magnitude, R - reconstruct mesh",0,0); translate(0,20);
  text("ADV3 WALL: Q - to select triangles by dragging mouse, W - to create a wall",0,0); translate(0,20);
  text("ADV4 TENT CLOTH EFFECT: E - to pull up a selected corner and decay the surrounding vertices (Tent cloth effect)",0,0); translate(0,20);
  text("VIEW: 'z' zoom ",0,0); translate(0,20);
  text("FILE: keys '6','7','8','9','0','-' and '=' to load diff models, '+' to generate flat plane",0,0); translate(0,20);
  text("   ",0,0); translate(0,20);
  text("   ",0,0); translate(0,20);
  popMatrix(); noFill();
}
void keys() {
  if (key==' ') {showHelpText=!showHelpText;};
  if (key=='H') {C.F.setToPoint(Cbox); C.D=Rbox*2; C.U.setTo(0,1,0); C.E.setToPoint(C.F); C.E.addVec(new vec(0,0,1)); C.pullE(); C.pose();};
  if (key=='X') {String S="mesh"+"-####.tif"; saveFrame(S);};   ;
  if (key=='6') {M.cur_sample=0;M.reinit(0);initView(M);}
  if (key=='7') {M.cur_sample=1;M.reinit(0);initView(M);}
  if (key=='8') {M.cur_sample=2;M.reinit(0);initView(M);}
  if (key=='9') {M.cur_sample=3;M.reinit(0);initView(M);}
  if (key=='0') {M.cur_sample=4;M.reinit(0);initView(M);}
  //if (key=='-') {M.cur_sample=5;M.reinit(0);initView(M);}
  if (key=='=') {M.cur_sample=6;M.reinit(0);initView(M);}
  if (key=='+') {M.cur_sample=0;M.reinit(1);initView(M);}
  //Corner
  if (key == 'c') {C.setMark(); M.hitTriangle();}
  if (key == 'n') {M.cur_corner = M.n(M.cur_corner);}
  if (key == 'p') {M.cur_corner = M.p(M.cur_corner);}
  if (key == 's') {M.cur_corner = M.s(M.cur_corner);}
  if (key == 'u') {M.cur_corner = M.u(M.cur_corner);}
  //Triangle
  if (key=='x') {C.setMark(); M.hitTriangle();  M.X[M.t(M.cur_corner)]=!M.X[M.t(M.cur_corner)]; };
  if (key=='t') {C.setMark(); M.hitTriangle(); 
                 int st = M.t(M.cur_corner); 
                 M.selectedTriangles[st]=!M.selectedTriangles[st];}
  if (key=='e') {//expand selection
                 C.setMark(); M.hitTriangle(); 
                 int st = M.t(M.cur_corner); 
                 M.selectedTriangles[st]=true;
                 M.expandSelectedTriangles();
                }
  if (key=='d'){M.resetSelTriangles();}
  //ADV-1
  if (key=='D') {// Adv-1 i. Subsurface smoothing
                  M.detailSelectedTriangles();
                  M.reconstruct(); //Enable correcSTable()
                  M.tuck(10);M.tuck(-7);M.reconstruct();
                }
  //ADV-2
  if (key=='S'){//Adv-2 swirl
                //M.showSwirlValues = !M.showSwirlValues;
                //if(M.showSwirlValues){
                  M.swirl();
                  //M.reconstruct();
                //}
                }
  if (key=='R'){M.reconstruct();}
  if (key=='M'){ M.magnitude+=30;}//if(M.showSwirlValues)}
  
  //ADV-3 wall
  if (key=='Q'){M.curveSelection = true;}//!M.curveSelection; print("\nKey Q = "+M.curveSelection);}
  if (key=='W'){M.constructWall();M.reconstruct();}
  
  //ADV-4 elevation
  if (key=='E'){//M.elevateMode = !M.elevateMode; print("key E:"+M.elevateMode);
                //if(M.elevateMode==true){ 
                  M.elevate();
                M.reconstruct();//}
              }
  //if (key=='H'){if(M.elevateMode==true){M.eleHeight+=10; M.elevate();}}
  /*
  if (key=='P'){M.pinch();}
  if (key=='H'){M.pinchHeight +=10;}*/
  /*if (key=='W'){M.showWave = !M.showWave; 
                if(M.showWave==true) M.startWave();
                else  M.endWave();
              }
  if (key=='A'){M.amplitude++;}*/
             
  if (keyCode==LEFT) {};
  if (keyCode==RIGHT) {};
  if (keyCode==DOWN) {};
  if (keyCode==UP) {};
  }   
void updateView() {
  if (keyCode==SHIFT) {C.Pan(); C.pullE(); };
  if (keyCode==CONTROL) {C.turn(); C.pullE(); };  
  if (key=='z') {C.pose(); C.zoom(); C.pullE(); };
  if (key=='1') {C.pose(); C.fly(1.0); C.pullE(); };  
  if (key=='2') {C.pose(); C.Pan(); C.pullE(); };
  if (key=='3') {C.pose(); C.fly(-1.0); C.pullE();  };
  if (key=='4') {C.pose(); C.Turn(); C.pullE(); };
  if (key=='5') {C.pan(); C.pullE(); }; 
}

pt Mouse = new pt(0,0,0);                 // current mouse position
float xr, yr = 0;                         // mouse coordinates relative to center of window
int px=0, py=0;                           // coordinats of mouse when it was last pressed