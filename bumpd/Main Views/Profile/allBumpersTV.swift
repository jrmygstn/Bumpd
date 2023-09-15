//
//  allBumpersTV.swift
//  bumpd
//
//  Created by Jeremy Gaston on 9/13/23.
//

import UIKit
import Firebase

class allBumpersTV: UITableViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var bumpers = [Bumpers]()
    
    // Outlets
    
    @IBOutlet weak var uidField: UILabel!
    @IBOutlet weak var nameField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)

        setupBumpers()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bumpers.count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bumper", for: indexPath) as! allTVC

        cell.setupCell(bum: bumpers[indexPath.row])
        
        let uid = self.bumpers[indexPath.row].uid
        
        self.databaseRef.child("Users/\(uid)").observeSingleEvent(of: .value) { snapshot in
            
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            
            self.nameField.text = name
            
        }
        
        cell.btnTapAction = {
            
            () in
            
            self.uidField.text = uid
            
            self.presentOption()
            
        }

        return cell
    }
    
    // Functions
    
    func setupBumpers() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Bumpers").observeSingleEvent(of: .value) { (snapshot) in
            
            var array = [Bumpers]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let user = child.childSnapshot(forPath: "uid").value as? String ?? ""
                let bumps = child.childSnapshot(forPath: "bumps").value as? Int ?? 0
                
                let bmp = Bumpers(uid: user, bumps: bumps)
                
                array.append(bmp)
                
            }
            
            self.bumpers = array
            self.tableView.reloadData()
            
        }
        
    }
    
    func presentOption() {
        
        let uid = Auth.auth().currentUser?.uid
        let user = self.uidField.text!
        let fullname = self.nameField.text!
        let name = fullname.components(separatedBy: " ")[0]
        
        let actionSheet = UIAlertController()
        
        actionSheet.addAction(UIAlertAction(title: "Block", style: .default) {(action: UIAlertAction) in
            
            let alert = UIAlertController(title: "Are you sure?", message: "You're about block this user. They won't be able see you or bump with you anymore.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { alert in
                
                let uid = Auth.auth().currentUser?.uid
                let user = self.uidField.text!
                let ref = self.databaseRef.child("Users/\(uid!)/Blocked")
                
                let val = [user: ["uid": user]]
                
                ref.updateChildValues(val)
                
                let alert = UIAlertController(title: "User blocked!", message: "", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                self.dismiss(animated: true)
                
                self.uidField.text = ""
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        })
        actionSheet.addAction(UIAlertAction(title: "Unbump", style: .default) {(action: UIAlertAction) in
            
            let alert = UIAlertController(title: "Are you certain?", message: "You're about to remove all past bumps with this user. This cannot be undone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { alert in
                
                let alert = UIAlertController(title: "Bumps removed!", message: "", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                self.dismiss(animated: true)
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }

}
