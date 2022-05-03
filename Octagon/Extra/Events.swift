//
//  Events.swift
//  Octagon
//
//  Created by sid on 5/26/19.
//  Copyright © 2019 sid. All rights reserved.
//

import Foundation
import MapKit

import UIKit
public class Events{
    var eventName: String!
    var start: String!
    var end: String!
    var eventLength: String!
    var eventSignUps: [Users]!
    var eventWaitList: [Users]!
    var allSignUps: [Users]!
    var checkIns: [String]!
    var allCheckIns: [String]!
    var maxSignUps: Int!
    var eventLocation: CLLocation!
    var summary:String!
    var eventID: String!
    var isCompleted: Bool!
    var hours: Int!
    
    
    init(name: String, start: String, end: String, length: String, limit: Int, eventLocation: CLLocation, eventSummary: String, uid: String, hours: Int) {
        eventName = name
        self.start = start
        self.end = end
        eventLength = length
        maxSignUps = limit
        self.eventLocation = eventLocation
        self.summary = eventSummary
        self.eventID = uid
        eventSignUps = [Users]()
        eventWaitList = [Users]()
        allSignUps = [Users]()
        checkIns = [String]()
        allCheckIns = [String]()
        self.hours = hours
        self.isCompleted = false
        
//        for n in 0..<limit{
//            checkIns.append("none")
//            allCheckIns.append("none")
//        }
        
    }
    
    func addNewSignUp(participantName:Users, CIStatus: String){
        if(eventSignUps.count >= maxSignUps){
            eventWaitList!.append(participantName)
        } else{
            eventSignUps!.append(participantName)
            checkIns.append(CIStatus)
        }
        allSignUps.append(participantName)
        allCheckIns.append(CIStatus)
    }
    
    func addNewCheckIn(user2: Users){
        for n in 0..<eventSignUps.count{
            if(eventSignUps[n].equals(other: user2)){
                checkIns[n] = "CI"
                allCheckIns[n] = "CI"
                break
            }
        }
    }
    
    func getLocationNumber(user2: Users) -> Int{
        for n in 0..<eventSignUps.count{
            if(eventSignUps[n].equals(other: user2)){
                return n
            }
        }
        return -1
    }
//
    func addNewCheckOut(user2: Users){
        for n in 0..<eventSignUps.count{
            if(eventSignUps[n].equals(other: user2)){
                checkIns[n] = "CO"
                allCheckIns[n] = "CI"
                break
            }
        }
    }
    
    func getCheckInStatus(user2: Users)->Bool{
        for n in 0..<eventSignUps.count{
            if(eventSignUps[n].equals(other: user2)){
                return checkIns[n] == "CI"
            }
        }
        return false
    }
    
    func getCheckOutStatus(user2: Users)->Bool{
        for n in 0..<eventSignUps.count{
            if(eventSignUps[n].equals(other: user2)){
                return checkIns[n] == "CO"
            }
        }
        return false
    }
    
    
    func removeName(participantName: Users){
        for n in 0..<allSignUps.count{
            if(allSignUps[n].equals(other: participantName)){
                allSignUps.remove(at: n)
                allCheckIns.remove(at: n)
                break
            }
        }
        eventSignUps.removeAll()
        eventWaitList.removeAll()
        checkIns.removeAll()
        if(maxSignUps < allSignUps.count){
            for n in 0..<maxSignUps{
                eventSignUps.append(allSignUps[n])
                checkIns.append(allCheckIns[n])
            }
            for n in maxSignUps..<allSignUps.count{
                eventWaitList.append(allSignUps[n])
            }
        }
        if(maxSignUps > allSignUps.count){
            for n in 0..<allSignUps.count{
                eventSignUps.append(allSignUps[n])
                checkIns.append(allCheckIns[n])
            }
        }
    }
    
