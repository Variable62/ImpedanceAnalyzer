#include <Wire.h>
#include <Adafruit_MCP4725.h>

#define SDA_PIN 21    
#define SCL_PIN 22   

const float Vref = 3.3;

Adafruit_MCP4725 dac;

void setup() {
  Serial.begin(115200);
  Wire.begin(SDA_PIN, SCL_PIN);

  Serial.println("I2C started");

  if (!dac.begin(0x61, &Wire)) {
    Serial.println("Could not find MCP4725!");
    while (1);
  }

  Serial.println("MCP4725 Ready");
}

void loop() {
  uint16_t dacValue = 0x00;
  dac.setVoltage(dacValue, false);

  Serial.print("Set DAC = ");
  Serial.println(dacValue);

  delay(1000);
}
