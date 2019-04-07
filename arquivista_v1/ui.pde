

void keyPressed() {
 
  if(!cp5.get(Textfield.class,"search").isFocus()) {
    if(key == 'r') randomSearch();
    if(key == 'e') export = true;
    if(key == 'f') {
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
      saveStrings("../tags.txt", tags);
      println("exported tag list to ../tags.txt");
    }

    if(key == 'h') { // print help
      println(
        "space - hold to listen" + '\n' +
        "c - toggle refine search lock" + '\n' +
        "r - random search" + '\n' +
        "e - export" + '\n' +
        "f - toggle image frames" + '\n' +
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
      i = columns*floor(y/ys) + floor(x/xs);
      if(i > -1 && i < imagesOnScreen()) {
        int id = imageIDs.get(i + (page-1)*rows*columns);
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
