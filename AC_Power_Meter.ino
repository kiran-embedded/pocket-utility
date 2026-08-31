#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <EEPROM.h>

// --- Hardware definitions ---
const uint8_t LCD_ADDRESS = 0x27;
const uint8_t LCD_COLUMNS = 16;
const uint8_t LCD_ROWS = 2;
LiquidCrystal_I2C lcd(LCD_ADDRESS, LCD_COLUMNS, LCD_ROWS);

const uint8_t VOLTAGE_SENSOR_PIN = A1;
const uint8_t CURRENT_SENSOR_PIN = A2;

const uint8_t KEY1_PIN = 9;
const uint8_t KEY2_PIN = 10;
const uint8_t KEY3_PIN = 11;
const uint8_t KEY4_PIN = 12;

// --- Time constants ---
const unsigned long LCD_UPDATE_INTERVAL = 200UL;
const unsigned long PAGE_SWITCH_INTERVAL = 2000UL;
const unsigned long BUTTON_SCAN_INTERVAL = 20UL;
const unsigned long SAMPLE_INTERVAL_MICROS = 2000UL; // 2ms between ADC samples
const unsigned long LONG_PRESS_DURATION = 2000UL;
const unsigned long REPEAT_START_DELAY = 500UL;
const unsigned long REPEAT_NORMAL_INTERVAL = 200UL;
const unsigned long REPEAT_FAST_INTERVAL = 100UL;
const unsigned long FAST_HOLD_THRESHOLD = 1500UL;

// --- Sampling configuration ---
const uint16_t SAMPLE_COUNT = 400;
const uint8_t SMOOTHING_WINDOW = 8;
const float ADC_REFERENCE_VOLTAGE = 5.0f;
const float ADC_COUNTS_PER_VOLT = ADC_REFERENCE_VOLTAGE / 1023.0f;

// --- EEPROM storage ---
const int EEPROM_BASE_ADDRESS = 0;
const uint8_t EEPROM_MAGIC = 0xA5;

struct CalibrationRecord {
  uint8_t marker;
  float voltageFactor;
  float currentFactor;
};

// --- Application state ---
bool splashActive = true;
unsigned long splashStartMillis = 0;
unsigned long lastLCDUpdate = 0;
unsigned long lastPageSwitch = 0;
unsigned long lastButtonScan = 0;
unsigned long lastSampleMicros = 0;

bool calibrationMode = false;
uint8_t activePage = 0;        // 0..2 for main pages
uint8_t calibrationSensor = 0; // 0 = voltage, 1 = current

float voltageCalibration = 1.0000f;
float currentCalibration = 1.0000f;
bool eepromValid = false;

float sampleSumV = 0.0f;
float sampleSumVSq = 0.0f;
float sampleSumI = 0.0f;
float sampleSumISq = 0.0f;
float sampleSumVI = 0.0f;
uint16_t sampleIndex = 0;

float filteredVoltage = 0.0f;
float filteredCurrent = 0.0f;
float filteredPower = 0.0f;
float filteredApparent = 0.0f;
float filteredPF = 0.0f;

float voltageBuffer[SMOOTHING_WINDOW] = {0};
float currentBuffer[SMOOTHING_WINDOW] = {0};
float powerBuffer[SMOOTHING_WINDOW] = {0};
float apparentBuffer[SMOOTHING_WINDOW] = {0};
uint8_t smoothingIndex = 0;

char lcdCache[2][17] = {{0}};
char statusMessage[17] = "";
unsigned long statusEndMillis = 0;

struct ButtonState {
  uint8_t pin;
  bool stableState;
  bool lastReading;
  unsigned long lastDebounceMillis;
  unsigned long pressStartMillis;
  unsigned long nextRepeatMillis;
  bool pressed;
  bool actionHandled;
};

ButtonState buttons[4] = {
  {KEY1_PIN, HIGH, HIGH, 0, 0, 0, false, false},
  {KEY2_PIN, HIGH, HIGH, 0, 0, 0, false, false},
  {KEY3_PIN, HIGH, HIGH, 0, 0, 0, false, false},
  {KEY4_PIN, HIGH, HIGH, 0, 0, 0, false, false}
};

