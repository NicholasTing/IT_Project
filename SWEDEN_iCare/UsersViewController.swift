//
//  UsersViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 25/8/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    //Save the new information the user has provided in their database profile
    @IBAction func saveButtonPressed(_ sender: Any) {
        //the database reference
        let databaseRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        
        //change each value individually so as not to affect the other preexisting values
        databaseRef.child("firstName").setValue(firstNameTextField.text)
        databaseRef.child("lastName").setValue(lastNameTextField.text)
        databaseRef.child("dob").setValue(dobTextField.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = Database.database().reference()
        database.child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            if let properties = snapshot.value as? [String: AnyObject] {
                self.firstNameTextField.text = properties["firstName"] as? String
                self.lastNameTextField.text = properties["lastName"] as? String
                self.dobTextField.text = properties["dob"] as? String
                self.addressTextField.text = properties["address"] as? String
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
