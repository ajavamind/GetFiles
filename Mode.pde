// Android Mode
import select.files.*;
boolean grantedRead = false;
boolean grantedWrite = false;

SelectLibrary files;
String selection="photobooth.xml";

void openFileSystem() {
  requestPermissions();
  files = new SelectLibrary(this);
}

//public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
  //  println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
  //  for (int i=0; i<permissions.length; i++) {
  //  println(permissions[i]);
  //  }
  //}  

public void onRequestPermissionsResult(int requestCode, String[] permissions,  int[] grantResults) {
  super.onRequestPermissionsResult(requestCode, permissions, grantResults);
  if (requestCode == PackageManager.REQUEST_STORAGE_PERMISSION) {
    if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      // Permission granted, access the image
      //accessImageFile();
    } else {
      // Permission denied, handle the situation (e.g., show explanation to user)
      println("Storage permission is required to access the image.");
    }
  }
}


void requestPermissions() {
  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
  }
  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
  }
}

void handleRead(boolean granted) {
  if (granted) {
    grantedRead = granted;
    println("Granted read permissions.");
  } else {
    println("Does not have permission to read external storage.");
  }
}

void handleWrite(boolean granted) {
  if (granted) {
    grantedWrite = granted;
    println("Granted write permissions.");
  } else {
    println("Does not have permission to write external storage.");
  }
}

void fileSelected() {
  if (selection == null) {
    println("Selection window was closed or the user hit cancel.");
    showMsg("Selection window was closed or canceled.");
    xmlFile = null;
    found = true;
  } else {
    xmlFile = new File(selection);
    println("User selected " + xmlFile.getAbsolutePath());
    found = true;
  }
}


void inputDialog() {
  println("inputDialog");
  //if (!grantedRead || !grantedWrite) {
  //  requestPermissions();
  //}
  //files.selectInput("Select XML Configuration File:", "fileSelected");
  fileSelected();
}

//..........................................................................

//// Java mode
//void openFileSystem() {
//}

//void inputDialog() {
//  selectInput("Select XML Configuration File:", "fileSelected");
//}

//void fileSelected(File selection) {
//  if (selection == null) {
//    println("Selection window was closed or the user hit cancel.");
//    showMsg("Selection window was closed or canceled.");
//    xmlFile = null;
//    found = true;
//  } else {
//    xmlFile = selection;
//    println("User selected " + selection.getAbsolutePath());
//    found = true;
//  }
//}
