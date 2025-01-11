// Processing sketch in Java or Android mode transfers
// photo and video files from twin camera Android phones
// that run the Android Google Play "Open Camera Remote" app
// with the HTTP server turned on.

// Written by Andy Modla June 2020

// To use with your computer and phones:
// Modify XML configuration file to change
// where photos will be stored
// Set URLs for one, two or more HTTP web servers
// Set optional trigger URLs.

import java.util.Collections;
import java.util.Comparator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
//import android.view.KeyEvent;
//import netP5.*;
import netP5.UdpClient;
//import oscP5.*; // does not use this part of oscP5 library
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InterfaceAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;
import android.os.Environment;
import java.net.URL;
//import java.net.HttpURLConnection;
//import java.io.BufferedInputStream;

//"http://192.168.1.104:8080/", // Samsung S8 left
//"http://192.168.1.62:8080/"  // Sony XZ Premium
//"http://192.168.1.224:8080/", // Samsung S8 right
//"http://192.168.1.106:8080/" // Samsung S6 left
//"http://192.168.1.xxx:8080/" // Samsung S6 right
//"http://192.168.1.128:8080/" // Samsung S7

String configFile; // XML configuration filename
String[] saveFolder;
// HTTP photo server URL list
String[] httpUrlList;
// Camera IP address list for remote focus and shutter trigger
String[] udpIpList;
String[] udpName;
// File suffix attachment list
String[] suffix;
// HTTP Server description list
String[] description;
//filename starts with
String[] filter;
// Rotate photo degrees
int[] rotate;
int[] flip;


ReadWriteFile rw;
ArrayList<String[]>[] fileList;
String textValue = "Get Files from Camera HTTP Servers";
String[] lines;
String[] list;
String[] lastFile;
PImage[] lastPhoto;
int listIndex = 0;
int fileIndex = 0;
int showIndex = 0;

String PATTERN = "href=\"(.*?)\"";
Pattern pattern;

int count = 0;
int total = 0;
int skips = 0;
String textMsg;
String errorMsg;
int fileCounter = 0;

// Display screen text parameters
int VERT_SPACING = 40;
int HORZ_SPACING = 20;
int vert = 0;
int horz = HORZ_SPACING;

volatile boolean done = false;
volatile boolean found = false;  // configruation file
boolean initial = true;
boolean start = true;
boolean display = true;
boolean error = false;
boolean portrait = false;
boolean rawOnly = false;

UdpClient[] client;
UdpClient broadcast;
int udpPort[];
int broadcastPort = 8000;
String broadcastIp;
int WAIT_FOR_CAMERA_SAVE = 5000; // ms

public void settings() {
  size(1920, 1080);
  smooth();
}

public void setup() {
  background(0);
  textSize(48);
  frameRate(200);
  horz = HORZ_SPACING;
  vert = VERT_SPACING;
  displayText(textValue);
}

void displayText(String line) {
  text(line, horz, vert);
  vert += VERT_SPACING;
  if (vert > (height -VERT_SPACING ))
    vert -= VERT_SPACING;
}

void backLine(String line, int offset) {
  vert -= VERT_SPACING;
  text(line, horz+offset, vert);
  vert += VERT_SPACING;
  if (vert > (height -VERT_SPACING ))
    vert -= VERT_SPACING;
}

