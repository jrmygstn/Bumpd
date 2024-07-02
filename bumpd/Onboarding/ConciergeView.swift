//
//  ConciergeView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/23/23.
//

import UIKit
import Firebase

class ConciergeView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var signupBtn: CustomizableButton!
    @IBOutlet weak var loginBtn: CustomizableButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkIfLoggedIn()
        
    }
    
    // Actions
    
    @IBAction func signupBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "toLanding", sender: nil)
        
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "toLogin", sender: nil)
        
    }
    
    // Functions
    
    func checkIfLoggedIn() {
        
        if Auth.auth().currentUser != nil {
            
            signupBtn.isHidden = true
            loginBtn.isHidden = true
            
            self.checkAccountComplete()
            
        } else {
            
            signupBtn.isHidden = false
            loginBtn.isHidden = false
            
        }
        
    }
    
    func checkAccountComplete() {
        
        let user = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(user!)").observe(.value) { (snapshot) in
            
            let user = snapshot.childSnapshot(forPath: "username").value as? String ?? ""
            
            if user != "" {
                
                self.checkProfileComplete()
                
            } else {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "usernameNav")
                self.present(vc!, animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    func checkProfileComplete() {
        
        let user = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(user!)").observe(.value) { (snapshot) in
            
            let image = snapshot.childSnapshot(forPath: "img").value as? String ?? ""
            
            if image != "" {
                
                self.checkBirthdayComplete()
                
            } else if image == "" {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "picNav")
                self.present(vc!, animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    func checkBirthdayComplete() {
        
        let user = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(user!)").observe(.value) { (snapshot) in
            
            let bday = snapshot.childSnapshot(forPath: "birthday").value as? String ?? ""
            
            if bday != "" {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainView")
                self.present(vc!, animated: false, completion: nil)
                
            } else if bday == "" {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "birthdayNav")
                self.present(vc!, animated: false, completion: nil)
                
            }
            
        }
        
    }

}
