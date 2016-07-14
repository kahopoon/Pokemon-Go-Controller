import os
import urllib2
import json
import time

def checkConnected():
	try:
		response = urllib2.urlopen("http://172.16.255.195/", timeout = 1)
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