// --- Forward declarations ---
void initializeHardware();
void initializeButtons();
void loadCalibration();
void saveCalibration();
void handleSplashScreen();
void handleSampling();
void processSampleBlock();
void applyMovingAverage(float voltage, float current, float power, float apparent);
void updateLCD();
void displaySplash();
void displayMainPage();
void displayCalibrationPage();
void setLCDLine(uint8_t row, const char *text);
void readButtons();
void handleButtonActions(uint8_t index, unsigned long now);
void setStatusMessage(const char *message, unsigned long duration);
void adjustCalibration(float delta);
void switchCalibrationSensor();
void homeDisplay();

void setup() {
  initializeHardware();
  initializeButtons();
  loadCalibration();
  splashStartMillis = millis();
  lastLCDUpdate = millis();
  lastPageSwitch = millis();
  lastButtonScan = millis();
  lastSampleMicros = micros();
  setStatusMessage("System Ready", 1200);
}

void loop() {
  unsigned long now = millis();

  readButtons();
  handleSampling();

  if (!calibrationMode && !splashActive && now - lastPageSwitch >= PAGE_SWITCH_INTERVAL) {
    activePage = (activePage + 1) % 3;
    lastPageSwitch = now;
  }

  if (splashActive) {
    if (now - splashStartMillis >= 1800UL) {
      splashActive = false;
      homeDisplay();
    }
  }

  if (now - lastLCDUpdate >= LCD_UPDATE_INTERVAL) {
    lastLCDUpdate = now;
    updateLCD();
  }
}

void initializeHardware() {
  Wire.begin();
  lcd.init();
  lcd.backlight();

  pinMode(VOLTAGE_SENSOR_PIN, INPUT);
  pinMode(CURRENT_SENSOR_PIN, INPUT);

  pinMode(KEY1_PIN, INPUT_PULLUP);
  pinMode(KEY2_PIN, INPUT_PULLUP);
  pinMode(KEY3_PIN, INPUT_PULLUP);
  pinMode(KEY4_PIN, INPUT_PULLUP);
}

void initializeButtons() {
  for (uint8_t i = 0; i < 4; i++) {
    buttons[i].stableState = digitalRead(buttons[i].pin);
    buttons[i].lastReading = buttons[i].stableState;
    buttons[i].lastDebounceMillis = millis();
    buttons[i].pressed = false;
    buttons[i].actionHandled = false;
  }
}

void loadCalibration() {
  CalibrationRecord record;
  EEPROM.get(EEPROM_BASE_ADDRESS, record);
  if (record.marker == EEPROM_MAGIC && record.voltageFactor > 0.25f && record.voltageFactor < 5.00f && record.currentFactor > 0.25f && record.currentFactor < 5.00f) {
    voltageCalibration = record.voltageFactor;
    currentCalibration = record.currentFactor;
    eepromValid = true;
    setStatusMessage("EEPROM Loaded", 1200);
  } else {
    voltageCalibration = 1.0000f;
    currentCalibration = 1.0000f;
    eepromValid = false;
    setStatusMessage("EEPROM Default", 1200);
  }
}

void saveCalibration() {
  CalibrationRecord record;
  EEPROM.get(EEPROM_BASE_ADDRESS, record);

  bool changed = (record.marker != EEPROM_MAGIC || fabs(record.voltageFactor - voltageCalibration) > 0.0001f || fabs(record.currentFactor - currentCalibration) > 0.0001f);
  if (!changed) {
    setStatusMessage("Already Saved", 1000);
    return;
  }

  record.marker = EEPROM_MAGIC;
  record.voltageFactor = voltageCalibration;
  record.currentFactor = currentCalibration;
  EEPROM.put(EEPROM_BASE_ADDRESS, record);
  eepromValid = true;
  setStatusMessage("Calibration Saved", 1600);
}

void handleSampling() {
  unsigned long currentMicros = micros();
  if ((unsigned long)(currentMicros - lastSampleMicros) < SAMPLE_INTERVAL_MICROS) {
    return;
  }

  lastSampleMicros += SAMPLE_INTERVAL_MICROS;
  int voltageRaw = analogRead(VOLTAGE_SENSOR_PIN);
  int currentRaw = analogRead(CURRENT_SENSOR_PIN);

  float v = (float)voltageRaw;
  float i = (float)currentRaw;

  sampleSumV += v;
  sampleSumVSq += v * v;
  sampleSumI += i;
  sampleSumISq += i * i;
  sampleSumVI += v * i;
  sampleIndex++;

  if (sampleIndex >= SAMPLE_COUNT) {
    processSampleBlock();
    sampleIndex = 0;
    sampleSumV = 0.0f;
    sampleSumVSq = 0.0f;
    sampleSumI = 0.0f;
    sampleSumISq = 0.0f;
    sampleSumVI = 0.0f;
  }
}

