import java.io.*;
import java.util.*;

// String NUM_FILE_PATH = "C:\\Users\\jarre\\Documents\\Processing\\code\\JarArtBot\\drawingNum.txt";
String NUM_FILE_PATH = "C:\\Users\\jarrettvm\\Desktop\\JarArtBot\\drawingNum.txt";

boolean DEBUG = false;

PGraphics exp;
Particle p;
float scl;
int rows;
int cols;
float randOff;
float zoff;
PVector[][] flowfield;
int floTime, changeTime;
int floTimeThresh, floTimeBuffer, changeTimeThresh;
float a;

int[] randFillKeys, randStrokeKeys;
int randStrokeHue, randStrokeSize;
int randSizeKey, randMaxSize;

int numDrawings;
int maxDrawings;

int totalDrawings;

void setup(){
    if(args != null) {
        maxDrawings = int(args[0]);
    }
    else {
        maxDrawings = -1;
    }

    numDrawings = 0;

    try {
        File f = new File(NUM_FILE_PATH);
        Scanner fr = new Scanner(f);
        totalDrawings = int(fr.nextLine());
    }
    catch (FileNotFoundException e) {
        println(e);
    }

    size(800,800);
    scl = 10;
    rows = floor(height/scl);
    cols = floor(width/scl);
    flowfield = new PVector[rows][cols];
    zoff = 0;
    updateFlowField();
    p = new Particle(width/2, height/2);
    a = 0;

    // timing stuff
    floTime = 0;
    floTimeThresh = 2;
    changeTime = 0;
    exp = createGraphics(2400, 2400);
    changeParameters();
}

void draw() {
    // exit
    if(maxDrawings != -1 && numDrawings >= maxDrawings) {
        exit();
    }

    // tick
    if(frameCount % 60 == 0) {
        timerTick();
    } 

    p.update();
    p.follow(scl, flowfield);
    float xx = p.getPos().x;
    float yy = p.getPos().y;
    float size = getRandomSize(randSizeKey, randMaxSize);

    // draw to exporting canvas at 4x scale
    beginRecord(exp);
        exp.scale(3);
        exp.fill(getRandomColor(randFillKeys));
        exp.stroke(getRandomColor(randStrokeKeys, randStrokeHue));
        exp.strokeWeight(randStrokeSize);

        exp.ellipse(xx, yy, size, size);
        exp.ellipse(yy, xx, size, size);

        exp.ellipse(width - xx, width - yy, size, size);
        exp.ellipse(width - yy, width - xx, size, size);

        exp.ellipse(xx, width - yy, size, size);
        exp.ellipse(yy, width - xx, size, size);

        exp.ellipse(width - xx, yy, size, size);
        exp.ellipse(width - yy, xx, size, size);
    endRecord();

    if(DEBUG) {
        fill(getRandomColor(randFillKeys));
        stroke(getRandomColor(randStrokeKeys, randStrokeHue));
        strokeWeight(randStrokeSize);
        fill(getRandomColor(randFillKeys));
        stroke(getRandomColor(randStrokeKeys, randStrokeHue));
        strokeWeight(randStrokeSize);

        ellipse(xx, yy, size, size);
        ellipse(yy, xx, size, size);

        ellipse(width - xx, width - yy, size, size);
        ellipse(width - yy, width - xx, size, size);

        ellipse(xx, width - yy, size, size);
        ellipse(yy, width - xx, size, size);

        ellipse(width - xx, yy, size, size);
        ellipse(width - yy, xx, size, size);
    }
}

void timerTick() {
    floTime += 1;
    changeTime += 1;
    print("FPS:\t" + ceil(frameRate) + "\t\tTime:\t" + changeTime + "/" + changeTimeThresh + "             \r");

    if(floTime == floTimeThresh){
        updateFlowField();
        floTime = 0;
    }

    if(changeTime == changeTimeThresh) {
        if(maxDrawings != -1) {
            saveSketch();
        }
        changeParameters();
        changeTime = 0;
    }
}

void updateFlowField(){
  float mag = 0.15;
  noiseSeed(System.currentTimeMillis());
  int randAngle = floor(random(360) - 180);
  float yoff = 0;
  for(int r = 0; r < rows; r++){
    float xoff = 0;
    for(int c = 0; c < cols; c++){
      float angle = noise(xoff, yoff) * TWO_PI;
      PVector v = PVector.fromAngle(angle + radians(randAngle));
      v.setMag(mag);
      if(floor(random(2)) == 0){
        v.mult(1);
      }
      flowfield[r][c] = v;
      xoff += randOff;
    }
    yoff += randOff;
  }
}

