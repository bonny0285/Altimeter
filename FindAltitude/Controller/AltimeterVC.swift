//
//  ViewController.swift
//  FindAltitude
//
//  Created by Massimiliano on 31/10/2019.
//  Copyright © 2019 Massimiliano Bonafede. All rights reserved.
//

import UIKit
import MapKit

class AltimeterVC: UIViewController, MKMapViewDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var background: UIImageView!
    @IBOutlet var altitudeLbl: UILabel!
    @IBOutlet var gpsErrorLbl: UILabel!
    @IBOutlet var altimeterLbl: UILabel!
    
    //MARK: - Properties
    
    var viewModel: LocationManagerViewModel!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        viewModel = LocationManagerViewModel(mapView)
        
        altitudeUpdating()
        errorAcuurancy()
        climbingUpdate()
        mapViewUpdating()
        viewModelError()
    }
    
    //MARK: - Methods
    
    private func altitudeUpdating() {
        viewModel.onAltitudeUpdating = { [weak self] altitude in
            DispatchQueue.main.async {
                self?.altitudeLbl.text = altitude
            }
        }
    }
    
    private func errorAcuurancy() {
        viewModel.onErrorAccuracyAltitude = { [weak self] error in
            DispatchQueue.main.async {
                self?.gpsErrorLbl.text = error
            }
        }
    }
    
    private func climbingUpdate() {
        viewModel.onClimbingUpdate = { [weak self] climbed in
            DispatchQueue.main.async {
                self?.altimeterLbl.text = climbed
            }
        }
    }
    
    private func mapViewUpdating() {
        viewModel.onMapViewUpdating = { [weak self] mapView in
            DispatchQueue.main.async {
                self?.mapView = mapView
            }
        }
    }
    
    private func viewModelError() {
        viewModel.onShowAlert = { [weak self] alert in
            guard let self = self else { return }
            
            switch alert {
            case .deniedAlert:
                MyAlert.deniedAlert(on: self)
            case .restrictedAlert:
                MyAlert.restrictedAlert(on: self)
            case .notDeterminateAlert:
                MyAlert.notDetermianateAlert(on: self)
            case .altimeterNotSupported:
                MyAlert.altimeterNotSupported(on: self)
            case .authorizationChanged:
                MyAlert.authorizationChanged(on: self)
            }
        }
    }
    
    private func showAppDetails() {
        MyAlert.appVersion(on: self)
    }
    
    //MARK: - Actions
    
    @IBAction func infoBtnWasPressed(_ sender: Any) {
        showAppDetails()
    }
}

