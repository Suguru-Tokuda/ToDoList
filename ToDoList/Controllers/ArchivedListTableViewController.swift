//
//  ArchivedListTableViewController.swift
//  ToDoList
//
//  Created by Suguru on 5/7/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class ArchivedListTableViewController: UIViewController {
    var archivedLists = [List]()
    var listIds = [String]()
    var user: User?
    var appDelegate: AppDelegate?
    var activityIndicatorView: UIActivityIndicatorView?
    var toDoListDataStore: ToDoListDataStore?
    var isLoggedIn: Bool?
    
    @IBOutlet weak var archivedListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        archivedListTableView.delegate = self
        archivedListTableView.dataSource = self
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        isLoggedIn = appDelegate!.isLoggedIn
        self.navigationItem.title = "Build from History"
        
        if !isLoggedIn! {
            performSegue(withIdentifier: "goBackToLogin", sender: self)
        }
        
        toDoListDataStore = ToDoListDataStore()
        user = appDelegate!.user
        self.getArchivedLists()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ArchivedListTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "archivedListCell", for: indexPath)
        let list = self.archivedLists[indexPath.row]
        cell.textLabel!.text = list.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Build from History?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            let listToPut = self.archivedLists[indexPath.row]
            listToPut.isArchived = false
            let putListGroup = DispatchGroup()
            putListGroup.enter()
            self.toDoListDataStore?.postPutList(method: "PUT", list: listToPut, completion: { (result) in
                switch result {
                case let .success(response):
                    print(response)
                case let .failure(error):
                    print(error)
                }
                putListGroup.leave()
            })
            putListGroup.notify(queue: .main, execute: {
                self.getArchivedLists()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ArchivedListTableViewController {
    private func getArchivedLists() {
        archivedLists.removeAll()
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView?.startAnimating()
        activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatorView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        let getListUserAssignsDispatchGroup = DispatchGroup()
        getListUserAssignsDispatchGroup.enter()
        toDoListDataStore?.getListUserAssigns(listUserAssignId: nil) { (listUserAssigns) in
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
        getListUserAssignsDispatchGroup.notify(queue: .main) {
            self.toDoListDataStore?.getLists(listId: nil, completion: { (listsResult) in
                switch listsResult {
                case let .success(lists):
                    for list in lists {
                        for listId in self.listIds {
                            if listId == list.id && list.isArchived {
                                self.archivedLists.append(list)
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
            self.activityIndicatorView?.stopAnimating()
            self.archivedListTableView.reloadData()
        }
    }
}
