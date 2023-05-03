//
//  tabBarControls.swift
//  trainr
//
//  Created by Jeremy Gaston on 12/18/20.
//  Copyright © 2020 uballn. All rights reserved.
//

import UIKit

class tabBarControls: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.selectedIndex = 0
        
        self.tabBar.unselectedItemTintColor = .white
        
    }
    
}
