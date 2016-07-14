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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var currentLocation:CLLocationCoordinate2D!
    var webServer:GCDWebServer = GCDWebServer()
	
	@IBOutlet weak var autoMoveSwitch: UISwitch!
	@IBOutlet weak var moveMode: UISegmentedControl!
	var locationManager:CLLocationManager = CLLocationManager()
	var tempLocation:CLLocationCoordinate2D!
	var longPressTimer = NSTimer()
	var pokeballLocation:MKPointAnnotation = MKPointAnnotation()
	var isAutoMoving:Bool = false
	var firstTime:Bool = true
	
	
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
		
		pokeballLocation.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
		mapView.addAnnotation(pokeballLocation)
        
        if getSavedLocation() { showMapOnLocation() }
        
        startWebServer()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		locationManager.requestWhenInUseAuthorization()
	}
	
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
	}
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard !annotation.isKindOfClass(MKUserLocation) else {
			return nil
		}
		
		// Better to make this class property
		let annotationIdentifier = "AnnotationIdentifier"
		
		var annotationView: MKAnnotationView?
		if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) {
			annotationView = dequeuedAnnotationView
			annotationView?.annotation = annotation
		}
		else {
			let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
			av.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
			annotationView = av
		}
		
		if let annotationView = annotationView {
			
			annotationView.canShowCallout = true
			annotationView.image = UIImage(named: "pokeball")
			annotationView.frame = CGRectMake(0,0,30,30)
		}
		
		return annotationView
	}
	
	func cancelAutoMove(){
		if(mapView.overlays.count > 0){
			mapView.removeOverlay(mapView.overlays[0])
		}
		if(currentRoutes.count > 0){
			currentRoutes.removeAll()
		}
		autoMoveSwitch.setOn(false, animated: true)
	}
	
	@IBAction func moveValueChange(sender: UISwitch){
		if(sender.on){
			if(currentRoutes.count > 0){
				startAutoMove()
			}else{
				sender.setOn(false, animated: true)
			}
		}
	}
	
	@IBAction func cancelMove(sender: AnyObject) {
		if(autoMoveSwitch.on){
			isAutoMoving = true
			autoMoveSwitch.setOn(false, animated: true)
		}
		let warningAlert = UIAlertController(title: "Warning!!", message: "Do you want to cancel auto moving ?", preferredStyle: UIAlertControllerStyle.Alert)
		
		warningAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
			self.cancelAutoMove()
		}))
		warningAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
			if(self.isAutoMoving){
				self.autoMoveSwitch.setOn(true, animated: true)
				self.moveValueChange(self.autoMoveSwitch)
			}
		}))
		presentViewController(warningAlert, animated: true, completion: nil)
	}
	@IBAction func findPokeballLocation(sender: AnyObject) {
		mapView.setCamera(MKMapCamera(lookingAtCenterCoordinate: pokeballLocation.coordinate, fromEyeCoordinate: pokeballLocation.coordinate, eyeAltitude: 500.0), animated: true)
		
	}
	@IBAction func resetLocation(sender: AnyObject) {
		if(autoMoveSwitch.on){
			isAutoMoving = true
			autoMoveSwitch.setOn(false, animated: true)
		}
		let warningAlert = UIAlertController(title: "Warning!!", message: "Do you want to move pokeball to your current location ?", preferredStyle: UIAlertControllerStyle.Alert)
		
		warningAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
			self.cancelAutoMove()
			self.currentLocation = self.mapView.userLocation.coordinate
			
			self.saveLocation()
			self.showMapOnLocation()
			
			self.mapView.setCamera(MKMapCamera(lookingAtCenterCoordinate: self.currentLocation, fromEyeCoordinate: self.currentLocation, eyeAltitude: 500.0), animated: true)
		}))
		warningAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
			if(self.isAutoMoving){
				self.autoMoveSwitch.setOn(true, animated: true)
				self.moveValueChange(self.autoMoveSwitch)
			}
		}))
		presentViewController(warningAlert, animated: true, completion: nil)
	}

	
	@IBAction func longHold(sender: UIGestureRecognizer){
		if sender.state == .Began {
			tempLocation = mapView.convertPoint(sender.locationInView(sender.view), toCoordinateFromView: sender.view)
			longPressTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(longHoldTrigger), userInfo: nil, repeats: false)
		}else if( sender.state == .Ended || sender.state == .Cancelled){
			longPressTimer.invalidate()
		}
	}
	
	func longHoldTrigger(){
		longPressTimer.invalidate()
		let warningAlert = UIAlertController(title: "Warning!!", message: "Do you want to move to this location ?", preferredStyle: UIAlertControllerStyle.Alert)
		
		warningAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
			if(self.autoMoveSwitch.on){
				self.cancelAutoMove()
			}
			if(self.getSpeedMeterPerHour() == 0){
				//Warp
				self.currentLocation = self.tempLocation
				
				self.saveLocation()
				self.showMapOnLocation()
				return
			}
			let request: MKDirectionsRequest = MKDirectionsRequest()
			request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.currentLocation,addressDictionary: nil))
			request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.tempLocation,addressDictionary: nil))
			
			request.requestsAlternateRoutes = true
			
			request.transportType = .Walking
			if(self.getSpeedMeterPerHour() >= 60000.0){
				request.transportType = .Automobile
			}
			
			let directions = MKDirections(request: request)
			directions.calculateDirectionsWithCompletionHandler ({
				(response: MKDirectionsResponse?, error: NSError?) in
				if (response?.routes) != nil {
					self.showRoute((response?.routes)!)
				} else if let _ = error {
					
				}
			})
		}))
		warningAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
			
		}))
		presentViewController(warningAlert, animated: true, completion: nil)
	}
	
	var currentRoutes:[Waypoint] = []
	
	func prepareRoute(route: MKRoute) {
		currentRoutes.removeAll()
		for _step in route.steps {
			currentRoutes.append(Waypoint(step: _step))
		}
		if(currentRoutes.count > 0){
			autoMoveSwitch.setOn(true, animated: true)
			startAutoMove()
		}
	}
	
	func getSpeedMeterPerHour() -> Double {
		var moveSpeedPerHour:Double = 6500.0
		switch moveMode.selectedSegmentIndex {
		case 0: //Walk
			moveSpeedPerHour = 6500.0
			break
		case 1: //Run
			moveSpeedPerHour = 19000.0
			break
		case 2: //Drive
			moveSpeedPerHour = 60000.0
			break
		case 3: //Train
			moveSpeedPerHour = 90000.0
			break
		case 4: //Warp
			moveSpeedPerHour = 0
			break
		default:
			moveSpeedPerHour = 6500.0
			
		}
		return moveSpeedPerHour
	}
	
	func startAutoMove(){
		if(currentRoutes.count > 0){
			currentRoutes[0].calculateMoving(currentLocation, moveSpeed: getSpeedMeterPerHour(), eachMove: { (newLocation) in
				self.currentLocation = newLocation
				
				self.saveLocation()
				self.showMapOnLocation()
				
				return self.autoMoveSwitch.on
				}, completion: {
					self.currentRoutes.removeFirst()
					self.startAutoMove()
					
			})
		}else{
			if(mapView.overlays.count > 0){
				mapView.removeOverlay(mapView.overlays[0])
			}
			self.autoMoveSwitch.setOn(false, animated: true)
		}
	}
	
	func showRoute(routes: [MKRoute]) {
		if(routes.count > 0){
			plotPolyline(routes[0])
			prepareRoute(routes[0])
		}
	}
	
	func plotPolyline(route: MKRoute) {
		
		if(mapView.overlays.count > 0){
			mapView.removeOverlay(mapView.overlays[0])
		}
		mapView.addOverlay(route.polyline)
		
		if mapView.overlays.count == 1 {
			mapView.setVisibleMapRect(route.polyline.boundingMapRect,
			                          edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
			                          animated: false)
		}
			
		else {
			let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
			                                           route.polyline.boundingMapRect)
			mapView.setVisibleMapRect(polylineBoundingRect,
			                          edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
			                          animated: false)
		}
	}
	func mapView(mapView: MKMapView,
	             rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		
		let polylineRenderer = MKPolylineRenderer(overlay: overlay)
		if (overlay is MKPolyline) {
			if mapView.overlays.count == 1 {
				polylineRenderer.strokeColor =
					UIColor.blueColor().colorWithAlphaComponent(0.75)
			} else if mapView.overlays.count == 2 {
				polylineRenderer.strokeColor =
					UIColor.greenColor().colorWithAlphaComponent(0.75)
			} else if mapView.overlays.count == 3 {
				polylineRenderer.strokeColor =
					UIColor.redColor().colorWithAlphaComponent(0.75)
			}
			polylineRenderer.lineWidth = 5
		}
		return polylineRenderer
	}

	
	func showMapOnLocation() {
		pokeballLocation.coordinate = currentLocation
		
		if(firstTime){
			firstTime = false
			mapView.setCamera(MKMapCamera(lookingAtCenterCoordinate: currentLocation, fromEyeCoordinate: currentLocation, eyeAltitude: 500.0), animated: true)
		}
	}
	
    func changeCurrentLocation(movement:Direction) {
		if(autoMoveSwitch.on){
			return
		}
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
        case .DOWN:
            currentLocation.latitude -= moveInterval()
            currentLocation.longitude += jitter
        }
        
        saveLocation()
        showMapOnLocation()
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

