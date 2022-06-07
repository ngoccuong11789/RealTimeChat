//
//  MessageCell.swift
//  RealTimeChat
//
//  Created by Nguyen Ngoc Cuong on 16/05/2022.
//

import UIKit
import Firebase
class MessageCell: UITableViewCell {

    var message : Message? {
        didSet {
            
            setupNameAndProfileImage()
            self.textTxt.text = message?.text
            if let second = message?.timeStamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: second)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLbl.text = dateFormatter.string(from: timestampDate as Date)
                
            }
        }
    }
    @IBOutlet weak var nameTxt: UILabel!
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textTxt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupNameAndProfileImage() {
        
        if let id = message?.chatParnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value) { snapshot in
                print("Snapshot : \(snapshot)")
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.nameTxt.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
            } withCancel: { err in
                print("Error : \(err)")
            }

        }
    }

}
