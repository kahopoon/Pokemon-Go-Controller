from __future__ import print_function, division
import xml.etree.cElementTree as ET
import time as time
import os
from copy import deepcopy
from subprocess import Popen, PIPE


''' x and y coordinate of xcode location button '''
XCODE_LOCATION_BUTTON_COORDINATES = {
    'x': 650,
    'y': 900
}

''' amount of time to wait between location changes'''
SECONDS_PAUSE_BETWEEN_MOVES = 2.2

''' number of steps to move vertical when on box edges '''
NUM_STEPS_UP_PER_PASS = 2

''' number of steps to move between horizontal pass'''
NUM_STEPS_ACCROSS_PER_PASS = 25

''' number of moves going vertical '''
NUM_INCREMENTS_UP = 50

''' number of pixels down for xcode button '''
NUM_PIXELS_DOWN_FOR_CLICK = 50

''' click or perform apple script '''
USE_APPLE_SCRIPT = True

''' file name of location file '''
LOCATION_FILE_NAME = 'pokemonLocation'

class Coordinate:

    def __init__(self, lat, lon):
        self.lat = lat
        self.lon = lon

    def get(self):
        return [self.lat, self.lon]

    def __str__(self):
        return 'lat: %f, lon: %f' % (self.lat, self.lon)

    def __eq__(self, other):

        return (self.lat == other.lat) and (self.lon == other.lon)
    def __mul__(self, other):
        if isinstance(other, Coordinate):
            return Coordinate(self.lat * other.lat, self.lon * other.long)
        elif type(other) is int:
            return Coordinate(self.lat * other, self.lon * other)
        else:
            raise ValueError('Unknown type')

    def __add__(self, other):
        if isinstance(other, Coordinate):
            return Coordinate(self.lat + other.lat, self.lon + other.lon)
        elif type(other) is int:
            return Coordinate(self.lat + other, self.lon + other)
        else:
            raise ValueError('Unknown type')

    def __sub__(self, other):
        if isinstance(other, Coordinate):
            return Coordinate(self.lat - other.lat, self.lon - other.lon)
        elif type(other) is int:
            return Coordinate(self.lat - other, self.lon - other)
        else:
            raise ValueError('Unknown type')

    def __truediv__(self, other):
        if isinstance(other, Coordinate):
            return Coordinate(self.lat / other.lat, self.lon / other.lon)
        elif type(other) is int:
            return Coordinate(self.lat / other, self.lon / other)
        else:
            raise ValueError('Unknown type')

    def __div__(self, other):

        return self.__truediv__(other)


coordinates = [
    Coordinate(40.7680578657186, -73.981887864142),  # Bottom Left
    Coordinate(40.7643841763404, -73.972945530681),  # Bottom Right
    Coordinate(40.7969415563396, -73.949272376481),  # Top Right
    Coordinate(40.8006549898320, -73.958185987147),  # Top Left
]

def continueWalking(change, current, end):
    # print(change, current, end)

    if change > 0:
        return current < end
    elif change < 0:
        return current > end
    return False

# continueWalking(0.000073, coordinates[0].lat, coordinates[1].lat)
# continueWalking(-0.000179, coordinates[0].lon, coordinates[1].lon)

def moveInApp():

    if USE_APPLE_SCRIPT is True:
        move_script = '''
            property locationName : "%s" #  name of gpx filex

            tell application "System Events"
                tell process "Xcode"
                    click menu item locationName of menu 1 of menu item "Simulate Location" of menu 1 of menu bar item "Debug" of menu bar 1
                end tell
            end tell
        ''' % (LOCATION_FILE_NAME)

        args = []
        process = Popen(
            ['osascript', '-'] + args,
            stdin=PIPE,
            stdout=PIPE,
            stderr=PIPE
        )

        stdout, stderr = process.communicate(move_script)

        if len(stderr) != 0:
            print('Error', stderr)
            exit()

    else:
        os.system("./autoClicker -x %d -y %d" % (XCODE_LOCATION_BUTTON_COORDINATES ['x'], XCODE_LOCATION_BUTTON_COORDINATES ['y']))
        os.system("./autoClicker -x %d -y %d" % (XCODE_LOCATION_BUTTON_COORDINATES ['x'], XCODE_LOCATION_BUTTON_COORDINATES ['y'] + NUM_PIXELS_DOWN_FOR_CLICK))

    ''' delay '''
    time.sleep(SECONDS_PAUSE_BETWEEN_MOVES)

def writeFile(coordinate):
    gpx = ET.Element("gpx", version="1.1", creator="Xcode")
    wpt = ET.SubElement(gpx, "wpt", lat=str(coordinate.lat), lon=str(coordinate.lon))
    ET.SubElement(wpt, "name").text = LOCATION_FILE_NAME
    ET.ElementTree(gpx).write("%s.gpx" % (LOCATION_FILE_NAME))

    print("Location Updated to:", coordinate)

def moveToCoordinate(start, end, pace=NUM_STEPS_ACCROSS_PER_PASS):
    current = start

    change = end - start
    change /= pace

    i_moves = 0
    while (
        continueWalking(change.lat, current.lat, end.lat) \
        or continueWalking(change.lon, current.lon, end.lon)
    ):

        if i_moves > 500:
            print('TERMINATED')
            break

        current += change

        writeFile(current)
        moveInApp()

        i_moves += 1
    # print('moved', i_moves)
    return end



def main():
    start = coordinates[0]
    end = coordinates[3]

    current = deepcopy(start)

    change_left = coordinates[3] - coordinates[0]
    change_left /= NUM_INCREMENTS_UP

    change_right = coordinates[2] - coordinates[1]
    change_right /= NUM_INCREMENTS_UP

    num_times_left = 0
    num_times_right = 0

    i_loops = 0
    while True:

        if i_loops > 99999:
            print('ENDED GAME')
            break

        # move right
        current = moveToCoordinate(current,  coordinates[1] + change_right * num_times_right)
        num_times_right += 1

        # move up
        current =  moveToCoordinate(current, coordinates[1] + change_right * num_times_right, pace=2)

        # move left
        current = moveToCoordinate(current, coordinates[0] + change_left * num_times_left)
        num_times_left += 1

        # move up
        current = moveToCoordinate(current, coordinates[0] + change_left * num_times_left, pace=2)

        near_end = current - end
        if abs(near_end.lat) <= 0.0001 or abs(near_end.lon) <= 0.0001:
            print('END')
            break

        i_loops += 1

if __name__ == "__main__":
    main()
