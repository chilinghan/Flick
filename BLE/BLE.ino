#include <SparkFun_ISM330DHCX.h>
#include <Wire.h>
#include "SparkFun_BMI270_Arduino_Library.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "4FAFC201-1FB5-459E-8FCC-C5C9C331914B"
#define CHARACTERISTIC_YAW  "E848839A-6DB5-4AA8-918A-5D0F2A131E0D"
#define CHARACTERISTIC_ROLL "BEB5483E-36E1-4688-B7F5-EA07361B26A8"
#define CHARACTERISTIC_PITCH "066A8CE3-6217-4D38-AB95-E2C7EB872C4E"
#define CHARACTERISTIC_POSTURE "1BfCE46F-D96B-40F9-8EEB-B64F861AAD89"
#define CHARACTERISTIC_HAPTICS "AB3F4426-FFF9-42F9-9207-928245A924A5"
#define CHARACTERISTIC_TYPING "46EA3751-2006-4F14-A09A-161DACE1AC5D"

#define HAPTIC_PIN 17 // on pin D17

/* Set the delay between fresh samples */
#define DELTAT 100
#define APP_DATA_CYCLE 1000 // in ms

#define alpha 0.85
const int window_size = APP_DATA_CYCLE / DELTAT;
const int rangeYPR[3][2] = {{-180, 180}, {-25, 25}, {-180, 180}}; // in deg

BMI270 imu1; 
BMI270 imu2;

BLECharacteristic *pCharacteristicYaw;
BLECharacteristic *pCharacteristicPitch;
BLECharacteristic *pCharacteristicRoll;
BLECharacteristic *pCharacteristicPosture;
BLECharacteristic *pCharacteristicHaptics;
BLECharacteristic *pCharacteristicTyping;

BLEServer *pServer;
bool deviceConnected = false;
bool oldDeviceConnected = false;

float euler1[3];
float euler2[3];
int moving_window[window_size][3];
int count;

int haptic_mode = 0; // 0: off, 1: on
int typing_mode = 1; // 0: off, 1: on, 2: automatic

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyHapticsCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      uint8_t* value = pCharacteristicHaptics->getData();
      haptic_mode = value[0];
    } 
};

class MyTypingCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      uint8_t* value = pCharacteristicTyping->getData();
      typing_mode = value[0];
    }
};

