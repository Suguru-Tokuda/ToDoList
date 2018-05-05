//
//  ListUserAssign.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import Foundation

public class ListUserAssign {
    
    private var _id: String?
    private var _userId: String?
    private var _listId: String?
    
    public init(id: String, userId: String, listId: String) {
        _id = id
        _userId = userId
        _listId = listId
    }
    
    public var id: String {
        get {
            return _id!
        }
        set(id) {
            _id = id
        }
    }
    
    public var userId: String {
        get {
            return _userId!
        }
        set(userId) {
            _userId = userId
        }
    }
    
    public var listId: String {
        get {
            return _listId!
        }
        set(listId) {
            _listId = listId
        }
    }
}
