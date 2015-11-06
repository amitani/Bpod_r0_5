/*{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA
Copyright (C) 2015 Akinori Mitani, University of California, San Diego, CA, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include <SPI.h>
#include <SD.h>
#include <Adafruit_VS1053_SineWaveGenerator.h>

Adafruit_VS1053_SineWaveGenerator sineWaveGenerator = Adafruit_VS1053_SineWaveGenerator();

volatile byte SoundIndex = 0;
byte currentSoundIndex = 0;

void setup()
{
  Serial.begin(115200);
  
  if (! sineWaveGenerator.begin()) { // initialise the music player
     Serial.println(F("Couldn't find VS1053, do you have the right pins defined?"));
     while (1);
  }
  Serial.println(F("VS1053 found"));
  
  sineWaveGenerator.volume[0]=100;
  sineWaveGenerator.volume[1]=100;
  sineWaveGenerator.init();
  
  Serial.println(F("Initialized"));
}

void loop()
{
  byte newSoundIndex = SoundIndex;
  if(newSoundIndex==0) return;
  if(newSoundIndex == currentSoundIndex) return;
  
  if(currentSoundIndex & 31) sineWaveGenerator.stopSineTest();
  if(newSoundIndex & 31) sineWaveGenerator.startSineTest(newSoundIndex);
  currentSoundIndex = newSoundIndex;
}

void serialEvent(){
  if (Serial.available()){
    SoundIndex = Serial.read();
    Serial.println(SoundIndex);
  }
}



