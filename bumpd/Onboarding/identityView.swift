//
//  indentityView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/2/23.
//

import UIKit
import Firebase

class identityView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var gender = ["", "Woman", "Man", "Non Binary", "I prefer not to say",]
    
    let picker = UIPickerView()
    
    // Outlets
    
    @IBOutlet weak var genderField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        if #available(iOS 16.0, *) {
            navigationItem.leftBarButtonItem?.isHidden = true
        } else {
            // Fallback on earlier versions
        }
        
        picker.delegate = self
        picker.dataSource = self
        
        genderField.inputView = picker
        
        
    }
    
    // MARK: – Picker data source view
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var countrows : Int = gender.count
        
        countrows = self.gender.count
            
        return countrows
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == picker {
            
            let titleRow = gender[row]
            return titleRow
            
        }
            
        return ""
        
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.genderField.text = self.gender[row]
        self.view.endEditing(true)
        
    }
    
    // Actions
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = self.databaseRef.child("Users/\(uid!)")
        
        guard let gender = genderField.text, gender != ""
            else {
                let alert = UIAlertController(title: "Uh oh!", message: "Please make a selection.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        let userObj = ["gender": gender]

        ref.updateChildValues(userObj)
        
        let go = self.storyboard?.instantiateViewController(withIdentifier: "picNav")
        self.present(go!, animated: true, completion: nil)
        
    }

}
