//
//  LocationSharingViewController.swift
//  SWEDEN_iCare
//
//  Created by Weijia on 3/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import MapKit
import Firebase


class CustomAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    dynamic var title: String?

    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title

        super.init()
    }
}


class LocationSharingViewController: UIViewController, CLLocationManagerDelegate {
    
    var currLocation = ""
    var selectedFriend = String()
    let manager = CLLocationManager()
    
    var annotationsExist = Bool()
    var friendLocation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "")
    
    let databaseReference = Database.database().reference().child("users")
    
    @IBOutlet weak var map: MKMapView!
    
    
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        map.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        // Empty my location
        databaseReference.child(Auth.auth().currentUser!.uid).child("location").setValue("")
        
        // Stop observing the other user
        databaseReference.removeAllObservers()
        
        // Stop monitoring my location
        manager.stopUpdatingLocation()
        
        // Tell the other friend that I no longer wanna share location
        databaseReference.child(selectedFriend).child("friendsWannaShareLocation").child(Auth.auth().currentUser!.uid).setValue("false")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        annotationsExist = false
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        databaseReference.child(Auth.auth().currentUser!.uid).child("location").setValue("")
        
        print(selectedFriend)
        
        
        
        // Tell my friend that I wanna share location with him/her
        databaseReference.child(selectedFriend).child("friendsWannaShareLocation").child(Auth.auth().currentUser!.uid).setValue("true")
        
        
        
        
        // Set the observer to keep tracking the other user's location
        databaseReference.child(selectedFriend).observe(.childChanged, with: { (snapshot) in
            
            if let properties = snapshot.value as? [String:AnyObject] {
                
                
                if properties["location"] as? String != "" {
                    
                    let latitude = properties["latitude"] as? String ?? ""
                    let longitude = properties["longitude"] as? String ?? ""
                    
                    if (latitude != "" && longitude != "") {
                        self.friendLocation.coordinate.latitude = Double(latitude) ?? 0.0
                        self.friendLocation.coordinate.longitude = Double(longitude) ?? 0.0
                        
                        // Initialize the marker
                        if (self.annotationsExist == false) {
                            self.map.addAnnotation(self.friendLocation as MKAnnotation)
                            self.friendLocation.title = ""
                            self.annotationsExist = true
                        }
                    }
                }
                
            }
            else {
                if (self.annotationsExist == true) {
                    self.map.removeAnnotation(self.friendLocation)
                    self.annotationsExist = false
                }
            }
        })
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation = locations[0]
        
        databaseReference.child(Auth.auth().currentUser!.uid).child("location").child("latitude").setValue(String(format:"%f", currLocation.coordinate.latitude))
        
        databaseReference.child(Auth.auth().currentUser!.uid).child("location").child("longitude").setValue(String(format:"%f", currLocation.coordinate.longitude))
        
        print(currLocation)
        self.map.showsUserLocation = true
        
        
    }
    
    

    

}
