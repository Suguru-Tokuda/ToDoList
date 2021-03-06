//
//  ToDoListDataStore.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import Foundation

enum UsersResult {
    case success([User])
    case failure(Error)
}

enum ListsResult {
    case success([List])
    case failure(Error)
}

enum ItemsResult {
    case success([Item])
    case failure(Error)
}

enum ItemListAssignResult {
    case success([ItemListAssign])
    case failure(Error)
}

enum ListUserAssignResult {
    case success([ListUserAssign])
    case failure(Error)
}

enum PostPutDeleteResult {
    case success(Data)
    case failure(Error)
}

public class ToDoListDataStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    //MARK: GET Requests
    func getUsers(userId: String?, completion: @escaping (UsersResult) -> Void) {
        var method = QueryMethod.id
        if userId == nil {
            method = QueryMethod.noParams
        }
        let url = ToDoListAPI.getUsersRequestURL(method: method, userId: userId)
        let request = URLRequest(url: url)
        _ = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processUsersRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    func getLists(listId: String?, completion: @escaping (ListsResult) -> Void) {
        var method = QueryMethod.id
        if listId == nil {
            method = QueryMethod.noParams
        }
        let url = ToDoListAPI.getListsRequestURL(method: method, listId: listId)
        let request = URLRequest(url: url)
        _ = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processListsRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            }.resume()
    }
    
    func getItems(itemId: String?, completion: @escaping (ItemsResult) -> Void) {
        var method = QueryMethod.id
        if itemId == nil {
            method = QueryMethod.noParams
        }
        let url = ToDoListAPI.getItemsRequestURL(method: method, itemId: itemId)
        let request = URLRequest(url: url)
        _ = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processItemsRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    func getItemListAssigns(itemListAssignId: String?, completion: @escaping (ItemListAssignResult) -> Void) {
        var method = QueryMethod.id
        if itemListAssignId == nil {
            method = QueryMethod.noParams
        }
        let url = ToDoListAPI.getItemListAssignsURL(method: method, itemListAssignId: itemListAssignId)
        let request = URLRequest(url: url)
        _ = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processItemListAssignRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            }.resume()
    }
    
    func getListUserAssigns(listUserAssignId: String?, completion: @escaping (ListUserAssignResult) -> Void) {
        var method = QueryMethod.id
        if listUserAssignId == nil {
            method = QueryMethod.noParams
        }
        let url = ToDoListAPI.getListUserAssignURL(method: method, listUserAssignId: listUserAssignId)
        let request = URLRequest(url: url)
        _ = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processListUserAssignRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            }.resume()
    }
    
    //MARK: POST/PUT Request
    func postPutUser(method: String, user: User, completion: @escaping (PostPutDeleteResult) -> Void) {
        let parameters = ["id": user.id, "firstName": user.firstName, "lastName": user.lastName, "email": user.email, "password": user.password]
        var url: URL?
        if method == "POST" {
            url = ToDoListAPI.getUsersRequestURL(method: .noParams, userId: nil)
        } else if method == "PUT" {
            url = ToDoListAPI.getUsersRequestURL(method: .noParams, userId: user.id)
        }
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    func postPutList(method: String, list: List, completion: @escaping (PostPutDeleteResult) -> Void) {
        let parameters = ["id": list.id, "title": list.title, "isArchived": list.isArchived.description, "userId": list.userId]
        var url: URL?
        if method == "POST" {
            url = ToDoListAPI.getListsRequestURL(method: .noParams, listId: nil)
        } else if method == "PUT" {
            url = ToDoListAPI.getListsRequestURL(method: .noParams, listId: list.id)
        }
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            }.resume()
    }
    
    func postPutItem(method: String, item: Item, completion: @escaping (PostPutDeleteResult) -> Void) {
        var parameters = [String: String]()
        var url: URL?
        if method == "POST" {
            parameters = ["id": item.id, "userId": item.userId, "itemDescription": item.itemDescription, "isImportant": item.isImportant.description, "isComplete": item.isComplete.description]
            url = ToDoListAPI.getItemsRequestURL(method: .noParams, itemId: nil)
        } else if method == "PUT" {
            parameters = ["userId": item.userId, "itemDescription": item.itemDescription, "isImportant": item.isImportant.description, "isComplete": item.isComplete.description]
            url = ToDoListAPI.getItemsRequestURL(method: .noParams, itemId: item.id)
        }
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            }.resume()
    }
    
    func postPutItemListAssign(method: String, itemListAssign: ItemListAssign, completion: @escaping (PostPutDeleteResult) -> Void) {
        let parameters = ["id": itemListAssign.id, "itemId": itemListAssign.itemId, "listId": itemListAssign.listId]
        var url: URL?
        if method == "POST" {
            url = ToDoListAPI.getItemListAssignsURL(method: .noParams, itemListAssignId: nil)
        } else if method == "PUT" {
            url = ToDoListAPI.getItemListAssignsURL(method: .noParams, itemListAssignId: itemListAssign.id)
        }
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            }.resume()
    }
    
    func postPutListUserAssign(method: String, listUserAssign: ListUserAssign, completion: @escaping (PostPutDeleteResult) -> Void) {
        let parameters = ["id": listUserAssign.id, "userId": listUserAssign.userId, "listId": listUserAssign.listId, "accepted": listUserAssign.accepted.description]
        var url: URL?
        if method == "POST" {
            url = ToDoListAPI.getListUserAssignURL(method: .noParams, listUserAssignId: nil)
        } else if method == "PUT" {
            url = ToDoListAPI.getListUserAssignURL(method: .noParams, listUserAssignId: listUserAssign.id)
        }
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    //MARK: DELETE Requests
    func deleteUser(id: String, completion: @escaping (PostPutDeleteResult) -> Void) {
        let url = ToDoListAPI.getUsersRequestURL(method: .noParams, userId: id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    func deleteList(id: String, completion: @escaping (PostPutDeleteResult) -> Void) {
        let url = ToDoListAPI.getListsRequestURL(method: .noParams, listId: id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    func deleteItem(id: String, completion: @escaping (PostPutDeleteResult) -> Void) {
        let url = ToDoListAPI.getItemsRequestURL(method: .noParams, itemId: id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }

    func deleteItemListAssign(id: String, completion: @escaping (PostPutDeleteResult) -> Void) {
        let url = ToDoListAPI.getItemListAssignsURL(method: .noParams, itemListAssignId: id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    func deleteListUserAssign(id: String, completion: @escaping (PostPutDeleteResult) -> Void) {
        let url = ToDoListAPI.getListUserAssignURL(method: .noParams, listUserAssignId: id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processPostPutDeleteRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }.resume()
    }
    
    //MARK: private funcs to send data back to ToDoListAPI class
    private func processUsersRequest(data: Data?, error: Error?) -> UsersResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ToDoListAPI.getUsersResult(fromJSON: jsonData)
    }
    
    private func processListsRequest(data: Data?, error: Error?) -> ListsResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ToDoListAPI.getListsResult(fromJSON: jsonData)
    }
    
    private func processItemsRequest(data: Data?, error: Error?) -> ItemsResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ToDoListAPI.getItemsResult(fromJSON: jsonData)
    }
    
    private func processItemListAssignRequest(data: Data?, error: Error?) -> ItemListAssignResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ToDoListAPI.getItemListAssignResult(fromJSON: jsonData)
    }
    
    private func processListUserAssignRequest(data: Data?, error: Error?) -> ListUserAssignResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ToDoListAPI.getListUserAssignResult(fromJSON: jsonData)
    }
    
    private func processPostPutDeleteRequest(data: Data?, error: Error?) -> PostPutDeleteResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ToDoListAPI.getPostPutDeleteResult(fromJSON: jsonData)
    }
    
}
