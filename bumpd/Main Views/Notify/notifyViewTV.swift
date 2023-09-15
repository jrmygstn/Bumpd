//
//  notifyViewTV.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/26/23.
//

import UIKit
import Firebase

class notifyViewTV: UITableViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var notify = [Notify]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()

        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        
        setupNotifications()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notify.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notify", for: indexPath) as! notifyCell

        cell.setupCell(noti: notify[indexPath.row])
        
        cell.btnTapAction1 = {
            
            () in
            
            let fid = self.notify[indexPath.row].fid
            let id = self.notify[indexPath.row].id
            let uid = Auth.auth().currentUser?.uid
            let user = self.notify[indexPath.row].author
            
            let ref0 = self.databaseRef.child("Feed/\(fid)")
            let ref1 = self.databaseRef.child("Users/\(uid!)/Notify/\(id)")
            let ref2 = self.databaseRef.child("Users/\(user)/Notify")
            let refKey = ref2.childByAutoId()
            let key = refKey.key
            
            let value0 = ["approved": true]
            
            self.databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snap) in
                
                let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                
                let value2 = [key: ["author": uid!, "id": key!, "text": "\(name) accepted your bump!", "timestamp": ServerValue.timestamp(), "unread": true] as [String : Any]]
                
                ref2.updateChildValues(value2)
                
            }
            
            ref0.updateChildValues(value0)
            ref1.removeValue()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "confirmView") as! confirmView
            vc.notify = self.notify[indexPath.row]
            self.present(vc, animated: true)
            
        }
        
        cell.btnTapAction2 = {
            
            () in
            
            let alert = UIAlertController(title: "Are you sure?", message: "You're about to delete this bump.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes!", style: UIAlertAction.Style.destructive, handler: { alert in
                
                let fid = self.notify[indexPath.row].fid
                let id = self.notify[indexPath.row].id
                let uid = Auth.auth().currentUser?.uid
                let user = self.notify[indexPath.row].author
                
                let ref1 = self.databaseRef.child("Feed/\(fid)")
                let ref0 = self.databaseRef.child("Users/\(uid!)/Notify/\(id)")
                let ref2 = self.databaseRef.child("Users/\(user)/Notify")
                let refKey = ref2.childByAutoId()
                let key = refKey.key
                
                ref1.removeValue()
                ref0.removeValue()
                
                self.databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snap) in
                    
                    let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                    
                    let value2 = [key: ["author": uid!, "id": key!, "text": "\(name) did not accepted your bump.", "timestamp": ServerValue.timestamp(), "unread": true] as [String : Any]]
                    
                    ref2.updateChildValues(value2)
                    
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        cell.btnTapAction3 = {
            
            () in
            
            let id = self.notify[indexPath.row].id
            let uid = Auth.auth().currentUser?.uid
            
            let ref0 = self.databaseRef.child("Users/\(uid!)/Notify/\(id)")
            
            ref0.removeValue()
            
        }
        
        cell.btnTapAction4 = {
            
            () in
            
            let alert = UIAlertController(title: "Block this user?", message: "You will no longer be visible and able to bump with this user.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes, block!", style: .destructive, handler: { alert in
                
                let user = self.notify[indexPath.row].author
                let id = self.notify[indexPath.row].id
                let uid = Auth.auth().currentUser?.uid
                let ref = self.databaseRef.child("Users/\(uid!)/Blocked")
                let ref0 = self.databaseRef.child("Users/\(uid!)/Notify/\(id)")
                
                let val = [user: ["uid": user]]
                
                ref.updateChildValues(val)
                ref0.removeValue()
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }

        return cell
    }
    
    // Functions
    
    func setupNotifications() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Notify").observe(.value) { (snapshot) in
            
            var array = [Notify]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let author = child.childSnapshot(forPath: "author").value as? String ?? ""
                let time = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let text = child.childSnapshot(forPath: "text").value as? String ?? ""
                let fid = child.childSnapshot(forPath: "feedId").value as? String ?? ""
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let unread = child.childSnapshot(forPath: "unread").value as? Bool ?? true
                
                let noty = Notify(approved: approve, timestamp: time, message: text, author: author, fid: fid, id: id, unread: unread)
                
                array.insert(noty, at: 0)
                
            }
            
            self.notify = array
            self.tableView.reloadData()
            
        }
        
    }

}
