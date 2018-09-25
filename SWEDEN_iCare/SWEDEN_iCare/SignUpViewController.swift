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
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var dobText: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    
    //VARIABLES
    var databaseReference: DatabaseReference!
    var selectedImage: UIImage?
    
    //METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        userImage.addGestureRecognizer(tapGesture)
        userImage.isUserInteractionEnabled = true
    }
    
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    //ACTIONS
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        
        //Create user account with email and password
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
            
            //If there's no error and the user has provided the requested information, sign in user
            if let user = user {
                if self.firstNameText.text != "", self.lastNameText.text != "", self.dobText.text != ""
                {
                    
                    //Firebase Storage reference for user profile pictures
                    let storageRef = Storage.storage().reference(forURL: "gs://icare-daf55.appspot.com").child("profile_images").child("\(user.user.uid).jpg")
                    
                    if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(self.userImage.image!, 0.1) {
                        storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                return
                            }
                            
                            storageRef.downloadURL(completion: { (url, error) in
                                
                                //Stores the user information in a dictionary
                                let userInfo: [String: Any] = ["uid": user.user.uid,
                                                               "pathToImage": url?.absoluteString,
                                                               "firstName": self.firstNameText.text!,
                                                               "lastName": self.lastNameText.text!,
                                                               "friends": "",
                                                               "friendRequests": "",
                                                               "dob": self.dobText.text!,
                                                               "address": self.emailText.text!]

                                //Database reference
                                self.databaseReference = Database.database().reference()
                                
                                //Stores the dictionary under the 'users' branch within the database
                                self.databaseReference.child("users").child(user.user.uid).setValue(userInfo)
                            })
                        })
                    }

                    // Gets the home screen
                    let homeTabVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabVC") as! UITabBarController
                    
                    homeTabVC.selectedViewController = homeTabVC.viewControllers?[1]
                    self.present(homeTabVC, animated:true, completion: nil)
                }
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

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Pick an image for the user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            userImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
