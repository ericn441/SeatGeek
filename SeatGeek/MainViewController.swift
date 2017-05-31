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
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        //image downloader
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden =  true
        
        //Status bar style and visibility
        UIApplication.shared.statusBarStyle = .lightContent
        
        //Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = .blue
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
        cell.previewIcon.imageFromServerURL(urlString: searchItems[indexPath.row].imageURL)
        cell.previewIcon.contentMode = .scaleAspectFill
        cell.previewIcon.setRounded()
        
        return cell
    }

}


extension MainViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
}

extension MainViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            
            if let searchQueryFormatted = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                
                fetchResults("Texas+Rangers") { (JSON) in
                    self.parseSearchResults(json: JSON)
                }
            }
        }
    }
    func parseSearchResults(json: JSON) {
        
        //print(results["id"].stringValue)
        //print(results["title"].stringValue)
        //print(results["venue"]["display_location"].stringValue)
        //print(results["datetime_local"].stringValue)
        //print(results["performers"][0]["image"].stringValue)
        
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

}












