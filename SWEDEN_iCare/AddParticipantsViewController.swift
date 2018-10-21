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
import MaterialComponents

class AddParticipantsViewController: UIViewController, ParticipantsSelectionDelegate {
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var currentUser = Auth.auth().currentUser
    var selectedParticipants:[User]!
    var databaseGroup = Database.database().reference().child("groups")
    var groupNameController: MDCTextInputControllerOutlined?
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var createGroup: UIButton!
    
    // connecting button to the next segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "participantsContainer" {
            let vc = segue.destination as! ChatsParticipantsViewController
            vc.selectionDelegate = self as ParticipantsSelectionDelegate
        }
    }
    
    func selectedParticipants(participants: [User]){
        selectedParticipants = participants
    }
    
    // createGroupButtonPressed post group name and group members to firebase
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
    
    // Hide keyboard when user touches outisde keybar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

