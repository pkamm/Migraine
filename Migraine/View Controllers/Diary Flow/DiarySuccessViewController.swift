//
//  DiarySuccessViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/22/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit
import CoreLocation

class DiarySuccessViewController: UIViewController, SavablePage, CLLocationManagerDelegate {

    @IBOutlet weak var saveButtonFooter: SaveButtonFooterView!

    var locations = [CLLocation]()
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        //manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = false
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonFooter.setTitle(title: "Close")
        saveButtonFooter.saveDelagate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func saveButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion:nil);
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
        for loc in locations {
            var locationObject = [String: Any]()
            locationObject["latitude"] = loc.coordinate.latitude
            locationObject["longitude"] = loc.coordinate.longitude
            locationObject["horizontal_accuracy"] = loc.horizontalAccuracy
            locationObject["course"] = loc.course
            locationObject["speed"] = loc.speed
            PatientInfoService.sharedInstance.sendLocationDataToFirebase(locationObject)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                print("location unknown")
            case CLError.denied:
                print("denied")
                locationManager.requestWhenInUseAuthorization()
            default:
                print("other Core Location error")
            }
        } else {
            print("other error:", error.localizedDescription)
        }
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
