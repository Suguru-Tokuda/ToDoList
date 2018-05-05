//
//  User.swift
//  List
//
//  Created by Suguru on 4/26/18.
//  Copyright © 2018 stokuda. All rights reserved.
//

import Foundation

public class User {
    
    private var _id: String?
    private var _firstName: String?
    private var _lastName: String?
    private var _email: String?
    private var _password: String?
    
    public init(id: String, firstName: String, lastName: String, email: String, password: String) {
        self._id = id
        self._firstName = firstName
        self._lastName = lastName
        self._password = password
    }
    
    public var id: String {
        get {
            return _id!
        }
        set(id) {
            self._id = id
        }
    }
    
    public var firstName: String {
        get {
            return _firstName!
        }
        set(firstName) {
            self._firstName = firstName
        }
    }
    
    public var lastName: String {
        get {
            return _lastName!
        }
        set(id) {
            self._lastName = lastName
        }
    }
    
    public var email: String {
        get {
            return _email!
        }
        set(email) {
            self._email = email
        }
    }
    
    public var password: String {
        get {
            return _password!
        }
        set(id) {
            self._password = password
        }
    }
    
}
