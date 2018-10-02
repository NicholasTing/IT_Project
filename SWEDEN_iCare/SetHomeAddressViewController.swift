//
//  SetHomeAddressViewController.swift
//  SWEDEN_iCare
//
//  Created by mac on 1/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import Firebase
class SetHomeAddressViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var homeAddress: UITextField!
    
    
    let databaseReference = Database.database().reference().child("users")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeAddress.clearButtonMode = .whileEditing
        homeAddress.returnKeyType = UIReturnKeyType.done

        //add current address placeholder
        databaseReference.child(Auth.auth().currentUser!.uid).observe(.value, with: { (snapshot) -> Void in
    
            if let dictionary = snapshot.value as? [String:Any] {
                self.homeAddress.text = dictionary["home"] as? String ?? ""
                
            }
        })
        
        
        
        
        homeAddress.delegate = self
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
   databaseReference.child(Auth.auth().currentUser!.uid).child("home").setValue(homeAddress.text ?? "" as String)
        self.createAlert(title: "Success!", message: "Your home address is set.")
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            print("Dismiss")
        })
        
        
        
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
