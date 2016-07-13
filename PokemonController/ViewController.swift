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
    var webServer:GCDWebServer = GCDWebServer()
    enum Direction {
        case UP, DOWN, LEFT, RIGHT;
    }
    
    func moveInterval() -> Double {
        return Double("0.0000\(40 + (rand() % 20))")!
    }
    
    func randomNumberBetween(firstNumber: Double, secondNumber: Double) -> Double{
        return Double(arc4random()) / Double(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if getSavedLocation() { showMapOnLocation() }
        
        startWebServer()
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentLocation = mapView.centerCoordinate
        saveLocation()
    }

    func changeCurrentLocation(movement:Direction) {
        let jitter = randomNumberBetween(-0.000009, secondNumber: 0.000009) // add some jitteriness to the numbers for even more natural movement
    
        switch movement {
        case .LEFT:
            currentLocation.latitude += jitter
            currentLocation.longitude -= moveInterval()
        case .RIGHT:
            currentLocation.latitude += jitter
            currentLocation.longitude += moveInterval()
        case .UP:
            currentLocation.latitude += moveInterval()
            currentLocation.longitude += jitter
        case .DOWN
            currentLocation.latitude -= moveInterval()
            currentLocation.longitude += jitter
        }
        
        saveLocation()
        showMapOnLocation()
    }
    
    func showMapOnLocation() {
        mapView.setCamera(MKMapCamera(lookingAtCenterCoordinate: currentLocation, fromEyeCoordinate: currentLocation, eyeAltitude: 500.0), animated: false)
    }
    
    func saveLocation() {
        NSUserDefaults.standardUserDefaults().setObject(getCurrentLocationDict(), forKey: "savedLocation")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getSavedLocation() -> Bool {
        guard let savedLocation = NSUserDefaults.standardUserDefaults().objectForKey("savedLocation") else {
            return false
        }
        return putCurrentLocationFromDict(savedLocation as! [String : String])
    }
    
    func getCurrentLocationDict() -> [String:String] {
        return ["lat":"\(currentLocation.latitude)", "lng":"\(currentLocation.longitude)"]
    }
    
    func putCurrentLocationFromDict(dict: [String:String]) -> Bool {
        currentLocation = CLLocationCoordinate2D(latitude: Double(dict["lat"]!)!, longitude: Double(dict["lng"]!)!)
        return true
    }
    
    @IBAction func moveUp(sender: AnyObject) {
        changeCurrentLocation(.UP)
    }
    
    @IBAction func moveDown(sender: AnyObject) {
        changeCurrentLocation(.DOWN)
    }
    
    @IBAction func moveLeft(sender: AnyObject) {
        changeCurrentLocation(.LEFT)
    }
    
    @IBAction func moveRight(sender: AnyObject) {
        changeCurrentLocation(.RIGHT)
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