void draw() {
  background(0);
  fill(255);
  horz = HORZ_SPACING;
  vert = VERT_SPACING;
  displayText(textValue);

  if (start) {
    println("start");
    openFileSystem();

    int status = configure(configFile);
    if (status < 0) {
      println("configuration file error");
      displayText("configuration file error ");
      exit();
      return;
    }
    println(" pattern compile");
    pattern = Pattern.compile(PATTERN, Pattern.CASE_INSENSITIVE);

    //if (photosOnly) {
    //  String[] types = ImageIO.getReaderFormatNames();
    //  for (int i=0; i<types.length; i++) {
    //    println(types[i]);
    //  }
    //}

    println("HTTP server URLs:");
    if (httpUrlList != null && httpUrlList.length>0) {
      for (int i=0; i< httpUrlList.length; i++) {
        println(httpUrlList[i]+ " " + suffix[i]);
      }
    }
    fileList = new ArrayList[httpUrlList.length];
    lastFile = new String[httpUrlList.length];
    lastPhoto = new PImage[httpUrlList.length];


    println("File storage directory: "+saveFolder.toString());

    rw = new ReadWriteFile();
    client = new UdpClient[udpIpList.length];

    broadcastIp = getWifiBroadcastIpAddress();
    println("broadcastIp="+broadcastIp);
    start = false;
    return;
  }

  if (saveFolder.length > 0)
    displayText("Save Folder: " + saveFolder[0]);
  //displayText("");
  for (int i=0; i<httpUrlList.length; i++) {
    displayText(httpUrlList[i]+" "+description[i]);
  }
  displayText("");

  if (broadcast == null) {
    broadcast = new UdpClient(broadcastIp, broadcastPort);
    if (broadcast == null) {
      println("Error UDP socket "+ broadcastIp +":"+broadcastPort);
    }
  }

  for (int i=0; i<udpIpList.length; i++) {
    try {
      if (client[i] == null) {
        client[i] = new UdpClient(udpIpList[i], udpPort[i]);
        if (client[i] == null) {
          println("Error UDP Client");
        }
      } else if (client[i].socket() == null) {
        println("Error UDP socket "+ udpIpList[i]+":"+udpPort[i]);
      }
    }
    catch (Exception e) {
      println("Wifi UDP Trigger problem");
    }
  }

  for (int i=0; i<udpIpList.length; i++) {
    if (client[i] != null) {
      displayText("Camera IP Address: "+udpIpList[i]+ " "+udpName[i]);
    }
  }
  displayText("");
  if (udpIpList.length>0) {
    displayText("Key R Camera Status");
    displayText("Key F Camera Focus");
    displayText("Key S Camera Shutter");
    displayText("Key C Camera Take Photo");
    displayText("Key V Camera Video Start/Stop");
    displayText("Key P Camera Video Pause/Resume");
    displayText("");
  }
  displayText("Key M Read Configuration XML file");
  displayText("Key L Load Photos");
  displayText("Key spacebar Toggle last photo display");
  displayText("");

  if (error) {
    if (textMsg != null) {
      displayText(textMsg);
    }
    return;
  }

  if (initial) {
    total = 0;
    skips = 0;
    listIndex = 0;
    fileIndex = 0;
    for (int i=0; i< httpUrlList.length; i++) {
      fileList[i] = loadList(httpUrlList[i], suffix[i], description[i], filter[i]);
      if (fileList[i] == null) {
        return;
      }
      total += fileList[i].size();
    }
    initial = false;
    count = 0;
    println("total transfers="+total + " skips="+skips);
  }

  if (!done) {
    while (listIndex< httpUrlList.length) {
      try {
        while (fileIndex < fileList[listIndex].size()) {
          String[] str = fileList[listIndex].get(fileIndex);
          int num = 0;
          println(str[0] + " "+saveFolder[listIndex] + " "+str[1]);
          num = rw.readWrite(str[0], saveFolder[listIndex], str[1], listIndex);
          if (num < 0) {
            showMsg("File write error: "+ saveFolder[listIndex]);
            error = true;
          } else {
            count++;
            if (num==0)
              skips++;
            break;
          }
        }
        fileIndex++;
        if (fileIndex >= fileList[listIndex].size()) {
          fileIndex = 0;
          listIndex++;
        }
        displayText(str(count) + " of "+total+ " files");
      }
      catch (Exception e) {
        textMsg = e.toString();
        count = fileList[listIndex].size();
      }
      return;
    }
    done = true;
    println("total transfers="+total + " skips="+skips);
  }

  if (done) {
    //text(str(total-skips) + " of "+ str(fileList.size())+
    displayText(str(total-skips) + " of "+ total+
      " files transferred.");
    displayText(str(skips) +  " files already saved.");
    displayText("Done");
    displayText("");
    //displayText("");
    //displayText("");
    //displayText("");
    //displayText("");
    //displayText("");
    //displayText("");
    //displayText("");
    //displayText("");
    //displayText("Last two photos");


    for (int i=0; i<lastPhoto.length; i++) {
      try {
        if (i%2 == 0)
          displayText(lastFile[i].substring(lastFile[i].lastIndexOf(File.separator)+1));
        else
          backLine(lastFile[i].substring(lastFile[i].lastIndexOf(File.separator)+1), width/2);
        //println("display "+ lastFile[i]);
        if (display) {
          lastPhoto[i]= loadImage(lastFile[i]);
          float ar = ((float)lastPhoto[i].width)/ ((float)lastPhoto[i].height);
          //image(lastPhoto[i], i*width/2, height/2, (height/2)*ar, height/2);
          pushMatrix();
          imageMode(CENTER);
          if (rotate[i]>0) {
            translate(width/4+i*width/2, height/2);
            rotate(radians(rotate[i]));
          } else {
            translate(width/4+i*width/2, height/2);
          }
          if (portrait) {
            image(lastPhoto[i], 0, 0, (height)*ar, height);
          } else {
            image(lastPhoto[i], 0, 0, width/2, width/(2*ar));
          }
          popMatrix();
        }
      }
      catch(Exception e) {
        displayText("No photos found for display");
        println("No photos found for display");
        error = true;
      }
    }
  }
}

