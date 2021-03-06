//
//  NavigationInterfaceViewController.swift
//  SWEDEN_iCare

//  Inspired by Kyle Lee's tutorial: https://www.youtube.com/watch?v=8m-duJ9X_Hs

//  Created by Weijia on 1/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import Firebase

class NavigationInterfaceViewController: UIViewController, CLLocationManagerDelegate {
    
    var homeAddress = ""
    var mode = ""
    var currentCoordinate: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    // Go back
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setHomeAddressButtonPressed(_ sender: UIButton) {
        addHomeAddress()
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        mode = "nav"
//        performSegue(withIdentifier: "navigate", sender: self)
    }
    
    
    
    
    @IBAction func navigateToHomeButtonClicked(_ sender: UIButton) {
        if (homeAddress == "") {
            self.createAlert(title: "You haven't set home address yet!", message: "Set home address now?")
        }
        else {
            mode = "goHome"
            // Start navigation
//            performSegue(withIdentifier: "home", sender: self)
        }
    }
    
    @IBAction func eatButtonClicked(_ sender: UIButton) {
        mode = "eat"
//        performSegue(withIdentifier: "eat", sender: self)
    }
    
    
    
    // The user Firebase reference
    let databaseReference = Database.database().reference().child("users")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = ""
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        fetchHomeAddress()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        currentCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
    }
    
    
    func fetchHomeAddress() {
        databaseReference.child(Auth.auth().currentUser!.uid).observe(.value, with: { (snapshot) -> Void in
            
            if let dictionary = snapshot.value as? [String:Any] {
                let home = dictionary["home"] as? String ?? ""
                self.homeAddress = home
            }
        })
    }
    
    
    
    
    // Create an alert window if home address is not yet set
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
        })
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            self.mode = "setHomeAddress"
            self.addHomeAddress()
        })
        
        
        
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.preferredAction = ok
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Hide keyboard when user touches outisde keybar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Add a home address
    func addHomeAddress() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let setHomeAddressViewController = storyboard.instantiateViewController(withIdentifier: "SetHomeAddressViewController") as! SetHomeAddressViewController
        self.present(setHomeAddressViewController, animated: true, completion: nil)
    }
    
//    // Navigate to home
//    func navigateToHome(home: String) {
//        performSegue(withIdentifier: "navigate", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (mode != "setHomeAddress") {
            let navController = segue.destination as! NavController
            print(currentCoordinate)
            navController.currentCoordinate = currentCoordinate
            locationManager.stopUpdatingLocation()
            switch(mode) {
            case("goHome"):
                navController.initialAddress = homeAddress
                break
            case("eat"):
                navController.initialAddress = "restaurant"
                break
            default:
                navController.initialAddress = searchBar.text ?? ""
                break
            }
        }
        

    }

    
}

