import xml.etree.cElementTree as ET
import time as time
import os

seconds_pause = 1.2
pace_up = 100

from copy import deepcopy

class Coordinate:

    def __init__(self, lat, long):
        self.lat = lat
        self.long = long


    def get(self):
        return [self.lat, self.long]

    def __str__(self):
        return 'lat: %f, long: %f' % (self.lat, self.long)

    def __eq__(self, other):

        return (self.lat == other.lat) and (self.long == other.long)
    def __mul__(self, other):

        new_coord = Coordinate(self.lat, self.long)

        if type(other) is Coordinate:
            new_coord.lat *= other.lat
            new_coord.long *= other.long
        elif type(other) is int:
            new_coord.lat *= other
            new_coord.long *= other
        else:
            raise ValueError('Unknown type')
        return new_coord

    def __add__(self, other):
        new_coord = Coordinate(self.lat, self.long)
        if type(other) is Coordinate:
            new_coord.lat += other.lat
            new_coord.long += other.long
        elif type(other) is int:
            new_coord.lat += other
            new_coord.long += other
        else:
            raise ValueError('Unknown type')

        return new_coord


    def __sub__(self, other):
        new_coord = Coordinate(self.lat, self.long)

        if type(other) is Coordinate:
            new_coord.lat -= other.lat
            new_coord.long -= other.long
        elif type(other) is int:
            new_coord.lat -= other
            new_coord.long -= other
        else:
            raise ValueError('Unknown type', type(other))
        return new_coord


    def __truediv__(self, other):

        new_coord = Coordinate(self.lat, self.long)

        if type(other) is Coordinate:
            new_coord.lat /= other.lat
            new_coord.long /= other.long
        elif type(other) is int:
            new_coord.lat /= other
            new_coord.long /= other
        else:
            raise ValueError('Unknown type')
        return deepcopy(new_coord)


coordinates = [
    Coordinate(40.7680578657186, -73.981887864142),
    Coordinate(40.7643841763404, -73.972945530681),
    Coordinate(40.7969415563396, -73.949272376481),
    Coordinate(40.800654989832, -73.958185987147),
]

def continueWalking(change, current, end):
    # print(change, current, end)

    if change > 0:
        return current < end
    elif change < 0:
        return current > end
    return False

# continueWalking(0.000073, coordinates[0].lat, coordinates[1].lat)
# continueWalking(-0.000179, coordinates[0].long, coordinates[1].long)


def writeFile(coordinate):
    gpx = ET.Element("gpx", version="1.1", creator="Xcode")
    wpt = ET.SubElement(gpx, "wpt", lat=str(coordinate.lat), lon=str(coordinate.long))
    ET.SubElement(wpt, "name").text = "PokemonLocation"
    ET.ElementTree(gpx).write("pokemonLocation.gpx")

    print("Location Updated!", coordinate)
    time.sleep(0.01)

    os.system("./autoClicker -x 650 -y 900")
    os.system("./autoClicker -x 650 -y 950")

    print('Clicking!')
    time.sleep(seconds_pause)


def moveToCoordinate(start, end, pace=25):
    current = start

    change = end - start
    change /= pace

    i_moves = 0
    while (
        False
        or continueWalking(change.lat, current.lat, end.lat) \
        or continueWalking(change.long, current.long, end.long)
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
    change_left /= pace_up

    change_right = coordinates[2] - coordinates[1]
    change_right /= pace_up

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

        if abs(near_end.lat) <= 0.0001 or abs(near_end.long) <= 0.0001:
            print('END')
            break

        i_loops += 1

if __name__ == "__main__":
    main()
