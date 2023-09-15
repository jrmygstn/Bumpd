//
//  privacyView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/28/23.
//

import UIKit

class privacyView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Actions
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToSettings", sender: nil)
        
    }
    

}
