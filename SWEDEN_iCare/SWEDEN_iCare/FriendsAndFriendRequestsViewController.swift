//
//  FriendsAndFriendRequestsViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 17/9/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class FriendsAndFriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendsAndFriendRequestsSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var users = [String]()
    var requests = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchUsers()
    }
    
    // obtains a snapshot of the user tree within the database and adds it to the 'users' list
    func fetchUsers() {
        
        users.removeAll()
        /* The user Firebase reference */
        let databaseReference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("friends")
        
        // retrieve a snapshot of your current database
        databaseReference.observeSingleEvent(of: .value) { (snapshot) in
            
            // loop through each user and their corresponding properties
            if let friends = snapshot.value as? [String: AnyObject] {
                
                for (_, friendID) in friends {
                    self.users.append(friendID as! String)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // obtains a snapshot of the friend requests tree within the database and adds it to the 'requests' list. Works in the same way as fetchUsers() method
    func fetchFriendRequests() {
        
        requests.removeAll()
        /* The current user's tree Firebase reference */
        let databaseReference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("friendRequests")
        
        // retrieve a snapshot of your current database
        databaseReference.observeSingleEvent(of: .value) { (snapshot) in
            
            // loop through each user and their corresponding properties
            if let requests = snapshot.value as? [String: AnyObject] {
                
                for (_, friendID) in requests {
                    self.requests.append(friendID as! String)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //Fetch the users or a users friend request depending on the app user's Segment choice 
    @IBAction func segmentChange(_ sender: Any) {
        
        if friendsAndFriendRequestsSegment.selectedSegmentIndex == 0 {
            fetchUsers()
        } else {
            fetchFriendRequests()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //instantiate the FriendProfileViewController
        //(do this programmatically to reduce clutter in the Storyboard)
        let otherFriendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OtherUserProfileVC") as! FriendProfileViewController
        
        // obtain a snapshot of the current branch in the users tree in the database.
        // use that snapshot to pass values to the Friend Profile View Controller
        //Depending on the app user's selection of the segment options, either pass values from
        //the user's list or the friend request's list
        if friendsAndFriendRequestsSegment.selectedSegmentIndex == 0 {
            Database.database().reference().child("users").child(users[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
                if let properties = snapshot.value as? [String: AnyObject] {
                    otherFriendVC.currentUser.uid = properties["uid"] as? String
                    otherFriendVC.currentUser.address = properties["address"] as? String
                }
            })
        } else {
            Database.database().reference().child("users").child(requests[indexPath.row]).observeSingleEvent(of: .value, with: {(snapshot) in
                if let properties = snapshot.value as? [String: AnyObject] {
                    otherFriendVC.currentUser.uid = properties["uid"] as? String
                    otherFriendVC.currentUser.address = properties["address"] as? String
                }
            })
        }
        //present the view controller
        self.present(otherFriendVC, animated:  true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendCell
        
        if friendsAndFriendRequestsSegment.selectedSegmentIndex == 0 {
            Database.database().reference().child("users").child(self.users[indexPath.row]).observeSingleEvent(of: .value) { (snapshot) in
                
                if let properties = snapshot.value as? [String: AnyObject] {
                    cell.nameLabel.text = properties["address"] as? String
                }
            }
        } else {
            Database.database().reference().child("users").child(self.requests[indexPath.row]).observeSingleEvent(of: .value) { (snapshot) in
                
                if let properties = snapshot.value as? [String: AnyObject] {
                    cell.nameLabel.text = properties["address"] as? String
                    
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendsAndFriendRequestsSegment.selectedSegmentIndex == 0 {
            return users.count
        } else {
            return requests.count
        }
    }
}
