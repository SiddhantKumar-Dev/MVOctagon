//
//  Users.swift
//  Octagon
//
//  Created by sid on 6/15/19.
//  Copyright © 2019 sid. All rights reserved.
//

import Foundation

class Users{
    var name: String?
    var email: String?
    var isOfficer: Bool?
    var studentID: String?
    var uid: String?
    var hours: Int!
    var gradYear: Int?
    

    
    init(name: String, email: String, isOfficer: String, sID: String, uid: String, gradYear: Int, hours: Int) {
        self.name = name
        self.email = email
        if(isOfficer == "false"){
            self.isOfficer = false
        } else{
            self.isOfficer = true
        }
        self.studentID = sID
        self.uid = uid
        self.gradYear = gradYear
        self.hours = hours
    }
    
    func equals(other: Users) -> Bool{
        if(other.email != self.email){ return false }
        if(other.name != self.name){ return false }
        if(other.uid != self.uid){ return false }
        return true
        
    }
    
    func addHours(hours: Int){
        self.hours += hours
    }
    
    func removeHours(hours: Int){
        self.hours -= hours
    }
    
}
