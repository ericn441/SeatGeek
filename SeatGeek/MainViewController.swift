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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let clientID: String = "NzcwNTc5M3wxNDk2MTg0MTU0LjE5"
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchQueryText = "Texas Rangers"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        if let searchQueryFormatted = searchQueryText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            
            fetchResults(searchQueryFormatted) { (JSON) in
                print(JSON)
            }
        }
        
        

    }
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! ResultsTableViewCell
        return cell
    }

}


extension MainViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    /*func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
     filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
     }*/
}

extension MainViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        //let searchBar = searchController.searchBar
        //let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        //filterContentForSearchText(searchController.searchBar.text!)
    }
}
