#include <Wire.h>
#include "SparkFun_BMI270_Arduino_Library.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_YAW  "e848839a-6db5-4aa8-918a-5d0f2a131e0d"
#define CHARACTERISTIC_ROLL "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_PITCH "066a8ce3-6217-4d38-ab95-e2c7eb872c4e"

/* Set the delay between fresh samples */
#define DELTAT 100 // in ms
#define APP_DATA_CYCLE 500 // in ms

const int window_size = APP_DATA_CYCLE / DELTAT;
const float alpha = 0.98;

// Check I2C device address and correct line below (by default address is 0x29 or 0x28)
//                                   id, address
BMI270 imu1;
BMI270 imu2;
Haptic_Driver hapDrive;


BLECharacteristic *pCharacteristicYaw;
BLECharacteristic *pCharacteristicPitch;
BLECharacteristic *pCharacteristicRoll;

float euler1[3];
float euler2[3];
int moving_window[window_size][3];
int count;

void setup() {
  // Initialize the I2C library
  Wire.begin();

  Serial.begin(115200);

  while (!Serial) delay(500);  // wait for serial port to open!
  
  Serial.println("Starting BLE work!");

  BLEDevice::init("WristPlus");
  BLEServer *pServer = BLEDevice::createServer();
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

  /* Initialize the haptics */
  if( !hapDrive.begin())
    Serial.println("Could not communicate with Haptic Driver.");
  else
    Serial.println("Qwiic Haptic Driver DA7280 found!");

  if( !hapDrive.defaultMotor() ) 
    Serial.println("Could not set default settings.");

  hapDrive.enableFreqTrack(false);

  Serial.println("Setting I2C Operation.");
  hapDrive.setOperationMode(DRO_MODE);
  Serial.println("Ready.");
  
  /* Initialize the sensor */
  // Check if sensor is connected and initialize
  // Address is optional (defaults to 0x68)
  while(imu1.beginI2C(BMI2_I2C_PRIM_ADDR) != BMI2_OK || imu2.beginI2C(BMI2_I2C_SEC_ADDR) != BMI2_OK)
  {
      // Not connected, inform user
      Serial.println("Error: BMI270 not connected, check wiring and I2C address!");

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
  err2 = imu2.setConfig(accelConfig);

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

  pService->start();
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
  
  float gyroX1 = imu1.data.gyroX;
  float gyroY1 = imu1.data.gyroY;
  float gyroZ1 = imu1.data.gyroZ;
  Serial.print("Gyro X: ");
  Serial.print(gyroX1, 3);
  Serial.print(", Y: ");
  Serial.print(gyroY1, 3);
  Serial.print(", Z: ");
  Serial.print(gyroZ1, 3);
  Serial.println(" deg/s");

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
  euler1[0] = alpha * (euler1[0] + gyroX1 * DELTAT) + (1 - alpha) * atan2(accelY1, accelZ1);
  // pitch
  euler1[1] = alpha * (euler1[1] + gyroY1 * DELTAT) + (1 - alpha) * atan2(-accelX1, sqrt(accelY1 * accelY1 + accelZ1 * accelZ1));
  // yaw
  euler1[2] += gyroZ1 * DELTAT;

  // roll
  euler2[0] = alpha * (euler2[0] + gyroX2 * DELTAT) + (1 - alpha) * atan2(accelY2, accelZ2);
  // pitch
  euler2[1] = alpha * (euler2[1] + gyroY2 * DELTAT) + (1 - alpha) * atan2(-accelX2, sqrt(accelY2 * accelY2 + accelZ2 * accelZ2));
  // yaw
  euler2[2] += gyroZ2 * DELTAT;

  // Compute rotation matrices for both IMUs
  float R1[3][3], R2[3][3];
  // roll, pitch, yaw
  eulerToMatrix(euler1[0], euler1[1], euler1[2], R1);
  eulerToMatrix(euler2[0], euler2[1], euler2[2], R2);

  // Compute the relative rotation matrix R_relative = R1^T * R2
  float R_relative[3][3];
  relativeRotationMatrix(R1, R2, R_relative);

  // Convert the relative rotation matrix back to Euler angles
  float roll_r, pitch_r, yaw_r;
  matrixToEuler(R_relative, &roll_r, &pitch_r, &yaw_r);

  // Convert the relative angles back to degrees
  int roll = (int) degrees(roll_r);
  int pitch = (int) degrees(pitch_r);
  int yaw = (int) degrees(yaw_r);
  yaw = (yaw < 0) ? yaw += 180 : yaw -= 180;
  yaw = -yaw;

  // Print the relative Euler angles
  Serial.println();
  Serial.print("Relative Yaw:");
  Serial.print(yaw);
  Serial.print(" Relative Pitch:");
  Serial.print(pitch);
  Serial.print(" Relative Roll:");
  Serial.println(roll);

  moving_window[count][0] = yaw;
  moving_window[count][1] = pitch;
  moving_window[count][2] = roll;

  int avgRoll, avgPitch, avgYaw = 0;
  for (int i = 0; i < window_size; i++)
  {
    avgYaw += moving_window[i][0];
    avgPitch += moving_window[i][1];
    avgRoll += moving_window[i][2];
  }

  avgYaw /= window_size;
  avgPitch /= window_size;
  avgRoll /= window_size;

  pCharacteristicYaw->setValue(avgYaw);
  pCharacteristicPitch->setValue(avgPitch);
  pCharacteristicRoll->setValue(avgRoll);

  count++;
  count %= window_size;
  delay(DELTAT);
}

void eulerToMatrix(float roll, float pitch, float yaw, float matrix[3][3]) {
  float c1 = cos(yaw);
  float s1 = sin(yaw);
  float c2 = cos(pitch);
  float s2 = sin(pitch);
  float c3 = cos(roll);
  float s3 = sin(roll);

  matrix[0][0] = c1 * c2;
  matrix[0][1] = c1 * s2 * s3 - s1 * c3;
  matrix[0][2] = c1 * s2 * c3 + s1 * s3;
  matrix[1][0] = s1 * c2;
  matrix[1][1] = s1 * s2 * s3 + c1 * c3;
  matrix[1][2] = s1 * s2 * c3 - c1 * s3;
  matrix[2][0] = -s2;
  matrix[2][1] = c2 * s3;
  matrix[2][2] = c2 * c3;
}

void relativeRotationMatrix(float R1[3][3], float R2[3][3], float R_relative[3][3]) {
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      R_relative[i][j] = 0;
      for (int k = 0; k < 3; k++) {
        R_relative[i][j] += R1[k][i] * R2[k][j];  // the transpose of R1
      }
    }
  }
}

void matrixToEuler(float matrix[3][3], float *roll, float *pitch, float *yaw) {
  *pitch = -asin(matrix[2][0]);
  *roll = atan2(matrix[2][1], matrix[2][2]);
  *yaw = atan2(matrix[1][0], matrix[0][0]);
}
