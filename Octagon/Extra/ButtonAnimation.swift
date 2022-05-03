//
//  ButtonAnimation.swift
//  Octagon
//
//  Created by sid on 7/7/19.
//  Copyright © 2019 sid. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    func animateError(){
        UIView.animate(withDuration: 0.1, animations: {
            var transforms = CGAffineTransform.identity
            transforms = transforms.translatedBy(x: 15, y: 0)
            self.transform = transforms
        })
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            var transforms = CGAffineTransform.identity
            transforms = transforms.translatedBy(x: -15, y: 0)
            self.transform = transforms
        }, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveLinear, animations: {
            let transforms = CGAffineTransform.identity
            self.transform = transforms
        }, completion: nil)
    }
}
