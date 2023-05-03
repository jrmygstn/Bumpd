//
//  landingView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase

class landingView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // .default
        return .darkContent
    }
    
    // Actions
    
    @IBAction func unwindToLanding(segue:UIStoryboardSegue) {
    }
    
    @IBAction func googleBtnTapped(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "googleView") as! googleView
        present(controller, animated: true)
        
    }
    
    @IBAction func appleBtnTapped(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "googleView") as! googleView
        present(controller, animated: true)
        
    }
    
    @IBAction func emailBtnTapped(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "signupNav") as! signupNav
        present(controller, animated: true)
        
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "loginNav") as! loginNav
        present(controller, animated: true)
        
    }
    
    @IBAction func faqsBtnTapped(_ sender: Any) {
    }
    
    // Functions
    
    

}
