#include <Arduino.h>
#include <Wire/Wire.h>

#include "Adafruit_L3GD20/Adafruit_L3GD20.h"

#define PIN_GYRO_CS  4 // labeled CS
#define PIN_GYRO_DO  5 // labeled SA0
#define PIN_GYRO_DI  6 // labeled SDA
#define PIN_GYRO_CLK 7 // labeled SCL

#define PIN_BIN1 3
#define PIN_BIN2 9
#define PIN_AIN2 10
#define PIN_AIN1 11

#define LOOP_DT 10

#define QUID_PER_DEG 2.8444

#define GYR_Y 0
#define ACC_Y 1
#define ACC_Z 2

#define ACC_Y_START (-503)
#define ACC_Z_START (-469)
#define ACC_Y_MULT 1
#define ACC_Z_MULT .9689

#define GUARD_GAIN 20.0

// http://www.dspguru.com/dsp/tricks/fixed-point-atan2-with-self-normalization
//
// return angle in Quids (1024 Quids = 360 deg) in range -512 .. 512 (-pi .. pi)
int fast_atan2(int y, int x) {
    int coeff_1 = 128;
    int coeff_2 = 3*coeff_1;
    int abs_y = abs(y);
    int angle;

    if (x == 0 && y == 0) {
        return 0;
    }
    else if (x >= 0) {
        angle = coeff_1 - coeff_1 * ((x - abs_y) / (float) (x + abs_y));
    }
    else {
        angle = coeff_2 - coeff_1 * ((x + abs_y) / (float) (abs_y - x));
    }

    if (y < 0) {
        return -angle;
    }
    else {
        return angle;
    }
}

uint8_t outbuf[6]; // array to store arduino output
int cnt = 0;

int sensor_values[] = { 0, 0, 0 };

void nunchuck_init()
{
    Wire.beginTransmission(0x52); // transmit to device 0x52
    Wire.write(0x40);              // write memory address
    Wire.write(0x00);
    Wire.endTransmission();
}

// Encode data to format that most wiimote drivers except
// only needed if you use one of the regular wiimote drivers
char nunchuk_decode_byte (char x)
{
  x = (x ^ 0x17) + 0x17;
  return x;
}

void send_zero()
{
    Wire.beginTransmission(0x52);
    Wire.write(0x00);
    Wire.endTransmission();
}

Adafruit_L3GD20 gyro(PIN_GYRO_CS, PIN_GYRO_DO, PIN_GYRO_DI, PIN_GYRO_CLK);

void setup()
{
    Serial.begin(9600);

    // Try to initialise and warn if we couldn't detect the chip
    //if (!gyro.begin(gyro.L3DS20_RANGE_250DPS))
    //if (!gyro.begin(gyro.L3DS20_RANGE_500DPS))
    if (!gyro.begin(gyro.L3DS20_RANGE_2000DPS))
        {
    Serial.println("Oops ... unable to initialize the L3GD20. Check your wiring!");
    while (1);
        }

    Wire.begin();              // join i2c bus with address 0x52
    nunchuck_init();           // send the initilization handshake

    //pinMode(PIN_BIN1, OUTPUT);
    //pinMode(PIN_BIN2, OUTPUT);
    //pinMode(PIN_AIN2, OUTPUT);
    //pinMode(PIN_AIN1, OUTPUT);
}

void read_sensors()
{
    // accelerometer
    Wire.requestFrom (0x52, 6);	// request data from nunchuck

    while (Wire.available()) {
        // read byte as an integer
        outbuf[cnt] = nunchuk_decode_byte(Wire.read());
        cnt++;
    }

    sensor_values[ACC_Y] = outbuf[3] * 2 * 2;
    sensor_values[ACC_Z] = outbuf[4] * 2 * 2;

    // don't forget the least significant bits
    if ((outbuf[5] >> 2) & 1)
        sensor_values[ACC_Y] += 2;
    if ((outbuf[5] >> 3) & 1)
        sensor_values[ACC_Y] += 1;

    if ((outbuf[5] >> 6) & 1)
        sensor_values[ACC_Z] += 2;
    if ((outbuf[5] >> 7) & 1)
        sensor_values[ACC_Z] += 1;

    cnt = 0;
    send_zero(); // send the request for next bytes

    // gyro
    gyro.read();
    sensor_values[GYR_Y] = (int) gyro.data.y;
}

float Q_angle  =  0.001; //0.001
float Q_gyro   =  0.003;  //0.003
float R_angle  =  0.03;  //0.03

float x_angle = 0;
float x_bias = 0;
float P_00 = 0, P_01 = 0, P_10 = 0, P_11 = 0;
float dt, y, S;
float K_0, K_1;

