//
//  AddParticipantsViewController.swift
//  SWEDEN_iCare
//
//  Created by Zheng Wei Lim on 9/30/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AddParticipantsViewController: UIViewController, ParticipantsSelectionDelegate {
    
    var currentUser = Auth.auth().currentUser
    var selectedParticipants:[User]!
    var databaseGroup = Database.database().reference().child("groups")
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var createGroup: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "participantsContainer" {
            let vc = segue.destination as! ChatsParticipantsViewController
            vc.selectionDelegate = self as ParticipantsSelectionDelegate
        }
    }
    
    func selectedParticipants(participants: [User]){
        selectedParticipants = participants
    }
    
    @IBAction func createGroupButtonPressed(_ sender: UIButton) {
        let ref = databaseGroup.childByAutoId()
        let group = ["name": groupName.text, "creator": currentUser?.uid] as! [String : Any]
        ref.setValue(group)
        
        for selected in selectedParticipants{
            let key = ref.childByAutoId().key
            ref.updateChildValues(["participants/\(key)": selected.uid as Any])
        }
        let currentUserKey = ref.childByAutoId().key
        ref.updateChildValues(["participants/\(currentUserKey)": currentUser?.uid as Any])
    }
    
}
