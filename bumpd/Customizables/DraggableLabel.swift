//
//  DraggableLabel.swift
//  trainrplus
//
//  Created by Jeremy Gaston on 12/17/21.
//

import UIKit

class draggableLabel: UILabel {
    
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.cgColor
        self.isUserInteractionEnabled = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first;
        let location = touch?.location(in: self.superview);
        if(location != nil)
        {
        self.frame.origin = CGPoint(x: location!.x-self.frame.size.width/2, y: location!.y-self.frame.size.height/2);
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

}
