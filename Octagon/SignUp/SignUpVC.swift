//
//  SignUpVC.swift
//  Octagon
//
//  Created by sid on 6/4/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var studentIdTF: UITextField!
    @IBOutlet weak var pswdTF: UITextField!
    @IBOutlet weak var gradYearTF: UITextField!
    
    @IBOutlet weak var AccessCodeTF: UITextField!
    @IBOutlet weak var createButton: DesignableButton!
    static let storedData = UserDefaults.standard
    //HomeVC.storedData.set(nameArray, forKey: "Name Array")

    var isValid = true
    var uEmail: String?
    var uPswd: String?
    var uID: String?
    var uName: String?
    var uGradYear: Int?
    var code = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //readJSON()
        let ref = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                //let values = Array(data.values)
                print(data)
                let value = data["Access Code"] as! Int
                print(value)
                self.code = value
            }
        }) { (error) in  print(error.localizedDescription) }
        pswdTF.isSecureTextEntry = true
        AccessCodeTF.keyboardType = .numberPad
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if(!pswdTF.isEditing && !gradYearTF.isEditing && !studentIdTF.isEditing && !AccessCodeTF.isEditing){
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    @IBAction func goBack(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        guard let emailField = emailTF.text else{
            isValid = false
            return
        }
        guard let nameField = nameTF.text else{
            isValid = false
            return
        }
        guard let pswdField = pswdTF.text else{
            isValid = false
            return
        }
        
        guard let idField = studentIdTF.text else{
            isValid = false
            return
        }
        guard let gradYear = gradYearTF.text else{
            isValid = false
            return
        }
        guard let accessCode = AccessCodeTF.text else{
            isValid = false
            return
        }
        if(isValid && pswdField.count>6 && Int(accessCode) == code && gradYear.count == 4){
            uPswd = pswdField
            uEmail = emailField
            uID = idField
            uName = nameField
            uGradYear = Int(gradYear)
            addUser{ (success) in
                if(success){
                    SignUpVC.storedData.set(self.uEmail, forKey: "Email")
                    SignUpVC.storedData.set(self.uPswd, forKey: "Password")
                    SignUpVC.storedData.set(self.uPswd, forKey: "Super Password")
                    let newvc = self.storyboard?.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
                    self.present(newvc, animated: true, completion: nil)
//                    let newvc = self.storyboard?.instantiateViewController(withIdentifier: "NewEVC") as! EventVC
//                    self.present(newvc, animated: true, completion: nil)
                } else{
                    self.createButton.animateError()
                    //showErrorAnimation()
                }
                
            }
        } else{
            createButton.animateError()
            //self.dismiss(animated: true, completion: nil)
        }
        

    }
    //func addUser(uEmail: String, uPswd: String, name: String, id: String){
    func addUser(success:@escaping (Bool) -> Void){
          if(uPswd!.count < 1){ success(false); return }
          let text = SHA1.hexString(from: uPswd!)
          print(text!)
          print("THIS IS THE HASH")
          var hash = String(text!.filter { !" \n\t\r".contains($0) })
          hash = hash.lowercased()

        
        Auth.auth().createUser(withEmail: uEmail!, password: hash) { (user, error) in
            if(error != nil){
                print(error)
                success(false)
                return
            }
            var ref: DatabaseReference! = Database.database().reference()
            var dataDictionary: [String: Any] = [:]
            dataDictionary["name"] = self.uName
            dataDictionary["email"] = self.uEmail
            dataDictionary["student ID"] = self.uID
            dataDictionary["isOfficer"] = "false"
            dataDictionary["uid"] = (user?.user.uid)!
            dataDictionary["hours"] = 0
            dataDictionary["Grad Year"] = self.uGradYear
            constantVal.currentUID = (user?.user.uid)!
            ref.child("Users").child((user?.user.uid)!).setValue(dataDictionary)
            success(true)
        }
        
    }
    
   
}
