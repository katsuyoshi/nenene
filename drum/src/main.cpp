#include <Arduino.h>
#include <M5Stack.h>
#define MAX_EASING_SERVOS   1
#include <ServoEasing.hpp>

#define SERVO_PIN   2

ServoEasing drum;

bool running = false;
bool ex_running = false;
float deg = 90;
float ex_deg = 0;

void setup() {
  M5.begin(true, true, true, false);
  M5.Lcd.setTextFont(4);
  drum.attach(SERVO_PIN, 0, DEFAULT_MICROSECONDS_FOR_0_DEGREE, DEFAULT_MICROSECONDS_FOR_180_DEGREE);
  drum.setEasingType(EASE_LINEAR);
  setSpeedForAllServos(60);
}

void loop() {
    M5.update();
    if (M5.BtnA.wasPressed()) {
      deg -= 15.0;
      deg = max(deg, 0.0f);
    }
    if (M5.BtnB.wasPressed()) {
      running = !running;
    }
    if (M5.BtnC.wasPressed()) {
      deg += 15.0;
      deg = min(deg, 180.0f);
    }

    if (deg != ex_deg || running != ex_running) {
      ex_deg = deg;
      ex_running = running;
      M5.Lcd.clear(BLACK);
      M5.Lcd.setCursor(0, 0);
      M5.Lcd.printf("[%s] %.1f", running ? "R" : "S", deg);
      drum.easeTo(!running ? 90.0f : deg);
    }
}
