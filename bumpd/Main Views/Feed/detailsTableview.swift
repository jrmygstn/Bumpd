//
//  detailsTableview.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/13/23.
//

import UIKit
import Firebase

class detailsTableview: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var feed: Feed!
    var like = [Likes]()
    var liked = [Likes]()
    var comment = [Comments]()
    
    var replyName: String = ""
    
    // Outlets
    
    @IBOutlet weak var authorImg: CustomizableImageView!
    @IBOutlet weak var recipientImg: CustomizableImageView!
    @IBOutlet weak var likeCollection: UICollectionView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "commentTVC", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "comment")
        
        let footerNib = UINib(nibName: "footerTVC", bundle: nil)
        tableView.register(footerNib, forCellReuseIdentifier: "footer")
        
        likeCollection.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        
        setupBump()
        setupLikes()
        checkLikes()
        checkComments()
        
    }
    
    // MARK: – Data Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as? mapView
        vc?.feed = self.feed
        
        
    }
    
    // MARK: – Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return like.count
        case 1:
            return 1
        default:
            return like.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! likeCVC
            
            cell.configureLikes(lk: like[indexPath.row])
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "more", for: indexPath) as! moreCVC
            
            if liked.count >= 5 {
                
                cell.countLabel.isHidden = false
                
            } else if liked.count <= 4 {
                
                cell.countLabel.isHidden = true
                
            }
            
            cell.countLabel.text = "+\(liked.count - 4)"
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! likeCVC
            
            cell.configureLikes(lk: like[indexPath.row])
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            /*
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "groupVC") as! groupView
            self.navigationController?.pushViewController(vc, animated: true)
            */
            print("***This person's profile was selected!!")
            
        case 1:
            /*
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "groupVC") as! groupView
            self.navigationController?.pushViewController(vc, animated: true)
            */
            print("***You selected to see everyone who liked this!!")
            
        default:
            break
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section {
            
        case 0:
            return comment.count
        case 1:
            return 1
        default:
            return comment.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! commentTVC

            cell.configureCell(ct: comment[indexPath.row])
            
            cell.btnTapAction = {
                
                () in
                
                let user = self.comment[indexPath.row].author
                
                self.databaseRef.child("Users/\(user)").observeSingleEvent(of: .value) { (snap) in
                    
                    let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                    
                    self.replyName = name
                    
                    self.performSegue(withIdentifier: "replyName", sender: self)
                    
                }
                
            }

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "footer", for: indexPath) as! footerTVC

            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! commentTVC

            cell.configureCell(ct: comment[indexPath.row])
            
            cell.btnTapAction = {
                
                () in
                
                let user = self.comment[indexPath.row].author
                
                self.databaseRef.child("Users/\(user)").observeSingleEvent(of: .value) { (snap) in
                    
                    let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                    
                    self.replyName = name
                    
                }
                
                self.performSegue(withIdentifier: "replyName", sender: self)
                
            }

            return cell
        }
        
    }
    
    // Actions
    
    @IBAction func likeBtnTapped(_ sender: Any) {
        
        if likeBtn.isSelected == false {
            
            likeBtn.isSelected = true
            
            let id = self.feed.id
            let uid = Auth.auth().currentUser?.uid
            
            let ref = self.databaseRef.child("Feed/\(id)/Likes")
            
            let value = [uid: ["uid": uid!] as [String: Any]]
            
            DispatchQueue.main.async {
                
                ref.updateChildValues(value)
                
            }
            
        } else if likeBtn.isSelected == true {
            
            likeBtn.isSelected = false
            
            let id = self.feed.id
            let uid = Auth.auth().currentUser?.uid
            
            let ref = self.databaseRef.child("Feed/\(id)/Likes/\(uid!)")
            
            DispatchQueue.main.async {
                
                ref.removeValue()
                
            }
            
        }
        
    }
    
    // Functions
    
    func setupBump() {
        
        
        let uid = Auth.auth().currentUser?.uid
        let ref0 = databaseRef.child("Feed/\(feed.id)/Likes/\(uid!)")
        let ref1 = databaseRef.child("Users/\(feed.author)")
        let ref2 = databaseRef.child("Users/\(feed.recipient)")
        
        ref0.observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.likeBtn.isSelected = true
                
            } else {
                
                self.likeBtn.isSelected = false
                
            }
            
        }
        
        ref1.observeSingleEvent(of: .value) { (snapshot) in
            
            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let aname = fullname.components(separatedBy: " ")[0]
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            
            self.authorImg.loadImageUsingCacheWithUrlString(urlString: img)
            
            ref2.observeSingleEvent(of:.value) { (snapshot) in
                
                let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let name = fullname.components(separatedBy: " ")[0]
                let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                
                if self.feed.author == uid {
                    
                    self.detailsLabel.text = "You bumpd into \(name)\nat \(self.feed.location)\n\(self.feed.createdAt.timestampSinceNow())"
                    
                } else if self.feed.recipient == uid {
                    
                    self.detailsLabel.text = "\(aname)\nbumpd into You\nat \(self.feed.location)\n\(self.feed.createdAt.timestampSinceNow())"
                    
                } else {
                    
                    self.detailsLabel.text = "\(aname)\nbumpd into \(name)\nat \(self.feed.location)\n\(self.feed.createdAt.timestampSinceNow())"
                    
                }
                
                self.recipientImg.loadImageUsingCacheWithUrlString(urlString: img)
                
            }
            
        }
        
    }
    
    func setupLikes() {
        
        databaseRef.child("Feed/\(feed.id)/Likes").queryLimited(toFirst: 4).observeSingleEvent(of: .value) { (snapshot) in
            
            var array = [Likes]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let uid = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                let likey = Likes(uid: uid)
                
                array.append(likey)
                
            }
            
            self.like = array
            self.likeCollection.reloadData()
            
        }
        
    }
    
    func checkLikes() {
        
        databaseRef.child("Feed/\(feed.id)/Likes").observe(.value) { (snapshot) in
            
            var array = [Likes]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let uid = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                let likey = Likes(uid: uid)
                
                array.append(likey)
                
            }
            
            self.liked = array
            
        }
        
    }
    
    func checkComments() {
        
        databaseRef.child("Feed/\(feed.id)/Comments").observe(.value) { (snapshot) in
            
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
