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
    private var _accepted: Bool?
    
    public init(id: String, userId: String, listId: String, accepted: Bool) {
        _id = id
        _userId = userId
        _listId = listId
        _accepted = accepted
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
    
    public var accepted: Bool {
        get {
            return _accepted!
        }
        set(accepted) {
            _accepted = accepted
        }
    }
}
