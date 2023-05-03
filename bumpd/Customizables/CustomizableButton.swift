//
//  CustomizableButton.swift
//  Prept
//
//  Created by Jeremy Gaston on 8/11/19.
//  Copyright © 2019 UBALLN. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomizableButton: UIButton {
    
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
