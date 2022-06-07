//
//  Extensions.swift
//  RealTimeChat
//
//  Created by Nguyen Ngoc Cuong on 09/05/2022.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}

extension UIImageView {
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, err in
            if err != nil {
                print("Error : \(err)")
                return
            }
            DispatchQueue.main.async(execute: {
                //cell.imageView?.image = UIImage(data: data!)
                //cell.profileImageView.image = UIImage(data: data!)
                //self.image = UIImage(data: data!)
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
                
            })
        }.resume()
    }
}
