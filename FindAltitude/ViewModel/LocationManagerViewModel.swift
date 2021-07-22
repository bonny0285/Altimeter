//
//  LocationManagerViewModel.swift
//  FindAltitude
//
//  Created by Bonafede Massimiliano on 22/07/21.
//  Copyright © 2021 Massimiliano Bonafede. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import CoreMotion

class LocationManagerViewModel: NSObject {
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    let altimeter = CMAltimeter()
    let mapView: MKMapView
    var onAltitudeUpdating: ((String) -> Void)?
    var onErrorAccuracyAltitude: ((String) -> Void)?
    var onClimbingUpdate: ((String) -> Void)?
    var onMapViewUpdating: ((MKMapView) -> Void)?
    var onShowAlert: ((AlertType) -> Void)?
    
    //MARK: - Lifecycle
    
    init(_ mapView: MKMapView) {
        self.mapView = mapView
        super.init()
        checkLocationServices()
    }
    
    deinit {
        altimeter.stopRelativeAltitudeUpdates()
    }
    
    //MARK: - Methods
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            //Setup our Location Manager
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //Show alert Error
        }
    }
    
    private func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        
        case .authorizedWhenInUse, .authorizedAlways:
            // Do Map Stuff
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            startTrackingAltitudeChange()
            
        case .denied:
            onShowAlert?(.deniedAlert)
            
        case .notDetermined:
            onShowAlert?(.notDeterminateAlert)
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            onShowAlert?(.restrictedAlert)
            
        @unknown default:
            print("UNKNOWN")
        }
    }
    
    private func centerViewOnUserLocation() {
        guard let location = locationManager.location?.coordinate else { return }
        
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 8000, longitudinalMeters: 8000)
        mapView.setRegion(region, animated: true)
        onMapViewUpdating?(mapView)
    }
    
    private func startTrackingAltitudeChange() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            onShowAlert?(.altimeterNotSupported)
            return
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .background
        
        altimeter.startRelativeAltitudeUpdates(to: queue) { altimeterData, error in
            if let altimeterData = altimeterData {
                let relativeAltitude = altimeterData.relativeAltitude as! Double
                let roundedAltitude = Int(relativeAltitude.rounded(toDecimalPlaces: 0))
                let climbedAltitude = "Climbed: \(roundedAltitude)m"
                self.onClimbingUpdate?(climbedAltitude)
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension LocationManagerViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //When user change location
        guard let location = locations.last else { return }
        
        let altitude = location.altitude.rounded(toDecimalPlaces: 0)
        let altitudeText = "Altitude: \(Int(altitude))m"
        onAltitudeUpdating?(altitudeText)
        let accuracyAltitudeError = "+/-  \(location.verticalAccuracy.rounded(toDecimalPlaces: 1))m"
        onErrorAccuracyAltitude?(accuracyAltitudeError)
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 800, longitudinalMeters: 800)
        
        mapView.setRegion(region, animated: true)
        onMapViewUpdating?(mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
