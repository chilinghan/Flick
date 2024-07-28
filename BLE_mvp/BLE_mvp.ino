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
#define CHARACTERISTIC_HAPTICS "AB3F4426-FFF9-42F9-9207-928245A924A5"
#define CHARACTERISTIC_TYPING "46EA3751-2006-4F14-A09A-161DACE1AC5D"

#define HAPTIC_PIN 17 // on pin D17

/* Set the delay between fresh samples */
#define DELTAT 100
#define BNO055_PRIMARY_ADDRESS 0x28
#define BNO055_SECONDARY_ADDRESS 0x29
#define APP_DATA_CYCLE 1000 // in ms

#define alpha 0.85

#define ANGLE_OFFSET 0
const int window_size = APP_DATA_CYCLE / DELTAT;
const int rangeYPR[3][2] = {{-180, 180}, {-25, 25}, {-180, 180}}; // in deg

// Check I2C device address and correct line below (by default address is 0x29 or 0x28)
//                                   id, address
// Adafruit_BNO055 bno1; // on hand
SparkFun_ISM330DHCX ism; 
Adafruit_BNO055 bno2; // on forearm

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
int moving_window[window_size][3];
int count;

uint8_t haptic_mode = 0; // 0: off, 1: on
uint8_t typing_mode = -1; // 0: off, 1: on, 2: automatic

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

	// Reset the device to default settings. This if helpful is you're doing multiple
	// uploads testing different settings. 

  bno2 = Adafruit_BNO055(1, BNO055_SECONDARY_ADDRESS, &Wire);

  if(!ism.begin())
  {
    Serial.println("Ooops, no ism detected ... Check your wiring or I2C ADDR!");
    // while(1);
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
	ism.setGyroDataRate(ISM_GY_ODR_104Hz);
	ism.setGyroFullScale(ISM_125dps); 

	// Turn on the accelerometer's filter and apply settings. 
	ism.setAccelFilterLP2();
	ism.setAccelSlopeFilter(ISM_LP_ODR_DIV_100);

	// Turn on the gyroscope's filter and apply settings. 
	ism.setGyroFilterLP1();
	ism.setGyroLP1Bandwidth(ISM_MEDIUM);

  if (!bno2.begin())
  {
    Serial.println("Ooops, no BNO0552 detected ... Check your wiring or I2C ADDR!");
    // while(1);
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
  float pitch1 = -euler1[1] + ANGLE_OFFSET;
  float yaw1 = -euler1[2];

  imu::Vector<3> euler2 = bno2.getVector(Adafruit_BNO055::VECTOR_EULER);

  float roll2 = radians(euler2.z());
  float pitch2 = radians(euler2.y());
  float yaw2 = radians(euler2.x());

  Serial.print("Roll1:");
  Serial.print(degrees(roll1));
  Serial.print(" Pitch1:");
  Serial.print(degrees(pitch1));
  Serial.print(" Yaw1:");
  Serial.print(degrees(yaw1));
  Serial.print("\t");
  Serial.print("Roll2:");
  Serial.print(degrees(roll2));
  Serial.print(" Pitch2:");
  Serial.print(degrees(pitch2));
  Serial.print(" Yaw2:");
  Serial.println(degrees(yaw2));

  // Compute rotation matrices for both IMUs
  // float R1[3][3], R2[3][3];
  // eulerToMatrix(roll1, pitch1, yaw1, R1);
  // eulerToMatrix(roll2, pitch2, yaw2, R2);

  // // Compute the relative rotation matrix R_relative = R1^T * R2
  // float R_relative[3][3];
  // relativeRotationMatrix(R1, R2, R_relative);

  // // Convert the relative rotation matrix back to Euler angles
  // float roll_r, pitch_r, yaw_r;
  // matrixToEuler(R_relative, &roll_r, &pitch_r, &yaw_r);

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
