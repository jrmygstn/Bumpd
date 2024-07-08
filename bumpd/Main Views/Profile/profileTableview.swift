//
//  profileTableview.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/12/23.
//

import UIKit
import Firebase

class profileTableview: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var bumpers = [Bumpers]()
    var bumps = [Bumps]()
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var viewAllBtn: UIButton!
    
    @IBOutlet weak var topCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()
        self.navigationItem.backButtonTitle = ""
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        self.topCollection.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        self.headerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        self.tableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfile()
        setupTopBumps()
        setupYourBumps()
    }
    
    // MARK: – Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if bumpers.count != 0 {
            
            return bumpers.count
            
        }
        
        return 4
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! topCVC
        
        if bumpers.count == 0 {
            
            cell.cellEmpty.isHidden = false
            
        } else {
            
            cell.setupCell(bums: bumpers[indexPath.row])
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(identifier: "friendProfileVC") as! friendProfileTV
        vc.user = self.bumpers[indexPath.row].uid
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if bumps.count != 0 {
            
            return bumps.count
            
        }
        
        return 3
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bump", for: indexPath) as! bumpTVC
        
        if bumps.count == 0 {
            
            cell.cellEmpty.isHidden = false
            
        } else {
            
            cell.cellEmpty.isHidden = true
            cell.setupCell(bum: bumps[indexPath.row])
            
            cell.btnTapAction = {
                
                () in
                
                let uid = Auth.auth().currentUser?.uid
                
                if self.bumps[indexPath.row].author != uid && self.bumps[indexPath.row].recipient == uid {
                    
                    let vc = self.storyboard?.instantiateViewController(identifier: "friendProfileVC") as! friendProfileTV
                    vc.ath = self.bumps[indexPath.row].author
                    print("YOU SELECTED THE BUMP AUTHOR --->> \(self.bumps[indexPath.row].author)")
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else if self.bumps[indexPath.row].recipient != uid && self.bumps[indexPath.row].author == uid {
                    
                    let vc = self.storyboard?.instantiateViewController(identifier: "friendProfileVC") as! friendProfileTV
                    vc.rec = self.bumps[indexPath.row].recipient
                    print("YOU SELECTED THE BUMP RECIPIENT --->> \(self.bumps[indexPath.row].recipient)")
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
            }
            
            cell.btnTapAction2 = {
                
                () in
                
                let vc = self.storyboard?.instantiateViewController(identifier: "bumpDetails") as! bumpDetailsView
                vc.bumps = self.bumps[indexPath.row]
                self.present(vc, animated: true, completion: nil)
                
            }
            
        }
        
        return cell
        
    }
    
    // Actions
    
    @IBAction func unwindToProfile(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func settingBtnTapped(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "settingsView") as! settingsTableview
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func viewAllBtnTapped(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "allView") as! allBumpersTV
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // Functions
    
    func setupProfile() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            self.nameLabel.text = name
            
        }
        
    }
    
    func setupTopBumps() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Bumpers").queryOrdered(byChild: "bumps").observeSingleEvent(of: .value) { (snapshot) in
            
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
                self.viewAllBtn.isHidden = false
                
            } else {
                
                self.countLabel.text = "Bumpers: 0"
                self.viewAllBtn.isHidden = true
                
            }
            
        }
        
    }
    
    func setupYourBumps() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Feed").queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in

            var array = [Bumps]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {

                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let dets = child.childSnapshot(forPath: "details").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let recipient = child.childSnapshot(forPath: "recipient").value as? String ?? ""

                if auth == uid && approve == true || recipient == uid && approve == true {
                    
                    let bmp = Bumps(approved: approve, author: auth, date: date, details: dets, timestamp: stamp, id: id, location: local, latitude: lat, longitude: long, recipient: recipient)

                    array.insert(bmp, at: 0)
                    
                }

            }
            
            self.bumps = array
            self.tableView.reloadData()
            
            if self.bumps.count != 0 {
                
                self.totalLabel.text = "Total bumps: \(self.bumps.count)"
                
            } else {
                
                self.totalLabel.text = "Total bumps: 0"
                
            }

        }
        
    }

}
