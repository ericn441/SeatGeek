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
import DZNEmptyDataSet

class MainViewController: UIViewController, UITabBarDelegate, UITableViewDataSource,  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    let clientID: String = "NzcwNTc5M3wxNDk2MTg0MTU0LjE5"
    let searchController = UISearchController(searchResultsController: nil)
    var searchItems: [SearchItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //empty tableview
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        //search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.navigationController?.isNavigationBarHidden =  false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //MARK: - Search Functions
    func fetchResults(_ searchText: String, completionHandler: @escaping (JSON) ->()) {
        
        let searchQuery = "https://api.seatgeek.com/2/events?q=" + searchText
        
        Alamofire.request(searchQuery, method: .get, parameters: ["client_id":clientID]).responseJSON{ response in
            guard response.result.error == nil else
            {
                //offline handler
                let alert = UIAlertController(title: "Internet Offline", message: "Check your connection and retry", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { action in })
                self.present(alert, animated: true, completion: nil)
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
                    self.searchItems.removeAll()
                    let parsedResult = SeatGeekEventsResult(json: JSON)
                    self.searchItems = parsedResult.getParsedResults()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Empty Table View
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let str = "Welcome to SeatGeek"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let str = "Tap the search bar to begin searching for events. \n\n Example: Houston Rockets"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        
            let str = ""
            let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
            return NSAttributedString(string: str, attributes: attrs)
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
        
        //set favorite
        cell.favoriteImage.isHidden = !Favorite.isFavorite(id: searchItems[indexPath.row].id)
        
        
        
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
    // do work here if needed
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // do work here if needed
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { //adds micro delay to search query
        
        let searchDelay = 0.5 //seconds
        
        if !searchText.characters.isEmpty {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MainViewController.performSearchAfterDelay), object: nil)
            self.perform(#selector(MainViewController.performSearchAfterDelay), with: nil, afterDelay: searchDelay)
        }
        
    }
}

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












