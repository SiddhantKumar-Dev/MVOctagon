//
//  NewEventVC.swift
//  Octagon
//
//  Created by sid on 6/16/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol newEventDelegate{
    func createEvent(title: String, start: String, end: String, location: CLLocation, summary: String, maxSUs: String, hours: Int)
}

class NewEventVC: UIViewController {

    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet var recognizer: UITapGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var hoursTF: UITextField!
    @IBOutlet weak var eventTitle: UITextField! //first
    @IBOutlet weak var eventStartTime: UITextField! //first
    @IBOutlet weak var eventEndtime: UITextField! //first
    @IBOutlet weak var maxSUs: UITextField! //first
    @IBOutlet weak var eventSummary: UITextView! //second
    var eventLocation: CLLocationCoordinate2D? = nil
    var geocoder = CLGeocoder()

    private var datePicker: UIDatePicker?
    private var datePicker2: UIDatePicker?
    let screenWidth = UIScreen.main.bounds.width
    var currentAnimationMode = 0
    var delegate: newEventDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker2 = UIDatePicker()
        datePicker!.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        datePicker2!.addTarget(self, action: #selector(dateChanged2(datePicker:)), for: .valueChanged)
        eventStartTime.inputView = datePicker
        eventEndtime.inputView = datePicker2
        hideKeyboardWhenTappedAround()
        //var transforms4 = CGAffineTransform.identity
        //transforms4 = transforms4.translatedBy(x: screenWidth, y: 0)
        //eventStartTime.inputView = pickerView
        //eventEndtime.inputView = pickerView
       

        let center = CLLocationCoordinate2D(latitude: 37.34188267401152, longitude: -122.04636429880911 )
        var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        region.center = center
        
        mapView.setRegion(region, animated: true)
        // Do any additional setup after loading the view.
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        DateFormatter.dateFormat(fromTemplate: "MM/dd/yyyy hh:mm:ss", options: 0, locale: nil)
        eventStartTime.text = dateFormatter.string(from: datePicker.date)
        let converted = "\(datePicker.date.convertedDate)"
        let localized = datePicker.date.localizedDescription
        
        var sub1 = ""
        var temp = ""
        var index1: String.Index?
        var index2: String.Index?
        if let index = converted.index(of: " "){
            sub1 = String(converted[..<index])
        }
        if let index = localized.index(of: "at "){
            index1 = index
        }
        if let index = localized.index(of: "AM"){
            index2 = index
            temp = "AM"
        }
        if let index = localized.index(of: "PM"){
            index2 = index
            temp = "PM"
        }
        
        let sub2 = String(localized[index1!..<index2!])
        
        let final = "\(sub1) \(sub2) \(temp)"
        //print(final)
        
        
            eventStartTime.text = final
        
        //2019-07-11 00:00:00 +0000
        //Thursday, July 11, 2019 at 7:14:37 PM Pacific Daylight Time
        
        
    }
    
    @objc func dateChanged2(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        DateFormatter.dateFormat(fromTemplate: "MM/dd/yyyy hh:mm:ss", options: 0, locale: nil)
        eventStartTime.text = dateFormatter.string(from: datePicker.date)
        let converted = "\(datePicker.date.convertedDate)"
        let localized = datePicker.date.localizedDescription
        
        var sub1 = ""
        var temp = ""
        var index1: String.Index?
        var index2: String.Index?
        if let index = converted.index(of: " "){
            sub1 = String(converted[..<index])
        }
        if let index = localized.index(of: "at "){
            index1 = index
        }
        if let index = localized.index(of: "AM"){
            index2 = index
            temp = "AM"
        }
        if let index = localized.index(of: "PM"){
            index2 = index
            temp = "PM"
        }
        
        let sub2 = String(localized[index1!..<index2!])
        
        let final = "\(sub1) \(sub2) \(temp)"
        //print(final)
        
        
        
        
            eventEndtime.text = final
        
        //2019-07-11 00:00:00 +0000
        //Thursday, July 11, 2019 at 7:14:37 PM Pacific Daylight Time
        
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewEvent(_ sender: Any) {
        guard let title     = eventTitle.text     else{ self.createButton.animateError(); return}
        guard let startDate = eventStartTime.text else{ self.createButton.animateError(); return}
        guard let endDate   = eventEndtime.text   else{ self.createButton.animateError(); return}
        guard let summary   = eventSummary.text   else{ self.createButton.animateError(); return}
        guard let maxSU     = maxSUs.text         else{ self.createButton.animateError(); return}
        guard let hours     = hoursTF.text        else{ self.createButton.animateError(); return}
        if(self.eventLocation == nil){
            self.createButton.animateError()
            print("Error Code: 100")
            return
        }
        
        let location = CLLocation(latitude: self.eventLocation!.latitude, longitude: self.eventLocation!.longitude)


//20803 Alves Dr, Cupertino, CA 95014
        delegate.createEvent(title: title, start: startDate, end: endDate, location: location, summary: summary, maxSUs: maxSU, hours: Int(hours)!)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("in here")
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    @IBAction func executeGesture(_ sender: Any) {
        print("in here2")
        let touchPoint = recognizer.location(in: self.mapView)
        let initialLocation = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        self.eventLocation = initialLocation
        print(eventLocation?.longitude)
        print(eventLocation?.latitude)
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: self.eventLocation!.latitude, longitude: self.eventLocation!.longitude)
        annotation.coordinate = centerCoordinate
        annotation.title = "Event Locale"
        mapView.addAnnotation(annotation)
        
        
    }
    

}

extension NewEventVC {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewEventVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        print("WE ARE INHERE")
        view.endEditing(true)
    }
}
