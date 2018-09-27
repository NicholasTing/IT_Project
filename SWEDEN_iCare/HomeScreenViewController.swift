//
//  HomeScreenViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 1/9/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class HomeScreenViewController: UIViewController, UISearchBarDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var usersTableView: UITableView!
    
    var users = [User]() //everyone
    var filteredList = [User]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //the ViewController containing the table view will be
        //the data source itself
//        usersTableView.dataSource = self
//        usersTableView.delegate = self
        searchBar.delegate = self
        
        fetchUsers()
    }
    
    func fetchUsers() {
        
        let databaseReference = Database.database().reference().child("users")
        
        databaseReference.observeSingleEvent(of: .value) { (snapshot) in
            
            if let users = snapshot.value as? [String: AnyObject] {
                for (_, property) in users {
                    
                    let currentUser = User()
                    
                    currentUser.firstName = property["firstName"] as! String
                    currentUser.lastName = property["lastName"] as! String
                    currentUser.address = property["address"] as! String
                    currentUser.dob = property["dob"] as! String
                    
                    self.users.append(currentUser)
                    print(users.count)
                }
            }
        }
        
        
    }
    
}
