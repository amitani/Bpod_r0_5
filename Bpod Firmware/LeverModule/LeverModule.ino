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
const int pin=13;
void setup() {
  // put your setup code here, to run once:
   Serial.begin(115200);
   //analogReadResolution(12);
   serialBuffer.reserve(200);
   command.reserve(200);
   
   pinMode(pin, OUTPUT);
}

unsigned long current_millis;
unsigned int current_millis_remainder;
int val;
int threshold[2]={256,512};
unsigned long window=200; // ms
unsigned long last_below_threshold[2]={1,0};
int i;
char output[20];

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
  if(val>threshold[1] && last_below_threshold[1]-last_below_threshold[0]<window*1000){
    digitalWrite(pin,HIGH);
    sprintf(output,"%04uH%4u",current_millis_remainder,val);
  }else{
    digitalWrite(pin,LOW);
    sprintf(output,"%04uL%4u",current_millis_remainder,val);
  }
  Serial.println(output);
}



