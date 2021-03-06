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
    
    // fetchFriendEmail based on id from Firebase
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
    
    // fetch group friends ids from firebase
    static func fetchGroupsFriendsIds(completion: @escaping (_ idsInGroup:[String: [String]]?) -> Void) {
        let groupDBRef = Database.database().reference().child("groups")
        
        groupDBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var groupDict = [String: [String]]()
            print(snapshot.childrenCount) // I got the expected number of items
            let enumerator = snapshot.children
            while let childSnapshot = enumerator.nextObject() as? DataSnapshot {
                if let group = childSnapshot.value as? [String: AnyObject]{
                                        print(group["participants"])
                    let groupId = childSnapshot.key
                    let participantIds = group["participants"] as? [String: String]
                    var idList:[String] = []
                    
                    if participantIds != nil {
                    
                        for (_, id) in participantIds!{
                            if(id == currentUser?.uid){
                                for (_, id) in participantIds!{
                                    idList.append(id)
                                }
                                groupDict[groupId] = idList
                            }
                        }
                    }
                }
            }
            completion(groupDict)
        })
    }
    
    // concat addresses of all members in a group
    static func concatAddressesFromUsers(users: [User]) -> String{
        var addresses:String = ""
        for user in users{
            addresses += (user.address + " ")
        }
        return addresses
    }
    
    // return idList from a list of Users
    static func idListFromUsers(users: [User]) -> [String]{
        var idList:[String] = []
        for user in users{
            idList.append(user.uid)
        }
        return idList
    }
}
