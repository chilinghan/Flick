#include <SparkFun_ISM330DHCX.h>
#include <Wire.h>
#include "Adafruit_BNO055.h"
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

#define HAPTIC_PIN 17 // on pin D17

/* Set the delay between fresh samples */
#define DELTAT 100
#define BNO055_PRIMARY_ADDRESS 0x28
#define BNO055_SECONDARY_ADDRESS 0x29
#define APP_DATA_CYCLE 1000 // in ms

#define alpha 0.98
const int window_size = APP_DATA_CYCLE / DELTAT;
const int rangeYPR[3][2] = {{0, 0}, {30, 360-30}, {0, 0}}; // in deg

// Check I2C device address and correct line below (by default address is 0x29 or 0x28)
//                                   id, address
// Adafruit_BNO055 bno1; // on hand
SparkFun_ISM330DHCX ism; 
Adafruit_BNO055 bno2; // on forearm

BLECharacteristic *pCharacteristicYaw;
BLECharacteristic *pCharacteristicPitch;
BLECharacteristic *pCharacteristicRoll;
BLECharacteristic *pCharacteristicPosture;

BLEServer *pServer;
bool deviceConnected = false;
bool oldDeviceConnected = false;

float euler1[3];
int moving_window[window_size][3];
int count;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
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

  Serial.println("Orientation Sensor Raw Data Test");
  Serial.println("");

	// Reset the device to default settings. This if helpful is you're doing multiple
	// uploads testing different settings. 

  bno2 = Adafruit_BNO055(1, BNO055_SECONDARY_ADDRESS, &Wire);

  if(!ism.begin())
  {
    Serial.print("Ooops, no ism detected ... Check your wiring or I2C ADDR!");
    while(1);
  }

  ism.deviceReset();
	Serial.println("Reset.");
	Serial.println("Applying settings.");
	delay(100);
	
	ism.setDeviceConfig();
	ism.setBlockDataUpdate();
	
	// Set the output data rate and precision of the accelerometer
	ism.setAccelDataRate(ISM_XL_ODR_104Hz);
	ism.setAccelFullScale(ISM_4g); 

	// Set the output data rate and precision of the gyroscope
	ism.setGyroDataRate(ISM_GY_ODR_26Hz);
	ism.setGyroFullScale(ISM_125dps); 

	// Turn on the accelerometer's filter and apply settings. 
	ism.setAccelFilterLP2();
	ism.setAccelSlopeFilter(ISM_LP_ODR_DIV_100);

	// Turn on the gyroscope's filter and apply settings. 
	ism.setGyroFilterLP1();
	ism.setGyroLP1Bandwidth(ISM_MEDIUM);

  if (!bno2.begin())
  {
    Serial.print("Ooops, no BNO0552 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }

  delay(1000);

  // bno1.setExtCrystalUse(true);
  bno2.setExtCrystalUse(true);

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
  // uint8_t system1, gyro1, accel1, mag1, system2, gyro2, accel2, mag2 = 0;
  // bno1.getCalibration(&system1, &gyro1, &accel1, &mag1);
  // bno2.getCalibration(&system2, &gyro2, &accel2, &mag2);
    
  // Possible vector values can be:
  // - VECTOR_ACCELEROMETER - m/s^2
  // - VECTOR_MAGNETOMETER  - uT
  // - VECTOR_GYROSCOPE     - rad/s
  // - VECTOR_EULER         - degrees
  // - VECTOR_LINEARACCEL   - m/s^2
  // - VECTOR_GRAVITY       - m/s^2
  sfe_ism_data_t accelData; 
  sfe_ism_data_t gyroData;
  if (ism.checkStatus())
  {
    ism.getAccel(&accelData);
    ism.getGyro(&gyroData);
  }

  float accelX1 = accelData.xData / 1000.0;
  float accelY1 = accelData.yData / 1000.0;
  float accelZ1 = accelData.zData / 1000.0;
  float gyroX1 = gyroData.xData / 1000.0;
  float gyroY1 = gyroData.yData / 1000.0;
  float gyroZ1 = gyroData.zData / 1000.0;

  gyroX1 = radians(gyroX1);
  gyroY1 = radians(gyroY1);
  gyroZ1 = radians(gyroZ1);

  // roll
  euler1[0] = alpha * (euler1[0] + gyroX1 * DELTAT / 1000.0) + (1 - alpha) * atan2(accelY1, accelZ1);
  // pitch
  euler1[1] = alpha * (euler1[1] + gyroY1 * DELTAT / 1000.0) + (1 - alpha) * atan2(-accelX1, sqrt(accelY1 * accelY1 + accelZ1 * accelZ1));
  // yaw
  euler1[2] += gyroZ1 * DELTAT / 1000.0;

  // Convert Euler angles to radians
  float roll1 = euler1[0];
  float pitch1 = -euler1[1];
  float yaw1 = -euler1[2];

  imu::Vector<3> euler2 = bno2.getVector(Adafruit_BNO055::VECTOR_EULER);

  float roll2 = radians(euler2.z());
  float pitch2 = radians(euler2.y());
  float yaw2 = radians(euler2.x());

  // Serial.print("Roll1:");
  // Serial.print(degrees(roll1));
  // Serial.print(" Pitch1:");
  // Serial.print(degrees(pitch1));
  // Serial.print(" Yaw1:");
  // Serial.print(degrees(yaw1));
  // Serial.print("\t");
  // Serial.print("Roll2:");
  // Serial.print(degrees(roll2));
  // Serial.print(" Pitch2:");
  // Serial.print(degrees(pitch2));
  // Serial.print(" Yaw2:");
  // Serial.println(degrees(yaw2));

  // Compute rotation matrices for both IMUs
  float R1[3][3], R2[3][3];
  eulerToMatrix(roll1, pitch1, yaw1, R1);
  eulerToMatrix(roll2, pitch2, yaw2, R2);

  // Compute the relative rotation matrix R_relative = R1^T * R2
  float R_relative[3][3];
  relativeRotationMatrix(R1, R2, R_relative);

  // Convert the relative rotation matrix back to Euler angles
  float roll_r, pitch_r, yaw_r;
  matrixToEuler(R_relative, &roll_r, &pitch_r, &yaw_r);

  // Convert the relative angles back to degrees
  int roll = (int) degrees(roll_r);
  int pitch = (int) -degrees(pitch_r);
  int yaw = (int) degrees(yaw_r);
  // yaw = (yaw < 0) ? yaw += 180 : yaw -= 180;
  // yaw = -yaw;

  if (yaw < 0) {
    yaw += 360;
  }
  if (pitch < 0) {
    pitch += 360;
  }
  if (roll < 0) {
    roll += 360;
  }

  //Print the relative Euler angles
  Serial.print("Relative Yaw:");
  Serial.print(yaw);
  Serial.print(" Relative Pitch:");
  Serial.print(pitch);
  Serial.print(" Relative Roll:");
  Serial.println(roll);

  moving_window[count][0] = yaw;
  moving_window[count][1] = pitch;
  moving_window[count][2] = roll;
  uint16_t avgYaw = 0;
  uint16_t avgPitch = 0;
  uint16_t avgRoll = 0;
  
  for (int i = 0; i < window_size; i++)
  {
    avgYaw += moving_window[i][0];
    avgPitch += moving_window[i][1];
    avgRoll += moving_window[i][2];
  }

  avgYaw /= window_size;
  avgPitch /= window_size;
  avgRoll /= window_size;

  Serial.print("Average Yaw:");
  Serial.print(avgYaw);
  Serial.print(" Average Pitch:");
  Serial.print(avgPitch);
  Serial.print(" Average Roll:");
  Serial.println(avgRoll);

  uint8_t badPosture = 0;

  digitalWrite(HAPTIC_PIN, 0);

  if (pitch > rangeYPR[1][0] && pitch < rangeYPR[1][1])
  {
    digitalWrite(HAPTIC_PIN, 1);
    badPosture = 1;
  }
  
  if (deviceConnected) {
    pCharacteristicYaw->setValue((uint8_t *)&avgYaw, 2);
    pCharacteristicYaw->notify();
    pCharacteristicPitch->setValue((uint8_t *)&avgPitch, 2);
    pCharacteristicPitch->notify();
    pCharacteristicRoll->setValue((uint8_t *)&avgRoll, 2);
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

void matrixToEuler(float matrix[3][3], float *roll, float *pitch, float *yaw) {
  *pitch = -asin(matrix[2][0]);
  *roll = atan2(matrix[2][1], matrix[2][2]);
  *yaw = atan2(matrix[1][0], matrix[0][0]);
}

void relativeRotationMatrix(float R1[3][3], float R2[3][3], float R_relative[3][3]) {
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      R_relative[i][j] = 0;
      for (int k = 0; k < 3; k++) {
        R_relative[i][j] += R1[k][i] * R2[k][j];  // Note the transpose of R1
      }
    }
  }
}
