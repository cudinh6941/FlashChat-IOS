//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages : [Mesasage] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessage()

    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text,let messageSender = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField : messageSender,
                K.FStore.bodyField : messageBody,
                K.FStore.dateField : Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error{
                    print("There was an error \(e)")
                }else{
                    print("Successfully")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""

                    }
                }
            }
        }
        
    }
    
    func loadMessage(){
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener{(querySnapshot,error) in
            self.messages = []
            if let e = error{
                print("There was an error \(e)")
            }else
            {
                if let snapshotDocument = querySnapshot?.documents{
                    for snap in snapshotDocument{
                        let data = snap.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            let newMessage = Mesasage(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            // Reload data table
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)

                            }
                        }
                    }
                }
            }
            
        }
    }

    @IBAction func LogoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
        navigationController?.popToRootViewController(animated: true)
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
      
    }
}
extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        as! MessageCell
        cell.label.text = message.body
        //this is a message from current user
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImage.isHidden = true
            cell.rightImage.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        //This is a message from another user
        else{
            cell.leftImage.isHidden = false
            cell.rightImage.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
    
    
}
