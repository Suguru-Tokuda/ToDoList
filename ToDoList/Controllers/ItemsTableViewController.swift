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
    var allItems: [Item] = [Item]() // contains all the items
    var activeItems: [Item] = [Item]() // contains all the items with not completed
    var itemsToShow: [Item] = [Item]() // contains items to show
    var filteredItems: [Item] = [Item]() // contains items that are filtered
    var itemIds: [String] = [String]()
    var showCompleted = false
    
    @IBOutlet weak var itemsTableView: UITableView!
    var activityIndicatorView: UIActivityIndicatorView?
    let searchController = UISearchController(searchResultsController: nil)
    var showCompleteItemsBtn: UIButton?
    var addItemBtn: UIBarButtonItem?
    var addToListBtn: UIBarButtonItem?
    var isLoggedIn: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        user = appDelegate!.user
        isLoggedIn = appDelegate!.isLoggedIn
        
        if !isLoggedIn! {
            performSegue(withIdentifier: "goBackToLogin", sender: self)
        }
        
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
        addItemBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemBtnTapped))
        addToListBtn = UIBarButtonItem(image: UIImage(named: "group"), style: .plain, target: self, action: #selector(addToGroupBtnTapped))
        self.navigationItem.setRightBarButtonItems([addItemBtn!, addToListBtn!], animated: true)
        getItems(listId: listToShow!.id)
    }
    
}

extension ItemsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        var item: Item = self.itemsToShow[indexPath.row]
        cell.textLabel!.text = item.itemDescription
        if item.isImportant {
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
                let updateItemGroup = DispatchGroup()
                updateItemGroup.enter()
                self.toDoListDataStore?.postPutItem(method: "PUT", item: item, completion: { (result) in
                    switch result {
                    case let .success(response):
                        print(response)
                        updateItemGroup.leave()
                    case let .failure(error):
                        print(error)
                    }
                })
                updateItemGroup.notify(queue: .main, execute: {
                    self.getItems(listId: self.listToShow!.id)
                })
            }
            actions.append(complete)
        }
        return actions
    }
}

extension ItemsTableViewController {
    @objc func addItemBtnTapped() {
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
    
    @objc func showCompleteBtnTapped() {
        showCompleted = !showCompleted
        if showCompleted {
            self.itemsToShow = self.allItems
            showCompleteItemsBtn!.setTitle("Hide Completed Items", for: .normal)
        } else {
            self.itemsToShow = self.activeItems
            showCompleteItemsBtn!.setTitle("Show Completed Items", for: .normal)
        }
        itemsTableView.reloadData()
    }
    
    @objc func addToGroupBtnTapped() {
        let alert = UIAlertController(title: "Add a Member", message: "Enter an email of the person to add.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "Email"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let email = alert!.textFields![0].text
            if email!.isEmpty {
                let emptyAlert = UIAlertController(title: "Fill in the blank", message: "Enter an email", preferredStyle: .alert)
                emptyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emptyAlert, animated: true)
            }
            if email!.lowercased() == self.user!.email {
                let sameEmailAlert = UIAlertController(title: "You cannot add yourself.", message: "Enter a different email.", preferredStyle: .alert)
                sameEmailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(sameEmailAlert, animated: true)
            }
            if self.isValidEmail(email: email!) {
                self.addToGroup(email: email!)
            } else {
                let emailAlert = UIAlertController(title: "Invalid email", message: "Enter valid email", preferredStyle: .alert)
                emailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emailAlert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func resetAllItems() {
        allItems.removeAll()
        activeItems.removeAll()
        itemsToShow.removeAll()
        filteredItems.removeAll()
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func addToGroup(email: String) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView?.startAnimating()
        activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatorView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
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
            var userFound = false
            for user in users! {
                if user.email.lowercased() == email.lowercased() {
                    userId = user.id
                    userFound = true
                }
            }
            if !userFound {
                let userExistsAlert = UIAlertController(title: "Could not found a user for the email", message: "Choose Different Email", preferredStyle: .alert)
                userExistsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(userExistsAlert, animated: true)
                self.activityIndicatorView?.stopAnimating()
                return
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
                        self.activityIndicatorView?.stopAnimating()
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
                let insertListUserAssignGrouop = DispatchGroup()
                insertListUserAssignGrouop.enter()
                let listUserAssignToInsert = ListUserAssign(id: idCandidate.description, userId: userId!, listId: self.listToShow!.id)
                self.toDoListDataStore?.postPutListUserAssign(method: "POST", listUserAssign: listUserAssignToInsert, completion: { (result) in
                    switch result {
                    case let .success(response):
                        print(response)
                    case let .failure(error):
                        print(error)
                    }
                    insertListUserAssignGrouop.leave()
                })
                insertListUserAssignGrouop.notify(queue: .main, execute: {
                    self.activityIndicatorView?.stopAnimating()
                    let userExistsAlert = UIAlertController(title: "\(email) was added to the list.", message: "Now the member can see this list", preferredStyle: .alert)
                    userExistsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(userExistsAlert, animated: true)
                })
            })
        }
    }
    
    private func createItem(desc: String, isImportant: Bool) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView?.startAnimating()
        activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatorView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
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
            
            let itemToInsert = Item(id: idCandidate.description, userId: self.user!.id, itemDescription: desc, isImportant: isImportant, isComplete: false)
            self.toDoListDataStore!.postPutItem(method: "POST", item: itemToInsert, completion: { (result) in
                switch result {
                case let .success(response):
                    print(response)
                case let .failure(error):
                    print(error)
                }
            })
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
                let insertItemListAssignGroup = DispatchGroup()
                insertItemListAssignGroup.enter()
                let itemListAssignToInsert = ItemListAssign(id: idCandidate.description, itemId: itemToInsert.id, listId: self.listToShow!.id)
                self.toDoListDataStore?.postPutItemListAssign(method: "POST", itemListAssign: itemListAssignToInsert, completion: { (result) in
                    switch result {
                        case let .success(response):
                        print(response)
                    case let .failure(error):
                        print(error)
                    }
                    insertItemListAssignGroup.leave()
                })
                insertItemListAssignGroup.notify(queue: .main, execute: {
                    self.activityIndicatorView?.stopAnimating()
                    self.getItems(listId: self.listToShow!.id)
                })
            })
        }
    }
    
    private func getItems(listId: String) {
        resetAllItems()
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
            self.allItems = self.allItems.sorted(by: {$0.isImportant && !$1.isImportant })
            for item in self.allItems {
                if !item.isComplete {
                    self.activeItems.append(item)
                }
            }
            self.itemsToShow = self.activeItems
            self.itemsTableView.reloadData()
            self.activityIndicatorView?.stopAnimating()
        }
    }
}

extension ItemsTableViewController: UISearchResultsUpdating {
    // MARK: - Search bar function
    func updateSearchResults(for searchController: UISearchController) {
        var itemsToSearch = [Item]()
        if showCompleted {
            itemsToSearch = self.allItems
        } else {
            itemsToSearch = self.activeItems
        }
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredItems = itemsToSearch.filter { item in
                return item.itemDescription.lowercased().contains(searchText.lowercased())
            }
            itemsToShow = filteredItems
        } else {
            itemsToShow = itemsToSearch
        }
        itemsTableView.reloadData()
    }
}
