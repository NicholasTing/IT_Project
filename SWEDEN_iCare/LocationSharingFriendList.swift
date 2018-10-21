//
//  LocationSharingFriendList.swift
//  SWEDEN_iCare
//
//  Created by Weijia on 6/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import Firebase


class LocationSharingFriendList: UITableViewController {
    
    var usersSharingLocationWithMe = [String]()
    
    var selectedFriend = ""
    var selectedFriendName = ""
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if (selectedFriend == "") {
            self.createAlert(title: "Hey!", message: "You haven't selected a friend yet.")
        }
        else {
//            performSegue(withIdentifier: "segue_s", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedFriend = ""
        selectedFriendName = ""
        fetchUsers()
    }
    
    func fetchUsers() {
        
        let databaseReference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("friendsWannaShareLocation")
        
        databaseReference.observeSingleEvent(of: .value) { (snapshot) in
            
            // loop through each user and their corresponding properties
            if let friends = snapshot.value as? [String: AnyObject] {
                
                for (friendID, bool) in friends {
                    if ((bool as! String) == "true") {
                        self.usersSharingLocationWithMe.append(friendID)
                    }
                    
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(usersSharingLocationWithMe.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell_s")
        
        Database.database().reference().child("users").child(self.usersSharingLocationWithMe[indexPath.row]).observeSingleEvent(of: .value) { (snapshot) in
            
            if let properties = snapshot.value as? [String: AnyObject] {
                cell.textLabel?.text = properties["address"] as? String
            }
        }
        
        
        
        
        //cell.textLabel?.text=users[indexPath.row]
        return(cell)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFriend = usersSharingLocationWithMe[indexPath.row]
        print(usersSharingLocationWithMe[indexPath.row])
        
        //        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let locationSharingVC = segue.destination as! LocationSharingViewController
        locationSharingVC.selectedFriend = selectedFriend
        
    }
    
    
    
    
    
    
    
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            print("Dismiss")
        })
        
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