void processSampleBlock() {
  float meanV = sampleSumV / SAMPLE_COUNT;
  float meanI = sampleSumI / SAMPLE_COUNT;
  float meanVSq = sampleSumVSq / SAMPLE_COUNT;
  float meanISq = sampleSumISq / SAMPLE_COUNT;
  float meanVI = sampleSumVI / SAMPLE_COUNT;

  float rmsCountsV = sqrt(max(0.0f, meanVSq - meanV * meanV));
  float rmsCountsI = sqrt(max(0.0f, meanISq - meanI * meanI));
  float powerCounts = meanVI - meanV * meanI;

  float voltageRms = rmsCountsV * ADC_COUNTS_PER_VOLT * voltageCalibration;
  float currentRms = rmsCountsI * ADC_COUNTS_PER_VOLT * currentCalibration;
  float realPower = powerCounts * ADC_COUNTS_PER_VOLT * ADC_COUNTS_PER_VOLT * voltageCalibration * currentCalibration;
  float apparentPower = voltageRms * currentRms;
  float powerFactor = apparentPower > 0.001f ? realPower / apparentPower : 0.0f;

  if (voltageRms < 0.0f) {
    voltageRms = 0.0f;
  }
  if (currentRms < 0.0f) {
    currentRms = 0.0f;
  }
  if (realPower < 0.0f && realPower > -0.5f) {
    realPower = 0.0f;
  }
  if (apparentPower < 0.0f) {
    apparentPower = 0.0f;
  }

  applyMovingAverage(voltageRms, currentRms, realPower, apparentPower);
  filteredPF = constrain(powerFactor, 0.0f, 1.0f);
}

void applyMovingAverage(float voltage, float current, float power, float apparent) {
  voltageBuffer[smoothingIndex] = voltage;
  currentBuffer[smoothingIndex] = current;
  powerBuffer[smoothingIndex] = power;
  apparentBuffer[smoothingIndex] = apparent;

  smoothingIndex = (smoothingIndex + 1) % SMOOTHING_WINDOW;

  float sumV = 0.0f;
  float sumI = 0.0f;
  float sumP = 0.0f;
  float sumS = 0.0f;

  for (uint8_t i = 0; i < SMOOTHING_WINDOW; i++) {
    sumV += voltageBuffer[i];
    sumI += currentBuffer[i];
    sumP += powerBuffer[i];
    sumS += apparentBuffer[i];
  }

  filteredVoltage = sumV / SMOOTHING_WINDOW;
  filteredCurrent = sumI / SMOOTHING_WINDOW;
  filteredPower = sumP / SMOOTHING_WINDOW;
  filteredApparent = sumS / SMOOTHING_WINDOW;
}

void updateLCD() {
  if (statusMessage[0] != '\0' && millis() < statusEndMillis) {
    setLCDLine(0, statusMessage);
  }

  if (splashActive) {
    displaySplash();
    return;
  }

  if (calibrationMode) {
    displayCalibrationPage();
    return;
  }

  displayMainPage();
}

void displaySplash() {
  setLCDLine(0, "  AC POWER METER ");
  setLCDLine(1, "  ZMPT101B + ZMCT103C");
}

void displayMainPage() {
  char line1[17];
  char line2[17];
  char value1[12];
  char value2[12];

  if (activePage == 0) {
    dtostrf(filteredVoltage, 5, 1, value1);
    dtostrf(filteredCurrent, 4, 2, value2);
    snprintf(line1, sizeof(line1), "V:%5s I:%4s", value1, value2);
    snprintf(line2, sizeof(line2), "Hold 1 for CAL  ");
  } else if (activePage == 1) {
    dtostrf(filteredPower, 5, 1, value1);
    dtostrf(filteredApparent, 5, 1, value2);
    snprintf(line1, sizeof(line1), "P:%5s S:%5s", value1, value2);
    dtostrf(filteredPF, 4, 2, value2);
    snprintf(line2, sizeof(line2), "PF:%4s", value2);
  } else {
    dtostrf(voltageCalibration, 6, 4, value1);
    snprintf(line1, sizeof(line1), "Cal V:%6s", value1);
    snprintf(line2, sizeof(line2), "EEP:%s", eepromValid ? "OK" : "ERR");
  }

  setLCDLine(0, line1);
  setLCDLine(1, line2);
}

