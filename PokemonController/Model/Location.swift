//
//  Location.swift
//  PokemonController
//
//  Created by win on 7/13/16.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import CoreLocation

class Location: NSObject, NSCoding {
    let name: String
    let lat: Double
    let lng: Double

    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.lat = coordinate.latitude
        self.lng = coordinate.longitude
    }
    
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.lat = aDecoder.decodeDoubleForKey("lat")
        self.lng = aDecoder.decodeDoubleForKey("lng")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeDouble(self.lat, forKey: "lat")
        aCoder.encodeDouble(self.lng, forKey: "lng")
    }
}

extension Location {
    static func allLocations() -> [Location] {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("ALL_LOCATIONS") as? NSData,
            locations = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Location] {
                return locations
        }
        return []
    }
    
    func save() {
        var newLocations = Location.allLocations()
        newLocations.insert(self, atIndex: 0)
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(newLocations)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "ALL_LOCATIONS")
    }
    
    func remove() {
        let newLocations = Location.allLocations().filter { (location) -> Bool in
            return !(location == self)
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(newLocations)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "ALL_LOCATIONS")
    }
}

func ==(lhs: Location, rhs: Location) -> Bool {
    
    if lhs.name == rhs.name && lhs.lng == rhs.lng && lhs.lat == lhs.lat {
        
        return true
    }
    return false
}