public void showMsg(String msg) {
  textMsg = msg;
}


public ArrayList<String[]> loadList(String url, String suffix, String description, String filter) {
  ArrayList<String[]> fileList = new ArrayList<String[]>();
  println(url);
  showMsg("");

  // read directory listing from server
  try {
    lines = loadStrings(url);
  }
  catch (Exception e) {
    errorMsg = e.toString();
    lines = null;
  }

  if (lines == null ) {
    showMsg(errorMsg + ": loadStrings() lines null URL error "+url+ "  suffix: "+suffix);
    error = true;
    return fileList;
  } else if (lines.length == 0) {
    showMsg(description + ": loadStrings() no lines read URL error "+url+ "  suffix: "+suffix);
    error = true;
    return fileList;
  }

  String str = new String();
  for (int i=0; i<lines.length; i++) {
    println(lines[i]);
    str += lines[i];
  }
  matchPattern(str, url, fileList, suffix, filter);

  if (fileList.size() == 0) {
    showMsg("No Photos");
    println("No photos");
  } else {
    for (String[] s : fileList) {
      println( s[0] + " suffix="+s[1]);
    }
  }
  count = 0;
  println();
  //Collections.sort(fileList, String.CASE_INSENSITIVE_ORDER);
  return fileList;
}

public class ReadWriteFile
{
  public int readWrite(String inputUrl, String writeFolder, String suffix, int index)
  {
    int numberWritten = 0;
    URL url = null;
    try
    {
      url = new URL(inputUrl);
    }
    catch (MalformedURLException e1)
    {
      e1.printStackTrace();
      return numberWritten;
    }
    println("read " + inputUrl);

    try
    {
      String filename = inputUrl.substring(inputUrl.lastIndexOf(File.separator)+1);
      println("filename="+filename);
      if (suffix.equals("") ) {
        println("no suffix for URL");
      } else {
        if (!hasSuffix(filename)) {
          String name = filename.substring(0, filename.lastIndexOf("."));
          String filetype = filename.substring(filename.lastIndexOf("."));
          filename=name+suffix+filetype;
        }
      }
      File envdir = Environment.getExternalStorageDirectory();
      String path = envdir.getAbsolutePath();
      String dir = path+File.separator+writeFolder;
      println("path="+path);
      println("dir="+dir);
      File d = new File(dir);
      if (!d.exists()) {
        try {
          boolean done = d.mkdirs();
          if (done)
            println("Directory "+dir+" created");
          else {
            println("Directory "+dir+" not created");
            println("ERROR");
            exit();
          }
        }
        catch (Exception e) {
          e.printStackTrace();
        }
      }
      String loc = path + File.separator + writeFolder + File.separator + filename;
      String filetype= filename.substring(filename.lastIndexOf(".")+1);
      println("File="+ loc + " Filetype="+filetype+ " index="+index);
      lastFile[index] = loc;
      File f = new File(loc);
      if (f.exists()) {
        println("Skip file already exists "+loc);
      } else if (f.isDirectory()) {
        println("Skip file directory "+loc);
      } else {
        saveFile(inputUrl, loc);
        //image = ImageIO.read(url);
        //println("Write image " + filename);
        //ImageIO.write(image, filetype, new File(loc));
        println("Wrote image "+loc);
        numberWritten++;
      }
    }
    catch (IOException e)
    {
      e.printStackTrace();
      return -1;
    }
    return numberWritten;
  }

  public void saveFile(String fileUrl, String destinationFile) throws IOException {
    URL url = new URL(fileUrl);
    InputStream is = url.openStream();
    OutputStream os = new FileOutputStream(destinationFile);

    byte[] b = new byte[1500];
    int length;

    while ((length = is.read(b)) != -1) {
      os.write(b, 0, length);
    }

    is.close();
    os.close();
  }
}

