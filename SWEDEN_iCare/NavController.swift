
import UIKit
import MapKit
import CoreLocation
import AVFoundation

class NavController: UIViewController {
    
    
    @IBOutlet weak var Transportation: UISegmentedControl!
    
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var exitButton: UIButton!
    
    
    @IBAction func userLocationButtonClicked(_ sender: UIButton) {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        locationManager.stopUpdatingLocation()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Clear map
    @IBAction func exitButtonClicked(_ sender: UIButton) {
        self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        mapView.removeOverlays(self.mapView.overlays)
        directionsLabel.text = ""
        exitButton.isHidden = true
    }
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    
    var steps = [MKRouteStep]()
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var stepCounter = 0
    
    // Added for initial address search
    var initialAddress = String()
    
    
    @IBAction func dismissController(_ sender: Any) {
        
        
    }
    // By default, the transportation method is driving.
    var transportMethod = "drive";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Navcontroller: ")
        print(currentCoordinate)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        exitButton.isHidden = true
        
        // Perform search if search bar is not empty
        if (initialAddress != "") {
            // **************** Added ******************
            // If you're free, put everything below into another function
            searchBar.text = initialAddress
            searchBarSearchButtonClicked(searchBar)
            
        }
        
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
    
    
    
    
}

extension NavController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.userTrackingMode = .followWithHeading
        
        // Test: show user location
        print(currentLocation)
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
}

extension NavController: UISearchBarDelegate {
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

extension NavController: MKMapViewDelegate {
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
}


