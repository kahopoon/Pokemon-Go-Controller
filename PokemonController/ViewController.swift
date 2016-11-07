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
        case up, down, left, right;
    }
    
    func moveInterval() -> Double {
        return Double("0.0000\(40 + (arc4random() % 20))")!
    }
    
    func randomNumberBetween(_ firstNumber: Double, secondNumber: Double) -> Double{
        return Double(arc4random()) / Double(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if getSavedLocation() { showMapOnLocation() }
        
        startWebServer()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentLocation = mapView.centerCoordinate
        saveLocation()
    }

    func changeCurrentLocation(_ movement:Direction) {
        let jitter = randomNumberBetween(-0.000009, secondNumber: 0.000009) // add some jitteriness to the numbers for even more natural movement
    
        switch movement {
        case .left:
            currentLocation.latitude += jitter
            currentLocation.longitude -= moveInterval()
        case .right:
            currentLocation.latitude += jitter
            currentLocation.longitude += moveInterval()
        case .up:
            currentLocation.latitude += moveInterval()
            currentLocation.longitude += jitter
        case .down:
            currentLocation.latitude -= moveInterval()
            currentLocation.longitude += jitter
        }
        
        saveLocation()
        showMapOnLocation()
    }
    
    func showMapOnLocation() {
        mapView.setCamera(MKMapCamera(lookingAtCenter: currentLocation, fromEyeCoordinate: currentLocation, eyeAltitude: 500.0), animated: false)
    }
    
    func saveLocation() {
        UserDefaults.standard().set(getCurrentLocationDict(), forKey: "savedLocation")
        UserDefaults.standard().synchronize()
    }
    
    func getSavedLocation() -> Bool {
        guard let savedLocation = UserDefaults.standard().object(forKey: "savedLocation") else {
            return false
        }
        return putCurrentLocationFromDict(savedLocation as! [String : String])
    }
    
    func getCurrentLocationDict() -> [String:String] {
        return ["lat":"\(currentLocation.latitude)", "lng":"\(currentLocation.longitude)"]
    }
    
    func putCurrentLocationFromDict(_ dict: [String:String]) -> Bool {
        currentLocation = CLLocationCoordinate2D(latitude: Double(dict["lat"]!)!, longitude: Double(dict["lng"]!)!)
        return true
    }
    
    @IBAction func moveUp(_ sender: AnyObject) {
        changeCurrentLocation(.up)
    }
    
    @IBAction func moveDown(_ sender: AnyObject) {
        changeCurrentLocation(.down)
    }
    
    @IBAction func moveLeft(_ sender: AnyObject) {
        changeCurrentLocation(.left)
    }
    
    @IBAction func moveRight(_ sender: AnyObject) {
        changeCurrentLocation(.right)
    }
    
    func startWebServer(){
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse.init(jsonObject: self.getCurrentLocationDict())
        })
        webServer.start(withPort: 80, bonjourName: "pokemonController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentFavouriteViewController",
            let viewController = segue.destinationViewController.childViewControllers[0] as? FavouritesTableViewController {
                viewController.delegate = self
            
        }
    }
}

extension ViewController: FavouritesTableViewControllerDelegate {
    @IBAction func addToFavourite(_ sender: AnyObject) {
        showAlert()
    }
    
    func favouritesTableViewControllerDidSelectLocation(_ viewController: FavouritesTableViewController, location: Location) {

        currentLocation = CLLocationCoordinate2DMake(location.lat, location.lng)
        
        saveLocation()
        showMapOnLocation()
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Add to Favourites", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Location name"
        }
        
        let sendAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { [unowned self] (action) in
            
            if let string = alertController.textFields?.first?.text {
                self.saveFavourites(string, location: self.currentLocation)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func saveFavourites(_ name: String, location: CLLocationCoordinate2D) {
        
        let object = Location(name: name, coordinate: location)
        object.save()
    }
}


