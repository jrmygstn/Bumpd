//
//  verifyNav.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import UIKit

class verifyNav: UINavigationController {
    
    var phoneNumber: String = ""
    var countryCode: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let vc = self.topViewController as? verifyView {
            
            vc.phoneNumber = self.phoneNumber
            vc.countryCode = self.countryCode
            
        }
        
    }

}
