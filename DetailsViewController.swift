//
//  DetailsViewController.swift
//  SeatGeek
//
//  Created by Eric on 5/30/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    // MARK: - Properties
    var selectedItem = SearchItem(id: "", title: "", detail: "", time: "", imageURL: "", image: nil, didFavor: false)
    
    @IBOutlet weak var selectedTitle: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var selectedTime: UILabel!
    @IBOutlet weak var selectedLocation: UILabel!
    @IBOutlet weak var selectedFavorite: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedTitle.text = selectedItem.title
        selectedTime.text = selectedItem.time
        selectedLocation.text = selectedItem.detail
        selectedImage.imageFromServerURL(urlString: selectedItem.imageURL)
        selectedImage.setBarelyRounded()
    }
    @IBAction func didPushFavorite(_ sender: Any) {
        
    }
    
}
