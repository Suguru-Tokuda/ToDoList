//
//  ItemTableViewController.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class ItemsTableViewController: UIViewController {
    
    var listToShow: List?
    var user: User?
    var appDelegate: AppDelegate?
    var toDoListDataStore: ToDoListDataStore?
    var allItems: [Item] = [Item]()
    var activeItems: [Item] = [Item]()
    var itemsToShow: [Item] = [Item]()
    var filteredItems: [Item] = [Item]()
    var itemIds: [String] = [String]()
    var inSearch = false
    var showCompleted = false
    
    @IBOutlet weak var itemsTableView: UITableView!
    var activityIndicatorView: UIActivityIndicatorView?
    let searchController = UISearchController(searchResultsController: nil)
    var showCompleteItemsBtn: UIButton?
    var addToListBtn: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        user = appDelegate!.user
        toDoListDataStore = ToDoListDataStore()
        self.navigationItem.title = listToShow!.title
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Lists"
        navigationItem.searchController = searchController
        showCompleteItemsBtn = UIButton(type: .system)
        showCompleteItemsBtn!.setTitle("Show Completed Items", for: .normal)
        showCompleteItemsBtn?.addTarget(self, action: #selector(showCompleteBtnTapped), for: .touchUpInside)
        showCompleteItemsBtn?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(showCompleteItemsBtn!)
        showCompleteItemsBtn!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        showCompleteItemsBtn!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        addToListBtn = UIBarButtonItem(image: UIImage(named: "group"), style: .plain, target: self, action: #selector(addToGroupBtnTapped))
        getItems(listId: listToShow!.id)
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: "New Item", message: "Enter an item description and click \"Important\" or \"Less Important\"", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Item Description"
        }
        alert.addAction(UIAlertAction(title: "Important", style: .default, handler: { [weak alert] (_) in
            let desc = alert!.textFields![0].text
            self.createItem(desc: desc!, isImportant: true)
        }))
        alert.addAction(UIAlertAction(title: "Less Important", style: .default, handler: { [weak alert] (_) in
            let desc = alert!.textFields![0].text
            self.createItem(desc: desc!, isImportant: false)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

}

extension ItemsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearch {
            return self.filteredItems.count
        } else {
            if showCompleted {
                return self.allItems.count
            } else {
                return activeItems.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        var item: Item?
        if inSearch {
            item = self.filteredItems[indexPath.row]
        } else {
            item = self.allItems[indexPath.row]
        }
        cell.textLabel!.text = item!.desc
        if item!.isImportant {
            cell.textLabel!.textColor = UIColor.red
        }
        return cell
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
                var item = self.allItems[indexPath.row]
                item.isComplete = true
                self.toDoListDataStore?.postPutItem(method: "PUT", item: item)
            }
            actions.append(complete)
        }
        return actions
    }
}

extension ItemsTableViewController {
    @objc func showCompleteBtnTapped() {
        showCompleted = !showCompleted
        if showCompleted {
            self.itemsToShow = self.activeItems
            
            showCompleteItemsBtn!.setTitle("Hide Completed Items", for: .normal)
        } else {
            self.itemsToShow = self.allItems
            showCompleteItemsBtn!.setTitle("Show Completed Items", for: .normal)
        }
    }
    
    @objc func addToGroupBtnTapped() {
        let alert = UIAlertController(title: "Add a Member", message: "Enter an email of the person to add.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Email"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let email = alert!.textFields![0].text
            if self.isValidEmail(email: email!) {
                self.addToGroup(email: email!)
            } else {
                let emailAlert = UIAlertController(title: "Invalid email", message: "Enter valid email", preferredStyle: .alert)
                alert?.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emailAlert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func addToGroup(email: String) {
        let getAllUsersGroup = DispatchGroup()
        var users: [User]?
        var userId: String?
        getAllUsersGroup.enter()
        toDoListDataStore?.getUsers(userId: nil, completion: { (usersResult) in
            switch usersResult {
            case let .success(response):
                users = response
            case let .failure(error):
                print(error)
            }
            getAllUsersGroup.leave()
        })
        
        getAllUsersGroup.notify(queue: .main) {
            for user in users! {
                if user.email.lowercased() == email.lowercased() {
                    userId = user.id
                }
            }
            
            let getAllListUserAssignsGroup = DispatchGroup()
            var listUserAssigns: [ListUserAssign]?
            getAllListUserAssignsGroup.enter()
            self.toDoListDataStore?.getListUserAssigns(listUserAssignId: nil, completion: { (itemListAssignsResult) in
                switch itemListAssignsResult {
                case let .success(response):
                    listUserAssigns = response
                case let .failure(error):
                    print(error)
                }
                getAllListUserAssignsGroup.leave()
            })
            
            getAllListUserAssignsGroup.notify(queue: .main, execute: {
                for listUserAssign in listUserAssigns! {
                    if listUserAssign.userId == userId && listUserAssign.listId == self.listToShow!.id {
                        let userExistsAlert = UIAlertController(title: "The member is already in the list", message: "Choose Different Email", preferredStyle: .alert)
                        userExistsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(userExistsAlert, animated: true)
                        return
                    }
                }
                
                var idCandidate = arc4random_uniform(1000) + 1
                var uniqueCounter = 0
                let max = listUserAssigns!.count
                
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
                let listUserAssignToInsert = ListUserAssign(id: idCandidate.description, userId: userId!, listId: self.listToShow!.id)
                self.toDoListDataStore?.postPutListUserAssign(method: "POST", listUserAssign: listUserAssignToInsert)
            })
        }
    }
    
    private func createItem(desc: String, isImportant: Bool) {
        let getAllItemsGroup = DispatchGroup()
        var items: [Item]?
        getAllItemsGroup.enter()
        toDoListDataStore?.getItems(itemId: nil, completion: { (itemsResult) in
            switch itemsResult {
            case let .success(response):
                items = response
            case let .failure(error):
                print(error)
            }
            getAllItemsGroup.leave()
        })
        
        getAllItemsGroup.notify(queue: .main) {
            var idCandidate = arc4random_uniform(1000) + 1 // represents the candidate of the listId
            var uniqueCounter = 0 // represents the number of IDs from the DB that are different from idCandidate
            var max = items!.count
            
            while uniqueCounter != max {
                for i in 0...max {
                    if i == max && uniqueCounter != max {
                        uniqueCounter = 0 // reset the counter to 0
                        idCandidate = arc4random_uniform(1000) + 1
                        break
                    }
                    if i != max {
                        if items![i].id != idCandidate.description {
                            uniqueCounter += 1
                        }
                    }
                }
            }
            
            let itemToInsert = Item(id: idCandidate.description, userId: self.user!.id, desc: desc, isImportant: isImportant, isComplete: false)
            self.toDoListDataStore!.postPutItem(method: "POST", item: itemToInsert)
            let allItemListAssignsGroup = DispatchGroup()
            var itemListAssigns: [ItemListAssign]?
            allItemListAssignsGroup.enter()
            
            self.toDoListDataStore?.getItemListAssigns(itemListAssignId: nil, completion: { (itemLitAssignsResult) in
                switch itemLitAssignsResult {
                case let .success(response):
                    itemListAssigns = response
                case let .failure(error):
                    print(error)
                }
                allItemListAssignsGroup.leave()
            })
            
            allItemListAssignsGroup.notify(queue: .main, execute: {
                idCandidate = arc4random_uniform(1000) + 1
                uniqueCounter = 0
                max = itemListAssigns!.count
                
                while uniqueCounter != max {
                    for i in 0...max {
                        if i == max && uniqueCounter != max {
                            uniqueCounter = 0
                            idCandidate = arc4random_uniform(1000) + 1
                            break
                        }
                        if i != max {
                            if itemListAssigns![i].id != idCandidate.description {
                                uniqueCounter += 1
                            }
                        }
                    }
                }
                let itemListAssignToInsert = ItemListAssign(id: idCandidate.description, itemId: itemToInsert.id, listId: self.listToShow!.id)
                self.toDoListDataStore?.postPutItemListAssign(method: "POST", itemListAssign: itemListAssignToInsert)
                self.getItems(listId: self.listToShow!.id)
            })
        }
    }
    
    private func getItems(listId: String) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView?.startAnimating()
        activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatorView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        var itemListAssignsArray = [ItemListAssign]()
        let getItemListAssigns = DispatchGroup()
        getItemListAssigns.enter()
        toDoListDataStore?.getItemListAssigns(itemListAssignId: nil, completion: { (itemListAssigns) in
            switch itemListAssigns {
            case let .success(response):
                itemListAssignsArray = response
                for itemListAssign in itemListAssignsArray {
                    let listIdFromDB = itemListAssign.listId
                    let itemIdFromDB = itemListAssign.itemId
                    if listIdFromDB == listId && !self.itemIds.contains(itemIdFromDB) {
                        self.itemIds.append(itemIdFromDB)
                    }
                }
            case let .failure(error):
                print(error)
            }
            getItemListAssigns.leave()
        })
        
        var tempItemsArray = [Item]()
        let getItemsDispatchGroup = DispatchGroup()
        getItemsDispatchGroup.enter()
        allItems.removeAll()
        getItemListAssigns.notify(queue: .main) {
            self.toDoListDataStore?.getItems(itemId: nil, completion: { (itemsResult) in
                switch itemsResult {
                case let .success(response):
                    tempItemsArray = response
                    for item in tempItemsArray {
                        for id in self.itemIds {
                            if item.id == id {
                                self.allItems.append(item)
                            }
                        }
                    }
                case let .failure(error):
                    print(error)
                }
                getItemsDispatchGroup.leave()
            })
        }
        
        getItemsDispatchGroup.notify(queue: .main) {
            self.activityIndicatorView?.stopAnimating()
            self.allItems = self.allItems.sorted(by: {$0.isImportant && !$1.isImportant })
            for item in self.allItems {
                if !item.isComplete {
                    self.activeItems.append(item)
                }
            }
            self.itemsTableView.reloadData()
        }
    }
}

extension ItemsTableViewController: UISearchResultsUpdating {
    // MARK: - Search bar function
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.inSearch = true
            filteredItems = allItems.filter { item in
                return item.desc.lowercased().contains(searchText.lowercased())
            }
            itemsToShow = filteredItems
        } else {
            itemsToShow = allItems
            self.inSearch = false
        }
        itemsTableView.reloadData()
    }
}
