//
//  friendProfileTV.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/16/23.
//

import UIKit
import Firebase

class friendProfileTV: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var bumpers = [Bumpers]()
    var bumps = [Bumps]()
    var user: String = ""
    var ath: String = ""
    var rec: String = ""
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var instagramStackView: UIStackView!
    @IBOutlet weak var webStackView: UIStackView!
    @IBOutlet weak var webLabel: UILabel!{
        didSet{
            webLabel.tag = 2
        }
    }
    @IBOutlet weak var instagramLabel: UILabel!{
        didSet{
            instagramLabel.tag = 1
        }
    }
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var uidLabel: UILabel!
    
    @IBOutlet weak var topCollection: UICollectionView!
    
    
    private var webUrl = ""
    private var instagramUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()
        
        self.topCollection.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        self.headerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        self.tableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        if self.ath != "" && self.rec == "" && self.user == "" {
            
            self.uidLabel.text = self.ath
            
            print("THEIR UID IS--->>\(self.uidLabel.text!)")
            
        } else if self.ath == "" && self.rec != "" && self.user == "" {
            
            self.uidLabel.text = self.rec
            
            print("THEIR UID IS--->>\(self.uidLabel.text!)")
            
        } else if self.ath == "" && self.rec == "" && self.user != "" {
            
            self.uidLabel.text = self.user
            
            print("THEIR UID IS--->>\(self.uidLabel.text!)")
            
        }
        
        setupBumpCount()
        setupProfile()
        setupTopBumps()
        setupUsersBumps()
        
    }
    
    // MARK: – Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return bumpers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! friendTopCVC
        
        cell.setupCell(bums: bumpers[indexPath.row])
        
        return cell
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bumps.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bump", for: indexPath) as! friendBumpTVC
        
        cell.setupCell(bum: bumps[indexPath.row])
        
        return cell
        
    }
    
    // Actions
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToProfile", sender: nil)
        
    }
    
    
    // Functions
    
    func setupProfile() {
        
        let user = self.uidLabel.text!
        
        self.databaseRef.child("Users/\(user)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            self.nameLabel.text = name
            
            let instagram = snapshot.childSnapshot(forPath: "instagram").value as? String ?? ""
            
            let web = snapshot.childSnapshot(forPath: "web").value as? String ?? ""
            
            if instagram.isEmpty == false{
                self.instagramUrl = instagram
                self.instagramStackView.isHidden = false
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
                self.instagramLabel.addGestureRecognizer(tap)
            }
            
            if web.isEmpty == false{
                self.webUrl = web
                self.webStackView.isHidden = false
                self.webLabel.text = web
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
                self.webLabel.addGestureRecognizer(tap)
            }
            
            
        }
        
    }
    
    func openUrl(urlString: String){
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc
    func tapFunction(sender: UITapGestureRecognizer) {
        if sender.view?.tag == 1{
            openUrl(urlString: instagramUrl)
        }else{
            openUrl(urlString: webUrl)
        }
    }
    
    func setupTopBumps() {
        
        let user = self.uidLabel.text!
        
        self.databaseRef.child("Users/\(user)/Bumpers").queryOrdered(byChild: "bumps").observeSingleEvent(of: .value) { (snapshot) in
            
            var array = [Bumpers]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let bmps = child.childSnapshot(forPath: "bumps").value as? Int ?? 0
                let uid = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                let bmpr = Bumpers(uid: uid, bumps: bmps)
                
                array.insert(bmpr, at: 0)
                
            }
            
            self.bumpers = array
            self.topCollection.reloadData()
            
            if self.bumpers.count != 0 {
                
                self.countLabel.text = "Bumpers: \(self.bumpers.count)"
                
            } else {
                
                self.countLabel.text = "Bumpers: 0"
                
            }
            
        }
        
    }
    
    func setupUsersBumps() {
        
        let user = self.uidLabel.text!
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Feed").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in

            var array = [Bumps]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {

                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let ath = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let dets = child.childSnapshot(forPath: "details").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let recipient = child.childSnapshot(forPath: "recipient").value as? String ?? ""

                if ath == user && approve == true && recipient == uid || recipient == user && approve == true && ath == uid {
                    
                    let bmp = Bumps(approved: approve, author: ath, date: date, details: dets, timestamp: stamp, id: id, location: local, latitude: lat, longitude: long, recipient: recipient)

                    array.insert(bmp, at: 0)
                    
                }

            }
            
            self.bumps = array
            self.tableView.reloadData()

        }
        
    }
    
    func setupBumpCount() {
        
        let user = self.uidLabel.text!
        
        databaseRef.child("Feed").observeSingleEvent(of: .value) { (snapshot) in

            var array = [Bumps]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {

                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let ath = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let dets = child.childSnapshot(forPath: "details").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let recipient = child.childSnapshot(forPath: "recipient").value as? String ?? ""

                if ath == user && approve == true || recipient == user && approve == true {
                    
                    let bmp = Bumps(approved: approve, author: ath, date: date, details: dets, timestamp: stamp, id: id, location: local, latitude: lat, longitude: long, recipient: recipient)

                    array.insert(bmp, at: 0)
                    
                }

            }
            
            self.bumps = array
            
            if self.bumps.count != 0 {
                
                self.totalLabel.text = "Total bumps: \(self.bumps.count)"
                
            } else {
                
                self.totalLabel.text = "Total bumps: 0"
                
            }

        }
        
    }

}
