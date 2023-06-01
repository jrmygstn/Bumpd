//
//  feedDetailsNav.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/24/23.
//

import UIKit

class feedDetailsNav: UINavigationController {
    
    var feed: Feed!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let vc = self.topViewController as? feedDetailsView {
            
            vc.feed = self.feed
            
        }
        
    }

}
