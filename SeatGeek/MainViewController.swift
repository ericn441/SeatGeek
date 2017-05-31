//
//  MainViewController.swift
//  SeatGeek
//
//  Created by Eric on 5/30/17.
//  Copyright © 2017 Eric. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    let clientID: String = "NzcwNTc5M3wxNDk2MTg0MTU0LjE5"
    let searchController = UISearchController(searchResultsController: nil)
    var searchItems: [SearchItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden =  false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //MARK: - Search Functions
    func fetchResults(_ searchText: String, completionHandler: @escaping (JSON) ->()) {
        
        let searchQuery = "https://api.seatgeek.com/2/events?q=" + searchText
        
        Alamofire.request(searchQuery, method: .get, parameters: ["client_id":clientID]).responseJSON{ response in
            guard response.result.error == nil else
            {
                print(response.result.error!)
                return
            }
            if let value = response.result.value
            {
                let data = JSON(value)
                completionHandler(data)
            }
        }
    }
    func performSearchAfterDelay() {
        if let searchText = searchController.searchBar.text {
            
            if let searchQueryFormatted = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                
                fetchResults(searchQueryFormatted) { (JSON) in
                    self.parseSearchResults(json: JSON)
                }
            }
        }
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! ResultsTableViewCell
        cell.resultTitle.text = searchItems[indexPath.row].title
        cell.resultDetail.text = searchItems[indexPath.row].detail
        cell.resultTime.text = searchItems[indexPath.row].time
        
        //download preview image
        if searchItems[indexPath.row].imageURL.isEmpty { //handle missing links
            cell.previewIcon.image = UIImage(named: "placeholder")
        } else {
            cell.previewIcon.imageFromServerURL(urlString: searchItems[indexPath.row].imageURL)
        }
        cell.previewIcon.contentMode = .scaleAspectFill
        cell.previewIcon.setRounded()
        
        return cell
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetail" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let detailsVC = segue.destination as! DetailsViewController
                detailsVC.selectedItem.id = searchItems[indexPath.row].id
                detailsVC.selectedItem.title = searchItems[indexPath.row].title
                detailsVC.selectedItem.detail = searchItems[indexPath.row].detail
                detailsVC.selectedItem.time = searchItems[indexPath.row].time
                detailsVC.selectedItem.imageURL = searchItems[indexPath.row].imageURL
                detailsVC.selectedItem.didFavor = searchItems[indexPath.row].didFavor
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        }
        
        
    }

}

// MARK: - UISearchBar Delegate
extension MainViewController: UISearchBarDelegate {
}

// MARK: - UISearchResultsUpdating Delegate
extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // do work here if needed
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchItems.removeAll()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MainViewController.performSearchAfterDelay), object: nil)
        self.perform(#selector(MainViewController.performSearchAfterDelay), with: nil, afterDelay: 0.5)
    }
    
    func parseSearchResults(json: JSON) {
        
        for results in json["events"].arrayValue {
            
            let id = results["id"].stringValue
            let title = results["title"].stringValue
            let locationDetail = results["venue"]["display_location"].stringValue
            let time = convertToCST(utcTime: results["datetime_local"].stringValue)
            let imageURL = results["performers"][0]["image"].stringValue
            
            self.searchItems.append(SearchItem(id: id, title: title, detail: locationDetail, time: time, imageURL: imageURL, image: UIImage(named: "placeholder"), didFavor: false))
        }
        self.tableView.reloadData()
    }
    
    func convertToCST(utcTime: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let date = dateFormatter.date(from: utcTime) // create date from UTC string
        
        // change to readable time format and local time zone
        dateFormatter.dateFormat = "EEE, MMM d, yyyy h:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
        
    }
}

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
    
    public func setRounded() { //round corners
        self.layer.cornerRadius = (self.frame.width / 4) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
    public func setBarelyRounded() { //round corners
        self.layer.cornerRadius = (self.frame.width / 12) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }

}












