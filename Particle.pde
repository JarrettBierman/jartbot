

public class Particle{
  PVector pos;
  PVector vel;
  PVector acc;
  float maxSpeed;
  
  public Particle(float x, float y){
    this.pos = new PVector(x, y);
    this.vel = new PVector(0, 0);
    this.acc = new PVector(0, 0);
    this.maxSpeed = 5;
  }
  
  public PVector getPos(){
    return this.pos;
  }

  public PVector getVel(){
      return this.vel;
  }

  public float getFieldValue(float scale){
    int row = floor(this.pos.x / scale);
    int col = floor(this.pos.y / scale);
    try{
        return flowfield[row][col].heading();
    }
    catch(Exception e){
        return flowfield[0][0].heading();
    }
  }

  public float getMaxSpeed() {
      return this.maxSpeed;
  }
  public void setMaxSpeed(float value) {
      this.maxSpeed = value;
  }
  
  public void update(){
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }
  
  public void applyForce(PVector force){
    this.acc.add(force);
  }
  
  public void show(){
    ellipse(this.pos.x, this.pos.y, 10, 10);
  }
  
  public void follow(float scale, PVector[][] flowfield){
    this.edges();
    int row = floor(this.pos.x / scale);
    int col = floor(this.pos.y / scale);
    if(row >= 0 && row < flowfield.length && col >= 0 && col < flowfield[0].length)
      this.applyForce(flowfield[row][col]);
  }
  
  public void edges() {
    if (pos.x > width) {
      pos.x = 0;
    }
    if (pos.x < 0) {
      pos.x = width;    
    }
    if (pos.y > height) {
      pos.y = 0;
    }
    if (pos.y < 0) {
      pos.y = height;
    }
  }

}
