//
//  FriendsController.swift
//  SWEDEN_iCare
//
//  Created by Zheng Wei Lim on 9/22/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import Firebase

class FriendsController {
    static var currentUser = Auth.auth().currentUser
    static var userDBRef = Database.database().reference().child("users").child((currentUser?.uid)!).child("friends")
    
    static func fetchFriendIds(completion: @escaping (_ idList:[String]) -> Void){
        /* The user Firebase reference */
        var idList:[String] = []
        // retrieve a snapshot of your current database
        userDBRef.observeSingleEvent(of: .value) { (snapshot) in
            // loop through each user and their corresponding properties
            if let fs = snapshot.value as? [String: AnyObject] {
                for (_, friendID) in fs {
                    let fid = friendID as! String
                    idList.append(fid)
                }
      
                completion(idList)
            }
        }
    }
    
    static func fetchFriendEmail(id:String, completion: @escaping (_ email:String?) -> Void) {
        let friendsDBRef = Database.database().reference().child("users")
        
        friendsDBRef.child(id).observeSingleEvent(of: .value, with:  {(snapshot) in
            var address:String?
            if let properties = snapshot.value as? [String: AnyObject]{
                let add = properties["address"] as! String
                address = add
                completion(address)
            }
        })
    }
}
