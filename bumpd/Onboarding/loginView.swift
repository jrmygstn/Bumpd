//
//  loginView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase

class loginView: UIViewController {

    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
    }
    
    // Actions
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func googleBtnTapped(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "googleView") as! googleView
        present(controller, animated: true)
        
    }
    
    @IBAction func appleBtnTapped(_ sender: Any) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "googleView") as! googleView
        present(controller, animated: true)
        
    }
    
    @IBAction func forgotBtnTapped(_ sender: Any) {
        
        let email = emailField.text
        Auth.auth().sendPasswordReset(withEmail: email!) {
            (error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                let alert = UIAlertController(title: "Success!", message: "Your password reset link has been sent to your email address.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        guard let email = emailField.text, email != "", let password = passwordField.text, password != ""
            else {
                let alert = UIAlertController(title: "Forget Something?", message: "Your email or password is missing", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
            
            if (error != nil) {
                
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                UserDefaults.standard.synchronize()
            
            } else {
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "mainView")
                self.present(controller!, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}
