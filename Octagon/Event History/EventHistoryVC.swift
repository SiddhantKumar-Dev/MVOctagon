//
//  EventHistoryVC.swift
//  Octagon
//
//  Created by sid on 7/8/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit

class EventHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    var eventCopy: [Events] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        for event in constantVal.allHistory{
            eventCopy.append(event)
        }
        
    }
    @IBAction func goBack(_ sender: Any) {
        EventVC.isSelectedHistory = false
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventCopy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventHistoryCell") as! EventHistoryCell
        cell.set(event: eventCopy[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        EventVC.isSelectedHistory = true
        EventVC.selectedEvent = eventCopy[indexPath.row]
        let newvc = self.storyboard?.instantiateViewController(withIdentifier: "EventInfoVC") as! EventInfoVC
        self.present(newvc, animated: true, completion: nil)
        
            
        
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
