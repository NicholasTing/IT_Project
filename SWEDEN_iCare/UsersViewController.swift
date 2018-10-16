//
//  UsersViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 25/8/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class UsersViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet var profileImage: UIImageView!
    var selectedImage: UIImage?
    
    //the current user
    let uid = Auth.auth().currentUser?.uid
    //the database reference
    let database = Database.database().reference()
    
    //Save the new information the user has provided in their database profile
    @IBAction func saveButtonPressed(_ sender: Any) {
        //the database reference
        //the database reference to the current user tree
        let databaseRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        
        //change each value individually so as not to affect the other preexisting values
        databaseRef.child("firstName").setValue(firstNameTextField.text)
        databaseRef.child("lastName").setValue(lastNameTextField.text)
        databaseRef.child("dob").setValue(dobTextField.text)
        
        //the firebase storage reference to the node containing the profile photo of the current user, contained within the node with all the user profile photos
        let data = UIImageJPEGRepresentation(self.profileImage.image!, 0.5)
        let storageRef = Storage.storage().reference(forURL: "gs://icare-daf55.appspot.com").child("profile_images").child("\(uid!).jpg")
        
        //place the image in Firebase Storage and save the URL
        storageRef.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    return
                }
                
                if let url = url {
                    self.database.child("users").child(self.uid!).child("pathToImage").setValue(url.absoluteString)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //obtain and display the current user's information on their profile view controller
        database.child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            if let properties = snapshot.value as? [String: AnyObject] {
                self.firstNameTextField.text = properties["firstName"] as? String
                self.lastNameTextField.text = properties["lastName"] as? String
                self.dobTextField.text = properties["dob"] as? String
                self.addressTextField.text = properties["address"] as? String
                if properties["pathToImage"] as! String != "" {
                    self.profileImage.downloadImage(from: properties["pathToImage"] as! String)
                }
            }
        }
        
        //the tap gesture recogniser constant
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UsersViewController.handleSelectProfileImageView))
        //allow the user to tap on the profile image placeholder
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
    }
    
    // Hide keyboard when user touches outisde keybar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //after a tap is detected, show the user's photo library for them to pick an image
    @objc func handleSelectProfileImageView() {
        
        let pickerController = UIImagePickerController()
        
        //let the image picker know that we want the UsersViewController to be its delegate by assigning self to the delegate of the image picker. That means self is now the delegate of the image picker we now used. As a result, we can now gain access to the requested media files
        pickerController.delegate = self
        
        //present the photo picker
        present(pickerController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
//use extension to add more methods to this view controller
extension UsersViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //once an image has been picked from the photo library, display it to the current user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
//use this extension to define a download function usable by all UIImageViewss
extension UIImageView {
    func downloadImage(from imgURL: String) {
        let url = URLRequest(url: URL(string: imgURL)!)
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