void displayCalibrationPage() {
  char line1[17];
  char line2[17];
  char valueString[12];

  if (calibrationSensor == 0) {
    snprintf(line1, sizeof(line1), "Sensor: Voltage");
    dtostrf(voltageCalibration, 6, 4, valueString);
  } else {
    snprintf(line1, sizeof(line1), "Sensor: Current");
    dtostrf(currentCalibration, 6, 4, valueString);
  }

  snprintf(line2, sizeof(line2), "-%6s+ SAVE", valueString);
  setLCDLine(0, line1);
  setLCDLine(1, line2);
}

void setLCDLine(uint8_t row, const char *text) {
  char buffer[17];
  memset(buffer, ' ', 16);
  buffer[16] = '\0';
  strncpy(buffer, text, 16);

  if (strncmp(buffer, lcdCache[row], 16) != 0) {
    memcpy(lcdCache[row], buffer, 16);
    lcd.setCursor(0, row);
    lcd.print(buffer);
  }
}

void readButtons() {
  unsigned long now = millis();
  if (now - lastButtonScan < BUTTON_SCAN_INTERVAL) {
    return;
  }
  lastButtonScan = now;

  for (uint8_t index = 0; index < 4; index++) {
    ButtonState &button = buttons[index];
    bool rawState = digitalRead(button.pin);

    if (rawState != button.lastReading) {
      button.lastDebounceMillis = now;
      button.lastReading = rawState;
    }

    if (now - button.lastDebounceMillis >= 30UL) {
      if (rawState != button.stableState) {
        button.stableState = rawState;
        if (button.stableState == LOW) {
          button.pressStartMillis = now;
          button.nextRepeatMillis = now + REPEAT_START_DELAY;
          button.pressed = true;
          button.actionHandled = false;
        } else {
          if (button.pressed && !button.actionHandled && now - button.pressStartMillis < LONG_PRESS_DURATION) {
            handleButtonActions(index, now);
          }
          button.pressed = false;
          button.actionHandled = false;
        }
      }
    }

    if (button.pressed) {
      unsigned long holdTime = now - button.pressStartMillis;
      if (!button.actionHandled && holdTime >= LONG_PRESS_DURATION) {
        handleButtonActions(index, now);
        button.actionHandled = true;
      } else if (holdTime >= REPEAT_START_DELAY && now >= button.nextRepeatMillis) {
        bool fast = holdTime >= FAST_HOLD_THRESHOLD;
        handleButtonActions(index, now);
        button.nextRepeatMillis = now + (fast ? REPEAT_FAST_INTERVAL : REPEAT_NORMAL_INTERVAL);
      }
    }
  }
}

void handleButtonActions(uint8_t index, unsigned long now) {
  bool isLong = buttons[index].pressed && (now - buttons[index].pressStartMillis >= LONG_PRESS_DURATION);

  if (index == 0) {
    if (calibrationMode) {
      if (!isLong) {
        switchCalibrationSensor();
      } else {
        calibrationMode = false;
        setStatusMessage("Exit Cal Mode", 1200);
      }
    } else if (!isLong) {
      activePage = (activePage + 1) % 3;
      lastPageSwitch = now;
    } else {
      calibrationMode = true;
      calibrationSensor = 0;
      setStatusMessage("Calibration Mode", 1000);
    }
  }

  if (!calibrationMode) {
    return;
  }

  if (index == 1) {
    float delta = (isLong ? -0.005f : -0.001f);
    adjustCalibration(delta);
  }
  if (index == 2) {
    float delta = (isLong ? 0.005f : 0.001f);
    adjustCalibration(delta);
  }
  if (index == 3 && !isLong) {
    saveCalibration();
  }
}

void adjustCalibration(float delta) {
  if (calibrationSensor == 0) {
    voltageCalibration = constrain(voltageCalibration + delta, 0.5000f, 5.0000f);
  } else {
    currentCalibration = constrain(currentCalibration + delta, 0.5000f, 5.0000f);
  }
}

void switchCalibrationSensor() {
  calibrationSensor = (calibrationSensor + 1) % 2;
}

void setStatusMessage(const char *message, unsigned long duration) {
  strncpy(statusMessage, message, 16);
  statusMessage[16] = '\0';
  statusEndMillis = millis() + duration;
}

void homeDisplay() {
  memset(lcdCache, 0, sizeof(lcdCache));
}
