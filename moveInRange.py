import xml.etree.cElementTree as ET
import time as time
import os
from copy import deepcopy

''' x and y coordinate of xcode location button '''
XCODE_LOCATION_BUTTON_COORDINATES = {
    'x': 650,
    'y': 900
}

''' amount of time to wait between location changes'''
SECONDS_PAUSE_BETWEEN_MOVESZ = 1.2

''' number of steps to move between horizontal locations'''
NUMBER_STEPS_UP_PER_PASS = 100

''' number of pixels down for xcode button '''
NUM_PIXELS_DOWN_FOR_CLICK = 50


class Coordinate:

    def __init__(self, lat, lng):
        self.lat = lat
        self.lng = lng

    def get(self):
        return [self.lat, self.lng]

    def __str__(self):
        return 'lat: %f, lng: %f' % (self.lat, self.lng)

    def __eq__(self, other):

        return (self.lat == other.lat) and (self.lng == other.lng)
    def __mul__(self, other):

        new_coord = Coordinate(self.lat, self.lng)

        if type(other) is Coordinate:
            new_coord.lat *= other.lat
            new_coord.lng *= other.lng
        elif type(other) is int:
            new_coord.lat *= other
            new_coord.lng *= other
        else:
            raise ValueError('Unknown type')
        return new_coord

    def __add__(self, other):
        new_coord = Coordinate(self.lat, self.lng)
        if type(other) is Coordinate:
            new_coord.lat += other.lat
            new_coord.lng += other.lng
        elif type(other) is int:
            new_coord.lat += other
            new_coord.lng += other
        else:
            raise ValueError('Unknown type')

        return new_coord

    def __sub__(self, other):
        new_coord = Coordinate(self.lat, self.lng)

        if type(other) is Coordinate:
            new_coord.lat -= other.lat
            new_coord.lng -= other.lng
        elif type(other) is int:
            new_coord.lat -= other
            new_coord.lng -= other
        else:
            raise ValueError('Unknown type', type(other))
        return new_coord

    def __truediv__(self, other):

        new_coord = Coordinate(self.lat, self.lng)

        if type(other) is Coordinate:
            new_coord.lat /= other.lat
            new_coord.lng /= other.lng
        elif type(other) is int:
            new_coord.lat /= other
            new_coord.lng /= other
        else:
            raise ValueError('Unknown type')
        return new_coord


coordinates = [
    Coordinate(40.7680578657186, -73.981887864142),  # Bottom Left
    Coordinate(40.7643841763404, -73.972945530681),  # Bottom Right
    Coordinate(40.7969415563396, -73.949272376481),  # Top Right
    Coordinate(40.800654989832, -73.958185987147),   # Top Left
]

def continueWalking(change, current, end):
    # print(change, current, end)

    if change > 0:
        return current < end
    elif change < 0:
        return current > end
    return False

# continueWalking(0.000073, coordinates[0].lat, coordinates[1].lat)
# continueWalking(-0.000179, coordinates[0].lng, coordinates[1].lng)


def writeFile(coordinate):
    gpx = ET.Element("gpx", version="1.1", creator="Xcode")
    wpt = ET.SubElement(gpx, "wpt", lat=str(coordinate.lat), lon=str(coordinate.lng))
    ET.SubElement(wpt, "name").text = "PokemonLocation"
    ET.ElementTree(gpx).write("pokemonLocation.gpx")

    print("Location Updated!", coordinate)
    time.sleep(0.01)

    os.system("./autoClicker -x %d -y %d" % (XCODE_LOCATION_BUTTON_COORDINATES ['x'], XCODE_LOCATION_BUTTON_COORDINATES ['y']))
    os.system("./autoClicker -x %d -y %d" % (XCODE_LOCATION_BUTTON_COORDINATES ['x'], XCODE_LOCATION_BUTTON_COORDINATES ['y'] + NUM_PIXELS_DOWN_FOR_CLICK))

    print('Clicking!')
    time.sleep(SECONDS_PAUSE_BETWEEN_MOVESZ)


def moveToCoordinate(start, end, pace=25):
    current = start

    change = end - start
    change /= pace

    i_moves = 0
    while (
        False
        or continueWalking(change.lat, current.lat, end.lat) \
        or continueWalking(change.lng, current.lng, end.lng)
    ):

        if i_moves > 500:
            print('TERMINATED')
            break

        current += change

        writeFile(current)

        i_moves += 1
    print('moved', i_moves)
    return end



def main():
    start = coordinates[0]
    end = coordinates[3]

    current = deepcopy(start)

    change_left = coordinates[3] - coordinates[0]
    change_left /= NUMBER_STEPS_UP_PER_PASS

    change_right = coordinates[2] - coordinates[1]
    change_right /= NUMBER_STEPS_UP_PER_PASS

    num_times_left = 0
    num_times_right = 0

    i_loops = 0
    while True:

        if i_loops > 999:
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
        if abs(near_end.lat) <= 0.0001 or abs(near_end.lng) <= 0.0001:
            print('END')
            break

        i_loops += 1

if __name__ == "__main__":
    main()
