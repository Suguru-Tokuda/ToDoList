//
//  ItemListAssign.swift
//  List
//
//  Created by Suguru on 5/5/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import Foundation

public class ItemListAssign {
    
    private var _id: String?
    private var _itemId: String?
    private var _listId: String?
    
    public init(id: String, itemId: String, listId: String) {
        _id = id
        _itemId = itemId
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
    
    public var itemId: String {
        get {
            return _itemId!
        }
        set(itemId) {
            _itemId = itemId
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
