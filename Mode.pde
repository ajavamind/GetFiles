//// Android Mode

//boolean grantedRead = false;
//boolean grantedWrite = false;

//SelectLibrary files;

//void openFileSystem() {
//  requestPermissions();
//  files = new SelectLibrary(this);
//}

//public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
//    println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
//    for (int i=0; i<permissions.length; i++) {
//    println(permissions[i]);
//    }
//  }  


//void requestPermissions() {
//  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
//  }
//  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
//  }
//}

//void handleRead(boolean granted) {
//  if (granted) {
//    grantedRead = granted;
//    println("Granted read permissions.");
//  } else {
//    println("Does not have permission to read external storage.");
//  }
//}

//void handleWrite(boolean granted) {
//  if (granted) {
//    grantedWrite = granted;
//    println("Granted write permissions.");
//  } else {
//    println("Does not have permission to write external storage.");
//  }
//}

//void inputDialog() {
//  //if (!grantedRead || !grantedWrite) {
//  //  requestPermissions();
//  //}
//  files.selectInput("Select XML Configuration File:", "fileSelected");
//}

//..........................................................................

// Java mode
void openFileSystem() {
}

void inputDialog() {
  selectInput("Select XML Configuration File:", "fileSelected");
}
