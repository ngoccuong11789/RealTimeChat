//
//  NewMessageController.swift
//  RealTimeChat
//
//  Created by Nguyen Ngoc Cuong on 10/05/2022.
//

import UIKit
import FirebaseDatabase
class NewMessageController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let cellID = "cellId"
    private let myArray: NSArray = ["First","Second","Third"]
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        fetchUser()
    }

    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            if let dictionary = snapshot.value as? [String : Any] {
                let user = User()
                //user.setValuesForKeys(dictionary)
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = snapshot.key
                self.users.append(user)
                print(user.name, user.email)
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
        } withCancel: { err in
            print("Error : \(err)")
        }

    }
    
//    @objc func handleCancel() {
//        dismiss(animated: true, completion: nil)
//    }
    var messagesController: MessagesController?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(users[indexPath.row])")
//        dismiss(animated: true) {
            //self.messagesController?.showChatControllerForUser()
//            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChatLogVC") as? ChatLogViewController
//            self.navigationController?.pushViewController(vc!, animated: true)
//            let chatLogController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLogVC") as! ChatLogViewController
//            self.present(chatLogController, animated: true, completion: nil)
          //navigationController?.pushViewController(chatLogController, animated: true)
        //}
        //dismiss(animated: true, completion: nil)
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChatLogVC") as! ChatLogViewController
        //self.present(nextViewController, animated:true, completion:nil)
        var user = users[indexPath.row]
        let chatLogViewController = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogViewController.user = user
        self.navigationController?.pushViewController(chatLogViewController, animated: true)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath as IndexPath) as! UserCell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        //cell.textLabel!.text = "\(myArray[indexPath.row])"
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        //cell.imageView?.image = UIImage(named: "new_message_icon")
        
        if let profileImageUrl = user.profileImageUrl {
//            guard let url = URL(string: profileImageUrl) else {
//                return UITableViewCell()
//            }
//            URLSession.shared.dataTask(with: url) { data, response, err in
//                if err != nil {
//                    print("Error : \(err)")
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    //cell.imageView?.image = UIImage(data: data!)
//                    cell.profileImageView.image = UIImage(data: data!)
//                })
//            }.resume()
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "ChatLogVC") {
//            let chatLogController = self.storyboard?.instantiateViewController(withIdentifier: "ChatLogVC") as! ChatLogViewController
//            //            self.present(chatLogController, animated: true, completion: nil)
//            navigationController?.pushViewController(chatLogController, animated: true)
//        }
//    }

}

class UserCell : UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
