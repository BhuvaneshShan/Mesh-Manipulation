boolean showHelpText=false;
void showHelp() {
  fill(yellow,50); rect(0,0,height,height); pushMatrix(); translate(20,20); fill(0);
  text("B",0,0); translate(0,20);
  translate(0,20);
  text("Click in this window. Press SPACE to show/hide this help text  ",0,0); translate(0,20);
  text("CORNER OPS: c - pick corner of selected traingle, n - next, p - prev, s - swing, u - unswing.",0,0); translate(0,20);
  text("TRIANGLE OPS: t - select triangle. 'f' flip edge, 'm' merge vertices', 'k' hide/rveal triangle  ",0,0); translate(0,20);
  text("MESH OPS: 'R' refine, 'S' smooth, 'M' mnimize, 'F' fill holes  ",0,0); translate(0,20);
  text("EDGEBREAKER: 'i' init, 'a' advance, 'b' compress, 'B' show colors   ",0,0); translate(0,20);
  text("DISTANCE: 'D' show, 'I' isolation, 'P' path, 'd' distance, ',' smaller, '.' larger, '0' zero   ",0,0); translate(0,20);
  text("FILES: 'g' next file. 'G' read from file, 'A' archive.",0,0); translate(0,20);
  text("VIEW: 'z' zoom, 'H home, 'j' jump, 'J' jumping,   ",0,0); translate(0,20);
  text("DISPLAY: 'E' edges, 'V' vertices, 'N' normals, ",0,0); translate(0,20);
  text("   ",0,0); translate(0,20);
  text("If running local: 'W' to save points and 'X' to save a picture (DO NOT USE IN WEB BROWSER!).",0,0); translate(0,20);
  popMatrix(); noFill();
}
void keys() {
  if (key==' ') {showHelpText=!showHelpText;};
  if (key=='H') {C.F.setToPoint(Cbox); C.D=Rbox*2; C.U.setTo(0,1,0); C.E.setToPoint(C.F); C.E.addVec(new vec(0,0,1)); C.pullE(); C.pose();};
  if (key=='X') {String S="mesh"+"-####.tif"; saveFrame(S);};   ;
  
  if (key == 'c') {C.setMark(); M.hitTriangle();}
  if (key == 'n') {M.cur_corner = M.n(M.cur_corner);}
  if (key == 'p') {M.cur_corner = M.p(M.cur_corner);}
  if (key == 's') {M.cur_corner = M.s(M.cur_corner);}
  if (key == 'u') {M.cur_corner = M.u(M.cur_corner);}
  
  if (key=='t') {C.setMark(); M.hitTriangle(); 
                 int st = M.t(M.cur_corner); 
                 M.selectedTriangles[st]=!M.selectedTriangles[st];}
  if (key=='D') {// Adv-1 i. Detail exaggeration
                  M.detailSelectedTriangles();
                }
  if (key=='S'){//Adv-1 ii. Smooth
                }
  
  if (key=='x') {C.setMark(); M.hitTriangle();  M.X[M.t(M.cur_corner)]=!M.X[M.t(M.cur_corner)]; };
  
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