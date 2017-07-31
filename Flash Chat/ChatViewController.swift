
//
//  ViewController.swift
//  Flash Chat
//

import UIKit
import Firebase
import ChameleonFramework
import GoogleSignIn
import FBSDKLoginKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    var photoURL : String = ""
    
    
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
         messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
            messageTableView.addGestureRecognizer(tapGesture)
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName:"MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
      
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell

        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        
        
        if messageArray[indexPath.row].photoURL == "" {

            cell.avatarImageView.image = UIImage(named: "egg")
            
        } else {
        
            let url = URL(string: messageArray[indexPath.row].photoURL)
            let data = try? Data(contentsOf: url!)
    
            //let data = try? Data(contentsOf: URL(savedPhotoURL)!)
                
            cell.avatarImageView.image = UIImage(data: data!)
        }
     
        
        if cell.senderUsername.text == FIRAuth.auth()?.currentUser?.email as String!{
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        }
        else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        
        return cell
    }
    
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return messageArray.count
    
    }
    
    
    //TODO: Declare tableViewTapped here:
    func tableViewTapped(){
        
        messageTextfield.endEditing(true)
    }
    
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5 ){
            self.heightConstraint.constant = 306
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5 ){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }

        
        
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    

    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB = FIRDatabase.database().reference().child("Messages")

        let user = FIRAuth.auth()?.currentUser
        
        if let user = user{
            
            if let photo = user.photoURL?.absoluteString {
                
                print(photo)
                
                photoURL = photo
                    
                }
            
            }


    
        
        let messageDictionary = ["Sender":  FIRAuth.auth()?.currentUser?.email!, "MessageBody": messageTextfield.text!, "PhotoURL": photoURL]
        
        messageDB.childByAutoId().setValue(messageDictionary){
            (error, ref) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                
                self.messageTextfield.text = ""
                
            }
        }
        
        
        
        
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages() {
        
        let messageDB = FIRDatabase.database().reference().child("Messages")
        
        messageDB.observe(.childAdded, with: { (snapshot) in
        
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            var savedPhotoURL = ""
            
            if snapshotValue["PhotoURL"] != nil  {
                savedPhotoURL = snapshotValue["PhotoURL"]!
            }
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            message.photoURL = savedPhotoURL
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
                        
            let lastRow: Int = self.messageTableView.numberOfRows(inSection: 0) - 1
            let indexPath = IndexPath(row: lastRow, section: 0);
            self.messageTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        })
        
        
    }

    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController

    
       
        do {
            try FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()
       
            FBSDKLoginManager().logOut()
            
            
        }
        catch {
            print("error: there was a problem signing out")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else{
                print("No View Controllers to pop off")
                return
        }
        
        
        
    }

    

}
