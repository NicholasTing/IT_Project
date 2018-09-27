//
//  PrevChatsViewController.swift
//  SWEDEN_iCare
//
//  Created by Zheng Wei Lim on 9/20/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PrevChatsViewController: UITableViewController {
 
    struct contactChat {
        var contact:User
        var lastMessage:String
    }
    
    var user = Auth.auth().currentUser
    var databaseChats = Database.database().reference().child("chats")
    var databaseUsers = Database.database().reference().child("users")
    var contactChats:[contactChat] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    var selectedContact:User?

    let dispatchGroup = DispatchGroup()
//    var contactChats = [contactChat(email: "222@gmail.com", lastMessage: "hahaha"),contactChat(email: "444@gmail.com", lastMessage: "hahaha")]
    
    override func viewDidLoad() {
        self.title = "Contacts"
        self.fetchContactChats()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return contactChats.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        cell.textLabel?.text = contactChats[indexPath.row].contact.address
        cell.detailTextLabel?.text = contactChats[indexPath.row].lastMessage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currContact = contactChats[indexPath.row].contact
        
        selectedContact = currContact
        performSegue(withIdentifier: "contactSegue", sender: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchContactChats(){
        FriendsController.fetchFriendIds(completion: { friendIds in
            for id in friendIds {
                FriendsController.fetchFriendEmail(id: id, completion: {add in
                    let lastMessage = "default message"
                    let contact = User()
                    contact.address = add!
                    contact.uid = id
                    self.contactChats.insert(contactChat(contact: contact, lastMessage: lastMessage), at:0)
                })
            }
        })
    }
 
    func fetchLastMessage(id:String, completion: @escaping (_ lastMessage:String?) -> Void) {
        let query = databaseChats.queryOrdered(byChild: "timestamp")
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            var lastMessage:String?
            if  let data        = snapshot.value as? [String: String],
                let senderId          = data["sender_id"],
                let text        = data["text"],
                let receiverId  = data["receiver_id"],
                !text.isEmpty
            {
                if ((receiverId == id && senderId == self?.user?.uid) || (senderId == id && receiverId == self?.user?.uid)) {
                    print(text)
                    lastMessage = text
                    completion(lastMessage)
                }
            }

        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactSegue" {
            let vc = segue.destination as! ChatViewController
            vc.currentFriend = self.selectedContact!
        }
    }
}
