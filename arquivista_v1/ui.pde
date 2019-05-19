

void keyPressed() {
 
  if(!cp5.get(Textfield.class,"search").isFocus()) {
    if(key == 'r') randomSearch();
    if(key == 'e') export = true;
    if(key == 'm') {
      showFrames = !showFrames;
      updateBuffer();
    }
    if(key == 'i') {
      showImages = !showImages;
      updateBuffer();
    }
    if(key == 'c') {
      refineSearch = !refineSearch;
      println("refineSearch = " + refineSearch + '\n');
      setTextboxColor();
    }
    if(key == 'f') {
      singleView = !singleView;
      println("singleView = " + singleView + '\n');
      setupLayout();
      refresh = true;
      newSearch = true;
    }
    if(key == 'g') {
      cp5.get(Textfield.class,"search").setVisible(!cp5.get(Textfield.class,"search").isVisible());
      searchLabel.setVisible(!searchLabel.isVisible());
    }
    if(!refresh) {
      if(key == CODED) {
        if(keyCode == RIGHT) {
          pageRight();
        }
        if(keyCode == LEFT) {
          pageLeft();
        }
      }
      if(key == ' ') {
        ws.sendMessage("start");
        cp5.setColorBackground(color(#6F0108));  // red textbox
      }
    }
    
    if(key == 'l') {
      exportTags();
    }

    if(key == 'h') { // print help
      println(
        "space - hold to listen" + '\n' +
        "c - toggle refine search lock" + '\n' +
        "f - toggle single image view" + '\n' +
        "r - random search" + '\n' +
        "e - export" + '\n' +
        "m - toggle image frames" + '\n' +
        "i - toggle images" + '\n' +
        "g - toggle search box" + '\n' +
        "l - save tag list to file" + '\n'
      );
    }
      
  }
  
}


void keyReleased(){
  if(key == ' ') {
    ws.sendMessage("stop");
    setTextboxColor();
  }  
}


void mousePressed() {

  int x = mouseX;
  int y = mouseY;

  int i = -1;

  if (x > xm && x < width - xm) {
    if (y > ym && y < height - ym) {
      x -= xm;
      y -= ym;
      i = nc * floor(y/ys) + floor(x/xs);
      if(i > -1 && i < imagesOnScreen()) {
        int id = imageIDs.get(i + (page-1) * nr * nc);
        println("id = " + id);
        println("filename = " + filenames[id] + ".jpg");
        print("tags = ");
        int[] tagList = getTags(id);
        for(int j=0; j<tagList.length; j++) {
          print(tags[tagList[j]] + ", ");
        }
        println();
        println();
      }
    }
  }

}
