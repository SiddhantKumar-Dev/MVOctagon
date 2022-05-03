//
//  EventVC.swift
//  Octagon
//
//  Created by sid on 5/18/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import TrueTime
class EventVC: UIViewController, newEventDelegate, ResetUIDelegate {
   

    @IBOutlet weak var eventTV: UITableView!
    var eventNames: [Events] = [] //these are all the events
    var historyEvents: [Events] = [] //these are the events that I took part in
    var todayEvent: [Events] = [] //these are the events that I signed up for
    var currentMode = 0;
    var userAble = false
    static var selectedEvent: Events?
    static var timer = Timer()
    static var selectedNumber = -1
    static var isSelectedHistory = false
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var newEventButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        //self.newEventButton.isHidden = true
        self.eventTV.delegate = self
        self.eventTV.dataSource = self
        setUpView()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        eventTV.addSubview(refreshControl)
        readFromDB{ (success) in
            if(success){
                var isOfficer = false
                if(constantVal.allUsers[constantVal.currentUID]!.isOfficer!){
                    isOfficer = true
                }
                if(isOfficer){
                    self.newEventButton.isHidden = false
                } else{
                    self.newEventButton.isHidden = true
                }
                self.todayEvent.removeAll()
                for event in constantVal.allEvents{
                    self.todayEvent.append(event)
                }
//                self.todayEvent.append("YMCA")
//                self.historyEvents.append("Hack MV")
//                self.historyEvents.append("DV Hacks")
//                self.eventNames.append("SV Hacks")
//                self.eventNames.append("Fall Festival")
//                self.eventNames.append("Movie Night")
//                self.eventNames.append("Homecoming")
                self.eventTV.reloadData()
               
            }
        }
        //runTimer()
        // Do any additional setup after loading the view.
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Weather Data
        fetchData()
    }
    
    func fetchData(){
        readFromDB{ (success) in
            if(success){
                self.todayEvent.removeAll()
                for event in constantVal.allEvents{
                    self.todayEvent.append(event)
                }
                self.eventTV.reloadData()
                self.refreshControl.endRefreshing()
                
            }
            
        }
    }
    
    @IBAction func goback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func setUpView(){
        print("in here")
        navigationController?.navigationBar.prefersLargeTitles = true
//        let searchController = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        navigationController?.navigationBar.barStyle = .black
        
        // If you want it to be persistent use this
        // navigationItem.hidesSearchBarWhenScrolling = false
        // If you want to not have large titles on more detailed pages use this line of code in viewDidLoad
        // navigationItem.largeTitleDisplayMode = .never
    }
    func runTimer() {
        print("hello finna here")
        EventVC.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        print("hello finna here")
        readFromDB{ (success) in
            if(success){
                self.todayEvent.removeAll()
                for event in constantVal.allEvents{
                    self.todayEvent.append(event)
                }
                self.eventTV.reloadData()
            }
            
        }
    }
    
    @IBAction func changeEvent(_ sender: DesignableButton) {
        currentMode = sender.tag
        eventTV.reloadData()
    }
    
    func resetUI() {
       // runTimer()
        readFromDB{ (success) in
            if(success){
                self.todayEvent.removeAll()
                for event in constantVal.allEvents{
                    self.todayEvent.append(event)
                }
                self.eventTV.reloadData()
            }
            
        }
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        let newvc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.present(newvc, animated: true, completion: nil)
    }
    
    @IBAction func addNewEvent(_ sender: Any) {
        let newvc = self.storyboard?.instantiateViewController(withIdentifier: "NewEventVC") as! NewEventVC
        newvc.delegate = self
        self.present(newvc, animated: true, completion: nil)
        
    }
    
    
    func readFromDB(success:@escaping (Bool) -> Void){
        let ref = Database.database().reference()
        ref.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let values = Array(data.values)
                
               print(values)
                
                let valueDict  = values as! [[String: Any]]
                for objects in valueDict{
                    let name = objects["name"] as! String
                    let email = objects["email"] as! String
                    let officerStatus = objects["isOfficer"] as! String
                    let UID = objects["uid"] as! String
                    let SID = objects["student ID"] as! String
                    let gradYear = objects["Grad Year"] as! Int
                    let hours = objects["hours"] as! Int

                    let curUser = Users.init(name: name, email: email, isOfficer: officerStatus, sID: SID, uid: UID, gradYear: gradYear, hours: hours)
                    constantVal.allUsers[UID] = curUser
                    print("in here")
                    self.userAble = true
                }
                //success(true)
                print("WE ARE IN HERE")
                self.userAble = true
            }
        }) { (error) in  print(error.localizedDescription) }
        
        ref.child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let values = Array(data.values)
                constantVal.allEvents.removeAll()
                constantVal.allHistory.removeAll()
                print(values)
                
                let valueDict  = values as! [[String: Any]]
                for objects in valueDict{
                    let title = objects["title"] as? String
                    let start = objects["start"] as? String
                    let end = objects["end"] as? String
                    let lat = objects["latitude"] as? CLLocationDegrees
                    let long = objects["longitude"] as? CLLocationDegrees
                    let summary = objects["summary"] as? String
                    let max = objects["max sign ups"] as? Int
                    let currentSU = objects["current sign ups"] as? Int
                    let eID = objects["eventID"] as! String
                    let hours = objects["hours"] as? Int

                    let preString = "signUp"
//                    print(title!)
//                    print(start!)
//                    print(end!)
//                    print(location!)
//                    print(summary!)
//                    print(currentSU!)
//                    print(currentWL!)
//                    print(max!)
                    
                    let eLocation = CLLocation(latitude: lat!, longitude: long!)

                    var a = Events.init(name: title!, start: start!, end: end!, length: end!, limit: max!, eventLocation: eLocation, eventSummary: summary!, uid: eID, hours: hours!)
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
                    
//                    for n in 0..<currentWL!{
//                        let string = "signUp\(n)"
//                        let code = objects[string] as! String
//                        let use = constantVal.allUsers[code]
//                        a.addNewSignUp(participantName: use!)
//                    }
                    
                    
                    a.toString()
                    let client = TrueTimeClient.sharedInstance
                    var now1 = client.referenceTime?.now()
                    if(now1 == nil){
                        now1 = Date()
                    }
                    let now2 = "\(now1!.convertedDate)"
                    if(self.getTrueTime(str: now2) > a.getEndDate()){
                        constantVal.allHistory.append(a)
                    } else{
                        constantVal.allEvents.append(a)
                    }
                    constantVal.allEvents = constantVal.allEvents.sorted { $0.start < $1.start }
                    print("THIS IS THE LENGTH OF THE THINGGY \(constantVal.allHistory.count)")

                }
                success(true)
                
            }
        }) { (error) in  print(error.localizedDescription) }
        if(userAble){
            success(true)
        }
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
    
    func createEvent(title: String, start: String, end: String, location: CLLocation, summary: String, maxSUs: String, hours: Int) {
       
      
        var ref: DatabaseReference! = Database.database().reference()
        let userId = NSUUID().uuidString
        var dataDictionary: [String: Any] = [:]
        dataDictionary["title"] = title
        dataDictionary["start"] = start
        dataDictionary["end"] = end
        dataDictionary["latitude"] = location.coordinate.latitude
        dataDictionary["longitude"] = location.coordinate.longitude
        dataDictionary["summary"] = summary
        dataDictionary["max sign ups"] = Int(maxSUs)
        dataDictionary["current sign ups"] = 0
        dataDictionary["eventID"] = userId
        dataDictionary["hours"] = hours
        ref.child("Events").child(userId).setValue(dataDictionary)
        
    }
    
    
}

