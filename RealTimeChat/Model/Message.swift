//
//  Message.swift
//  RealTimeChat
//
//  Created by Nguyen Ngoc Cuong on 16/05/2022.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromId : String?
    var text : String?
    var timeStamp : NSNumber?
    var toId : String?
    var imageUrl : String?
    var imageHeight: NSNumber?
    var imageWidth : NSNumber?
    
    func chatParnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dictionary : [String : AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
    }
    
    
}
