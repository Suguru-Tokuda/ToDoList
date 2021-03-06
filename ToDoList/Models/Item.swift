//
//  ToDoItem.swift
//  List
//
//  Created by Suguru on 4/26/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import Foundation

public struct Item {
    
    private var _id: String?
    private var _userId: String?
    private var _itemDescription: String?
    private var _isImportant: Bool?
    private var _isComplete: Bool?
    
    public init(id: String, userId: String, itemDescription: String, isImportant: Bool, isComplete: Bool) {
        self._id = id
        self._userId = userId
        self._itemDescription = itemDescription
        self._isImportant = isImportant
        self._isComplete = isComplete
    }
    
    public var id: String {
        get {
            return _id!
        }
        set(id) {
            self._id = id
        }
    }
    
    public var userId: String {
        get {
            return _userId!
        }
        set(userId) {
            self._userId = userId
        }
    }
    
    public var itemDescription: String {
        get {
            return _itemDescription!
        }
        set(description) {
            self._itemDescription = description
        }
    }
    
    public var isImportant: Bool {
        get {
            return _isImportant!
        }
        set(isImportant) {
            self._isImportant = isImportant
        }
    }
    
    public var isComplete: Bool {
        get {
            return _isComplete!
        }
        set(isComplete) {
            self._isComplete = isComplete
        }
    }
    
}
