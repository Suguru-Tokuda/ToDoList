//
//  ListTableTableViewController.swift
//  List
//
//  Created by Suguru on 4/26/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class ListTableTableViewController: UIViewController {
    @IBOutlet weak var listTableView: UITableView!
    
    var activityIndicatorView: UIActivityIndicatorView?
    
    var allLists: [List] = [List]()
    var activeLists: [List] = [List]()
    var filteredLists: [List] = [List]()
    var lists: [List] = [List]()
    
    var listToShow: List?
    
    var listIds: [String] = [String]()
    var appDelegate: AppDelegate?
    var user: User?
    var isLoggedIn: Bool?
    let toDoListDataStore: ToDoListDataStore = ToDoListDataStore()
    
    let searchController = UISearchController(searchResultsController: nil)
    var inSearch: Bool!
    var showCompleted: Bool = false
    
    var buildFromHistoryBtn: UIBarButtonItem?
    var addListBtn: UIBarButtonItem?
    var logoutBtn: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        user = appDelegate!.user
        isLoggedIn = appDelegate!.isLoggedIn
        
        buildFromHistoryBtn = UIBarButtonItem(image: UIImage(named: "stopWatch"), style: .plain, target: self, action: #selector(buildFromHistoryBtnTapped))
        self.navigationItem.setLeftBarButton(buildFromHistoryBtn!, animated: true)
        
        if !isLoggedIn! {
            performSegue(withIdentifier: "goBackToLogin", sender: self)
        }
        
        inSearch = false
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = user!.firstName + "'s Lists"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Lists"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        addListBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListBtnTapped))
        logoutBtn = UIBarButtonItem(image: UIImage(named: "exit"), style: .plain, target: self, action: #selector(logoutBtnTapped))
        
        self.navigationItem.setRightBarButtonItems([addListBtn!, logoutBtn!], animated: true)
        
        getLists()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ListTableTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        let list = self.lists[indexPath.row]
        cell.textLabel!.text = list.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
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
                print("Complete button tapped")
            }
            actions.append(complete)
        }
        return actions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listToShow = lists[indexPath.row]
        performSegue(withIdentifier: "goToItems", sender: self)
    }
}

extension ListTableTableViewController: UISearchResultsUpdating {
    // MARK: - Search bar function
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            inSearch = true
            filteredLists = activeLists.filter { list in
                return list.title.lowercased().contains(searchText.lowercased())
            }
            lists = filteredLists
        } else {
            lists = activeLists
            inSearch = false
        }
        listTableView.reloadData()
    }
}

// MARK: Custom functions
extension ListTableTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let itemsTableViewController = segue.destination as? ItemsTableViewController
            itemsTableViewController?.listToShow = self.listToShow!
        }
    }
    
    @objc func logoutBtnTapped() {
        appDelegate!.isLoggedIn = false
        performSegue(withIdentifier: "goBackToLogin", sender: self)
    }
    
    @objc func addListBtnTapped() {
        let alert = UIAlertController(title: "New List", message: "Enter a title", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "List Title"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let title = alert!.textFields![0]
            self.createList(title: title.text!, userId: self.user!.id)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func buildFromHistoryBtnTapped() {
        //TODO
    }
    
    private func createList(title: String, userId: String) {
        let getAllListsGroup = DispatchGroup()
        var lists: [List]?
        getAllListsGroup.enter()
        toDoListDataStore.getLists(listId: nil, completion: { (listsResult) in
            switch listsResult {
            case let .success(response):
                lists = response
            case let .failure(error):
                print(error)
            }
            getAllListsGroup.leave()
        })
        
        getAllListsGroup.notify(queue: .main) {
            var idCandidate = arc4random_uniform(1000) + 1 // represents the candidate of the listId
            var uniqueCounter = 0 // represents the number of IDs from the DB that are different from idCandidate
            var max = lists!.count
            
            while uniqueCounter != max {
                for i in 0...max {
                    if i == max && uniqueCounter != max {
                        uniqueCounter = 0 // reset the counter to 0
                        idCandidate = arc4random_uniform(1000) + 1
                        break
                    }
                    if i != max {
                        if lists![i].id != idCandidate.description {
                            uniqueCounter += 1
                        }
                    }
                }
            }
            
            let listToInsert = List(id: idCandidate.description, title: title, isArchived: false)
            self.toDoListDataStore.postPutList(method: "POST", list: listToInsert)
            let allListUserAssignGroup = DispatchGroup()
            var listUserAssigns: [ListUserAssign]?
            allListUserAssignGroup.enter()
            
            self.toDoListDataStore.getListUserAssigns(listUserAssignId: nil, completion: { (listUserAssignsResult) in
                switch listUserAssignsResult {
                case let .success(response):
                    listUserAssigns = response
                case let .failure(error):
                    print(error)
                }
                allListUserAssignGroup.leave()
            })
            
            allListUserAssignGroup.notify(queue: .main, execute: {
                idCandidate = arc4random_uniform(1000) + 1
                uniqueCounter = 0
                max = listUserAssigns!.count
                
                while uniqueCounter != max {
                    for i in 0...max {
                        if i == max && uniqueCounter != max {
                            uniqueCounter = 0 // reset the counter to 0
                            idCandidate = arc4random_uniform(1000) + 1
                            break
                        }
                        if i != max {
                            if listUserAssigns![i].id != idCandidate.description {
                                uniqueCounter += 1
                            }
                        }
                    }
                }
                let listUserAssignToInsert = ListUserAssign(id: idCandidate.description, userId: userId, listId: listToInsert.id)
                self.toDoListDataStore.postPutListUserAssign(method: "POST", listUserAssign: listUserAssignToInsert)
                self.getLists() // reloads the data after insert.
            })
        }
    }
    
    private func getLists() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView?.startAnimating()
        activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatorView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        let getListUserAssignsDispatchGroup = DispatchGroup()
        getListUserAssignsDispatchGroup.enter()
        toDoListDataStore.getListUserAssigns(listUserAssignId: nil) { (listUserAssigns) in
            switch listUserAssigns {
            case let .success(listUserAssigns):
                self.listIds.removeAll()
                for listUserAssign in listUserAssigns {
                    let listId = listUserAssign.listId
                    if self.user!.id == listUserAssign.userId && !self.listIds.contains(listId) {
                        self.listIds.append(listId)
                    }
                }
                self.listIds.sort()
                getListUserAssignsDispatchGroup.leave()
            case let .failure(error):
                print(error)
            }
        }
        
        let getListDispatchGroup = DispatchGroup()
        getListDispatchGroup.enter()
        allLists.removeAll()
        getListUserAssignsDispatchGroup.notify(queue: .main) {
            self.toDoListDataStore.getLists(listId: nil, completion: { (listsResult) in
                switch listsResult {
                case let .success(lists):
                    for list in lists {
                        for listId in self.listIds {
                            if listId == list.id {
                                self.allLists.append(list)
                            }
                        }
                    }
                case let .failure(error):
                    print(error)
                }
                getListDispatchGroup.leave()
            })
        }
        
        getListDispatchGroup.notify(queue: .main) {
            self.activeLists.removeAll()
            for list in self.allLists {
                if !list.isArchived {
                    self.activeLists.append(list)
                }
            }
            self.lists = self.activeLists
            self.activityIndicatorView?.stopAnimating()
            self.listTableView.reloadData()
        }
    }
    
    
}
