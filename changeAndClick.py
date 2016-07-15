import xml.etree.cElementTree as ET
import urllib2
import json
import os
import time

lastLat = ""
lastLng = ""

def getPokemonLocation():
    try:
        response = urllib2.urlopen("http://192.168.199.134/", timeout=10)
        return json.load(response)
    except urllib2.URLError as e:
        print e.reason


def clickAction():
	if os.path.isfile("click.applescript"):
		os.system("osascript click.applescript > /dev/null 2>&1")
	print "clicking!!"


def generateXML():
    global lastLat, lastLng
    geo = getPokemonLocation()
    if geo != None:
        if geo["lat"] != lastLat or geo["lng"] != lastLng:
            lastLat = geo["lat"]
            lastLng = geo["lng"]
            gpx = ET.Element("gpx", version="1.1", creator="Xcode")
            wpt = ET.SubElement(gpx, "wpt", lat=geo["lat"], lon=geo["lng"])
            ET.SubElement(wpt, "name").text = "PokemonLocation"
            ET.ElementTree(gpx).write("somewhere.gpx")
            print "Location Updated!", "latitude:", geo["lat"], "longitude:" ,geo["lng"]
            clickAction()

def start():
    while True:
        generateXML()

start()
