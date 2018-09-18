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
    var currentUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var dateOfBirth: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBAction func acceptbutton(_ sender: Any) {
        //random key to user
        let key = databaseReference.childByAutoId().key
        
        //update person 1's friend list
        databaseReference.child((Auth.auth().currentUser?.uid)!).updateChildValues(["friends/\(key)": currentUser.uid as Any])
        //update person 2's friend list
        databaseReference.child(currentUser.uid).updateChildValues(["friends/\(key)": Auth.auth().currentUser?.uid as Any])
        
        //remove this user from current user's friend requests
        databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").observeSingleEvent(of: .value) { (snapshot) in
            if let requests = snapshot.value as? [String: AnyObject] {
                for (key, requestID) in requests {
                    if requestID as? String == self.currentUser.uid {
                        self.databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").child(key).removeValue()
                    }
                }
            }
        }
        //hide the two buttons after the action is completed
        acceptUIButton.isHidden = true
        declineUIButton.isHidden = true
    }
    @IBOutlet weak var acceptUIButton: UIButton!
    
    @IBAction func declineButton(_ sender: Any) {
        
        //remove this user from current user's friend requests
        databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").observeSingleEvent(of: .value) { (snapshot) in
            if let requests = snapshot.value as? [String: AnyObject] {
                for (key, requestID) in requests {
                    if requestID as? String == self.currentUser.uid {
                        self.databaseReference.child((Auth.auth().currentUser?.uid)!).child("friendRequests").child(key).removeValue()
                    }
                }
            }
        }
        //hide the two buttons after the action is completed
        declineUIButton.isHidden = true
        declineUIButton.isHidden = true
    }
    @IBOutlet weak var declineUIButton: UIButton!
}