public static boolean isPhoto(String s) {
  String lcs = s.toLowerCase();
  return lcs.endsWith(".jpg") || lcs.endsWith(".png") || lcs.endsWith(".mpo")
    || lcs.endsWith(".jps")     || lcs.endsWith(".dng") || lcs.endsWith(".srw")
    || lcs.endsWith(".gif") || lcs.endsWith(".webp")
    || lcs.endsWith(".jpeg") || lcs.endsWith(".bmp") || lcs.endsWith(".wbmp")
    || lcs.endsWith(".nef")
    ;
}

public static boolean isRawPhoto(String s) {
  String lcs = s.toLowerCase();
  return lcs.endsWith(".dng") || lcs.endsWith(".srw")
    || lcs.endsWith(".nef")
    //    || lcs.endsWith(".nv21")
    ;
}

public static boolean isVideo(String s) {
  String lcs = s.toLowerCase();
  return lcs.endsWith(".mp4") || lcs.endsWith(".mov");
}

public static boolean isUrlPhoto(String s) {
  int i = s.lastIndexOf('?');
  if (i > 0) {
    return isPhoto(s.substring(0, i));
  }
  return isPhoto(s);
}

public static boolean hasSuffix(String s) {
  String lcs = s.toLowerCase();
  int i = lcs.lastIndexOf('.');
  String name = s.substring(0, i);
  return name.endsWith("_l") || name.endsWith("_r")
    || name.endsWith("-l") || name.endsWith("-r")
    || name.endsWith("_left") || name.endsWith("_right");
}


public static boolean isUrlVideo(String s) {
  int i = s.lastIndexOf('?');
  if (i > 0) {
    return isVideo(s.substring(0, i));
  }
  return isVideo(s);
}

