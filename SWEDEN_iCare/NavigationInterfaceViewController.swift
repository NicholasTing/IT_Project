//
//  NavigationInterfaceViewController.swift
//  SWEDEN_iCare
//
//  Created by mac on 1/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import Firebase

class NavigationInterfaceViewController: UIViewController {
    
    //var homeAdd = ""
    
    // Go back
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // The user Firebase reference
    let databaseReference = Database.database().reference().child("users")
    
    
    @IBAction func navigateToHomeButtonClicked(_ sender: UIButton) {
    databaseReference.child(Auth.auth().currentUser!.uid).observe(.value, with: { (snapshot) -> Void in
        
            if let dictionary = snapshot.value as? [String:Any] {
                let home = dictionary["home"] as? String ?? ""
                
                // Haven't set home address yet
                if (home == "") {
                    self.createAlert(title: "You haven't set home address yet!", message: "Set home address now?")
                }
                
                // Home address is set
                else {
//                    self.homeAdd = home
//                    print(self.homeAdd)
//                    self.navigateToHome(home: self.homeAdd)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    // Create an alert window if home address is not yet set
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            print("Cancel")
        })
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            print("OK")
            self.addHomeAddress()
        })
        
        
        
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.preferredAction = ok
        
        
        self.present(alert, animated: true, completion: nil)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let navController = segue.destination as! NavController
//        navController.initialAddress = homeAdd
//
//    }

    
}
