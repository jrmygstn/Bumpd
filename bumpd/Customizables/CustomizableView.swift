//
//  CustomizableView.swift
//  trainr
//
//  Created by Jeremy Gaston on 9/24/20.
//  Copyright © 2020 uballn. All rights reserved.
//

import UIKit

@IBDesignable class CustomizableView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet{
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    
}
