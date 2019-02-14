//Andrew Afflitto
//CPE-592
//HW1 - steganography
//Built with Processing 3.5.2

PImage original, lsbStego, msbStego;
PImage lsbDiff, msbDiff;
String name = "Andrew Afflitto"; //plaintext to be hidden
String keyStr = "I pledge my honor that I have abided by the Stevens Honor System"; //used to calculate the key

void setup() {
  size(480, 720);
  
  //load original image into all three PImages
  original = loadImage("original.jpg");
  lsbStego = loadImage("original.jpg");
  msbStego = loadImage("original.jpg");
  
  //load PImage pixel arrays
  lsbStego.loadPixels();
  msbStego.loadPixels();
  
  //calculate number of bits in plaintext string
  int numBits = name.length() * 8;
  
  //calculate the sum of key to be used as a random seed
  int keyInt = 0;
  for(int i = 0; i < keyStr.length(); i++) {
    keyInt += keyStr.charAt(i);
  }
  randomSeed(keyInt);
  int randomKey = (int)random(0, lsbStego.pixels.length);
  
  //modify lsb image
  for(int i = 0; i < numBits; i += 3) { //increment by 3 because 3 bits are stored per pixel (3 color channels)
    int index = (randomKey + i/3) % lsbStego.pixels.length; //Current pixel, offset by the key
    
    //get original pixel colors
    char r = (char) (lsbStego.pixels[index] >> 16 & 0xff);
    char g = (char) (lsbStego.pixels[index] >> 8  & 0xff);
    char b = (char) (lsbStego.pixels[index] >> 0  & 0xff);
    
    //set the LSB of each byte
    b = setLsb(b, nthBitInString(name, i));
    g = setLsb(g, nthBitInString(name, i+1));
    r = setLsb(r, nthBitInString(name, i+2));
     
    //recombine the R G and B bytes
    lsbStego.pixels[index] = r << 16 | g << 8 | b;
  }
  //update pixel buffer
  lsbStego.updatePixels();
  
  //modify msb image
  for(int i = 0; i < numBits; i += 3) { //increment by 3 because 3 bits are stored per pixel (3 color channels)
    int index = (randomKey + i/3) % msbStego.pixels.length; //Current pixel, offset by the key
    
    //get original pixel colors
    char r = (char) (msbStego.pixels[index] >> 16 & 0xff);
    char g = (char) (msbStego.pixels[index] >> 8  & 0xff);
    char b = (char) (msbStego.pixels[index] >> 0  & 0xff);
    
    //set the MSB of each byte
    b = setMsb(b, nthBitInString(name, i));
    g = setMsb(g, nthBitInString(name, i+1));
    r = setMsb(r, nthBitInString(name, i+2));
    
    //recombine the R G and B bytes
    msbStego.pixels[index] = r << 16 | g << 8 | b;
  }
  //update pixel buffer
  msbStego.updatePixels();
  
  //save images
  lsbStego.save("lsb.jpg");
  msbStego.save("msb.jpg");
  
  //optional: calculate diff between steg and original
  
  lsbDiff = diff(original, lsbStego);
  msbDiff = diff(original, msbStego);
  //lsbDiff.save("lsbDiff.png");
  //msbDiff.save("msbDiff.png");
}

void draw() {
  //draw diffs onto screen to see where the changes are
  image(lsbDiff, 0, 0, 480, 360);
  text("lsb", 10, 10);
  
  image(msbDiff, 0, 360, 480, 360);
  text("msb", 10, 370);
}

//sets or clears the LSB of a given byte
char setLsb(char originalChar, boolean isSet) { 
  if(isSet) {
    return (char)(originalChar | 1);
  } else {
    return (char)(originalChar & 0xfe);
  }
}

//sets or clears the MSB of a given byte
char setMsb(char originalChar, boolean isSet) { 
  if(isSet) {
    return (char)(originalChar | 0x80);
  } else {
    return (char)(originalChar & 0x7f);
  }
}

//get the nth byte of a given string
boolean nthBitInString(String str, int n) {
  if(n >= str.length()*8) { //just return false instead of indexing out of bounds
    return false;
  }
  
  char bitAsChar = (char) (str.charAt(n/8) >> (n % 8) & 1); //when n = 0-7, get bits of char 0, when 8-15, get bits of char 1, etc
  
  return bitAsChar == 1; //true if bit is set, false if bit is clear
}

PImage diff(PImage a, PImage b) { //highlight difference between images a and b
  if(a.width != b.width || a.height != b.height) {
    return createImage(0, 0, RGB);
  } //just return an empty image if images are not the same size
  
  
  PImage diffImage = createImage(a.width, a.height, RGB); //create blank image
  
  //load pixel arrays
  diffImage.loadPixels();
  a.loadPixels();
  b.loadPixels();
  
  //iterate through all pixels
  for(int i = 0; i < diffImage.pixels.length; i++) {
    //calculate absolute difference for each color channel
    int diffR = abs((a.pixels[i] >> 16 & 0xff) - (b.pixels[i] >> 16 & 0xff));
    int diffG = abs((a.pixels[i] >>  8 & 0xff) - (b.pixels[i] >>  8 & 0xff));
    int diffB = abs((a.pixels[i] >>  0 & 0xff) - (b.pixels[i] >>  0 & 0xff));
    
    //reassemble pixel
    diffImage.pixels[i] = diffR << 16 | diffG << 8 | diffB;
  }
  
  //update pixels
  diffImage.updatePixels();
  
  return diffImage;
}
