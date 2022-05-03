//
//  UsersVC.swift
//  Octagon
//
//  Created by sid on 6/27/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import Firebase

class UsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var accSettingsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var userCopy: [Users] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if(constantVal.allUsers[constantVal.currentUID]!.isOfficer!){
            accSettingsButton.isHidden = false
            
        } else{
            accSettingsButton.isHidden = true
        }
        tableView.delegate = self
        tableView.dataSource = self
        for (keyVal, userVal) in constantVal.allUsers{
            userCopy.append(userVal)
        }
        
    }
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCopy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        cell.set(user: userCopy[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(!constantVal.allUsers[constantVal.currentUID]!.isOfficer! || userCopy[indexPath.row].equals(other: constantVal.allUsers[constantVal.currentUID]!)){
            return nil
        }
        let promote = UITableViewRowAction(style: .default, title: "Make Officer") { (action, indexPath) in
            self.showAlert(title: "Make Officer", message: "Would you like to make \(self.userCopy[indexPath.row].name!) an officer?", index: indexPath.row)
        }
        
        promote.backgroundColor = constantVal.backgroundColor
        let delete = UITableViewRowAction(style: .default, title: "Remove User") { (action, indexPath) in
            self.showAlert(title: "Remove User", message: "Would you like to remove \(self.userCopy[indexPath.row].name!) from MVOctagon? Just remember that if you delete this user, the deletion information will be stored in the database.", index: indexPath.row)
        }
        
        delete.backgroundColor = UIColor.lightGray
        
        return [promote, delete]
        
    }
    
    func showAlert(title:String, message: String, index: Int){
        let ref = Database.database().reference()

        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "No!", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "Yes!", style: UIAlertAction.Style.default, handler: { _ in
            if(title == "Make Officer"){
                ref.child("Users").child(self.userCopy[index].uid!).updateChildValues(["isOfficer": "true"])
            } else{
                self.deleteUserFromDatabase(index: index)
//                SignUpVC.storedData.removeObject(forKey: "Password")
//                SignUpVC.storedData.removeObject(forKey: "Email")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteUserFromDatabase(index: Int){
        var reference: DocumentReference? = nil
        let db = Firestore.firestore()

        reference = db.collection("Deletions").addDocument(data: [
    
            "Removed": "\(userCopy[index].name!)",
            "Remover": "\(constantVal.allUsers[constantVal.currentUID]!.name!)",
            "Hours": "\(userCopy[index].hours!)",
            "Deletion Time": "\(Date().localizedDescription)"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                
                print("Document added with ID: \(reference!.documentID)")
            }
        }
        let myUser = userCopy[index]
        var ref: DatabaseReference! = Database.database().reference()

        for events in constantVal.allEvents{
            if(events.containsUser(with: myUser)){
                events.removeName(participantName: myUser)
                var dataDictionary: [String: Any] = [:]
                let length = events.allSignUps.count
                for n in 0...length{
                    print("THE N VALUE IS \(n)")
                    ref.child("Events").child(events.eventID).child("signUp\(n)").removeValue()
                    ref.child("Events").child(events.eventID).child("checkIn\(n)").removeValue()
                }
                for n in 0..<length{
                    ref.child("Events").child(events.eventID).updateChildValues(["signUp\(n)": events.allSignUps[n].uid])
                    ref.child("Events").child(events.eventID).updateChildValues(["checkIn\(n)": events.allCheckIns[n]])
                }
                ref.child("Events").child(events.eventID).updateChildValues(["current sign ups":length])
                
            }
        }
        ref.child("Users").child(myUser.uid!).removeValue()
        
        constantVal.allUsers.removeValue(forKey: myUser.uid!)
        for (keyVal, userVal) in constantVal.allUsers{
            userCopy.append(userVal)
        }
        tableView.reloadData()

        
    }
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
