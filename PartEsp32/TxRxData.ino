#include <Wire.h>
#include <Adafruit_MCP4725.h>

#define SDA_PIN 21    
#define SCL_PIN 22   

const float Vref = 3.3;

Adafruit_MCP4725 dac;
#define BTN         4
// ESP32 -> FPGA
#define Write    27
int modePin[4] = {32, 33, 25, 26};

// FPGA -> ESP32
#define FPGA_ACK    14
int dataRxPin[4] = {16, 17, 18, 19};

uint8_t mode = 0;
int lastBtn = HIGH;

// -----------------------------
// Send mode To FPGA (4-bit)
// -----------------------------
void sendMode(uint8_t val) {
    for (int i = 0; i < 4; i++) {
        digitalWrite(modePin[i], (val >> i) & 1);
    }

    digitalWrite(Write, HIGH);
    delayMicroseconds(5);
    digitalWrite(Write, LOW);
}
// -----------------------------
// Read 4 Nibble form FPGA
// -----------------------------
uint8_t readNibble() {
    uint8_t val = 0;
    for (int i = 0; i < 4; i++) {
        val |= digitalRead(dataRxPin[i]) << i;
    }
    return val;
}
// -----------------------------
// ReciveData 12-bit form FPGA
// -----------------------------
uint16_t readFpgaData() {
    uint16_t data = 0;

    for (int i = 0; i < 3; i++) {
        while (!digitalRead(FPGA_ACK));   // รอ FPGA
        data |= readNibble() << (i * 4);
        while (digitalRead(FPGA_ACK));    // รอ ACK ลง
    }
    return data;
}

void setup() {
    Serial.begin(115200);

    pinMode(BTN, INPUT_PULLUP);

    pinMode(Write, OUTPUT);
    digitalWrite(Write, LOW);

    for (int i = 0; i < 4; i++) {
        pinMode(modePin[i], OUTPUT);
        pinMode(dataRxPin[i], INPUT);
    }

    pinMode(FPGA_ACK, INPUT);
}

void loop() {
    int btn = digitalRead(BTN);

    // Change mode
    if (btn == LOW && lastBtn == HIGH) {
        mode = (mode + 1) & 0x03;   // 0–3
        sendMode(mode);

        Serial.print("Send Mode = ");
        Serial.println(mode);

        delay(300); // debounce
    }
    lastBtn = btn;

    // Read Data FPGA
    if (digitalRead(FPGA_ACK)) {
        uint16_t data = readFpgaData();
        Serial.print("FPGA Data = ");
        Serial.println(data);
    }
}