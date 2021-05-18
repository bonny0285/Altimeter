//
//  Alert.swift
//  FindAltitude
//
//  Created by Massimiliano on 02/11/2019.
//  Copyright © 2019 Massimiliano Bonafede. All rights reserved.
//

import UIKit


struct MyAlert{
    
     private static func basicAlert(on vc: UIViewController, whit title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    static func deniedAlert(on vc: UIViewController) {
        basicAlert(on: vc, whit: "Denied Location", message: "Please check your location status on setting")
    }
    
    static func restrictedAlert(on vc: UIViewController) {
        basicAlert(on: vc, whit: "Restricted Privacy" , message: "Please contatct the Administrator of your setting about the restriction")
    }
    
    static func notDetermianteAlert(on vc: UIViewController) {
        basicAlert(on: vc, whit: "Not Determinate Location Setting", message: "Please agree to use your location if you want use this app")
    }
    
    static func appVersion(on vc: UIViewController) {
        basicAlert(on: vc, whit: "APP VERSION", message: "\(String(describing: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))")
    }
    
    static func altimeterNotSupported(on vc: UIViewController) {
        basicAlert(on: vc, whit: "ALTIMETER NOT SUPPORTED", message: "Your device doesn't support the altimeter")
    }
    
    static func authorizationChanged(on vc: UIViewController) {
        basicAlert(on: vc, whit: "AUTHORIZATION CHANGED", message: "Your authorization has changed")
    }
    
}
