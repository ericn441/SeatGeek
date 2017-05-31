//
//  UIImageViewExtension.swift
//  SeatGeek
//
//  Created by Eric on 5/31/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIImageView Extensions
extension UIImageView {
    
    public func imageFromServerURL(urlString: String) { //async image downloader
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
    
    public func setRounded() { //round corners for preview icon
        self.layer.cornerRadius = (self.frame.width / 4)
        self.layer.masksToBounds = true
    }
    public func setBarelyRounded() { //round corners for full image
        self.layer.cornerRadius = (self.frame.width / 12)
        self.layer.masksToBounds = true
    }
    
}
