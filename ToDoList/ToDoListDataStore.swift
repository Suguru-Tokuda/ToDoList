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
    func postPutUser(method: String, user: User) {
        let parameters = ["id": user.id, "firstName": user.firstName, "lastName": user.lastName, "email": user.email, "password": user.password]
        let url = ToDoListAPI.getUsersRequestURL(method: .noParams, userId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = method
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
        }.resume()
    }
    
    func postPutList(method: String, list: List, userId: String) {
        let parameters = ["id": list.id, "title": list.title, "isArchived": list.isArchived.description, userId: userId]
        let url = ToDoListAPI.getListsRequestURL(method: .noParams, listId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = method
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
        }.resume()
    }
    
    func postPutItem(method: String, item: Item, userId: String) {
        let parameters = ["id": item.id, "userId": userId, "desc": item.desc, "isImportant": item.isImportant.description]
        let url = ToDoListAPI.getItemsRequestURL(method: .noParams, itemId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = method
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
        }.resume()
    }
    
    func postPutItemListAssign(method: String, id: String, itemId: String, listId: String) {
        let parameters = ["id": id, "itemId": itemId, "listId": listId]
        let url = ToDoListAPI.getItemListAssignsURL(method: .noParams, itemListAssignId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = method
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
        }.resume()
    }
    
    func postPutListUserAssign(method: String, id: String, userId: String, listId: String) {
        let parameters = ["id": id, "userId": userId, "listId": listId]
        let url = ToDoListAPI.getListUserAssignURL(method: .noParams, listUserAssignId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = method
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    //MARK: DELETE Requests
    func deleteUser(id: String) {
        let parameters = ["id": id]
        let url = ToDoListAPI.getUsersRequestURL(method: .noParams, userId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
            }.resume()
    }
    
    func deleteList(id: String) {
        let parameters = ["id": id]
        let url = ToDoListAPI.getListsRequestURL(method: .noParams, listId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
            }.resume()
    }
    
    func deleteItem(id: String) {
        let parameters = ["id": id]
        let url = ToDoListAPI.getItemsRequestURL(method: .noParams, itemId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
            }.resume()
    }
    
    func deleteItemListAssign(id: String) {
        let parameters = ["id": id]
        let url = ToDoListAPI.getItemListAssignsURL(method: .noParams, itemListAssignId: nil)
        var request = URLRequest(url: url)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
            }.resume()
    }
    
    func deleteListUserAssign(id: String) {
        let parameters = ["id": id]
        let url = ToDoListAPI.getListUserAssignURL(method: .noParams, listUserAssignId: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                print(error)
            }
        }
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
    
    
    
    
}
