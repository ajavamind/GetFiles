int KEYCODE_MOVE_HOME       = 122;
int KEYCODE_MOVE_END       = 123;

void keyPressed() {
  println("key="+key + " keyCode="+keyCode);
  
  if (key==' ') {
    display = !display;
  // load photos  
  } else if (key == 'l' || key == 'L') {
    error = false;
    initial = true;
    done = false;
  } else if (key == 'm' || key == 'M') {
    found = false;
    error = false;
    start = true;
    initial = true;
    display = true;
    done = false;
  } else if (key == 'q' || key == 'Q' || keyCode == 111) {  // quit/ESC key
    error = false;
    initial = true;
    done = false;
    exit();
 } else if (key == 'f' || key == 'F') {
    // focus
    for (int i=0; i<udpIpList.length; i++) {
      client[i].send("F");
    }
  } else if (key == 's' || key == 'S') {
    // shutter shoot
    String dt = getDateTime();
    for (int i=0; i<udpIpList.length; i++) {
      client[i].send("S"+dt);
    }
    delay(WAIT_FOR_CAMERA_SAVE);
    initial = true;
    done = false;
  } else if (key == 'c' || key == 'C') {
    // camera focus and shoot
    String dt = getDateTime();
    for (int i=0; i<udpIpList.length; i++) {
      client[i].send("C"+dt);
    }
    delay(WAIT_FOR_CAMERA_SAVE);
    initial = true;
    done = false;
  } else if (key == 'b' || key == 'B') {
    // broadcast camera focus and shoot
    String dt = getDateTime();
    broadcast.send("S"+dt);
    delay(WAIT_FOR_CAMERA_SAVE);
    initial = true;
    done = false;
  } else if (key == 'v' || key == 'V') {
    // video start and pause if already recording
    String dt = getDateTime();
    for (int i=0; i<udpIpList.length; i++) {
      client[i].send("V"+dt);
    }
    delay(WAIT_FOR_CAMERA_SAVE);
    initial = true;
    done = false;
  } else if (key == 'p' || key == 'P') {
    // video pause
    for (int i=0; i<udpIpList.length; i++) {
      client[i].send("P");
    }
    initial = true;
    done = false;
  } else if (key == 'r' || key == 'R') {
    // focus/shutter release
    for (int i=0; i<udpIpList.length; i++) {
      client[i].send("R");
    }
  } else if (keyCode == KEYCODE_MOVE_HOME) {
    showIndex = 0;
  } else if (keyCode == KEYCODE_MOVE_END) {
    showIndex = 0;
  } else if (key == '0') {
    showIndex += 2;
  }
}
