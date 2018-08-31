//
//  SignUpViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 1/9/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    //OUTLETS
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    //VARIABLES
    var databaseReference: DatabaseReference!
    
    //METHODS
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //ACTIONS
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        
        //Create user account with email and password
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
            
            //If there's no error, sign in user
            if let user = user {
                
                //Stores the user information in a dictionary
                let userInfo: [String: Any] = ["uid": user.user.uid,
                                               "firstName": "",
                                               "lastName": "",
                                               "dob": "",
                                               "address": ""]
                
                //Database reference
                self.databaseReference = Database.database().reference()
                
                //Stores the dictionary under the 'users' branch within the database
                self.databaseReference.child("users").child(user.user.uid).setValue(userInfo)

            } else {
                print("Error occurred")
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        //When button is pressed return to home screen
        self.dismiss(animated: true, completion: nil)
    }
    

}