extension ViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentFavouriteViewController",
            let viewController = segue.destinationViewController.childViewControllers[0] as? FavouritesTableViewController {
                viewController.delegate = self
            
        }
    }
}

extension ViewController: FavouritesTableViewControllerDelegate {
    @IBAction func addToFavourite(sender: AnyObject) {
        showAlert()
    }
    
    func favouritesTableViewControllerDidSelectLocation(viewController: FavouritesTableViewController, location: Location) {

        currentLocation = CLLocationCoordinate2DMake(location.lat, location.lng)
        
        saveLocation()
        showMapOnLocation()
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Add to Favourites", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Location name"
        }
        
        let sendAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { [unowned self] (action) in
            
            if let string = alertController.textFields?.first?.text {
                self.saveFavourites(string, location: self.currentLocation)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func saveFavourites(name: String, location: CLLocationCoordinate2D) {
        
        let object = Location(name: name, coordinate: location)
        object.save()
    }
}


extension CLLocationCoordinate2D {
	
	func distanceInMetersFrom(otherCoord : CLLocationCoordinate2D) -> CLLocationDistance {
		let firstLoc = CLLocation(latitude: self.latitude, longitude: self.longitude)
		let secondLoc = CLLocation(latitude: otherCoord.latitude, longitude: otherCoord.longitude)
		return firstLoc.distanceFromLocation(secondLoc)
	}
	
}

class Waypoint : NSObject {
	private var location:CLLocationCoordinate2D!
	private var distance:Double = 0.0
	private var triggerTimer:NSTimer!
	
	private var totalStep: Double = 0.0
	private var latDiffTotal: CLLocationDegrees = 0.0
	private var lngDiffTotal: CLLocationDegrees = 0.0
	private var latDiffPerStep: CLLocationDegrees = 0.0
	private var lngDiffPerStep: CLLocationDegrees = 0.0
	private var currentStep: Double = 0.0
	private var _currentLocation:CLLocationCoordinate2D!
	
	private var _eachMove: ((CLLocationCoordinate2D) -> Bool)!
	private var _completion: (() -> Void)!
	
	init(step:MKRouteStep){
		super.init()
		self.location = step.polyline.coordinate
		self.distance = step.distance
	}
	
	func calculateMoving(currentLocation: CLLocationCoordinate2D,moveSpeed: Double, eachMove: (CLLocationCoordinate2D) -> Bool, completion: () -> Void){
		_currentLocation = currentLocation
		currentStep = 0
		latDiffTotal = self.location.latitude - currentLocation.latitude
		lngDiffTotal = self.location.longitude - currentLocation.longitude
		let avgSpeed:Double = ((moveSpeed/60)/60)/10
		totalStep = ceil((currentLocation.distanceInMetersFrom(self.location)) / avgSpeed)
		latDiffPerStep = latDiffTotal / totalStep
		lngDiffPerStep = lngDiffTotal / totalStep
		_eachMove = eachMove
		_completion = completion
		
		triggerTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(move), userInfo: nil, repeats: true)
		
	}
	
	func move(){
		if(currentStep >= totalStep){
			triggerTimer.invalidate()
			_completion()
		}else{
			_currentLocation.longitude += lngDiffPerStep
			_currentLocation.latitude += latDiffPerStep
			if(!_eachMove(_currentLocation)){
				triggerTimer.invalidate()
			}
			currentStep+=1
		}
	}
}

