//
//  LocationManager.swift
//  Presence
//
//  Created by Michael Selsky on 10/4/14.
//  Copyright (c) 2014 Michael Selsky. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate{
    let locationManager :CLLocationManager = CLLocationManager()
    var locationUpdateCallback :(CLLocationCoordinate2D) -> ()
    
    init(callback:(CLLocationCoordinate2D) -> ()){
        self.locationUpdateCallback = callback
    }
    
    func start(){
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            return
        case .Restricted:
            return
        case .Denied:
            return
        case .Authorized:
            manager.startMonitoringSignificantLocationChanges()
            return
        case .AuthorizedWhenInUse:
            manager.startMonitoringSignificantLocationChanges()
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let coordinate = newLocation.coordinate
        self.locationUpdateCallback(coordinate)
    }
    
}
