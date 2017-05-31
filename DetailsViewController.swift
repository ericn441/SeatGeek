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
        if selectedItem.imageURL.isEmpty {
            selectedImage.image = UIImage(named: "placeholder")
        } else {
            selectedImage.imageFromServerURL(urlString: selectedItem.imageURL)
        }
        selectedImage.setBarelyRounded()        
        
        //update favorite icon if favorited
        if Favorites.isFavorite(id: selectedItem.id) {
            selectedFavorite.setImage(UIImage(named: "favoriteLarge"), for: .normal)
        } else {
            selectedFavorite.setImage(UIImage(named: "favoriteBorderLarge"), for: .normal)
        }
    }
    @IBAction func didPushFavorite(_ sender: Any) {
        
        if selectedFavorite.imageView?.image == UIImage(named: "favoriteBorderLarge") {
            Favorites.setFavorite(id: selectedItem.id, isFavorited: true)
            selectedFavorite.setImage(UIImage(named: "favoriteLarge"), for: .normal)
            
        } else {
            selectedFavorite.setImage(UIImage(named: "favoriteBorderLarge"), for: .normal)
            Favorites.setFavorite(id: selectedItem.id, isFavorited: false)
        }
        
    }
    
}