void setup() {
  // Initialize the I2C library
  Wire.begin();

  Serial.begin(115200);

  delay(1500);  // wait for serial port to open!
  
  Serial.println("Starting BLE work!");

  BLEDevice::init("WristPlus");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristicYaw = pService->createCharacteristic(
                                         CHARACTERISTIC_YAW,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_NOTIFY
                                       );
  pCharacteristicPitch = pService->createCharacteristic(
                                         CHARACTERISTIC_PITCH,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_NOTIFY
                                       );
  pCharacteristicRoll = pService->createCharacteristic(
                                         CHARACTERISTIC_ROLL,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_NOTIFY
                                       );
  pCharacteristicPosture = pService->createCharacteristic(
                                         CHARACTERISTIC_POSTURE,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_NOTIFY
                                       );
  pCharacteristicHaptics = pService->createCharacteristic(
                                         CHARACTERISTIC_HAPTICS,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristicTyping = pService->createCharacteristic(
                                         CHARACTERISTIC_TYPING,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristicHaptics->setCallbacks(new MyHapticsCallbacks());
  pCharacteristicTyping->setCallbacks(new MyTypingCallbacks());

  Serial.println("Orientation Sensor Raw Data Test");
  Serial.println("");

  
  /* Initialize the sensor */
  // Check if sensor is connected and initialize
  // Address is optional (defaults to 0x68)
  if(imu1.beginI2C(BMI2_I2C_PRIM_ADDR) != BMI2_OK)
  {
      // Not connected, inform user
      Serial.println("Error: BMI2701 not connected, check wiring and I2C address!");

      // Wait a bit to see if connection is established
      delay(1000);
  }

  if (imu2.beginI2C(BMI2_I2C_SEC_ADDR) != BMI2_OK)
  {
      // Not connected, inform user
      Serial.println("Error: BMI2702 not connected, check wiring and I2C address!");

      // Wait a bit to see if connection is established
      delay(1000);
  }

  // The accelerometer and gyroscope can be configured with multiple settings
  // to reduce the measurement noise. Both sensors have the following settings
  // in common:
  // .range       - Measurement range. Lower values give more resolution, but
  //                doesn't affect noise significantly, and limits the max
  //                measurement before saturating the sensor
  // .odr         - Output data rate in Hz. Lower values result in less noise,
  //                but lower sampling rates.
  // .filter_perf - Filter performance mode. Performance oprtimized mode
  //                results in less noise, but increased power consumption
  // .bwp         - Filter bandwidth parameter. This has several possible
  //                settings that can reduce noise, but cause signal delay
  // 
  // Both sensors have different possible values for each setting:
  // 
  // Accelerometer values:
  // .range       - 2g to 16g
  // .odr         - Depends on .filter_perf:
  //                  Performance mode: 12.5Hz to 1600Hz
  //                  Power mode:       0.78Hz to 400Hz
  // .bwp         - Depends on .filter_perf:
  //                  Performance mode: Normal, OSR2, OSR4, CIC
  //                  Power mode:       Averaging from 1 to 128 samples
  // 
  // Gyroscope values:
  // .range       - 125dps to 2000dps (deg/sec)
  // .ois_range   - 250dps or 2000dps (deg/sec) Only relevant when using OIS,
  //                see datasheet for more info. Defaults to 250dps
  // .odr         - Depends on .filter_perf:
  //                  Performance mode: 25Hz to 3200Hz
  //                  Power mode:       25Hz to 100Hz
  // .bwp         - Normal, OSR2, OSR4, CIC
  // .noise_perf  - Similar to .filter_perf. Performance oprtimized mode
  //                results in less noise, but increased power consumption
  // 
  // Note that not all combinations of values are possible. The performance
  // mode restricts which ODR settings can be used, and the ODR restricts some
  // bandwidth parameters. An error code is returned by setConfig, which can
  // be used to determine whether the selected settings are valid.
  int8_t err1 = BMI2_OK;
  int8_t err2 = BMI2_OK;

  // Set accelerometer config
  bmi2_sens_config accelConfig;
  accelConfig.type = BMI2_ACCEL;
  accelConfig.cfg.acc.odr = BMI2_ACC_ODR_50HZ;
  accelConfig.cfg.acc.bwp = BMI2_ACC_OSR4_AVG1;
  accelConfig.cfg.acc.filter_perf = BMI2_PERF_OPT_MODE;
  accelConfig.cfg.acc.range = BMI2_ACC_RANGE_2G;
  err1 = imu1.setConfig(accelConfig);

  // Set gyroscope config
  bmi2_sens_config gyroConfig;
  gyroConfig.type = BMI2_GYRO;
  gyroConfig.cfg.gyr.odr = BMI2_GYR_ODR_50HZ;
  gyroConfig.cfg.gyr.bwp = BMI2_GYR_OSR4_MODE;
  gyroConfig.cfg.gyr.filter_perf = BMI2_PERF_OPT_MODE;
  gyroConfig.cfg.gyr.ois_range = BMI2_GYR_OIS_250;
  gyroConfig.cfg.gyr.range = BMI2_GYR_RANGE_125;
  gyroConfig.cfg.gyr.noise_perf = BMI2_PERF_OPT_MODE;
  err1 = imu1.setConfig(gyroConfig);
  err2 = imu2.setConfig(gyroConfig);
      // Check whether the config settings above were valid
  while(err1 != BMI2_OK || err2 != BMI2_OK)
  {
      // Not valid, determine which config was the problem
      if(err1 == BMI2_E_ACC_INVALID_CFG || err2 == BMI2_E_ACC_INVALID_CFG)
      {
          Serial.println("Accelerometer config not valid!");
      }
      else if(err1 == BMI2_E_GYRO_INVALID_CFG || err2 == BMI2_E_GYRO_INVALID_CFG)
      {
          Serial.println("Gyroscope config not valid!");
      }
      else if(err1 == BMI2_E_ACC_GYR_INVALID_CFG || err2 == BMI2_E_ACC_GYR_INVALID_CFG)
      {
          Serial.println("Both configs not valid!");
      }
      else
      {
          Serial.print("Unknown error: ");
          Serial.println(err1);
      }
      delay(1000);
  }
  Serial.println("Configuration valid! Beginning measurements");
  delay(1000);

  pinMode(HAPTIC_PIN, OUTPUT);

  pService->start();
  pServer->getAdvertising()->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  // pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Characteristic defined! Now you can read it in your phone!");
}

void loop(void)
{
  imu1.getSensorData();
  imu2.getSensorData();

  float accelX1 = imu1.data.accelX;
  float accelY1 = imu1.data.accelY;
  float accelZ1 = imu1.data.accelZ;
  Serial.print("Acceleration: X: ");
  Serial.print(accelX1, 3);
  Serial.print(", Y: ");
  Serial.print(accelY1, 3);
  Serial.print(", Z: ");
  Serial.print(accelZ1, 3);
  Serial.println(" m/s^2");

  Serial.print("\t");
  
  float gyroX1 = radians(imu1.data.gyroX);
  float gyroY1 = radians(imu1.data.gyroY);
  float gyroZ1 = radians(imu1.data.gyroZ);
  Serial.print("Gyro X: ");
  Serial.print(gyroX1, 3);
  Serial.print(", Y: ");
  Serial.print(gyroY1, 3);
  Serial.print(", Z: ");
  Serial.print(gyroZ1, 3);
  Serial.println(" rad/s");

  float accelX2 = imu2.data.accelX;
  float accelY2 = imu2.data.accelY;
  float accelZ2 = imu2.data.accelZ;
  Serial.print("Acceleration: X: ");
  Serial.print(accelX2, 3);
  Serial.print(", Y: ");
  Serial.print(accelY2, 3);
  Serial.print(", Z: ");
  Serial.print(accelZ2, 3);
  Serial.println(" m/s^2");

  Serial.print("\t");
  
  float gyroX2 = radians(imu2.data.gyroX);
  float gyroY2 = radians(imu2.data.gyroY);
  float gyroZ2 = radians(imu2.data.gyroZ);
  Serial.print("Gyro X: ");
  Serial.print(gyroX2, 3);
  Serial.print(", Y: ");
  Serial.print(gyroY2, 3);
  Serial.print(", Z: ");
  Serial.print(gyroZ2, 3);
  Serial.println(" rad/s");

  // roll
  euler1[0] = alpha * (euler1[0] + gyroX1 * DELTAT / 1000.0) + (1 - alpha) * atan2(accelY1, accelZ1);
  // pitch
  euler1[1] = alpha * (euler1[1] + gyroY1 * DELTAT / 1000.0) + (1 - alpha) * atan2(-accelX1, sqrt(accelY1 * accelY1 + accelZ1 * accelZ1));
  // yaw
  euler1[2] += gyroZ1 * DELTAT / 1000.0;
  float roll1 = euler1[0];
  float pitch1 = -euler1[1];
  float yaw1 = -euler1[2];

  // roll
  euler2[0] = alpha * (euler2[0] + gyroX2 * DELTAT / 1000.0) + (1 - alpha) * atan2(accelY2, accelZ2);
  // pitch
  euler2[1] = alpha * (euler2[1] + gyroY2 * DELTAT / 1000.0) + (1 - alpha) * atan2(-accelX2, sqrt(accelY2 * accelY2 + accelZ2 * accelZ2));
  // yaw
  euler2[2] += gyroZ2 * DELTAT / 1000.0;
  float roll2 = euler2[0];
  float pitch2 = -euler2[1];
  float yaw2 = -euler2[2];

  float roll_r = roll2 - roll1;
  float pitch_r = pitch2 - pitch1;
  float yaw_r = yaw2 - yaw1;

  // Convert the relative angles back to degrees
  int YPR[3] = {(int) degrees(yaw_r),
                (int) -degrees(pitch_r),
                (int) degrees(roll_r)};
  // yaw = (yaw < 0) ? yaw += 180 : yaw -= 180;
  // yaw = -yaw;

  //Print the relative Euler angles
  Serial.print("Relative Yaw:");
  Serial.print(YPR[0]);
  Serial.print(" Relative Pitch:");
  Serial.print(YPR[1]);
  Serial.print(" Relative Roll:");
  Serial.println(YPR[2]);

  for (int i = 0; i < 3; i++)
  {
    moving_window[count][i] = YPR[i];
  }
  int avgYPRSigned[3] = {0};
  uint16_t avgYPR[3] = {0};

  for (int i = 0; i < window_size; i++)
  {
    for (int j = 0; j < 3; j++)
    {
      avgYPRSigned[j] += moving_window[i][j];
    }
  }

  for (int i = 0; i < 3; i++)
  {
    avgYPRSigned[i] /= window_size;
    avgYPR[i] = avgYPRSigned[i];
    if (avgYPRSigned[i] < 0)
    {
      avgYPR[i] += 360;
    }
  }

  Serial.print("Average Yaw:");
  Serial.print(avgYPR[0]);
  Serial.print(" Average Pitch:");
  Serial.print(avgYPR[1]);
  Serial.print(" Average Roll:");
  Serial.println(avgYPR[2]);

  uint8_t badPosture = 0;

  digitalWrite(HAPTIC_PIN, 0);

  for (int i = 1; i < 2; i++)
  {
    Serial.println(avgYPRSigned[i]);
    if (avgYPRSigned[i] < rangeYPR[i][0] || avgYPRSigned[i] > rangeYPR[i][1]) // since YPR is signed
    {
      if (typing_mode != 0)
      {
        badPosture = 1;
      }
    }
  }

  if (haptic_mode == 1 && badPosture == 1)
  {
    digitalWrite(HAPTIC_PIN, 1);
  }

  if (deviceConnected) {
    pCharacteristicYaw->setValue((uint8_t *)&avgYPR[0], 2);
    pCharacteristicYaw->notify();
    pCharacteristicPitch->setValue((uint8_t *)&avgYPR[1], 2);
    pCharacteristicPitch->notify();
    pCharacteristicRoll->setValue((uint8_t *)&avgYPR[2], 2);
    pCharacteristicRoll->notify();
    pCharacteristicPosture->setValue((uint8_t *)&badPosture, 1);
    pCharacteristicPosture->notify();  
  }
  if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
      oldDeviceConnected = deviceConnected;
  }

  count++;
  count %= window_size;
  delay(DELTAT);
}

