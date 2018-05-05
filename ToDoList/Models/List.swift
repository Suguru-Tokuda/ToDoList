//
//  List.swift
//  List
//
//  Created by Suguru on 4/26/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import Foundation

public class List {
    
    private var _id: String?
    private var _title: String?
    private var _isArchived: Bool?
    
    public init(id: String, title: String, isArchived: Bool) {
        _id = id
        _title = title
        _isArchived = isArchived
    }
    
    public var id: String {
        get {
            return _id!
        }
        set(id) {
            _id = id
        }
    }
    
    public var title: String {
        get {
            return _title!
        }
        set(title) {
            _title = title
        }
    }
    
    public var isArchived: Bool {
        get {
            return _isArchived!
        }
        set(isArchived) {
            _isArchived = isArchived
        }
    }
    
}
