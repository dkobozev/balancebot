import pygame
import math
from pygame.locals import *

import threading

WINSIZE = (640, 480)

data = math.radians(-90)

stop_thread = False
source = open('/dev/ttyACM0', 'r')

def read_data():
    global data

    while not stop_thread:
        line = source.readline().strip()
        try:
            quid_angle = int(line)
            data = math.radians(180*quid_angle/512 - 90)
        except ValueError:
            print 'bad data:', line

def main():
    global stop_thread

    pygame.init()

    screen = pygame.display.set_mode(WINSIZE)
    clock = pygame.time.Clock()
    font = pygame.font.SysFont('Arial', 12)
    face_r = 200
    hand_r = face_r - 10

    done = 0

    try:
        thread = threading.Thread(target=read_data)
        thread.start()

        while not done:
            screen.fill((20, 20, 20))
            pygame.draw.circle(screen, (255, 255, 255), (WINSIZE[0]/2, WINSIZE[1]/2), face_r)

            for i in range(0, 360, 10):
                a = math.radians(i-90)
                deg = font.render(str(i), 1, (255, 255, 255))
                fsize = font.size(str(i))
                screen.blit(deg, (WINSIZE[0]/2 + 1.08*face_r*math.cos(a) - fsize[0]/2,
                                  WINSIZE[1]/2 + 1.08*face_r*math.sin(a) - fsize[1]/2))

            pygame.draw.line(screen, (225, 0, 0), (WINSIZE[0]/2, WINSIZE[1]/2), (WINSIZE[0]/2 + hand_r*math.cos(data),
                                                                                 WINSIZE[1]/2 + hand_r*math.sin(data)), 3)

            pygame.display.update()

            for e in pygame.event.get():
                if e.type == QUIT or (e.type == KEYUP and e.key == K_ESCAPE):
                    done = 1
                    break

            clock.tick(60)
    finally:
        stop_thread = True
        thread.join()
        source.close()

main()
