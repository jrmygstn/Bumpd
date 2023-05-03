//
//  CustomizableLabel.swift
//  Prept
//
//  Created by Jeremy Gaston on 8/11/19.
//  Copyright © 2019 UBALLN. All rights reserved.
//

import UIKit

@IBDesignable class CustomizableLabel: UILabel {
    
    @IBInspectable var cnrRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cnrRadius
        }
    }
    
    @IBInspectable var brdrWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = brdrWidth
        }
    }
    
    @IBInspectable var brdrColor: UIColor? {
        didSet{
            layer.borderColor = brdrColor?.cgColor
        }
    }
    
}
