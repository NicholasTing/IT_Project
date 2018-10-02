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
        var contacts:[User]
        var groupId:String
        var lastMessage:String
    }
    
    var user = Auth.auth().currentUser
    var databaseChats = Database.database().reference().child("chats")
    var contactChats:[contactChat] = []{
        didSet{
            self.tableView.reloadData()
            
        }
    }
    var selectedContacts:contactChat!
    
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
        if contactChats[indexPath.row].contacts.count == 1 {
            cell.textLabel?.text = contactChats[indexPath.row].contacts[0].address
        } else {
            let addresses = FriendsController.concatAddressesFromUsers(users: contactChats[indexPath.row].contacts)
            cell.textLabel?.text = addresses
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currContact = contactChats[indexPath.row]
        selectedContacts = currContact
        if selectedContacts.contacts.count == 1 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "chatView") as! ChatViewController
            vc.currentFriend = self.selectedContacts.contacts[0]
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "groupChatView") as! GroupChatViewController
            vc.groupUsers = selectedContacts.contacts
            vc.groupId = selectedContacts.groupId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //        performSegue(withIdentifier: "contactSegue", sender: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchContactChats(){
        let lastMessage = "default message"
        FriendsController.fetchFriendIds(completion: { friendIds in
            for id in friendIds {
                FriendsController.fetchFriendEmail(id: id, completion: {add in
                    let contact = User()
                    contact.address = add!
                    contact.uid = id
                    self.contactChats.insert(contactChat(contacts: [contact], groupId: "", lastMessage: lastMessage), at:0)
                })
            }
        })
        
        FriendsController.fetchGroupsFriendsIds(completion: {groupFriendsIds in
            for (groupId, group) in groupFriendsIds! {
                var groupUserList:[User] = []
                for id in group {
                    FriendsController.fetchFriendEmail(id: id, completion: { add in
                        let contact = User()
                        contact.address = add!
                        contact.uid = id
                        groupUserList.insert(contact, at: 0)
                        if groupUserList.count == group.count {
                            print("your butt crack")
                            print(groupUserList)
                            self.contactChats.insert(contactChat(contacts: groupUserList, groupId: groupId, lastMessage: lastMessage), at:0)
                        }
                    })
                }
                
            }
        })
    }
    
    //    func fetchLastMessage(id:String, completion: @escaping (_ lastMessage:String?) -> Void) {
    //        let query = databaseChats.queryOrdered(byChild: "timestamp")
    //        _ = query.observe(.childAdded, with: { [weak self] snapshot in
    //            var lastMessage:String?
    //            if  let data        = snapshot.value as? [String: String],
    //                let senderId          = data["sender_id"],
    //                let text        = data["text"],
    //                let receiverId  = data["receiver_id"],
    //                !text.isEmpty
    //            {
    //                if ((receiverId == id && senderId == self?.user?.uid) || (senderId == id && receiverId == self?.user?.uid)) {
    //                    print(text)
    //                    lastMessage = text
    //                    completion(lastMessage)
    //                }
    //            }
    //
    //        })
    //    }
    
    
}
