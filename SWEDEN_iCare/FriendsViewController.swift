//
//  FriendsViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 15/9/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class usersTableViewCellSubClass: UITableViewCell {
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
}

class FriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /* The user Firebase reference */
    let databaseReference = Database.database().reference().child("users")
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    
    var users = [User]() //list to store all users
    var filteredList = [User]()
    var isSearching = false
    
    //returns the length of the user list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //creating a cell using the custom class
        let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! usersTableViewCellSubClass
        
        //the user object
        let user: User
        
        //getting the user of selected position
        user = users[indexPath.row]
        
        //adding values to the two labels
        
        userCell.firstName.text = user.address
        userCell.lastName.text = "" //fix this later into the user's last name
        
        //returning cell
        return userCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        fetchUsers()
    }
    
    // obtains a snapshot of the user tree within the database and adds it to the 'users' list
    func fetchUsers() {
        
        // retrieve a snapshot of your current database
        databaseReference.observeSingleEvent(of: .value) { (snapshot) in
            
            // loop through each user and their corresponding properties and add them to the table
            if let users = snapshot.value as? [String: AnyObject] {
                for (_, property) in users {
                    // Do not add the current user
                    if property["uid"] as? String != Auth.auth().currentUser?.uid {
                    
                        let currentUser = User()
                        
                        currentUser.firstName = property["firstName"] as? String
                        currentUser.lastName = property["lastName"] as? String
                        currentUser.address = property["address"] as? String
                        currentUser.dob = property["dob"] as? String
                        currentUser.uid = property["uid"] as? String
                        
                        self.users.append(currentUser)
                    }
                }
                self.usersTableView.reloadData()
            }
        }
    }
    
    //this function will be called when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //building an alert
        let alertController = UIAlertController(title: users[indexPath.row].address, message: "Confirm sending friend request", preferredStyle: .alert)
        
        //the confirm action
        let confirmAction = UIAlertAction(title: "Send", style: .default) { (_) in
            
            //getting user id
            guard let id = self.users[indexPath.row].uid else {return}
            
            //calling the sendFriendRequest method to send friend request
            self.sendFriendRequest(id: id)
            print("sent my man")
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding action
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //presenting dialog
        present(alertController, animated: true, completion: nil)
    }
    
    //this function will send a friend request out to the specified user id
    //from the current user
    func sendFriendRequest(id: String) {
        
        //random key to user
        let key = databaseReference.childByAutoId().key
        
        //sending the friend request to the other person
        databaseReference.child(id).updateChildValues(["friendRequests/\(key)": Auth.auth().currentUser?.uid as Any])
    }
}











