import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation

import random
import threading

xres = 300
ymin = -512
ymax = 512
ystep = 20

# First set up the figure, the axis, and the plot element we want to animate
fig = plt.figure()
line1,line2,line3,line4, = plt.plot(
        [], [], 'b-',
        [], [], 'y-',
        [], [], 'g-',
        [], [], 'r-',
        )
plt.xlim(0, xres)
plt.ylim(ymin, ymax)
plt.yticks(range(ymin, ymax+1, ystep))
plt.grid(True, which='both')

x = np.arange(xres)
gyro_rates    = [0] * xres
acc_angles    = [0] * xres
gyro_angles   = [0] * xres
kalman_angles = [0] * xres

source = open('/dev/ttyACM0', 'r')
stop_thread = False

def init():
    line1.set_data([], [])
    line2.set_data([], [])
    line3.set_data([], [])
    line4.set_data([], [])
    return line1, line2, line3, line4,

def animate(i):
    line1.set_data(x, acc_angles)
    line2.set_data(x, gyro_rates)
    line3.set_data(x, gyro_angles)
    line4.set_data(x, kalman_angles)
    return line1, line2, line3, line4,

def read_data():
    while not stop_thread:
        data = source.readline().split(',')
        if len(data) == 4:
            try:
                acc_angle = float(data[0])
                del acc_angles[0]
                acc_angles.append(acc_angle)

                gyro_rate = float(data[1])
                del gyro_rates[0]
                gyro_rates.append(gyro_rate)

                gyro_angle = float(data[2])
                del gyro_angles[0]
                gyro_angles.append(gyro_angle)

                kalman_angle = float(data[3])
                del kalman_angles[0]
                kalman_angles.append(kalman_angle)
            except ValueError:
                print 'bad data:', data
        else:
            print 'not enough data:', data

try:
    thread = threading.Thread(target=read_data)
    thread.start()

    # call the animator.  blit=True means only re-draw the parts that have changed.
    anim = animation.FuncAnimation(fig, animate, init_func=init, interval=20)
    plt.show()
finally:
    stop_thread = True
    thread.join()
    print 'Closing ttyACM0...'
    source.close()
