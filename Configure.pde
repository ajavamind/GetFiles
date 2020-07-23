// Read XML file for configuration

static final int XML_ERROR = -1;
volatile File xmlFile;
XML xml;

void fileSelected(File selection) {
  if (selection == null) {
    println("Selection window was closed or the user hit cancel.");
    showMsg("Selection window was closed or canceled.");
    xmlFile = null;
    found = true;
  } else {
    xmlFile = selection;
    println("User selected " + selection.getAbsolutePath());
    found = true;
  }
}

/** read XML file to configure
 * call from setup() only
 * return 0 ok XML_ERROR
 */
int configure(String xmlFilename) {
  inputDialog();
  while (!found) {
    delay(100);
  }
  if (xmlFile != null) {
    String name = xmlFile.getAbsolutePath();
    String[] xmlS = loadStrings(name);
    //for (int i=0; i<xmlS.length; i++) {
    //  println(xmlS[i]);
    //}
    xmlFilename = "temp_$.xml";
    saveStrings(xmlFilename, xmlS);
    println("XML configuration file "+xmlFilename);
  } else {
    xmlFilename = "temp_$.xml"; // use last saved
    println("Use last saved configuration file: "+xmlFilename);
    //return XML_ERROR;
  }

  try {
    xml = loadXML(xmlFilename);
  }
  catch (Exception e) {
    e.printStackTrace();
    return XML_ERROR;
  }
  if (xml == null) {
    return XML_ERROR;
  }
  XML[] scan = xml.getChildren("scan");
  XML[] storage = xml.getChildren("storage");
  XML[] httpserver = xml.getChildren("httpserver");
  XML[] trigger = xml.getChildren("trigger");

  if (scan.length > 0) {
    PATTERN = scan[0].getString("pattern");
  }
  println("PATTERN="+PATTERN);
  if (storage.length > 0) {
    rawOnly = storage[0].getString("rawOnly").equals("true");
  }
  println("rawOnly="+rawOnly);

  saveFolder = new String[httpserver.length];
  httpUrlList = new String[httpserver.length];
  udpIpList = new String[httpserver.length];
  suffix = new String[httpserver.length];
  description = new String[httpserver.length];
  rotate = new int[httpserver.length];
  flip = new int[httpserver.length];
  filter = new String[httpserver.length];
  
  for (int i = 0; i < httpserver.length; i++) {
    String name =httpserver[i].getName();
    println( name);
    println(httpserver[i].getString("httpurl"));
    println(httpserver[i].getString("name"));
    println(httpserver[i].getString("savefolder"));
    println(httpserver[i].getString("suffix"));
    println(httpserver[i].getInt("rotate"));
    println(httpserver[i].getInt("flip"));

    httpUrlList[i] = httpserver[i].getString("httpurl");
    description[i] = httpserver[i].getString("name");
    saveFolder[i] = httpserver[i].getString("savefolder");
    suffix[i] = httpserver[i].getString("suffix");
    rotate[i] = httpserver[i].getInt("rotate");
    flip[i] = httpserver[i].getInt("flip");
    filter[i] = httpserver[i].getString("filter");
  }

  udpIpList = new String[trigger.length];
  udpPort = new int[trigger.length];
  udpName = new String[trigger.length];

  for (int i = 0; i < trigger.length; i++) {
    String name =trigger[i].getName();
    println( name);
    println(trigger[i].getString("name"));
    println(trigger[i].getString("ipaddr"));
    println(trigger[i].getInt("port"));

    udpIpList[i] = trigger[i].getString("ipaddr");
    udpPort[i] = trigger[i].getInt("port");
    udpName[i] = trigger[i].getString("name");
  }
  return 0;
}
