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
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.lat = aDecoder.decodeDouble(forKey: "lat")
        self.lng = aDecoder.decodeDouble(forKey: "lng")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.lat, forKey: "lat")
        aCoder.encode(self.lng, forKey: "lng")
    }
}

extension Location {
    static func allLocations() -> [Location] {
        if let data = UserDefaults.standard().object(forKey: "ALL_LOCATIONS") as? Data,
            locations = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Location] {
                return locations
        }
        return []
    }
    
    func save() {
        var newLocations = Location.allLocations()
        newLocations.insert(self, at: 0)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: newLocations)
        UserDefaults.standard().set(data, forKey: "ALL_LOCATIONS")
    }
    
    func remove() {
        let newLocations = Location.allLocations().filter { (location) -> Bool in
            return !(location == self)
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: newLocations)
        UserDefaults.standard().set(data, forKey: "ALL_LOCATIONS")
    }
}

func ==(lhs: Location, rhs: Location) -> Bool {
    
    if lhs.name == rhs.name && lhs.lng == rhs.lng && lhs.lat == lhs.lat {
        
        return true
    }
    return false
}
