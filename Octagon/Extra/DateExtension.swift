//
//  DateExtension.swift
//  Octagon
//
//  Created by sid on 7/3/19.
//  Copyright © 2019 sid. All rights reserved.
//

import Foundation

extension Date {
    var localizedDescription: String {
        return description(with: .current)
    }
    
    var convertedDate:Date {
        
        let dateFormatter = DateFormatter();
        
        let dateFormat = "dd MMM yyyy";
        dateFormatter.dateFormat = dateFormat;
        let formattedDate = dateFormatter.string(from: self);
        
        dateFormatter.locale = NSLocale.current;
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC");
        
        dateFormatter.dateFormat = dateFormat as String;
        let sourceDate = dateFormatter.date(from: formattedDate as String);
        
        return sourceDate!;
    }
}
