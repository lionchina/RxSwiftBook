//
//  User.swift
//  RxTableViewWithEdit
//
//  Created by MaxChen on 05/08/2017.
//  Copyright © 2017 com.linglustudio. All rights reserved.
//

struct UserModel: CustomDebugStringConvertible {
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    var debugDescription: String {
        return firstName + " " + lastName
    }
}
