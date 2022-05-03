//
//  EventInfoVC.swift
//  Octagon
//
//  Created by sid on 5/30/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import TrueTime

protocol ResetUIDelegate {
    func resetUI()
}
class EventInfoVC: UIViewController, CLLocationManagerDelegate{

    
    @IBOutlet weak var deletionBtn: UIButton!
    @IBOutlet weak var copyEmailBtnConnection: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var checkInOutBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var eventInfo: UILabel!
    @IBOutlet weak var startEndLabel: UILabel!
    @IBOutlet weak var eventSummary: UILabel!
    @IBOutlet weak var signUpTV: UITableView!
    
    var timer = Timer()
    var signUp = true
    let myUser = constantVal.allUsers[constantVal.currentUID]
    var delegate: ResetUIDelegate!
    var userName: [String] = []
    var userEmail: [String] = []
    var userStatus: [String] = []
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1200 as CGFloat
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if(!myUser!.isOfficer!){
            self.deletionBtn.isHidden = true
        } else{
            self.deletionBtn.isHidden = false
        }
        if(EventVC.isSelectedHistory){
            distanceLabel.isHidden = true
            checkInOutBtn.isHidden = true
            signUpButton.isHidden = true

        }
        if(!myUser!.isOfficer!){
            copyEmailBtnConnection.isHidden = true
        }
        locationManager.requestWhenInUseAuthorization()
        checkInOutBtn.isHidden = true
        signUpTV.delegate = self
        signUpTV.dataSource = self
        let event2 = EventVC.selectedEvent!
        let initialLocation = event2.eventLocation!
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude)
        annotation.coordinate = centerCoordinate
        annotation.title = "Event Locale"
        mapView.addAnnotation(annotation)
        centerMapOnLocation(location: initialLocation)
        updateLabel()
        EventVC.timer.invalidate()
        var event = EventVC.selectedEvent
        signUpButton.setTitle("Sign Up", for: .normal)

        for user in event!.eventSignUps{
            if(user.equals(other: myUser!)){
                signUp = false
                signUpButton.setTitle("Drop Event", for: .normal)

            }
        }

        
        runTimer()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
   
    
    func checkInStatus(){
        if(EventVC.isSelectedHistory){
            return
            
        }
        print("WER ARE IN HERE")
        if(EventVC.selectedEvent!.hasSignedUp(user2: myUser!)){
            print("WER ARE IN HERE 3")
            if(EventVC.selectedEvent!.isOnMainSignUp(user2: myUser!)){
                print("WER ARE IN HERE2")
                checkInOutBtn.isHidden = false
                distanceLabel.isHidden = false

                if(EventVC.selectedEvent!.getCheckInStatus(user2: myUser!)){
                    self.checkInOutBtn.setTitle("Check Out", for: .normal)
                } else if(EventVC.selectedEvent!.getCheckOutStatus(user2: myUser!)){
                    self.checkInOutBtn.setTitle("-", for: .normal)
                    self.distanceLabel.text = "You are done with the event"
                } else{
                    self.checkInOutBtn.setTitle("Check In", for: .normal)
                }
            } else {
                checkInOutBtn.isHidden = true
                distanceLabel.isHidden = true
            }
        } else{
            checkInOutBtn.isHidden = true
            distanceLabel.isHidden = true

        }
        
    }
    
    @IBAction func deleteEvent(_ sender: Any){
        showAlert(title: "Event Deletion", message: "Do you really want to delete this event. Just remember that as you delete the event everyone who has signed up will lose their spot. Additionally your name will be added to the global log.")
        
    }
    
    func showAlert(title:String, message: String){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "No!", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "Yes!", style: UIAlertAction.Style.default, handler: { _ in
           self.deleteFromDB()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteFromDB(){
        let id = EventVC.selectedEvent!.eventID
        Database.database().reference().child("Events").child(id!).removeValue()
        for e in 0..<constantVal.allEvents.count{
            if(constantVal.allEvents[e].eventID! == id){
                constantVal.allEvents.remove(at: e)
                break
            }
        }
        
        var reference: DocumentReference? = nil
        let db = Firestore.firestore()
        
        reference = db.collection("EDeletions").addDocument(data: [
            
            "Removed": "\(EventVC.selectedEvent!.eventName!)",
            "Remover": "\(constantVal.allUsers[constantVal.currentUID]!.name!)",
            "Deletion Time": "\(Date().localizedDescription)"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                
                print("Document added with ID: \(reference!.documentID)")
            }
        }
        self.dismiss(animated: true, completion: {
            if(!EventVC.isSelectedHistory){ self.delegate.resetUI() }
        })
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        if(checkInOutBtn.isHidden){
            self.checkInStatus()
        }
        currentLocation = manager.location!
        let distanceInMeters = Int(currentLocation.distance(from: EventVC.selectedEvent!.eventLocation) )// result is in meters
        if(distanceInMeters <= 200){
            if(checkInOutBtn.titleLabel?.text == "Check In"){
                distanceLabel.text = "You can check in!"
            } else if(checkInOutBtn.titleLabel?.text == "Check Out"){
                distanceLabel.text = "You can check out!"
            } else{
                distanceLabel.text = "You are done with the event!"
            }
        } else if(distanceInMeters/1609 == 0){
            if(checkInOutBtn.titleLabel?.text == "Check In"){
                distanceLabel.text = "Check in point: \(distanceInMeters) m"
            } else{
                distanceLabel.text = "Check in point: \(distanceInMeters) m"
            }
        } else{
            if(checkInOutBtn.titleLabel?.text == "Check In"){
                distanceLabel.text = "Check out point: \(distanceInMeters/1600) mi"
            } else{
                distanceLabel.text = "Check out point: \(distanceInMeters/1600) mi"
            }
        }
       // print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func updateLabel(){
        let event = EventVC.selectedEvent!
        

        eventInfo.text = event.eventName
        startEndLabel.text = "\(event.start!) - \(event.end!) \n \(event.findSlotsLeft()) Remaining Slots"
        eventSummary.text = event.summary
        userName.removeAll()
        userEmail.removeAll()
        userStatus.removeAll()
        for user in event.eventSignUps{
            userName.append(user.name!)
            userEmail.append(user.email!)
            userStatus.append("Signed Up")
        }
        for user in event.eventWaitList{
            userName.append(user.name!)
            userEmail.append(user.email!)
            userStatus.append("Waitlisted")

        }
        signUpTV.reloadData()


    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        readFromDB{ (success) in
            if(success){
                print("I AM IN HERE BOII")
                self.checkInStatus()
                self.updateLabel()
            }
            
        }
    }
    
    func readFromDB(success:@escaping (Bool) -> Void){
        let ref = Database.database().reference()
        ref.child("Events").child(EventVC.selectedEvent!.eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let values = Array(data.values)
              //  constantVal.allEvents.removeAll()
               // print(values)
                
                let objects  = data
                //for objects in valueDict{
                    let title = objects["title"] as? String
                    let start = objects["start"] as? String
                    let end = objects["end"] as? String
                    let lat = objects["latitude"] as? CLLocationDegrees
                    let long = objects["longitude"] as? CLLocationDegrees
                    let summary = objects["summary"] as? String
                    let max = objects["max sign ups"] as? Int
                    let currentSU = objects["current sign ups"] as? Int
                    let eID = objects["eventID"] as! String
                    let hours = objects["hours"] as! Int
                    
                    let preString = "signUp"
                    let preStr = "checkIn"
                
                    let eLocation = CLLocation(latitude: lat!, longitude: long!)
                
                var a = Events.init(name: title!, start: start!, end: end!, length: end!, limit: max!, eventLocation: eLocation, eventSummary: summary!, uid: eID, hours: hours)
                    for n in 0..<currentSU!{
                        print("signUp\(n)")
                        var string = "signUp\(n)"
                        var code = objects[string] as! String
                        let use = constantVal.allUsers[code]
                        string = "checkIn\(n)"
                        code = objects[string] as! String
                        a.addNewSignUp(participantName: use!, CIStatus: code)
                       
                        
                        //let userCode: String = (objects["signUp\(n)"] as? String)!
                        //let user: Users = constantVal.allUsers[userCode]!
                        //a.addNewSignUp(participantName: user)
                    }
                for name in a.allSignUps{
                    print(name.name)
                }
                for val in a.allCheckIns{
                    print(val)
                }//print(a.allCheckIns)
                    
                    //                    for n in 0..<currentWL!{
                    //                        let string = "signUp\(n)"
                    //                        let code = objects[string] as! String
                    //                        let use = constantVal.allUsers[code]
                    //                        a.addNewSignUp(participantName: use!)
                    //                    }
                    
                    
                   // a.toString()
                    EventVC.selectedEvent = a
                if(!EventVC.isSelectedHistory){
                    for n in 0..<constantVal.allEvents.count{
                        if(constantVal.allEvents[n].eventName == a.eventName){
                            constantVal.allEvents.insert(a, at: n)
                            constantVal.allEvents.remove(at: n+1)
                            break
                        }
                    }
                    constantVal.allEvents.append(a)
                    constantVal.allEvents = constantVal.allEvents.sorted { $0.start < $1.start }
                } else{
                    for n in 0..<constantVal.allHistory.count{
                        if(constantVal.allHistory[n].eventName == a.eventName){
                            constantVal.allHistory.insert(a, at: n)
                            constantVal.allHistory.remove(at: n+1)
                            break
                        }
                    }
                   // constantVal.allHistory.append(a)
                    
                    constantVal.allHistory = constantVal.allHistory.sorted { $0.start < $1.start }
                }
                
                    
               // }
                success(true)
            }
        }) { (error) in  print(error.localizedDescription) }
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        var event = EventVC.selectedEvent

        if(signUp){
            var ref: DatabaseReference! = Database.database().reference()
            var dataDictionary: [String: Any] = [:]
            EventVC.selectedEvent?.addNewSignUp(participantName: constantVal.allUsers[constantVal.currentUID]!, CIStatus: "none")
            dataDictionary["current sign ups"] = (event?.allSignUps.count)!
            dataDictionary["signUp\((event?.allSignUps.count)!-1)"] = constantVal.currentUID
            dataDictionary["checkIn\((event?.allSignUps.count)!-1)"] = "none"
            ref.child("Events").child(event!.eventID).updateChildValues(dataDictionary)
            
        } else{
            event?.removeName(participantName: myUser!)
            var ref: DatabaseReference! = Database.database().reference()
            var dataDictionary: [String: Any] = [:]
            let length = event!.allSignUps.count
            for n in 0...length{
                print("THE N VALUE IS \(n)")
                ref.child("Events").child(event!.eventID).child("signUp\(n)").removeValue()
                ref.child("Events").child(event!.eventID).child("checkIn\(n)").removeValue()
            }
            for n in 0..<length{
                ref.child("Events").child(event!.eventID).updateChildValues(["signUp\(n)": event!.allSignUps[n].uid])
                ref.child("Events").child(event!.eventID).updateChildValues(["checkIn\(n)": event!.allCheckIns[n]])
            }
            ref.child("Events").child(event!.eventID).updateChildValues(["current sign ups":length])
           

        }
        signUp = !signUp
        if(signUp){
            signUpButton.setTitle("Sign Up", for: .normal)
        } else{
            signUpButton.setTitle("Drop event", for: .normal)

        }
        
        
    }
    
   
    @IBAction func copyAllEmailsBtn(_ sender: Any) {
        UIPasteboard.general.string = getAllEmails()
        showSimpleAlert()
        
    }
    
    func showSimpleAlert() {
        let alert = UIAlertController(title: "Success!", message: "A list of all the participants' emails has been copied to your clipboard", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.timer.invalidate()
        self.dismiss(animated: true, completion: {
            if(!EventVC.isSelectedHistory){ self.delegate.resetUI() }
        })
    }
    
    @IBAction func usrCheckInOut(_ sender: Any) {
        let client = TrueTimeClient.sharedInstance
        var now1 = client.referenceTime?.now()
        if(now1 == nil){
            now1 = Date()
        }
        var now = now1!.localizedDescription
        let now2 = "\(now1!.convertedDate)"
        print("\(now) THIS IS THE TIME RN")
        print("\(now2) THIS IS THE TIME RN2")
        print("\(getTrueTime(str: now2)) THIS IS THE TRUE TIME RN")
        var strArr = Array(now).map{String($0)}

        var startIndex = 0
        
        for index in 0..<now.count-2{
            if("\(strArr[index])\(strArr[index+1])\(strArr[index+2])" == "at "){
                startIndex = index+3
                break
            }
        }
        var stringVal2 = ""
        
        for index in 0..<now.count{
            if(index >= startIndex && index <= startIndex+7){
                stringVal2 += "\(strArr[index])"
            }
        }
        
        print("\(stringVal2) THIS IS THE SECOND ITERATION OF STRING VALUE")
        var strArr2 = Array(stringVal2).map{String($0)}
        var newString1 = ""
        var newString2 = ""
        
        var isDoubleDigits = false
        for index in 0..<stringVal2.count{
            if("\(strArr2[index])" == ":"){
                if(index == 2){
                    isDoubleDigits = true
                } else if(index == 1){
                    isDoubleDigits = false
                }
            }
        }
        
        if(isDoubleDigits){
            newString1 = "\(strArr2[0])\(strArr2[1])"
            newString2 = "\(strArr2[3])\(strArr2[4])"
        } else{
            newString1 = "\(strArr2[0])"
            newString2 = "\(strArr2[2])\(strArr2[3])"
        }

        var intArr: [Int] = [Int]()
       

        print("STRING ONE \(newString1)")
        print("STRING ONE \(newString2)")
        
        if(now.contains("PM")){
            print(newString1)
            intArr.append(Int(newString1.trimmingCharacters(in: .whitespacesAndNewlines))! + 12)
            intArr.append(Int(newString2.trimmingCharacters(in: .whitespacesAndNewlines))!)
        } else {
            intArr.append(Int(newString1.trimmingCharacters(in: .whitespacesAndNewlines))!)
            intArr.append(Int(newString2.trimmingCharacters(in: .whitespacesAndNewlines))!)
        }
        
        let numMins = intArr[0] * 60 + intArr[1]
        
        
        print("THIS IS THE TRUE TIME")
        let date = Date()
        let calendar = Calendar.current
        var hours = calendar.component(.hour, from: date)
        var minutes = calendar.component(.minute, from: date)
        hours = 9
        minutes = 02
        let totalmins = hours*60 + minutes
        
        let distanceInMeters = currentLocation.distance(from: EventVC.selectedEvent!.eventLocation) // result is in meters
        if(distanceInMeters <= 200){
            if(checkInOutBtn.titleLabel?.text == "Check In"){
                let arr = EventVC.selectedEvent!.getTime(start: true)
                if(isLoginAble(array: arr, totalmins: numMins) && getTrueTime(str: now2) == EventVC.selectedEvent!.getStartDate()){
                    //print("LOGGING IN WORKSSSSS")
                    EventVC.selectedEvent?.addNewCheckIn(user2: myUser!)
                    let ref = Database.database().reference()
                    let number = EventVC.selectedEvent!.getLocationNumber(user2: myUser!)
                    ref.child("Events").child(EventVC.selectedEvent!.eventID).updateChildValues(["checkIn\(number)": "CI"])
                    
                    checkInOutBtn.setTitle("Check Out", for: .normal)
                    signUpTV.reloadData()
                } else{
                    checkInOutBtn.animateError()

                }
                
            } else{
                let arr = EventVC.selectedEvent!.getTime(start: false)
                if(isLoginAble(array: arr, totalmins: numMins) && getTrueTime(str: now2) == EventVC.selectedEvent!.getEndDate()){
                    EventVC.selectedEvent?.addNewCheckOut(user2: myUser!)
                    constantVal.allUsers[constantVal.currentUID] = myUser!
                    let ref1 = Database.database().reference()
                    let number2 = EventVC.selectedEvent!.hours + constantVal.allUsers[constantVal.currentUID]!.hours
                    ref1.child("Users").child(constantVal.currentUID).updateChildValues(["hours": number2])
                    print(myUser!.hours)
                    print("THESE ARE THE HOURS")
                    let ref = Database.database().reference()
                    let number = EventVC.selectedEvent!.getLocationNumber(user2: myUser!)
                    ref.child("Events").child(EventVC.selectedEvent!.eventID).updateChildValues(["checkIn\(number)": "CO"])
                    checkInOutBtn.setTitle("-", for: .normal)
                    checkInOutBtn.isEnabled = true
                    
                    signUpTV.reloadData()
                } else{
                    print(isLoginAble(array: arr, totalmins: totalmins))
                    print(getTrueTime(str: now2) == EventVC.selectedEvent!.getEndDate())
                    print(" YOu Can't log out! :(")
                    checkInOutBtn.animateError()

                }
               
            }
        } else{
            print("UH OH YOU ARE TOO FAR")
            checkInOutBtn.animateError()

        }

        
    }
    
    func getAllEmails() -> String{
        var allStrings = ""
        for user in EventVC.selectedEvent!.allSignUps{
            allStrings += "\(user.email!), "
        }
        return allStrings
    }
    
    func isLoginAble(array: [Int], totalmins: Int) -> Bool{
        var mins1 = array[1] - 30
        var mins2 = array[1] + 20
        var hours1 = array[0]
        var hours2 = array[0]
        if(mins1 < 0){ mins1 = 60 + mins1; hours1 -= 1 }
        if(mins2 > 60){ mins2 = mins2 - 60; hours2 += 1 }
        let totalmins1 = 60*hours1 + mins1
        let totalmins2 = 60*hours2 + mins2
        print(totalmins1)
        print(totalmins2)
        print(totalmins)
        if(totalmins <= totalmins2 && totalmins >= totalmins1){
            return true
        }
        return false
    }
    
    func getTrueTime(str: String) -> String{
        var string = ""
        var strArr = Array(str).map{String($0)}
        print(strArr)
        
        for n in 0..<10{
            string += strArr[n]
        }
        print("THISIS THE VALUE OF THE DSNG STKLJD:LFKJS:LDKJDLK \(string)")

        return string
    }
    func showErrorAnimation(){
        UIView.animate(withDuration: 0.1, animations: {
            var transforms = CGAffineTransform.identity
            transforms = transforms.translatedBy(x: 15, y: 0)
            self.signUpButton.transform = transforms
        })
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            var transforms = CGAffineTransform.identity
            transforms = transforms.translatedBy(x: -15, y: 0)
            self.signUpButton.transform = transforms
        }, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveLinear, animations: {
            let transforms = CGAffineTransform.identity
            self.signUpButton.transform = transforms
        }, completion: nil)
    }
    

}

