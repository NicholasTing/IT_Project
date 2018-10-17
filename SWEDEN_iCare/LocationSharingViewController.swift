//
//  LocationSharingViewController.swift
//  SWEDEN_iCare
//
//  Created by mac on 3/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import CoreLocation
import AVFoundation


class CustomAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    dynamic var title: String?

    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title

        super.init()
    }
}


class LocationSharingViewController: UIViewController, CLLocationManagerDelegate,  UITextFieldDelegate, MKMapViewDelegate,UISearchBarDelegate {
    
    var currLocation = ""
    var selectedFriend = String()
    let manager = CLLocationManager()
    var annotationsExist = Bool()
    var friendLocation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), title: "")
    
    @IBOutlet weak var Transportation: UISegmentedControl!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var exitButton: UIButton!
    
    let databaseReference = Database.database().reference().child("users")
    

    @IBOutlet var mapView: MKMapView!
    
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    // Hide keyboard when user touches outisde keybar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    
    var steps = [MKRouteStep]()
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var stepCounter = 0
    
    // Added for initial address search
    var initialAddress = String()
    
    // By default, the transportation method is driving.
    var transportMethod = "drive";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        annotationsExist = false
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        exitButton.isHidden = true
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
                            self.mapView.addAnnotation(self.friendLocation as MKAnnotation)
                            self.friendLocation.title = ""
                            self.annotationsExist = true
                        }
                    }
                }
                
            }
            else {
                if (self.annotationsExist == true) {
                    self.mapView.removeAnnotation(self.friendLocation)
                    self.annotationsExist = false
                }
            }
        })
        
        
        
        
        
    }
    
    func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destination
        print(transportMethod)
        
        if transportMethod == "drive" {
            directionsRequest.transportType = .automobile
        }
        else if transportMethod == "walk" {
            directionsRequest.transportType = .walking
        }
        
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, _) in
            guard let response = response else { return }
            guard let primaryRoute = response.routes.first else { return }
            
            // Clear overlays
            self.mapView.removeOverlays(self.mapView.overlays)
            
            // Add polyline route
            self.mapView.add(primaryRoute.polyline)
            
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
            
            self.steps = primaryRoute.steps
            print(self.steps)
            for i in 0 ..< primaryRoute.steps.count {
                let step = primaryRoute.steps[i]
                print(step.instructions)
                print(step.distance)
                let region = CLCircularRegion(center: step.polyline.coordinate,
                                              radius: 9,
                                              identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.add(circle)
            }
            
            let initialMessage = "In \(self.steps[0].distance) meters, \(self.steps[0].instructions) then in \(self.steps[1].distance) meters, \(self.steps[1].instructions)."
            self.directionsLabel.text = initialMessage
            let speechUtterance = AVSpeechUtterance(string: initialMessage)
            self.speechSynthesizer.speak(speechUtterance)
            self.stepCounter += 1
        }
        
        // Show the exit navigation button
        self.exitButton.isHidden = false
    }
    
    @IBAction func SwitchTransMethod(_ sender: Any) {
        print("Transport method changed!")
        if Transportation.selectedSegmentIndex == 0 {
            transportMethod = "drive"
        }
        if Transportation.selectedSegmentIndex == 1 {
            transportMethod = "walk"
        }
        // **************** Added ******************
        // If you're free, put everything below into another function
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let region = MKCoordinateRegion(center: currentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        localSearchRequest.region = region
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (response, _) in
            guard let response = response else { return }
            guard let firstMapItem = response.mapItems.first else { return }
            self.getDirections(to: firstMapItem)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation = locations[0]
        
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.userTrackingMode = .followWithHeading
        
        // Test: show user location
        print(currentLocation)
        
        databaseReference.child(Auth.auth().currentUser!.uid).child("location").child("latitude").setValue(String(format:"%f", currLocation.coordinate.latitude))
        
        databaseReference.child(Auth.auth().currentUser!.uid).child("location").child("longitude").setValue(String(format:"%f", currLocation.coordinate.longitude))
        
        print(currLocation)
        self.mapView.showsUserLocation = true
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("ENTERED")
        stepCounter += 1
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            let dist = Int(currentStep.distance)
            let message = "In \(dist) meters, \(currentStep.instructions)"
            directionsLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
        } else {
            let message = "Arrived at destination"
            directionsLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
            stepCounter = 0
            locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
            
        }
    }
    
    
    // WHY??? WHY YOU ARE NOT CALLED???
    func applicationWillTerminate(_ application: UIApplication) {
        print("\n\n\n\n\n\n\nCalled\n\n\n\n\n\n")
        databaseReference.child(Auth.auth().currentUser!.uid).child("location").setValue("")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor (red: 198/255, green: 9/255, blue: 57/255, alpha: 1.0)
            renderer.lineWidth = 9
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = .white
            renderer.alpha = 1
            renderer.lineWidth = 1
            renderer.strokeColor = .black
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        if (currentCoordinate == nil) {
            let message = "Cannot locate you, you idiot!"
            self.directionsLabel.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            self.speechSynthesizer.speak(speechUtterance)
        }
            
        else {
            let localSearchRequest = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = searchBar.text
            let region = MKCoordinateRegion(center: currentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            localSearchRequest.region = region
            let localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.start { (response, _) in
                guard let response = response else { return }
                guard let firstMapItem = response.mapItems.first else { return }
                self.getDirections(to: firstMapItem)
            }
        }
        
    }
    

}




