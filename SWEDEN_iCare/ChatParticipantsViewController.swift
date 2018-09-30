//
//  ChatParticipantsViewController.swift
//  SWEDEN_iCare
//
//  Created by Zheng Wei Lim on 9/27/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatsParticipantsViewController: UITableViewController {
    var user = Auth.auth().currentUser
    var databaseChats = Database.database().reference().child("chats")
    var databaseUsers = Database.database().reference().child("users")
    var friends:[User] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var selectedFriends:[User]?
    
    override func viewDidLoad() {
        self.fetchFriends()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return friends.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].address
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchFriends(){
        FriendsController.fetchFriendIds(completion: { friendIds in
            for id in friendIds {
                FriendsController.fetchFriendEmail(id: id, completion: {add in
                    let contact = User()
                    contact.address = add!
                    contact.uid = id
                    self.friends.insert(contact, at:0)
                })
            }
        })
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "contactSegue" {
//            let vc = segue.destination as! ChatViewController
//            vc.currentFriend = self.selectedContact!
//        }
//    }
}

    

