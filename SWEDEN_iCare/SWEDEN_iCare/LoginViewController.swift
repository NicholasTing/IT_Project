//
//  ViewController.swift
//  SWEDEN_iCare
//
//  Created by Nicholas on 9/8/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //OUTLETS
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    //VARIABLES

    //METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //ACTIONS
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        //Authenticate user when they attempt to log in
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated:true, completion: nil)
                
            } else {
                print("you're in")
            }
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        
        //Instantiate and present SignUpViewController when button is pressed
        let SignUpViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        
        self.present(SignUpViewController!, animated: true, completion: nil)
    }

}

