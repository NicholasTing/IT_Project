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
    }
    
    func fetchUsers() {
        
        let databaseReference = Database.database().reference().child("users")
        

        
    }

}
