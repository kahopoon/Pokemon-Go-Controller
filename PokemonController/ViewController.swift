//
//  ViewController.swift
//  PokemonController
//
//  Created by Ka Ho on 7/7/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit
import MapKit
import GCDWebServer

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var currentLocation:CLLocationCoordinate2D!
    let moveInterval = 0.00005
    var webServer:GCDWebServer = GCDWebServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startWebServer()
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentLocation = mapView.centerCoordinate
    }

    func changeCurrentLocation(direction:String) {
        
        direction == "left" ? currentLocation = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude - moveInterval) : ()
        direction == "right" ? currentLocation = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude + moveInterval) : ()
        direction == "up" ? currentLocation = CLLocationCoordinate2D(latitude: currentLocation.latitude + moveInterval, longitude: currentLocation.longitude) : ()
        direction == "down" ? currentLocation = CLLocationCoordinate2D(latitude: currentLocation.latitude - moveInterval, longitude: currentLocation.longitude) : ()
        
        mapView.setCamera(MKMapCamera(lookingAtCenterCoordinate: currentLocation, fromEyeCoordinate: currentLocation, eyeAltitude: 500.0), animated: false)
    }
    
    func getCurrentLocationDict() -> [String:String] {
        return ["lat":"\(currentLocation.latitude)", "lng":"\(currentLocation.longitude)"]
    }
    
    @IBAction func moveUp(sender: AnyObject) {
        changeCurrentLocation("up")
    }
    
    @IBAction func moveDown(sender: AnyObject) {
        changeCurrentLocation("down")
    }
    
    @IBAction func moveLeft(sender: AnyObject) {
        changeCurrentLocation("left")
    }
    
    @IBAction func moveRight(sender: AnyObject) {
        changeCurrentLocation("right")
    }
    
    func startWebServer(){
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse.init(JSONObject: self.getCurrentLocationDict())
        })
        webServer.startWithPort(80, bonjourName: "pokemonController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

