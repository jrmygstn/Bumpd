//
//  CustomizableTextView.swift
//  Prept
//
//  Created by Jeremy Gaston on 8/11/19.
//  Copyright © 2019 UBALLN. All rights reserved.
//

import UIKit

@IBDesignable class CustomizableTextView: UITextView {
    
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
