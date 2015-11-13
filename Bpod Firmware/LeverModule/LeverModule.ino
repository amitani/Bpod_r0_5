#include <stdio.h>

const unsigned long interval = 1; // ms
unsigned long last_millis=millis();
unsigned long wait_until_next(){
  while(millis()-last_millis>interval){
    last_millis+=interval;
  }
  while(millis()-last_millis<interval){
    delayMicroseconds(1);
  }
  last_millis+=interval;
  return last_millis;
}

String serialBuffer;
String command;
const int pin[2]={13,12};
void setup() {
  // put your setup code here, to run once:
   Serial.begin(115200);
   analogReadResolution(12);
   serialBuffer.reserve(200);
   command.reserve(200);
   
   pinMode(pin[0], OUTPUT);
   pinMode(pin[1], OUTPUT);
}

unsigned long current_millis;
unsigned int current_millis_remainder;
int val;
int threshold[4]={1600,2800,1200,1600};
unsigned long window=200; // ms
unsigned long last_below_threshold[2]={1,0};
int i;
char output[20];
char flag[2];

void loop() {
  while (Serial.available()){
    char c=(char)Serial.read();
    serialBuffer += c;
  }
  
  while(serialBuffer.indexOf('\n')>=0){
    command=serialBuffer.substring(0,serialBuffer.indexOf('\n'));
    serialBuffer.remove(0,1+serialBuffer.indexOf('\n'));
    if(command.startsWith("T1 ")){
      command=command.substring(command.indexOf(' ')+1);
      threshold[0]=command.toInt();      
    }else if(command.startsWith("T2 ")){
      command=command.substring(command.indexOf(' ')+1);
      threshold[1]=command.toInt(); 
    }else if(command.startsWith("T3 ")){
      command=command.substring(command.indexOf(' ')+1);
      threshold[2]=command.toInt(); 
    }else if(command.startsWith("T4 ")){
      command=command.substring(command.indexOf(' ')+1);
      threshold[3]=command.toInt(); 
    }else if(command.startsWith("I ")){
      command=command.substring(command.indexOf(' ')+1);
      window=command.toInt();
    }
  }
  
  current_millis=wait_until_next();
  val = analogRead(0);
  
  for(i=0;i<2;i++){
    if(val<threshold[i]) last_below_threshold[i]=current_millis;  
  }
  
  current_millis_remainder=current_millis%10000;
  if(val>threshold[1] && last_below_threshold[1]-last_below_threshold[0]<window){
    digitalWrite(pin[0],HIGH);
    flag[0]='H';
  }else{
    digitalWrite(pin[0],LOW);
    flag[0]='L';
  }
  if(val>threshold[2] && val<threshold[3]){
    digitalWrite(pin[1],HIGH);
    flag[1]='H';
  }else{
    digitalWrite(pin[1],LOW);
    flag[1]='L';
  }
  
  sprintf(output,"%04u%c%c%4u",current_millis_remainder,flag[0],flag[1],val);
  Serial.println(output);
}



