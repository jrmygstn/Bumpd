//
//  privacyTableview.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/28/23.
//

import UIKit
import Firebase

class privacyTableview: UITableViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var Switch1: Bool = false
    var Switch2: Bool = false
    var Switch3: Bool = false
    var Switch4: Bool = false
    var Switch5: Bool = false
    
    // Outlets
    
    @IBOutlet weak var switchOne: UISwitch!
    @IBOutlet weak var switchTwo: UISwitch!
    @IBOutlet weak var switchThree: UISwitch!
    @IBOutlet weak var switchFour: UISwitch!
    @IBOutlet weak var switchFive: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()
        
        tableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)

        addSettings()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    // Actions
    
    @IBAction func toggleOneSwitch(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)/Settings")
        
        if switchOne.isOn {
            
            let value = ["world": true,
                         "friends": false,
                         "personal": false]
            
            ref.updateChildValues(value)
            
            
            self.switchTwo.isOn = false
            self.switchThree.isOn = false
            
        }
        
    }
    
    @IBAction func toggleTwoSwitch(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)/Settings")
        
        if switchTwo.isOn {
            
            let value = ["world": false,
                         "friends": true,
                         "personal": false]
            
            ref.updateChildValues(value)
            
            
            self.switchOne.isOn = false
            self.switchThree.isOn = false
            
        }
        
    }
    
    @IBAction func toggleThreeSwitch(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)/Settings")
        
        if switchThree.isOn {
            
            let value = ["world": false,
                         "friends": false,
                         "personal": true]
            
            ref.updateChildValues(value)
            
            
            self.switchTwo.isOn = false
            self.switchOne.isOn = false
            
        }
        
    }
    
    @IBAction func toggleFourSwitch(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)/Settings")
        
        if switchFour.isOn {
            
            let value = ["worldLoc": true,
                         "friendsLoc": false]
            
            ref.updateChildValues(value)
            
            self.switchFive.isOn = false
            
        }
        
    }
    
    @IBAction func toggleFiveSwitch(_ sender: Any) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)/Settings")
        
        if switchFive.isOn {
            
            let value = ["worldLoc": false,
                         "friendsLoc": true]
            
            ref.updateChildValues(value)
            
            self.switchFour.isOn = false
            
        }
        
    }
    
    // Function
    
    func addSettings() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)/Settings")
        
        ref.observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.setupSettings()
                
            } else {
                
                let values = ["personal": false,
                              "friends": false,
                              "world": true,
                              "worldLoc": true,
                              "friendsLoc": false]
                
                ref.updateChildValues(values)
                
            }
            
        }
        
    }
    
    func setupSettings() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Settings").observe(.value) { (snapshot) in
            
            let person = snapshot.childSnapshot(forPath: "personal").value as? Bool ?? false
            let friend = snapshot.childSnapshot(forPath: "friends").value as? Bool ?? false
            let world = snapshot.childSnapshot(forPath: "world").value as? Bool ?? false
            let worldloc = snapshot.childSnapshot(forPath: "worldLoc").value as? Bool ?? false
            let frndloc = snapshot.childSnapshot(forPath: "friendsLoc").value as? Bool ?? false
            
            // Setup bump privacy
            
            if world == true {
                
                self.switchOne.isOn = true
                self.switchTwo.isOn = false
                self.switchThree.isOn = false
                
            } else if friend == true {
                
                self.switchOne.isOn = false
                self.switchTwo.isOn = true
                self.switchThree.isOn = false
                
            } else if person == true {
                
                self.switchOne.isOn = false
                self.switchTwo.isOn = false
                self.switchThree.isOn = true
                
            }
            
            // Setup location privacy
            
            if worldloc == true {
                
                self.switchFour.isOn = true
                self.switchFive.isOn = false
                
            } else if frndloc == true {
                
                self.switchFour.isOn = false
                self.switchFive.isOn = true
                
            }
            
        }
        
    }

}
