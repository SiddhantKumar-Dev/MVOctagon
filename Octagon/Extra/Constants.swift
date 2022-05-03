//
//  Constants.swift
//  Octagon
//
//  Created by sid on 5/26/19.
//  Copyright © 2019 sid. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth


struct constantVal{
    //static var allUsers:[Users] = []
    static var allEvents: [Events] = []
    static var allHistory: [Events] = []
    static var allUsers = [String: Users]()
    static var currentUID: String = ""
    static var wasAbleToAuth = true
    static var backgroundColor = UIColor(red: 32/255, green: 127/255, blue: 198/255, alpha: 1.0)
    
   
    
    
    
    
    static func addUser(uEmail: String, uPswd: String, name: String, id: String){
        Auth.auth().createUser(withEmail: uEmail, password: uPswd) { (user, error) in
            if(error != nil){
                print(error)
                return
            }
            var ref: DatabaseReference! = Database.database().reference()
            var dataDictionary: [String: Any] = [:]
            dataDictionary["name"] = name
            dataDictionary["email"] = uEmail
            dataDictionary["student ID"] = id
            dataDictionary["isOfficer"] = false
            constantVal.currentUID = (user?.user.uid)!
            ref.child("Users").child((user?.user.uid)!).setValue(dataDictionary)
        }
        
    }
}