void saveSketch() {
    String drawNumStr = String.format("%05d", totalDrawings);
    String imageName = "botdraw-" + drawNumStr;
    PImage temp = exp.get();
    temp.save("\\drawings\\"+imageName+".png");
    numDrawings++;

    println("Saved sketch " + imageName + "                           ");
    println(numDrawings + "/" + maxDrawings + " Drawings Complete");
    totalDrawings++;
    try{
        FileWriter fw = new FileWriter(NUM_FILE_PATH);
        fw.write(totalDrawings + "");
        fw.close();
    }
    catch(IOException e) {
        println(e);
    }
}

void changeParameters() {
    // random colors
    int numOptions = 9;
    int tempRand = floor(random(10));
    if(tempRand == 0) {
        int randKey = floor(random(numOptions));
        randFillKeys = new int[]{randKey, randKey, randKey};
        randStrokeKeys = new int[]{randKey, randKey, randKey};
    }
    else if(tempRand < 4) {
        int []randKeys = {floor(random(numOptions)), floor(random(numOptions)), floor(random(numOptions))};
        randFillKeys = randKeys;
        randStrokeKeys = randKeys;
    }
    else{
        randFillKeys = new int[]{floor(random(numOptions)), floor(random(numOptions)), floor(random(numOptions))};
        randStrokeKeys = new int[]{floor(random(numOptions)), floor(random(numOptions)), floor(random(numOptions))};
    }
    randStrokeHue = (floor(random(2)) == 0) ? 255 : 128; 

    // random sizes
    randStrokeSize = floor(random(4));
    randMaxSize = floor(random(20,120));
    randSizeKey = floor(random(numOptions));

    // random flow field attributes
    randOff = random(0.05, 0.3);
    updateFlowField();

    // random particle attributes
    p.setMaxSpeed(random(5,15));

    // random drawing duration
    changeTimeThresh = floor(random(5,28));

    // Restart Canvas
    delay(500);
    int[] rands = new int[]{int(random(100,255)), int(random(100,255)), int(random(100,255))};
    beginRecord(exp);
        exp.clear();
        exp.background(rands[0], rands[1], rands[2]);
    endRecord();

    // preview background
    if(DEBUG) {
        background(rands[0], rands[1], rands[2]);
    }
    printRandoms();
}


// helper functions
float getRandomAttrVal(int key, int range) {
    float[] choices = new float[] {
        mapPos(true, range),
        mapPos(false, range),
        range - mapPos(true, range),
        range - mapPos(false, range),
        mapFlow(range),
        range-mapFlow(range),
        mapDistCenter(range),
        range-mapDistCenter(range),
        random(range),
    };
    // DEBUG
    return choices[key % choices.length];
}

color getRandomColor(int[] keys) {return getRandomColor(keys, 255);}
color getRandomColor(int[] keys, int range) {
    return color(getRandomAttrVal(keys[0], range), 
                 getRandomAttrVal(keys[1], range), 
                 getRandomAttrVal(keys[2], range));
}

float getRandomSize(int ret, int maxSize) {
    return getRandomAttrVal(ret, maxSize);
}

float mapPos(boolean isX, int small, int big) {
  if(isX)  return map(p.getPos().x, 0, width, small, big);
  return map(p.getPos().y, 0, height, small, big);
}

float mapPos(boolean isX, int big) {
  return mapPos(isX, 0, big);
}

float mapFlow(int small, int big) {
    return map(p.getFieldValue(scl), -PI, PI, small, big);
}
float mapFlow(int big) {
    return mapFlow(0, big);
}

float mapDistCenter(int small, int big) {
    float d = PVector.dist(p.getPos(), new PVector(width/2, height/2));
    return map(d, 0, 680, small, big);
}

float mapDistCenter(int big){
    return mapDistCenter(0, big);
}

void printRandoms() {
    println("----RANDOM VARIABLES----");
    println("Fill Key:  \t" + Arrays.toString(randFillKeys));
    println("Stroke Key:\t" + Arrays.toString(randStrokeKeys));
    println("Stroke Weight:\t" + randStrokeSize);
    println("Size Key:\t" + randSizeKey);
    println("Size Max:\t" + randMaxSize);
    println("Max Speed:\t" + p.getMaxSpeed());
    println("Drawing Time:\t" + changeTimeThresh);
}
