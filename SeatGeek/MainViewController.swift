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
    let searchController = UISearchController(searchResultsController: nil)
    var searchItems: [SearchItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up empty tableview
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        //set up search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

        //style status bar
        self.navigationController?.isNavigationBarHidden =  false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData() //refresh in case event was favorited
    }
    
    //MARK: - Search SeatGeek API
    
    func performSearchAfterDelay() {
        if let searchText = searchController.searchBar.text {
            
            if let searchQueryFormatted = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                if searchQueryFormatted.characters.count > 0 {
                    SeatGeekAPI.queryEvents(searchQueryFormatted) { (JSON) in
                        //offline handler
                        if (JSON.null != nil) { //this means JSON is nil
                            let alert = UIAlertController(title: "Internet Offline", message: "Check your connection and retry", preferredStyle: .actionSheet)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in })
                            self.present(alert, animated: true, completion: nil)
                        } else { //show results
                            
                            self.searchItems.removeAll()
                            let parsedResult = SeatGeekEventsResult(json: JSON)
                            self.searchItems = parsedResult.getParsedResults()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty Table View
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        var str: String
        if searchController.isActive && searchItems.isEmpty {
            str = "No results found"
        } else {
            str = "Welcome to SeatGeek"
        }
        
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        var str: String
        if searchController.isActive && searchItems.isEmpty {
            str = "Try a different search."
        } else {
            str = "Tap the search bar to begin searching for events. \n\n Example: Houston Rockets"
        }
        
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
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
        cell.favoriteImage.isHidden = !Favorites.isFavorite(id: searchItems[indexPath.row].id)
        
        
        
        return cell
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetail" { //handle segue to details view controller
            
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { //adds delay to search query to prevent unnecessary server calls
        
        let searchDelay = 0.25 //seconds
        
        if !searchText.characters.isEmpty {
            print("search query called")
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MainViewController.performSearchAfterDelay), object: nil)
            self.perform(#selector(MainViewController.performSearchAfterDelay), with: nil, afterDelay: searchDelay)
        } else {
            
            searchItems.removeAll()
            tableView.reloadData()            
        }
        
    }
}












