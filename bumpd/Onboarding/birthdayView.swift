//
//  birthdayView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/2/23.
//

import UIKit
import Firebase

class birthdayView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    let birthday = UIDatePicker()
    
    // Outlets
    
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var ageField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        if #available(iOS 16.0, *) {
            navigationItem.leftBarButtonItem?.isHidden = true
        } else {
            // Fallback on earlier versions
        }
        
        createDatePicker()
        
    }
    
    // Actions
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = self.databaseRef.child("Users/\(uid!)")
        
        guard let dob = dobField.text, dob != ""
            else {
                let alert = UIAlertController(title: "Uh oh!", message: "Please make a selection.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        let userObj = ["birthday": dob, "age": self.ageField.text!]

        ref.updateChildValues(userObj)
        
        let go = self.storyboard?.instantiateViewController(withIdentifier: "mainView")
        self.present(go!, animated: true, completion: nil)
        
    }
    
    // Functions
    
    func createDatePicker(){
        
        birthday.preferredDatePickerStyle = .wheels
        birthday.datePickerMode = .date
        birthday.maximumDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        birthday.frame = CGRect(x: 10, y: 100, width: self.view.frame.width, height: 270)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        dobField.inputAccessoryView = toolbar
        
        dobField.inputView = birthday
        
    }
    
    @objc func donePressed(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.setLocalizedDateFormatFromTemplate("MM-dd-yyyy")
        
        let dob:String = dateFormatter.string(from: birthday.date)
        
        let finalDate:Date = dateFormatter.date(from: dob)!
        
        let now = Date()
        
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: finalDate, to: now)
        
        dobField.text = dateFormatter.string(from: birthday.date)
        ageField.text = String(ageComponents.year!)
        
        print(self.dobField.text!)
        
        view.endEditing(true)
    }

}
