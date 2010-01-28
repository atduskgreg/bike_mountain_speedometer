/* this is a simple change, just for demo */
#include <Stepper.h>

#define STEPS 200


// hello from the drive by

int reedSwitch = 5;
long startTime = 0;
int revsPer = 0;
float runningAve = 0;
long lastSeen = 0;
int basePin = 3;
int peakPin = 4;
float rpm = 0;

float lastFour[] = {
  0,0,0,0};

Stepper stepper(STEPS, 12, 11, 8, 7);

float ave(float nums[]){
  float sum = 0;
  for(int i = 0; i < 4; i++){
    sum = sum + nums[i];
  }
  return sum / 4.0; 
}

void pushOnArray(float incoming, float arr[]){
  for(int i = 3; i > 0; i--){
    arr[i] = arr[i -1];
  }
  arr[0] = incoming;
}


void setup(){
  pinMode(reedSwitch, INPUT);
  pinMode(basePin, INPUT);
  pinMode(peakPin, INPUT);
  Serial.begin(9600);
  startTime = millis(); 

  digitalWrite(10, HIGH); // enable
  digitalWrite(6, HIGH); // enable

  stepper.setSpeed(50);
}

void loop(){
  int atBase = digitalRead(basePin); 
  int atPeak = digitalRead(peakPin);
  // ====BEGIN RPM CODE=======
  digitalWrite(13, LOW);
  if(revsPer < 4){
    if(digitalRead(reedSwitch) && (millis() > lastSeen + 300)){
      digitalWrite(13, HIGH);
      revsPer++;

      long thisInterval = millis() - lastSeen;

      pushOnArray(thisInterval, lastFour);
      lastSeen = millis();
    } 
  } 
  else {
    runningAve = ave(lastFour); // this is now average time for 1/2 wheel rev
    float wheelTime = runningAve * 2;
    rpm = 60000 / wheelTime;

    revsPer = 0;
    startTime = millis();
  }

  //====COMMUNICATE WITH PROCESSING
  Serial.print(rpm);
  Serial.print(",");
  Serial.print(atBase);
  Serial.print(",");
  Serial.print(atPeak);
  Serial.println(",");

  //=====DECIDE WHERE TO MOVE
  if(atBase){
   // Serial.println("up atBase");
    stepper.step(1);
  } 
  else {
    if(rpm < 50){
    //Serial.println("down under 50");
      stepper.step(-1);
    } 
    else {
      if(atPeak != 1){
      //  Serial.println("up not at top");
        stepper.step(1);
      }
    }
  }
}