extension EventVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(currentMode == 0){
            return todayEvent.count
        } else if(currentMode == 1){
            return eventNames.count
        } else{
            return historyEvents.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        var event: Events?
        
        //if(currentMode == 0){
            event = todayEvent[indexPath.row]
        //else if(currentMode == 1){ event = eventNames[indexPath.row].eventName! }
        //else{ event = historyEvents[indexPath.row].eventName! }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! EventCell
        cell.set(eventValue: event!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        EventVC.isSelectedHistory = false
        EventVC.selectedEvent = todayEvent[indexPath.row]
        readFromDB{ (success) in
            if(success){
                print("THIS WORKED PERFECTLYU")
                tableView.reloadData()
                print(EventVC.selectedEvent!.eventID)
                for e in constantVal.allEvents{
                    print(e.eventName)
                    print(e.eventID)
                }
                EventVC.selectedEvent = self.getEventWithId(id: EventVC.selectedEvent!.eventID)
                var ref: DatabaseReference! = Database.database().reference()
                ref.child("Users").child(constantVal.allUsers[constantVal.currentUID]!.uid!).updateChildValues(["currentEvent":EventVC.selectedEvent!.eventID])
                
                let newvc = self.storyboard?.instantiateViewController(withIdentifier: "EventInfoVC") as! EventInfoVC
                newvc.delegate = self
                self.present(newvc, animated: true, completion: nil)
                
                
            } else{
                print("IT DIDNt work")
            }
            
        }
       
        
    }
    func getEventWithId(id: String) -> Events{
        for e in constantVal.allEvents{
            if(e.eventID == id){
                return e
            }
        }
        return constantVal.allEvents[0]
    }

}

