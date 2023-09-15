//
//  bumpDetailsTV.swift
//  bumpd
//
//  Created by Jeremy Gaston on 8/17/23.
//

import UIKit
import Firebase

class bumpDetailsTV: UITableViewController {

    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var bumps: Bumps!
    var comment = [Comments]()
    
    // Outlets
    
    @IBOutlet weak var recipientImg: CustomizableImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var toggleBtn: UISegmentedControl!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var photoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "commentTVC", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "comment")
        
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        
        databaseRef.child("Feed/\(bumps.id)/Memory").observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.mapView.isHidden = true
                self.photoView.isHidden = false
                
            } else {
                
                self.mapView.isHidden = false
                self.photoView.isHidden = true
                
            }
            
        }
        
        setupBump()
        checkComments()
        
    }
    
    // MARK: – Data Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as? bumpMap
        vc?.bumps = self.bumps
        
        let vc2 = segue.destination as? bumpPhoto
        vc2?.bumps = self.bumps
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comment.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! commentTVC

        cell.configureCell(ct: comment[indexPath.row])
        
        cell.btnTapAction = {
            
            () in
            
            print("THE REPLY BUTTON WAS TAPPED!!")
            
        }

        return cell
    }
    
    // Actions
    
    @IBAction func toggleBtnTapped(_ sender: Any) {
        
        if toggleBtn.selectedSegmentIndex == 0 {
            
            mapView.isHidden = true
            photoView.isHidden = false
            
        } else if toggleBtn.selectedSegmentIndex == 1 {
            
            mapView.isHidden = false
            photoView.isHidden = true
            
        }
        
    }
    
    
    // Functions
    
    func setupBump() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref1 = databaseRef.child("Feed/\(bumps.id)/Memory")
        let ref2 = databaseRef.child("Users/\(bumps.author)")
        let ref3 = databaseRef.child("Users/\(bumps.recipient)")
        
        ref1.observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.toggleBtn.isHidden = false
                
            } else {
                
                self.toggleBtn.isHidden = true
                
            }
            
        }
        
        if bumps.author == uid && bumps.recipient != uid {
            
            ref3.observe(.value) { (snapshot) in
                
                let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let name = fullname.components(separatedBy: " ")[0]
                let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                
                self.detailsLabel.text = "You bumpd into \(name) at \(self.bumps.details) on \(self.bumps.date)"
                
                self.recipientImg.loadImageUsingCacheWithUrlString(urlString: img)
                
            }
            
        } else if bumps.recipient == uid && bumps.author != uid {
            
            ref2.observe(.value) { (snapshot) in
                
                let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let name = fullname.components(separatedBy: " ")[0]
                let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                
                self.detailsLabel.text = "You bumpd into \(name) at \(self.bumps.details) on \(self.bumps.date)"
                
                self.recipientImg.loadImageUsingCacheWithUrlString(urlString: img)
                
            }
            
        }
        
    }
    
    func checkComments() {
        
        databaseRef.child("Feed/\(bumps.id)/Notes").observe(.value) { (snapshot) in
            
            var array = [Comments]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let text = child.childSnapshot(forPath: "text").value as? String ?? ""
                let time = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                
                let cmt = Comments(author: auth, timestamp: time, id: id, text: text)
                
                array.append(cmt)
                
            }
            
            self.comment = array
            self.tableView.reloadData()
            
        }
        
    }

}
