//
//  FriendProfileViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 17/9/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class FriendProfileViewController: UIViewController {
    
    var databaseReference = Database.database().reference().child("users")
    var uid: String!
    
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var dateOfBirth: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
   
    
    @IBAction func acceptbutton(_ sender: Any) {
        //random key to user
        let key = databaseReference.childByAutoId().key
        
        //update person 1's friend list
        databaseReference.child((Auth.auth().currentUser?.uid)!).updateChildValues(["friends/\(key)": uid as Any])
        //update person 2's friend list
        databaseReference.child(uid).updateChildValues(["friends/\(key)": Auth.auth().currentUser?.uid as Any])
        
        //remove this user from current user's friend requests
        databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").observeSingleEvent(of: .value) { (snapshot) in
            if let requests = snapshot.value as? [String: AnyObject] {
                for (key, requestID) in requests {
                    if requestID as? String == self.uid {
                        self.databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").child(key).removeValue()
                    }
                }
            }
        }
        // Hide the two buttons after an action is completed
        acceptUIButton.isHidden = true
        declineUIButton.isHidden = true
    }
    @IBOutlet weak var acceptUIButton: UIButton!
    
    @IBAction func declineButton(_ sender: Any) {
        
        //remove this user from current user's friend requests
        databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").observeSingleEvent(of: .value) { (snapshot) in
            if let requests = snapshot.value as? [String: AnyObject] {
                for (key, requestID) in requests {
                    if requestID as? String == self.uid {
                        self.databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").child(key).removeValue()
                    }
                }
            }
        }
        // Hide the two buttons after an action is completed
        acceptUIButton.isHidden = true
        declineUIButton.isHidden = true
    }
    @IBOutlet weak var declineUIButton: UIButton!
}
