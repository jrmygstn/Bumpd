//
//  googleView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/26/23.
//

import UIKit

class googleView: UIViewController {
    
    // Variables
    
    var timer = Timer()
    var counter = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
    }
    
    // Actions
    
    @objc func updateCounter() {
        counter += 1
        
        if counter == 7 {
            
            timer.invalidate()
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "mainView")
            self.present(controller!, animated: true, completion: nil)
            
        }
        
    }
    
    

}
