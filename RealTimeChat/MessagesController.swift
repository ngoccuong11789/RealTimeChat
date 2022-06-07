//
//  ViewController.swift
//  RealTimeChat
//
//  Created by Nguyen Ngoc Cuong on 09/05/2022.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class
MessagesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    let cellReuseIdentifier = "messageCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))

        //self.tableView.register(MessageCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        //observeMessages()
        //observeUserMessages()
    }
    
    var messages = [Message]()
    var messageDictionary = [String : Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users-messages").child(uid)
        ref.observe(.childAdded) { snapshot in
            let userId = snapshot.key
            Database.database().reference().child("users-messages").child(uid).child(userId).observe(.childAdded) { snapshot in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                
            } withCancel: { err in
                print("Error : \(err)")
            }

           // return
            

        } withCancel: { err in
            print("Error : \(err)")
        }

    }
    var timer: Timer?
    
    private func fetchMessageWithMessageId(messageId : String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        messagesReference.observeSingleEvent(of: .value) { snapshot in
            print("Snapshot : \(snapshot)")
            // Group message and show lastest message
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let message = Message(dictionary: dictionary)
//                message.fromId = dictionary["fromId"] as? String
//                message.text = dictionary["text"] as? String
//                message.timeStamp = dictionary["timeStamp"] as? NSNumber
//                message.toId = dictionary["toId"] as? String
                
                //self.messages.append(message)

                if let chatPartnerId = message.chatParnerId() {
                    self.messageDictionary[chatPartnerId] = message
                    
                }

                self.attemptReloadOfTable()


            }
            // End Group message and show latest message

        } withCancel: { err in
            print("Error : \(err)")
        }
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()

        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    @objc func handleReloadTable() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in

            guard let value1 = message1.timeStamp?.int32Value, let value2 = message2.timeStamp?.int32Value else {
                return false
            }
            if value1 > value2 {
                return true
            }
            return false
        })
//        self.messages = Array(self.messagesDictionary.values)
//        self.messages.sort(by: { (message1, message2) -> Bool in
//
//            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
//        })
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async {
            print("we reloaded the table")
            self.tableView.reloadData()
        }
    }
    
    
    @objc func handleNewMessage() {
//        let newMessageController = NewMessageController()
//        let navController = UINavigationController(rootViewController: newMessageController)
//        present(navController, animated: true, completion: nil)
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let newMessageController = storyBoard.instantiateViewController(withIdentifier: "NewMessageVC") as! NewMessageController
        //self.present(newMessageController, animated:true, completion:nil)
        self.navigationController?.pushViewController(newMessageController, animated: true)
    }
    
    func checkIfUserIsLoggedIn() {
        // user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
            //performSelector(onMainThread: #selector(handleLogout()), with: nil, waitUntilDone: true)
        } else {
            print("User is logged in")
//            guard let uid = Auth.auth().currentUser?.uid else {
//                return
//            }
//            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
//                print("Snapshot : \(snapshot.value)")
//                if let dictionary = snapshot.value as? [String : AnyObject] {
//                    self.navigationItem.title = dictionary["name"] as? String
//                }
//            }
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                
//                let user = User(dictionary: dictionary)
//                self.setupNavBarWithUser(user)
                //let user = User(dictionary: dictionary)
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                //self.users.append(user)
                self.setupNavBarWithUser(user)
            }
            
            }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.red
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }

    func showChatControllerForUser() {
        let chatLogController = ChatLogViewController()
        //chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
        
        
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        var loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }

}

extension MessagesController : UITableViewDelegate, UITableViewDataSource {
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MessageCell
        
        // set the text from the data model
        let message = messages[indexPath.row]
        cell.message = message
        
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatParnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value) { snapshot in
            print("Snapshot : \(snapshot)")
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                return
            }
            let user = User()
//            user.setValuesForKeys(dictionary as! [String : Any])
            user.id = chatPartnerId
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            //print("User : \(user)")
            //self.showChatControllerForUser()
            let chatLogViewController = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogViewController.user = user
            self.navigationController?.pushViewController(chatLogViewController, animated: true)
        } withCancel: { err in
            print("Error : \(err)")
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
