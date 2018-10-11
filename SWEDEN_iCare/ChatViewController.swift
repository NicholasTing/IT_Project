//
//  ChatViewController.swift
//  SWEDEN_iCare
//
//  Created by Zheng Wei Lim on 9/8/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController
{
    var user = Auth.auth().currentUser
    var currentFriend = User()
    var messages = [JSQMessage]()
    var databaseChats = Database.database().reference().child("chats")
    
    //message bubbles
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = user?.uid
        senderDisplayName = "Me"
        self.title = currentFriend.address
        
        //hide attachment button and reduce avatar size to zero
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    
        // load last 10 messages
        let query = databaseChats.queryLimited(toLast: 100000)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: Any],
                let id          = data["sender_id"] as? String,
                let text        = data["text"] as? String,
                let receiverId  = data["receiver_id"] as? String,
                let timeInt   = data["timestamp"] as? TimeInterval,
                !text.isEmpty
            {
                if (self?.currentFriend.uid == id && self?.user?.uid == receiverId) || (self?.currentFriend.uid == receiverId && self?.user?.uid == id){
                    if let message = JSQMessage(senderId: id, senderDisplayName: self?.currentFriend.address, date: NSDate(timeIntervalSince1970: timeInt/1000) as Date?, text: text)
                    {
                        self?.messages.append(message)
                        
                        self?.finishReceivingMessage()
                    }
                }
                
            }
        })
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // return message based on index
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return messages[indexPath.item]
    }
    // return message count
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    // decide bubble color
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    //hide avatar in bubbles
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    //change text color
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if !(messages[indexPath.item].senderId == senderId){
            cell.textView!.textColor = UIColor.black
        }
        return cell
    }
    
    //called when the label text is needed
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        let options:ISO8601DateFormatter.Options = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]
        let timeZone = TimeZone.current
        let dateString = ISO8601DateFormatter.string(from: messages[indexPath.item].date, timeZone: timeZone, formatOptions: options)
        print(dateString)
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: dateString)
    }
    
    //called when the height of the top label is needed
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let ref = databaseChats.childByAutoId()
        
        let message = ["sender_id": user?.uid, "name": user?.email! , "text": text, "receiver_id": currentFriend.uid!, "timestamp": Firebase.ServerValue.timestamp()] as! [String : Any]
        print(message)
        ref.setValue(message)
        
        finishSendingMessage()
    }
    

}
