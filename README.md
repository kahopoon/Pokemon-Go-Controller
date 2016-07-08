# Pokemon-Go-Controller

## iOS device as game controller
![Alt text](controller.png?raw=true "controller")  
Clone this xcode project and run on your iphone / ipad, this app actually perform a web server that tells your chosen location, your location will be wherever the poke ball is, so you may drag the map of press the buttons.

```
{"lng":"114.132530212402","lat":"22.3636264801025"}
```
This is what the app response via port 80 by http, so be sure to connect the iphone / ipad to your wifi network in order to gain access.

## Get controller message
```python
import xml.etree.cElementTree as ET
import urllib2
import json

lastLat = ""
lastLng = ""

def getPokemonLocation():
	try:
		response = urllib2.urlopen("http://your controller's ip/", timeout = 1)
		return json.load(response)
	except urllib2.URLError as e:
		print e.reason

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

def start():
	while True:
		generateXML()

start()
```
Change the urlopen address to your controller's ip and write to somewhere your gpx file you want to put. Be sure you remember where the gpx you put :)
