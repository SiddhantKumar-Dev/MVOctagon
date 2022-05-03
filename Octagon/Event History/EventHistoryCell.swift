//
//  EventHistoryCell.swift
//  Octagon
//
//  Created by sid on 7/8/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit

class EventHistoryCell: UITableViewCell {

    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventEnd: UILabel!
    @IBOutlet weak var eventStart: UILabel!
    
    func set(event: Events){
        backgroundColorView.layer.cornerRadius = 10
        if(event.containsUser(with: constantVal.allUsers[constantVal.currentUID]!)){
            eventNameLabel.textColor = .white
            eventEnd.textColor = .white
            eventStart.textColor = .white
        } else{
            eventNameLabel.textColor = .white
            eventEnd.textColor = .white
            eventStart.textColor = .white
            backgroundColorView.backgroundColor = UIColor(named: "NoParticipationColor")

    
        }
        eventNameLabel.text = event.eventName
        eventEnd.text = event.end
        eventStart.text = event.start
    }
    
}
