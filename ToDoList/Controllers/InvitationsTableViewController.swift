//
//  InvitationsTableViewController.swift
//  ToDoList
//
//  Created by Suguru on 5/8/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import UIKit

class InvitationsTableViewController: UIViewController {
    
    var listsToAccept: [List] = [List]()
    var allLists: [List] = [List]()
    var listUserAssigns = [ListUserAssign]()
    var toDoListDataStore = ToDoListDataStore()
    var allUsers: [User]?
    var listIds: [String] = [String]()
    var listIdsToAccept: [String] = [String]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var user: User?
    
    var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet weak var invitationsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        invitationsTableView.delegate = self
        invitationsTableView.dataSource = self
        user = appDelegate!.user
        self.navigationItem.title = "Invitations"
        getInvitations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension InvitationsTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listsToAccept.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath)
        let list = self.listsToAccept[indexPath.row]
        var invitee: User?
        for user in allUsers! {
            if list.userId == user.id {
                invitee = user
            }
        }
        if invitee != nil {
            cell.detailTextLabel?.text = "from \(invitee!.firstName)"
        }
        cell.textLabel?.text = list.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = listsToAccept[indexPath.row]
        let alert = UIAlertController(title: "Accept an invitation?", message: "\(list.title) from ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (_) in
            let listId = list.id
            var listUserAssignToPut: ListUserAssign?
            for listUserAssign in self.listUserAssigns {
                if listUserAssign.listId == listId && !listUserAssign.accepted {
                    listUserAssignToPut = listUserAssign
                }
            }
            let putListUserAssignGroup = DispatchGroup()
            putListUserAssignGroup.enter()
            listUserAssignToPut?.accepted = true
            self.toDoListDataStore.postPutListUserAssign(method: "PUT", listUserAssign: listUserAssignToPut!, completion: { (result) in
                switch result {
                case let .success(response):
                    print(response)
                case let .failure(error):
                    print(error)
                }
                putListUserAssignGroup.leave()
            })
            putListUserAssignGroup.notify(queue: .main, execute: {
                self.getInvitations()
            })
        }))
        alert.addAction(UIAlertAction(title: "Decline", style: .default, handler: { (_) in
            let listId = list.id
            var listUserAssignToDelete: ListUserAssign?
            for listUserAssign in self.listUserAssigns {
                if listUserAssign.listId == listId {
                    listUserAssignToDelete = listUserAssign
                }
            }
            let deleteListUserAssignGroup = DispatchGroup()
            deleteListUserAssignGroup.enter()
            self.toDoListDataStore.deleteListUserAssign(id: listUserAssignToDelete!.id, completion: { (result) in
                switch result {
                case let .success(response):
                    print(response)
                case let .failure(error):
                    print(error)
                }
                deleteListUserAssignGroup.leave()
            })
            deleteListUserAssignGroup.notify(queue: .main, execute: {
                self.getInvitations()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension InvitationsTableViewController {
    
    private func startActivityIndicator() {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView?.startAnimating()
        activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatorView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    private func resetDataArrays() {
        listsToAccept.removeAll()
        allLists.removeAll()
        listUserAssigns.removeAll()
    }
    
    private func getInvitations() {
        startActivityIndicator()
        resetDataArrays()
        
        let getListUserAssignsDispatchGroup = DispatchGroup()
        getListUserAssignsDispatchGroup.enter()
        toDoListDataStore.getListUserAssigns(listUserAssignId: nil) { (result) in
            switch result {
            case let .success(response):
                self.listUserAssigns = response
                self.listIds.removeAll()
                self.listIdsToAccept.removeAll()
                for listUserAssign in self.listUserAssigns {
                    let listId = listUserAssign.listId
                    if self.user!.id == listUserAssign.userId && !self.listIds.contains(listId) && !listUserAssign.accepted {
                        self.listIdsToAccept.append(listId)
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
                        for listIdToAccept in self.listIdsToAccept {
                            if listIdToAccept == list.id {
                                self.listsToAccept.append(list)
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
            self.invitationsTableView.reloadData()
        }
        
    }
    
    private func getAllUsers() {
        self.toDoListDataStore.getUsers(userId: nil, completion: { (result) in
            switch result {
            case let .success(response):
                self.allUsers = response
            case let .failure(error):
                print(error)
            }
        })
    }
}

