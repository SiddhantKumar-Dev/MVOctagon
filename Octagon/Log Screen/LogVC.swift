//
//  LogVC.swift
//  Octagon
//
//  Created by sid on 7/25/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import Firebase
class LogVC: UIViewController {
    let db = Firestore.firestore()
    let ref = Database.database().reference()
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var logTV: UITextView!
    @IBOutlet weak var enablerSwitch: UISwitch!
    @IBOutlet weak var BACKorSAVE: UIButton!
    var code = 0
    var isEnabled = true
    
    var textViewString = "There is nothing to log"
    override func viewDidLoad() {
        super.viewDidLoad()
        readFromDB{ (success) in
            if(success){
                if(self.code == -1){
                    self.codeLabel.text = "Sign ups are not allowed"
                    self.code = 123456
                    self.enablerSwitch.isOn = false
                    self.isEnabled = false
                } else{
                    self.codeLabel.text = "User sign up code - \(self.code)"
                    self.enablerSwitch.isOn = true
                }
                self.logTV.text = self.textViewString
            }
            
        }
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func readFromDB(success:@escaping (Bool) -> Void){
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                //let values = Array(data.values)
                print(data)
                let value = data["Access Code"] as! Int
                print(value)
                self.code = value
            }
        }) { (error) in  print(error.localizedDescription) }
        
        db.collection("Deletions").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if(self.textViewString == "There is nothing to log"){
                        self.textViewString = ""
                    }
                    print("\(document.documentID) => \(document.data())")
                    self.textViewString += "\(self.extractData(value: document.data(), isEvent: false)) \n\n"
                    
                }
                success(true)
            }
        }
        
        db.collection("EDeletions").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if(self.textViewString == "There is nothing to log"){
                        self.textViewString = ""
                    }
                    print("\(document.documentID) => \(document.data())")
                    self.textViewString += "\(self.extractData(value: document.data(), isEvent: true)) \n\n"
                    
                }
                success(true)
            }
        }

    }
    
    @IBAction func saveButton(_ sender: Any) {
            if(!isEnabled){
                code = -1
            }
            ref.updateChildValues(["Access Code": code])
        
        self.dismiss(animated: true, completion: nil)

    }
    
    func extractData(value: [String: Any], isEvent: Bool) -> String{
        var string = ""
        if(!isEvent){
            string += "~~~Deletion~~~\n"
            string += "Deleter: \(value["Remover"]!)\n"
            string += "User Deleted: \(value["Removed"]!)\n"
            string += "User Hours: \(value["Hours"]!)\n"
        } else {
            string += "~~Event Deletion~~\n"
            string += "Deleter: \(value["Remover"]!)\n"
            string += "Event Deleted: \(value["Removed"]!)\n"

        }
        string += "Deletion Time: \(value["Deletion Time"]!)\n"
        string += "~~~~~~~~~~~~~~\n\n\n"

        return string
        
    }
    
    @IBAction func regenerateCode(_ sender: Any) {

        if(!isEnabled){ return }
        let random = Int.random(in: 100000...999999)
        self.code = random
        self.codeLabel.text = "Sign Up Code: \(code)"
        
    }
    
    @IBAction func executeSwitch(_ sender: UISwitch) {

        if(sender.isOn){
            isEnabled = true
            print("THIS  IS THE CODE \(code)")
            codeLabel.text = "Sign Up Code: \(code)"
        } else{
            isEnabled = false
            codeLabel.text = "Sign ups are not allowed"
        }
    }
    
    
}