extension EventInfoVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let event = EventVC.selectedEvent!
        let cell = tableView.dequeueReusableCell(withIdentifier: "signUpInfoCell") as! UITableViewCell
        
//        if(EventVC.selectedEvent!.getCheckInStatus(user2: myUser!)){
//            cell.backgroundColor = .green
//        }
//        else{
//            cell.backgroundColor = .white
//        }
//        if(EventVC.selectedEvent!.getCheckOutStatus(user2: myUser!)){
//            cell.backgroundColor = .blue
//        }
        
        if(event.checkIns.count > indexPath.row && event.checkIns[indexPath.row] == "CI"){
            cell.backgroundColor = .green
        } else if(event.checkIns.count > indexPath.row && event.checkIns[indexPath.row] == "CO") {
            cell.backgroundColor = constantVal.backgroundColor
        }else{
            cell.backgroundColor = .gray
        }
        
        if(myUser!.isOfficer!){
            cell.textLabel!.text = "\(userName[indexPath.row]) - \(userStatus[indexPath.row])"
            cell.detailTextLabel!.text = "\(userEmail[indexPath.row])"
        } else{
            cell.textLabel!.text = "\(userName[indexPath.row])"
            cell.detailTextLabel!.text = "\(userStatus[indexPath.row])"
        }
        return cell
    }
    
    
}


