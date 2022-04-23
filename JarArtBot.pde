import java.io.*;
import java.util.*;

boolean SAVE_ON = true;
int SCALE = 4;
PGraphics exp;

Particle p;
float scl;
int rows;
int cols;
float randOff;
float zoff;
PVector[][] flowfield;
float floTime, changeTime;
int floTimeThresh, changeTimeThresh;
float a;

int[] randFillKeys, randStrokeKeys;
int randStrokeHue, randStrokeSize;
int randSizeKey, randMaxSize;

int numDrawings;


void setup(){
    if(args != null) {
        println(args.length);
        for (int i = 0; i < args.length; i++) {
            println(args[i]);
        }
    }
    size(800,800);
    exp = createGraphics(3200, 3200);
    scl = 10;
    numDrawings = 0;
    rows = floor(height/scl);
    cols = floor(width/scl);
    flowfield = new PVector[rows][cols];
    zoff = 0;
    updateFlowField();
    p = new Particle(width/2, height/2);
    a = 0;

    // timing stuff
    floTimeThresh = 2;
    changeTimeThresh = 30;
    saveAndChange();
}



void draw(){
  floTime = (System.currentTimeMillis() / 100) % (10 * floTimeThresh);
  changeTime = (System.currentTimeMillis() / 100) % (10 * changeTimeThresh);
  if(floTime == 0){
    updateFlowField();
  }
  if(changeTime == 0) {
    saveAndChange();
  }
    p.update();
    p.follow(scl, flowfield);
    float xx = p.getPos().x;
    float yy = p.getPos().y;
    float size = getRandomSize(randSizeKey, randMaxSize);


    // draw to exporting canvas at 4x scale
    beginRecord(exp);
        exp.scale(4);
        exp.fill(getRandomColor(randFillKeys));
        exp.stroke(getRandomColor(randStrokeKeys, randStrokeHue));
        exp.strokeWeight(randStrokeSize);

        exp.ellipse(xx, yy, size, size/2);
        exp.ellipse(yy, xx, size, size);

        exp.ellipse(width - xx, width - yy, size, size);
        exp.ellipse(width - yy, width - xx, size, size);

        exp.ellipse(xx, width - yy, size, size);
        exp.ellipse(yy, width - xx, size, size);

        exp.ellipse(width - xx, yy, size, size);
        exp.ellipse(width - yy, xx, size, size);
    endRecord();

    // draw to preview canvas
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


void updateFlowField(){
  float mag = 1;
  noiseSeed(System.currentTimeMillis());
  int randAngle = floor(random(360) - 180);
  float yoff = 0;
  for(int r = 0; r < rows; r++){
    float xoff = 0;
    for(int c = 0; c < cols; c++){
      float angle = noise(xoff, yoff) * TWO_PI;
      //PVector v = PVector.fromAngle(radians(a));
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

void saveAndChange() {

    // Save Image
    String imageName = "jarArt--"+year()+"-"+month()+"-"+day()+"--"+numDrawings;
    if(SAVE_ON && numDrawings != 0){
        PImage temp = exp.get();
        temp.save("\\drawings\\"+imageName+".png");
        println("Saved sketch " + imageName);
        println(numDrawings + "/24 Drawings Complete");
    }

    // increase drawing count
    numDrawings++;
    exp = createGraphics(3200, 3200);

    // close once 25 drawings have been made
    if(numDrawings >= 24) {
        exit();
    }

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
    p.setMaxSpeed(random(4,13));

    // random drawing duration
    changeTimeThresh = floor(random(15,45));

    // DEBUG
    // qualityControl();

    // Restart Canvas
    delay(500);
    int[] rands = new int[]{int(random(100,255)), int(random(100,255)), int(random(100,255))};
    // export background
    beginRecord(exp);
    exp.background(rands[0], rands[1], rands[2]);
    endRecord();
    // preview background
    background(rands[0], rands[1], rands[2]);
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

void qualityControl() {
//    randFillKeys = new int[]{8,8,8};
//    randStrokeKeys = 42;
//    randStrokeHue = 42;
//    randMaxSize = 200;
//    randStrokeSize = 0;
   randSizeKey = 8;
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

// void saveHighRes(String path, int scaleFactor) {
//   PGraphics hires = createGraphics(
//                         width * scaleFactor,
//                         height * scaleFactor,
//                         JAVA2D);
//   println("Generating high-resolution image...");

//   beginRecord(hires);
//   hires.scale(scaleFactor);
//   seededRender();
//   endRecord();

//   hires.save(path + "-highres.png");
//   println("Finished");
// }

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
