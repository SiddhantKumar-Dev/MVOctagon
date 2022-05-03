//
//  EventCell.swift
//  Octagon
//
//  Created by sid on 5/18/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class EventCell: UITableViewCell {

    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var spotsLeftLabel: UILabel!
    
    @IBOutlet weak var backgroundColorView: UIView!
    func set(eventValue: Events){
        eventLabel.text = eventValue.eventName!
       // locationLabel.text = "unsure of current location"
        self.getPlace(for: eventValue.eventLocation!) { placemark in
            guard let placemark = placemark else { return }
//            print(placemark.thoroughfare)
//            print(placemark.subThoroughfare)
//            print(placemark.locality)
//            print(placemark.country)
//            print(placemark.postalCode)
//            print(placemark.administrativeArea)
            var text = ""
            
            if(placemark.subThoroughfare != nil){
                text += "\(placemark.subThoroughfare!) "
            }
            if(placemark.thoroughfare != nil){
                text += "\(placemark.thoroughfare!). "
            }
            if(placemark.locality != nil){
                text += "\(placemark.locality!), "
            }
            if(placemark.administrativeArea != nil){
                text += "\(placemark.administrativeArea!) "
            }
            if(text == ""){
                text = "Location Not Found"
            }
            self.locationLabel.text = text
            if(eventValue.containsUser(with: constantVal.allUsers[constantVal.currentUID]!)){
                self.backgroundColorView.backgroundColor = UIColor(named: "SignUp Color")
            } else{
                self.backgroundColorView.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 1.0, alpha: 1.0)
            }
            // 0 122 /255
            
//            print("THIS IS THE THING THAT IS GONAA TELL US THE INFORMATION")
        }
            
        //locationLabel.text = eventValue.eventLocation!
        var startLabel2 = eventValue.start!
        var endLabel2 = eventValue.end!
        var strArr2 = Array(startLabel2).map{String($0)}
        var strArr3 = Array(endLabel2).map{String($0)}

        
        let len1 = startLabel2.count
        let len2 = endLabel2.count
        startLabel2 = ""
        endLabel2 = ""
        for n in 0..<len2-2{
            startLabel2 += strArr2[n]
        }
        
        for n in 0..<len1-2{
            endLabel2 += strArr3[n]
        }
        startTimeLabel.text = startLabel2
        endTimeLabel.text = endLabel2
        let left = eventValue.findSlotsLeft()
        spotsLeftLabel.text = "\(left) spaces left"
        
        
    }
    
    func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
    

}