float kalman_calculate(float angle, float rate,int looptime) {
    dt = float(looptime)/1000;

    x_angle += dt * (rate - x_bias);

    P_00 += dt * (dt * P_11 - P_01 - P_10 + Q_angle);
    P_01 -= dt * P_11;
    P_10 -= dt * P_11;
    P_11 += Q_gyro * dt;

    y = angle - x_angle;
    S = P_00 + R_angle;
    K_0 = P_00 / S;
    K_1 = P_10 / S;

    x_angle += K_0 * y;
    x_bias  += K_1 * y;

    P_00 -= K_0 * P_00;
    P_01 -= K_0 * P_01;
    P_10 -= K_1 * P_00;
    P_11 -= K_1 * P_01;

    return x_angle;
}


float last_error = 0;
float integrated_error = 0;

int updatePid(int targetPosition, int currentPosition, float K, float Kp, float Ki, float Kd) {
    float pTerm = 0, iTerm = 0, dTerm = 0;
    float error;

    error = targetPosition - currentPosition;
    pTerm = Kp * error;
    integrated_error += error;
    iTerm = Ki * constrain(integrated_error, -GUARD_GAIN, GUARD_GAIN);
    dTerm = Kd * (error - last_error);
    last_error = error;

    return -constrain((int) (K*(pTerm + iTerm + dTerm)), -255, 255);
}

void Drive_Motor(int torque) {
    if (torque >= 0) {
        //if (torque > 5)
        //    torque = map(torque, 0, 255, 30, 255);

        analogWrite(PIN_BIN1, torque);
        analogWrite(PIN_BIN2, 0);
        analogWrite(PIN_AIN2, 0);
        analogWrite(PIN_AIN1, torque*.75);
    } else {
        torque = abs(torque);
        //if (torque > 5)
        //    torque = map(torque, 0, 255, 30, 255);

        analogWrite(PIN_BIN1, 0);
        analogWrite(PIN_BIN2, torque);
        analogWrite(PIN_AIN2, torque*.75);
        analogWrite(PIN_AIN1, 0);
    }
}

int acc_y, acc_z;
int acc_angle = 0;
float gyro_rate = 0;
int kalman_angle = 0;
unsigned long t_loop_start = 0;
int t_loop_actual = 10;
int t_loop_total = 10;

double gap;
int drive = 0;
int set_point = 4;
int gap_dist = 15; // point where PID switches from conservative to agressive
//double aggK=0.5, aggKp=5, aggKi=.5, aggKd=4; // aggressive
//double aggK=1.0, aggKp=11, aggKi=1.5, aggKd=20;
double aggK=1.0, aggKp=12, aggKi=0, aggKd=30;
double consK=0.2, consKp=5, consKi=.2, consKd=1; // conservative

void loop()
{
    read_sensors();

    acc_y = round((sensor_values[ACC_Y] + ACC_Y_START) * ACC_Y_MULT);
    acc_z = round((sensor_values[ACC_Z] + ACC_Z_START) * ACC_Z_MULT);
    acc_angle = fast_atan2(-acc_z, -acc_y) + 256;
    gyro_rate = -sensor_values[GYR_Y] * QUID_PER_DEG;

    kalman_angle = kalman_calculate(acc_angle, gyro_rate, t_loop_total);

    //gap = abs(set_point - kalman_angle);
    //if (gap < gap_dist) {
    //    drive = updatePid(set_point, kalman_angle, consK, consKp, consKi, consKd);
    //} else {
    //    drive = updatePid(set_point, kalman_angle, aggK, aggKp, aggKi, aggKd);
    //}
    //
        drive = updatePid(set_point, kalman_angle, aggK, aggKp, aggKi, aggKd);
    //    drive = updatePid(set_point, kalman_angle, consK, consKp, consKi, consKd);

    if (abs(set_point - kalman_angle) < 150) {
        Drive_Motor(drive);
    } else {
        Drive_Motor(0); // stop motors if the situation is hopeless
    }

    //Serial.print(acc_angle);
    //Serial.print(",");
    //Serial.print(0);
    //Serial.print(",");
    //Serial.print(0);
    //Serial.print(",");
    //Serial.print(kalman_angle);
    //Serial.print(drive);
    //Serial.print("\n");

    // make sure the loop takes the exactly specified amount of time
    t_loop_actual = millis() - t_loop_start;
    if (t_loop_actual < LOOP_DT) {
        delay(LOOP_DT - t_loop_actual);
    }
    t_loop_total = millis() - t_loop_start;
    t_loop_start = millis();
}
