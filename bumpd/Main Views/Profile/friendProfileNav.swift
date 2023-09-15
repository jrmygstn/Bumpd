//
//  friendProfileNav.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/16/23.
//

import UIKit

class friendProfileNav: UINavigationController {
    
    var bump: Bumps!
    var user: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()

        if let vc = self.topViewController as? friendProfileTV {
            
            vc.user = self.user
            
        }
        
    }

}
