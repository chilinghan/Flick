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

#define HAPTIC_PIN 17 // on pin D17

/* Set the delay between fresh samples */
#define BNO055_SAMPLERATE_DELAY_MS 100
#define BNO055_PRIMARY_ADDRESS 0x28
#define BNO055_SECONDARY_ADDRESS 0x29
#define APP_DATA_CYCLE 1000 // in ms

const int window_size = APP_DATA_CYCLE / BNO055_SAMPLERATE_DELAY_MS;

// Check I2C device address and correct line below (by default address is 0x29 or 0x28)
//                                   id, address
Adafruit_BNO055 bno1; // on hand
Adafruit_BNO055 bno2; // on forearm

BLECharacteristic *pCharacteristicYaw;
BLECharacteristic *pCharacteristicPitch;
BLECharacteristic *pCharacteristicRoll;
BLEServer *pServer;
bool deviceConnected = false;
bool oldDeviceConnected = false;

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

  while (!Serial) delay(500);  // wait for serial port to open!
  
  Serial.println("Starting BLE work!");

  BLEDevice::init("WristPlus");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristicYaw = pService->createCharacteristic(
                                         CHARACTERISTIC_YAW,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_NOTIFY |
                                         BLECharacteristic::PROPERTY_WRITE

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

  Serial.println("Orientation Sensor Raw Data Test");
  Serial.println("");

  /* Initialize the IMUs */
  bno1 = Adafruit_BNO055(0, BNO055_PRIMARY_ADDRESS, &Wire);
  bno2 = Adafruit_BNO055(1, BNO055_SECONDARY_ADDRESS, &Wire);

  if(!bno1.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO0551 detected ... Check your wiring or I2C ADDR!");
    // while(1);
  }

  if (!bno2.begin())
  {
      /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO0552 detected ... Check your wiring or I2C ADDR!");
    // while(1);
  }

  delay(1000);

  bno1.setExtCrystalUse(true);
  bno2.setExtCrystalUse(true);

  /* Initialize haptics */
  // if( !hapDrive.begin())
  //   Serial.println("Could not communicate with Haptic Driver.");
  // else
  //   Serial.println("Qwiic Haptic Driver DA7280 found!");

  // if( !hapDrive.defaultMotor() ) 
  //   Serial.println("Could not set default settings.");

  // hapDrive.enableFreqTrack(false);
  // hapDrive.setOperationMode(DRO_MODE);
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
  imu::Vector<3> euler1 = bno1.getVector(Adafruit_BNO055::VECTOR_EULER);
  imu::Vector<3> euler2 = bno2.getVector(Adafruit_BNO055::VECTOR_EULER);

  // Convert Euler angles to radians
  float roll1 = radians(euler1.z());
  float pitch1 = radians(euler1.y());
  float yaw1 = radians(euler1.x());

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
  yaw = (yaw < 0) ? yaw += 180 : yaw -= 180;
  yaw = -yaw;

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
  uint16_t avgRoll, avgPitch, avgYaw = 0;
  
  for (int i = 0; i < window_size; i++)
  {
    avgYaw += moving_window[i][0];
    avgPitch += moving_window[i][1];
    avgRoll += moving_window[i][2];
  }

  avgYaw /= window_size;
  avgPitch /= window_size;
  avgRoll /= window_size;

  digitalWrite(HAPTIC_PIN, 1);
  // hapDrive.setVibrate(127);
  
  if (deviceConnected) {

    pCharacteristicYaw->setValue(avgYaw);
    pCharacteristicYaw->notify();
    pCharacteristicPitch->setValue(avgPitch);
    pCharacteristicPitch->notify();
    pCharacteristicRoll->setValue(avgRoll);
    pCharacteristicRoll->notify();
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
  delay(BNO055_SAMPLERATE_DELAY_MS);
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
