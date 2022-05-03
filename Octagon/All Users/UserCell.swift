//
//  UserCell.swift
//  Octagon
//
//  Created by sid on 6/27/19.
//  Copyright © 2019 sid. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    func set(user: Users){
        nameLabel.text = user.name!
        emailLabel.text = user.email!
        if(constantVal.allUsers[constantVal.currentUID]!.isOfficer!){
            hoursLabel.text = "\(user.hours!)"
        } else{
            hoursLabel.text = "-"
        }
        yearLabel.text = "\(user.gradYear!)"
        
    }

}
