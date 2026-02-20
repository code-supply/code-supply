#include <Keyboard.h>

// Encoder pins
const uint8_t CLK = 2;
const uint8_t DT  = 3;
const uint8_t SW  = 4; // encoder push-button

// Extra button
const uint8_t BTN1 = 5;

int16_t inputDelta = 0;
int16_t lastPosition = 0;

// Button states
bool encoderPressed = false;
bool btn1Held = false;   // true while button 1 is pressed

// Debounce timers
unsigned long lastEncoderBtnTime = 0;
const unsigned long encoderDebounce = 200; // ms

// Encoder FSM state
uint8_t encoderState = 0;

void setup() {
    pinMode(CLK, INPUT_PULLUP);
    pinMode(DT, INPUT_PULLUP);
    pinMode(SW, INPUT_PULLUP);
    pinMode(BTN1, INPUT_PULLUP);

    Serial.begin(115200);
    Keyboard.begin();
}

void loop() {
    readEncoder();
    readEncoderButton();
    readHoldButton();

    // Handle encoder rotation
    while (inputDelta != lastPosition) {
        if (inputDelta > lastPosition) {
            Keyboard.press(KEY_DOWN_ARROW);
            lastPosition++;
        } else {
            Keyboard.press(KEY_UP_ARROW);
            lastPosition--;
        }
        Keyboard.releaseAll();
    }

    // Encoder push-button
    if (encoderPressed) {
        encoderPressed = false;
        Serial.println("Encoder button pressed!");
        Keyboard.press(KEY_RETURN);
        Keyboard.releaseAll();
    }

    // Button 1: hold 'm' while pressed
    if (btn1Held) {
        Keyboard.press('m');  // hold key
    } else {
        Keyboard.release('m'); // release key if not pressed
    }
}

// Encoder FSM (polling)
void readEncoder() {
    bool clkState = digitalRead(CLK);
    bool dtState  = digitalRead(DT);

    switch (encoderState) {
        case 0: // Idle
            if (!clkState) encoderState = 1;       // CW started
            else if (!dtState) encoderState = 4;  // CCW started
            break;

        // Clockwise rotation
        case 1:
            if (!dtState) encoderState = 2;
            break;
        case 2:
            if (clkState) encoderState = 3;
            break;
        case 3:
            if (clkState && dtState) {
                encoderState = 0;
                inputDelta++;
            }
            break;

        // Counter-clockwise rotation
        case 4:
            if (!clkState) encoderState = 5;
            break;
        case 5:
            if (dtState) encoderState = 6;
            break;
        case 6:
            if (clkState && dtState) {
                encoderState = 0;
                inputDelta--;
            }
            break;
    }
}

// Encoder push-button with debounce
void readEncoderButton() {
    static bool lastEncState = HIGH;
    bool encState = digitalRead(SW);
    unsigned long now = millis();

    if (encState == LOW && lastEncState == HIGH) {
        if (now - lastEncoderBtnTime > encoderDebounce) {
            encoderPressed = true;
            lastEncoderBtnTime = now;
        }
    }
    lastEncState = encState;
}

// Extra button: hold 'm' while pressed
void readHoldButton() {
    btn1Held = (digitalRead(BTN1) == LOW);
}