private void matchPattern(final String str, final String tUrl,
  final ArrayList<String[]> list, String suffix, String filter) {
  println("tUrl = "+tUrl);
  Matcher m = pattern.matcher(str);
  println("match PATTERN ");
  while (m.find()) {
    String filename = null;
    String match = m.group(1);
    //println(match);
    if (match != null && match.endsWith("_2x1.jpg") && (isUrlPhoto(match) || isUrlVideo(match))) {
      println("MATCHING   "+match);
      filename = tUrl + File.separator + match.substring(12);
      //filename.replaceAll("\\", "/");
      if (match.startsWith("http://") || match.startsWith("https://")) {
        filename = match;
      } else if (match.startsWith("/") && !match.startsWith("/cgi")
        || match.startsWith("/image")) {
        //Log.d(TAG, "tUrl="+tUrl);
        String start = tUrl.substring(0, tUrl.indexOf("//") + 2);
        
        //Log.d(TAG, "start=" + start);
        String remainder = tUrl.substring(tUrl.indexOf("//") + 2);
        //Log.d(TAG, "remainder=" + remainder);
        int x = remainder.indexOf("File.separator");
        if (x < 0)
          filename = (start + remainder + match);
        else
          filename = (start + remainder.substring(0, remainder.indexOf("/")) + match);
        filename = "http://192.168.0.100/"+match;
      } else if (match.startsWith("../")) {
        filename = tUrl.substring(0, tUrl.lastIndexOf("/") + 1) +
          match.substring(0, match.lastIndexOf("/")) +
          match.replaceAll("\\.\\..*\\?", "/");  // remove .. to ? text
      } else {
        int q = match.lastIndexOf("?");
        if (q> 0) {
          filename = (tUrl.substring(0, tUrl.lastIndexOf("/") + 1) +
            match.substring(0, q));
        } else {
          filename = (tUrl.substring(0, tUrl.lastIndexOf("/") + 1) +
            match);
        }
        println("1 filename="+filename);
        filename = tUrl + File.separator +"data"+File.separator+"images"+File.separator+match.substring(12);
        println("new1 filename="+filename);
      }
    } else if (match != null && (isPhoto(match) || isVideo(match))) {
      if (match.startsWith("http://") || match.startsWith("https://")) {
        filename = match;
      } else {
        int q = match.lastIndexOf("?");
        if (q> 0) {
          filename = (tUrl.substring(0, tUrl.lastIndexOf("/") + 1) +
            match.substring(match.lastIndexOf("?") + 1));
        } else {
          filename = (tUrl.substring(0, tUrl.lastIndexOf("/") + 1) +
            match);
        }
        println("2filename="+filename);
      }
    }

    if (filename != null) {
      //println("filename="+filename);
      if (rawOnly) {
        if (!isRawPhoto(filename)) {
          filename = null;
        }
      } else {
        if (isRawPhoto(filename)) {
          filename = null;
        }
      }
    }
    println("test filename="+filename);
    println();
    try {
      if (filename != null) {
        //filename.replace("\\", File.separator);
        //filename.replace("http://", "http://192.168.0.100:80/");
        if (!filename.endsWith("_2x1.jpg")) filename = null;
        println("found 2x1 "+filename);
        //if (!(filename.substring(filename.lastIndexOf('/')+1).startsWith(filter))) {
        //  filename = null;
        //}
      }
    }
      catch(Exception eee) {
        println(eee);
        
      }
      

        if (filename != null) {
        boolean found = false;
        for (int i = 0; i < list.size(); i++) {
          String[] strs = list.get(i);
          if (strs[0].equals(filename)) {
            found = true;
            break;
          }
        }
        if (!found) {
          String[] store = new String[2];
          store[0] = filename;
          store[1] = getSuffix(suffix);
          println("found in PATTERN " + filename);
          list.add(store);
        }
        //println("found in PATTERN " + filename);
      }
    }
  }

  String getSuffix(String suffix) {
    String sym = "#";
    int i = suffix.indexOf(sym);
    String sCounter = "0";
    if (i>=0) {
      fileCounter++;
      if (fileCounter<10)
        sCounter = "00"+str(fileCounter);
      else if (fileCounter<100)
        sCounter = "0"+str(fileCounter);
      else
        sCounter = str(fileCounter);
      String result = suffix.replace(sym, sCounter);
      return result;
    }
    return suffix;
  }

  public static final Comparator<String> CASE_INSENSITIVE_PAIR_ORDER
    = new CaseInsensitivePairComparator();

  private static class CaseInsensitivePairComparator
    implements Comparator<String>, java.io.Serializable {
    // use serialVersionUID from JDK 1.2.2 for interoperability
    private static final long serialVersionUID = 8575799808933029326L;

    public int compare(String s1, String s2) {
      String las1 = s1.substring(s1.lastIndexOf('/'), s1.lastIndexOf('.'));
      String las2 = s2.substring(s2.lastIndexOf('/'), s2.lastIndexOf('.'));
      int n1 = las1.length();
      int n2 = las2.length();
      int min = Math.min(n1, n2);
      for (int i = 0; i < min; i++) {
        char c1 = las1.charAt(i);
        char c2 = las2.charAt(i);
        if (c1 != c2) {
          c1 = Character.toUpperCase(c1);
          c2 = Character.toUpperCase(c2);
          if (c1 != c2) {
            c1 = Character.toLowerCase(c1);
            c2 = Character.toLowerCase(c2);
            if (c1 != c2) {
              // No overflow because of numeric promotion
              return c1 - c2;
            }
          }
        }
      }
      return n1 - n2;
    }
  }

  //-----------------------------------------------------------------------------

  public String getDateTime() {
    Date current_date = new Date();
    String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
    return timeStamp;
  }

  public String getWifiBroadcastIpAddress() {
    try {
      for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en
        .hasMoreElements(); ) {
        NetworkInterface intf = en.nextElement();
        Enumeration<NetworkInterface> niEnum = NetworkInterface.getNetworkInterfaces();
        while (niEnum.hasMoreElements())
        {
          NetworkInterface ni = niEnum.nextElement();
          if (!ni.isLoopback()) {
            for (InterfaceAddress interfaceAddress : ni.getInterfaceAddresses())
            {
              if (interfaceAddress.getBroadcast()!= null) {
                //println(interfaceAddress.getBroadcast().toString());
                return (interfaceAddress.getBroadcast().toString().substring(1));
              }
            }
          }
        }
      }
    }
    catch (SocketException ex) {
      println(ex.toString());
    }
    return null;
  }

  //String[] getPage(String filename) {
  //  String[] result = null;
  //  HttpURLConnection urlConnection = null;
  //  try {
  //    URL url = new URL(filename);

  //    urlConnection = (HttpURLConnection) url.openConnection();
  //    urlConnection.setRequestMethod("GET");
  //    urlConnection.setDoInput(true);
  //    urlConnection.addRequestProperty("User-Agent", "SPViewer");
  //    InputStream in = new BufferedInputStream(urlConnection.getInputStream());
  //    result = loadStrings(in);
  //  }
  //  catch (Exception e) {
  //  }
  //  finally {
  //    if (urlConnection != null)
  //      urlConnection.disconnect();
  //  }
  //  return result;
  //}
