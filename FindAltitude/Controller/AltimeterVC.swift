//
//  ViewController.swift
//  FindAltitude
//
//  Created by Massimiliano on 31/10/2019.
//  Copyright © 2019 Massimiliano Bonafede. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion

class AltimeterVC: UIViewController,MKMapViewDelegate {
    
    //Outlet
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var background: UIImageView!
    @IBOutlet var altitudeLbl: UILabel!
    @IBOutlet var gpsErrorLbl: UILabel!
    @IBOutlet var altimeterLbl: UILabel!
    
    //Variable
    let locationManager = CLLocationManager()
    let altimeter = CMAltimeter()
    var myalert = MyAlert()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
       // startTrackingAltitudeChange()
        // Do any additional setup after loading the view
        
    }

    deinit {
        altimeter.stopRelativeAltitudeUpdates()
    }
    
    //MARK: - Methods

    func showAppDetails(){
        MyAlert.appVersion(on: self)
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            //Setup our Location Manager
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //Show alert Error
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            // Do Map Stuff
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            startTrackingAltitudeChange()
            
        case .denied:
            // Inform User how turn on location
            MyAlert.deniedAlert(on: self)
            
        case .notDetermined:
            MyAlert.notDetermianteAlert(on: self)
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            // Inform User how turn on location
            MyAlert.restrictedAlert(on: self)
            
        @unknown default:
            print("UNKNOWN")
        }
    }
    
    func centerViewOnUserLocation() {
        guard let location = locationManager.location?.coordinate else { return }
        
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 8000, longitudinalMeters: 8000)
        mapView.setRegion(region, animated: true)
    }
    
    func startTrackingAltitudeChange() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            // Show Error Alert
            MyAlert.altimeterNotSupported(on: self)
            return
        }
        
        let queue = OperationQueue()
        queue.qualityOfService = .background
        
        altimeter.startRelativeAltitudeUpdates(to: queue) { altimeterData, error in
            if let altimeterData = altimeterData {
                DispatchQueue.main.async {
                    let relativeAltitude = altimeterData.relativeAltitude as! Double
                    let roundedAltitude = Int(relativeAltitude.rounded(toDecimalPlaces: 0))
                    self.altimeterLbl.text = "Climbed: \(roundedAltitude)m"
                }
            }
        }
    }
    
    //MARK: - Actions

    @IBAction func infoBtnWasPressed(_ sender: Any) {
        showAppDetails()
    }
}

//MARK: - CLLocationManagerDelegate

extension AltimeterVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //When user change location
        guard let location = locations.last else { return }
        
        let altitude = location.altitude.rounded(toDecimalPlaces: 0)
        altitudeLbl.text = "Altitude: \(Int(altitude))m"
        gpsErrorLbl.text = "+/-     \(location.verticalAccuracy)m"
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 800, longitudinalMeters: 800)

        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
