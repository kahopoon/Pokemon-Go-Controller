# Pokemon-Go-Controller

![Alt text](Assets/result.gif?raw=true "result gif")
![Alt text](Assets/xcode.gif?raw=true "xcode gif")  

## iOS device as game controller
![Alt text](Assets/controller.png?raw=true "controller")  
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
Edit readAndChangeXML.py ,change the urlopen address to your controller's ip and write to somewhere your gpx file you want to put. Be sure you remember where the gpx you put :)

![Alt text](Assets/receiver.png?raw=true "controller")  
If running normal, at console you should see something like this when your drag the map or press the buttons on your game controller.

## Simulate location to target device
![Alt text](Assets/blankProject.png?raw=true "controller")  
Create a blank single page app in Xcode. Remember where you put the gpx file? Import the gpx file to your project without copying it, just referencing.

![Alt text](Assets/xcodeSimulate.png?raw=true "controller")  
Run this project on your iOS device that will actually run the Pokemon Go game. The app will continue to run in the background as long as it's plugged in, so you can hit the home button. While running, you will see a button in Xcode to simulate location, here you see the name of your gpx file. We want to keep clicking this button to update the device locaiton for any changes made to the gpx. See the two methods to do this below:


####Refresh location via AppleScript (Easier):
Double click the SimulateXCodeLocationPress.scpt file and click the run button within the Apple Script Editor. This continuously refreshes the simuluated location file from Xcode. To stop refreshing hit the stop button in the Apple Script Editor. (Using this applescript method you can continue to use your computer normally without xcode being the main window.)
![Alt text](Assets/appleScriptScreeshot.png?raw=true "controller")



####Refresh location via Python:
```
gcc -o autoClicker autoClicker.m -framework ApplicationServices -framework Foundation
```
compile the autoClicker.m with gcc at terminal.

```python
import os
import urllib2
import json
import time

def checkConnected():
	try:
		response = urllib2.urlopen("http://your controller's ip/", timeout = 1)
		return json.load(response)
	except urllib2.URLError as e:
		print e.reason

def clickAction():
	os.system("./autoClicker -x 750 -y 400")
	os.system("./autoClicker -x 750 -y 450")
	time.sleep(1)
	print "clicking!!"

def start():
	while True:
		if checkConnected() != None:
			clickAction()

start()
```

Using the python method you need to change the x,y location of your xcode's simulate button. LOL don't ask me your x,y, find it and test it by yourself, to have it easy when adjusting your x,y, you may set the sleep time longer among loops :) more tip: the loop will stop if you close the game controller as it looks for the active state on game controller, so please change the urlopen address here too with your game controller's ip.

## Overall flow
1. Location data on game controller (iPad in this case)
2. Mac receives the location data and updates a gpx file constantly when you move
3. A blank xcode project referencing the gpx is run on your playing device (iPhone in this case)
4. Run one of the methods to auto click xcode's simulate location button to update it

# Have Fun!
![Alt text](Assets/finalResult.png?raw=true "final result") 
