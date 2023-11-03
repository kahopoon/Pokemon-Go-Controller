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
        return Double("0.0000\(40 + (arc4random() % 20))")!
    }
    
    func randomNumberBetween(firstNumber: Double, secondNumber: Double) -> Double{
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
    
    func changeCurrentLocation(movement:Direction) {
        let jitter = randomNumberBetween(firstNumber: -0.000009, secondNumber: 0.000009) // add some jitteriness to the numbers for even more natural movement
        
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
        case .DOWN:
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
        UserDefaults.standard.set(getCurrentLocationDict(), forKey: "savedLocation")
        UserDefaults.standard.synchronize()
    }
    
    func getSavedLocation() -> Bool {
        guard let savedLocation = UserDefaults.standard.object(forKey: "savedLocation") else {
            return false
        }
        return putCurrentLocationFromDict(dict: savedLocation as! [String : String])
    }
    
    func getCurrentLocationDict() -> [String:String] {
        return ["lat":"\(currentLocation.latitude)", "lng":"\(currentLocation.longitude)"]
    }
    
    func putCurrentLocationFromDict(dict: [String:String]) -> Bool {
        currentLocation = CLLocationCoordinate2D(latitude: Double(dict["lat"]!)!, longitude: Double(dict["lng"]!)!)
        return true
    }
    
    @IBAction func moveUp(sender: AnyObject) {
        changeCurrentLocation(movement: .UP)
    }
    
    @IBAction func moveDown(sender: AnyObject) {
        changeCurrentLocation(movement: .DOWN)
    }
    
    @IBAction func moveLeft(sender: AnyObject) {
        changeCurrentLocation(movement: .LEFT)
    }
    
    @IBAction func moveRight(sender: AnyObject) {
        changeCurrentLocation(movement: .RIGHT)
    }
    
    @IBAction func addToFavourite(sender: AnyObject) {
        showAlert()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PresentFavouriteViewController",
           let viewController = segue.destination.children[0] as? FavouritesTableViewController {
            viewController.delegate = self
        }
    }
}

extension ViewController: FavouritesTableViewControllerDelegate {
    
    func favouritesTableViewControllerDidSelectLocation(viewController: FavouritesTableViewController, location: Location) {
        
        currentLocation = CLLocationCoordinate2DMake(location.lat, location.lng)
        
        saveLocation()
        showMapOnLocation()
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Add to Favourites", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Location name"
        }
        
        let sendAction = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { [unowned self] (action) in
            
            if let string = alertController.textFields?.first?.text {
                self.saveFavourites(name: string, location: self.currentLocation)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func saveFavourites(name: String, location: CLLocationCoordinate2D) {
        
        let object = Location(name: name, coordinate: location)
        object.save()
    }
}


