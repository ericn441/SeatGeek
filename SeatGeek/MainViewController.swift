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
    
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    let clientID: String = "NzcwNTc5M3wxNDk2MTg0MTU0LjE5"
    let searchController = UISearchController(searchResultsController: nil)
    var searchItems: [SearchItem] = []
    var searchQueryTextExample = "Texas Rangers"
    
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! ResultsTableViewCell
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
                    //print(JSON)
                    for results in JSON["events"].arrayValue
                    {
                        print(results["id"].stringValue)
                        print(results["title"].stringValue)
                        print(results["venue"]["display_location"])
                        print(results["datetime_local"].stringValue)
                        print(results["performers"][0]["image"].stringValue)
                    }
                    //self.searchItems.append(SearchItem(id: "", title: "", detail: "", time: "", imageURL: "", didFavor: false))
                }
            }
        }
        
    }
}













