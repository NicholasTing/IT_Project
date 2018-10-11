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
        // Do any additional setup after loading the view, typically from a nib.
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
    }
    
    // stop listening for keyboard hide/show events
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    //ACTIONS
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        
        //Create user account with email and password
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
            
            //If there's no error, sign in user
            if let user = user {
                
                //Stores the user information in a dictionary
                let userInfo: [String: Any] = ["uid": user.user.uid,
                                               "pathToImage": "",
                                               "firstName": "",
                                               "lastName": "",
                                               "friends": "",
                                               "friendRequests": "",
                                               "dob": "",
                                               "address": self.emailText.text,
                                               "home": ""]
                
                //Database reference
                self.databaseReference = Database.database().reference()
                
                //Stores the dictionary under the 'users' branch within the database
                self.databaseReference.child("users").child(user.user.uid).setValue(userInfo)
                
                // Gets the home screen
                let homeTabVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabVC") as! UITabBarController
                
                homeTabVC.selectedViewController = homeTabVC.viewControllers?[2]
                self.present(homeTabVC, animated:true, completion: nil)

            } else {
                print("Error occurred")
            }
        }
    }
    
    
    @objc func keyboardWillChange(notification: Notification){
        print("Keyboard will show: \(notification.name.rawValue)")
        
        // get size of keyboard
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if notification.name == Notification.Name.UIKeyboardWillShow ||
            notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            
            
            view.frame.origin.y = -keyboardRect.height
        } else {
            
            view.frame.origin.y = 0
        }
    }
    
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        //When button is pressed return to home screen
        self.dismiss(animated: true, completion: nil)
    }
    

}
