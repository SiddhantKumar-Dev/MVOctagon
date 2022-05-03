//
//  ViewController.swift
//  Octagon
//
//  Created by sid on 3/12/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import Firebase
import TrueTime

/*
 1) Create a login/sign up page
 2) Create a table view with all the events
 3) Create a page where they will be able to check in for certain events
    the check in process will simply be a button that they press, and upon pressing the button, the app will take their current location, and see if it matches the location of the event by a certain error margin, and if it does it will, the app will return TRUE meaning that the user has logged in. Then when they need to leave, the user will check out, and the app will log the number of hours and send it to you
 4) Have a page with the number of hours they have completed
 
 
 
 
 */
class LoginVC: UIViewController {
 
    

    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var bgView: DesignableView!
    var uPswd: String?
    var uEmail: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTF.isSecureTextEntry = true
        let client = TrueTimeClient.sharedInstance
        client.start()
        self.bgView.isHidden = true
        self.view.backgroundColor = .white
        var e = SignUpVC.storedData.string(forKey: "Email")
        var p = SignUpVC.storedData.string(forKey: "Password")
        if let pass = p as? String{
            if let email = e as? String{
                
                self.uPswd = pass// + " "
                self.uEmail = email
                logInUser{ (success) in
                    if(success){
                        let newvc = self.storyboard?.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
                        self.present(newvc, animated: true, completion: {
                            self.bgView.isHidden = false
                            self.view.backgroundColor = constantVal.backgroundColor
                        })
//                        let newvc = self.storyboard?.instantiateViewController(withIdentifier: "NewEVC") as! EventVC
//                        self.present(newvc, animated: true, completion: {
//                            self.bgView.isHidden = false
//                            self.view.backgroundColor = constantVal.backgroundColor
//                        })
                    } else{
                        self.bgView.isHidden = false
                        print("we are in here")
                        self.view.backgroundColor = constantVal.backgroundColor

                        //self.showErrorAnimation()
                    }
                }
            } else{
                self.bgView.isHidden = false
                self.view.backgroundColor = constantVal.backgroundColor

            }
        } else{
            self.bgView.isHidden = false
            self.view.backgroundColor = constantVal.backgroundColor

        }
    }

    @IBAction func login(_ sender: Any) {
//        guard let password = passwordTF.text else{ return }
//        guard let email = userNameTF.text else { return }
        guard let Pswd = passwordTF.text else{
            showErrorAnimation()
            return
        }
        guard let Email = userNameTF.text else {
            showErrorAnimation()
            return
        }
        self.uPswd = Pswd
        self.uEmail = Email
        logInUser{ (success) in
            if(success){
                SignUpVC.storedData.set(self.uEmail, forKey: "Email")
                SignUpVC.storedData.set(self.uPswd, forKey: "Password")
                SignUpVC.storedData.set(self.uPswd, forKey: "Super Password")
                let newvc = self.storyboard?.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
                self.present(newvc, animated: true, completion: {
                    self.userNameTF.text = ""
                    self.passwordTF.text = ""
                })
//                let newvc = self.storyboard?.instantiateViewController(withIdentifier: "NewEVC") as! EventVC
//                self.present(newvc, animated: true, completion: nil)
            } else{
                self.showErrorAnimation()
            }
        }
//        if(constantVal.wasAbleToAuth){
//            let newvc = storyboard?.instantiateViewController(withIdentifier: "EventVC") as! EventVC
//            present(newvc, animated: true, completion: nil)
//        } else{
//            showErrorAnimation()
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        showSimpleAlert()
    }
    
    func showSimpleAlert() {
        var p = SignUpVC.storedData.string(forKey: "Super Password")
        if let pass = p as? String{
            let alert = UIAlertController(title: "Password", message: "Your password is \(p!)", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { _ in
                //Cancel Action
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Password", message: "We can't display your password, please sign up first",         preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { _ in
                //Cancel Action
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showErrorAnimation(){
        
        UIView.animate(withDuration: 0.1, animations: {
            var transforms = CGAffineTransform.identity
            transforms = transforms.translatedBy(x: 15, y: 0)
            self.loginButton.transform = transforms
        })
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            var transforms = CGAffineTransform.identity
            transforms = transforms.translatedBy(x: -15, y: 0)
            self.loginButton.transform = transforms
        }, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveLinear, animations: {
            let transforms = CGAffineTransform.identity
            self.loginButton.transform = transforms
        }, completion: nil)
    }

     func logInUser(success:@escaping (Bool) -> Void){
        if(uPswd!.count < 1){ success(false); return }
        let text = SHA1.hexString(from: uPswd!)
        print(text!)
        print("THIS IS THE HASH")
        var hash = String(text!.filter { !" \n\t\r".contains($0) })
        hash = hash.lowercased()
        Auth.auth().signIn(withEmail: uEmail!, password: hash) { (user, error) in
            if(error != nil){
                print(error)
                success(false)
                return
            } else{
                constantVal.currentUID = (user?.user.uid)!
                success(true)
            }
            
        }
        
    }
}

