//
//  SettingsSection.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Social 
    case Communications
    
    var description: String {
        switch self {
        case .Social: return "Personal Settings"
        case .Communications: return "Public Settings"
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {
//    case editProfile
    case logout
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
//        case .editProfile: return "Edit Profile"
        case .logout: return "Log Out"
        }
    }
}

enum CommunicationOptions: Int, CaseIterable, SectionType {
//    case notifications
//    case email
//    case reportCrashes
    case getUsers
    case completedEvents
    
    var containsSwitch: Bool {
        switch self {
//        case .notifications: return true
//        case .email: return true
//        case .reportCrashes: return true
        case .getUsers: return false
        case .completedEvents: return false
        }
    }
    
    var description: String {
        switch self {
//        case .notifications: return "Notifications"
//        case .email: return "Make Email Public"
//        case .reportCrashes: return "Report Crashes"
        case .getUsers: return "All Users"
        case .completedEvents: return "Completed Events"
        
        }
    }
}
