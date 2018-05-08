//
//  ToDoListAPI.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import Foundation

enum QueryMethod: String {
    case id = "?id="
    case noParams = ""
}

class ToDoListAPI {
    
    //MARK: Base URLs
    private static let usersBaseURL = "https://78kgwweb04.execute-api.us-east-2.amazonaws.com/users"
    private static let listsBaseURL = "https://1xlcbnos03.execute-api.us-east-2.amazonaws.com/lists"
    private static let itemsBaseURL = "https://gim8s9c1t2.execute-api.us-east-2.amazonaws.com/items"
    private static let listUserAssignBaseURL = "https://yj5b3di6hl.execute-api.us-east-2.amazonaws.com/listUserAssign"
    private static let itemListAssignBaseURL = "https://yjcqnge35k.execute-api.us-east-2.amazonaws.com/itemListAssign"
    
    //MARK: Rquest URLs
    public static func getUsersRequestURL(method: QueryMethod, userId: String?) -> URL {
        var inputId = userId
        if userId == nil {
            inputId = ""
        } else {
            inputId = "?id=\(String(describing: inputId!))"
        }
        let urlString = usersBaseURL + method.rawValue + inputId!
        let url = URL(string: urlString)
        return url!
    }
    
    public static func getListsRequestURL(method: QueryMethod, listId: String?) -> URL {
        var inputId = listId
        if listId == nil {
            inputId = ""
        } else {
            inputId = "?id=\(String(describing: inputId!))"
        }
        let urlString = listsBaseURL + method.rawValue + inputId!
        let url = URL(string: urlString)
        return url!
    }
    
    public static func getItemsRequestURL(method: QueryMethod, itemId: String?) -> URL {
        var inputId = itemId
        if inputId == nil {
            inputId = ""
        } else {
            inputId = "?id=\(String(describing: inputId!))"
        }
        let urlString = itemsBaseURL + method.rawValue + inputId!
        let url = URL(string: urlString)
        return url!
    }
    
    public static func getItemListAssignsURL(method: QueryMethod, itemListAssignId: String?) -> URL {
        var inputId = itemListAssignId
        if inputId == nil {
            inputId = ""
        } else {
            inputId = "?id=\(String(describing: inputId!))"
        }
        let urlString = itemListAssignBaseURL + method.rawValue + inputId!
        let url = URL(string: urlString)
        return url!
    }
    
    public static func getListUserAssignURL(method: QueryMethod, listUserAssignId: String?) -> URL {
        var inputId = listUserAssignId
        if inputId == nil {
            inputId = ""
        } else {
            inputId = "?id=\(String(describing: inputId!))"
        }
        let urlString = listUserAssignBaseURL + method.rawValue + inputId!
        let url = URL(string: urlString)
        return url!
    }
    
    //MARK: JSON processing functions
    public static func getUsersResult(fromJSON data: Data) -> UsersResult {
        var usersArray = [User]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = jsonObject as? [AnyHashable: Any] {
                if let users = jsonArray["Items"] as? [[String: Any]] {
                    for user in users {
                        let id = user["id"] as? String ?? ""
                        let firstName = user["firstName"] as? String ?? ""
                        let lastName = user["lastName"] as? String ?? ""
                        let email = user["email"] as? String ?? ""
                        let password = user["password"] as? String ?? ""
                        usersArray.append(User(id: id, firstName: firstName, lastName: lastName, email: email, password: password))
                    }
                }
            }
            return .success(usersArray)
        } catch let jsonError {
            return .failure(jsonError)
        }
    }
    
    public static func getListsResult(fromJSON data: Data) -> ListsResult {
        var listsArray = [List]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = jsonObject as? [AnyHashable: Any] {
                if let lists = jsonArray["Items"] as? [[String: Any]] {
                    for list in lists {
                        let id = list["id"] as? String ?? ""
                        let title = list["title"] as? String ?? ""
                        let isArchivedStr = list["isArchived"] as? String ?? ""
                        var isArchived = false
                        if isArchivedStr == "true" {
                            isArchived = true
                        }
                        listsArray.append(List(id: id, title: title, isArchived: isArchived))
                    }
                }
            }
            return .success(listsArray)
        } catch let jsonError {
            return .failure(jsonError)
        }
    }
    
    public static func getItemsResult(fromJSON data: Data) -> ItemsResult {
        var itemsArray = [Item]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = jsonObject as? [AnyHashable: Any] {
                if let items = jsonArray["Items"] as? [[String: Any]] {
                    for item in items {
                        let id = item["id"] as? String ?? ""
                        let userId = item["userId"] as? String ?? ""
                        let itemDescription = item["itemDescription"] as? String ?? ""
                        var isImportant = false
                        let isImportantStr = item["isImportant"] as? String ?? ""
                        if isImportantStr == "true" {
                            isImportant = true
                        }
                        var isComplete = false
                        let isCompleteStr = item["isComplete"] as? String ?? ""
                        if isCompleteStr == "true" {
                            isComplete = true
                        }
                        itemsArray.append(Item(id: id, userId: userId, itemDescription: itemDescription, isImportant: isImportant, isComplete: isComplete))
                    }
                }
            }
            return .success(itemsArray)
        } catch let jsonError {
            return .failure(jsonError)
        }
    }
    
    public static func getItemListAssignResult(fromJSON data: Data) -> ItemListAssignResult {
        var itemListAssignsArray = [ItemListAssign]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = jsonObject as? [AnyHashable: Any] {
                if let itemListAssigns = jsonArray["Items"] as? [[String: Any]] {
                    for itemListAssign in itemListAssigns {
                        let id = itemListAssign["id"] as? String ?? ""
                        let itemId = itemListAssign["itemId"] as? String ?? ""
                        let listId = itemListAssign["listId"] as? String ?? ""
                        itemListAssignsArray.append(ItemListAssign(id: id, itemId: itemId, listId: listId))
                    }
                }
            }
            return .success(itemListAssignsArray)
        } catch let jsonError {
            return .failure(jsonError)
        }
    }
    
    public static func getListUserAssignResult(fromJSON data: Data) -> ListUserAssignResult {
        var listUserAssignsArray = [ListUserAssign]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = jsonObject as? [AnyHashable: Any] {
                if let listUserAssigns = jsonArray["Items"] as? [[String: Any]] {
                    for listUserAssign in listUserAssigns {
                        let id = listUserAssign["id"] as? String ?? ""
                        let listId = listUserAssign["listId"] as? String ?? ""
                        let userId = listUserAssign["userId"] as? String ?? ""
                        listUserAssignsArray.append(ListUserAssign(id: id, userId: userId, listId: listId))
                    }
                }
            }
            return .success(listUserAssignsArray)
        } catch let jsonError {
            return .failure(jsonError)
        }
    }
    
    public static func getPostPutDeleteResult(fromJSON data: Data) -> PostPutDeleteResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            print(jsonObject)
            return .success(data)
        } catch let error {
            return .failure(error)
        }
    }
    
}