    func hasSignedUp(user2: Users) -> Bool{
        for user in eventSignUps{
            if(user.equals(other: user2)){
                return true
            }
        }
        for user in eventWaitList{
            if(user.equals(other: user2)){
                return true
            }
        }
        return false
    }
    
    func isOnMainSignUp(user2: Users) -> Bool{
        for user in eventSignUps{
            if(user.equals(other: user2)){
                return true
            }
        }
        return false
    }
    
    func toString(){
        print( "\(eventName)~\(start)~\(end)~\(maxSignUps)~\(summary)~\(eventLocation)")
        for user in eventSignUps{
            print(user.name)
        }
        
    }
    
    func changeIsComplete(){
        isCompleted = !isCompleted
    }
    
    func findSlotsLeft() -> Int{
        var left = maxSignUps! - allSignUps!.count
        if(left<0){
            return 0
        }
        return left
    }
    
    func getTime(start: Bool) -> [Int]{
        var intArr: [Int] = [Int]()
        if(start){
            var strArr = Array(self.start).map{String($0)}
            var newString1 = ""
            var newString2 = ""
            var z = 15
            if(strArr[15] == ":"){
                z = 14
            }
            for n in 0..<strArr.count{
                if(n == z || n == 14){
                    newString1 += "\(strArr[n])"
                } else{
                    if(z == 15){
                        if(n==17 || n == 18){
                            newString2 += "\(strArr[n])"
                        }
                    } else{
                        if(n == 16 || n == 17){
                            newString2 += "\(strArr[n])"
                        }
                    }
                }
                
            }
            print("STRING ONE \(newString1)")
            print("STRING ONE \(newString2)")
            if(self.start.contains("PM")){
                intArr.append(Int(newString1.trimmingCharacters(in: .whitespacesAndNewlines))! + 12)
                intArr.append(Int(newString2.trimmingCharacters(in: .whitespacesAndNewlines))!)
            } else{
                intArr.append(Int(newString1.trimmingCharacters(in: .whitespacesAndNewlines))!)
                intArr.append(Int(newString2.trimmingCharacters(in: .whitespacesAndNewlines))!)
            }
            
        } else{
            var strArr = Array(self.end).map{String($0)}
            var newString1 = ""
            var newString2 = ""
            var z = 15
            if(strArr[15] == ":"){
                z = 14
            }
            for n in 0..<strArr.count{
                if(n == z || n == 14){
                    newString1 += "\(strArr[n])"
                } else{
                    if(z == 15){
                        if(n==17 || n == 18){
                            newString2 += "\(strArr[n])"
                        }
                    } else{
                        if(n == 16 || n == 17){
                            newString2 += "\(strArr[n])"
                        }
                    }
                }
                
            }
            print("STRING ONE \(newString1)")
            print("STRING ONE \(newString2)")
            
            print("STRING ONE \(newString1)")
            print("STRING ONE \(newString2)")
            if(self.end.contains("PM")){
                intArr.append(Int(newString1.trimmingCharacters(in: .whitespacesAndNewlines))! + 12)
                intArr.append(Int(newString2.trimmingCharacters(in: .whitespacesAndNewlines))!)
            } else{
                intArr.append(Int(newString1.trimmingCharacters(in: .whitespacesAndNewlines))!)
                intArr.append(Int(newString2.trimmingCharacters(in: .whitespacesAndNewlines))!)
            }
        }
        return intArr
    }
    
    func getStartDate() -> String{
        var str = ""
        var strArr = Array(self.start).map{String($0)}
        for n in 0..<10{
            str += strArr[n]
        }
        return str
    }
    
    func getEndDate() -> String{
        var str = ""
        var strArr = Array(self.end).map{String($0)}
        for n in 0..<10{
            str += strArr[n]
        }
        return str
    }
    
    func containsUser(with user: Users) -> Bool{
        for us in allSignUps{
            if(us.equals(other: user)){
                return true
            }
        }
        return false
    }
    
    
    
    
}



