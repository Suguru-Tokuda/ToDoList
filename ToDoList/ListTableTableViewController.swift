//
//  ListTableTableViewController.swift
//  List
//
//  Created by Suguru on 4/26/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class ListTableTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    var itemsList: [Item]?
    @IBOutlet weak var listTableView: UITableView!
    let inviteBtn = UIButton()
    let searchController = UISearchController(searchResultsController: nil)
    var inSearch: Bool!
    var showCompleted: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        inSearch = false
        self.navigationItem.hidesBackButton = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Course"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table view functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listItemCell", for: indexPath)
        cell.textLabel!.text = self.itemsList![indexPath.row].desc
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        if (showCompleted) {
            let delete = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
                print("delete button tapped")
            }
            actions.append(delete)
        } else {
            let complete = UITableViewRowAction(style: .normal, title: "Complete") { action, index in
                print("more button tapped")
            }
            actions.append(complete)
        }
        return actions
    }
    
    // MARK: - Search bar function
    func updateSearchResults(for searchController: UISearchController) {
        
    }

}
