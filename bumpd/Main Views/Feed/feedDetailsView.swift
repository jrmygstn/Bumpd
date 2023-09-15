//
//  feedDetailsView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/23/23.
//

import UIKit
import Firebase

class feedDetailsView: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate {

    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var feed: Feed!
    var like = [Likes]()
    var liked = [Likes]()
    var comment = [Comments]()
    
    // Outlets
    
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var detailsTable: UITableView!
    
    @IBOutlet weak var authorImg: CustomizableImageView!
    @IBOutlet weak var recipientImg: CustomizableImageView!
    @IBOutlet weak var likeCollection: UICollectionView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var placeholder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        let cellNib = UINib(nibName: "commentTVC", bundle: nil)
        detailsTable.register(cellNib, forCellReuseIdentifier: "comment")
        
        let footerNib = UINib(nibName: "footerTVC", bundle: nil)
        detailsTable.register(footerNib, forCellReuseIdentifier: "footer")
        
        likeCollection.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        detailsTable.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        
        setupBump()
        setupLikes()
        checkLikes()
        checkComments()
        
        messageField.delegate = self
        messageField.textColor = .white
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // .default
        return .darkContent
    }
    
    // MARK: – Data Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as? mapView
        vc?.feed = self.feed
        
    }
    
    // MARK: – Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return comment.count
        case 1:
            return 1
        default:
            return comment.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! commentTVC

            cell.configureCell(ct: comment[indexPath.row])
            
            cell.btnTapAction = {
                
                () in
                
                let user = self.comment[indexPath.row].author
                
                self.databaseRef.child("Users/\(user)").observeSingleEvent(of: .value) { (snap) in
                    
                    let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
                    
                    self.messageField.text = "@\(name) "
                    self.placeholder.isHidden = true
                    
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
                    
                    self.messageField.text = "@\(name)"
                    
                }
                
                self.performSegue(withIdentifier: "replyName", sender: self)
                
            }

            return cell
        }
        
    }
    
    // MARK: – Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            if like.count != 0 {
                
                return like.count
                
            }
            
            return 4
        case 1:
            return 1
        default:
            if like.count != 0 {
                
                return like.count
                
            }
            
            return 4
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! likeCVC
            
            if like.count == 0 {
                
                cell.cellEmpty.isHidden = false
                
            } else {
                
                cell.configureLikes(lk: like[indexPath.row])
                
            }
            
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
            
            if like.count == 0 {
                
                cell.cellEmpty.isHidden = false
                
            } else {
                
                cell.configureLikes(lk: like[indexPath.row])
                
            }
            
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
    
    // Actions
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "unwindToFeed", sender: nil)
        
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        
        if self.messageField.text != "" {
            
            self.notifyAuthor()
            self.notifyRecipient()
            self.addToFeed()
            
        }
        
        messageField.text = ""
        placeholder.isHidden = false
        
    }
    
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        placeholder.isHidden = true
        return true
        
    }
    
    func addToFeed() {
        
        let ID = feed.id
        let text = self.messageField.text!
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Feed/\(ID)/Comments")
        let refKey = ref.childByAutoId()
        let key = refKey.key
        
        let comment = [key: ["author": uid!,
                       "id": key!,
                       "text": text,
                       "timestamp": ServerValue.timestamp()] as [String : Any]]
        
        ref.updateChildValues(comment)
        
    }
    
    func notifyAuthor() {
        
        let text = self.messageField.text!
        let auth = feed.author
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(auth)/Notify")
        let refKey = ref.childByAutoId()
        let key = refKey.key
        
        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            
            if auth != uid {
                
                let comment = [key: ["author": uid!,
                                     "id": key!,
                               "text": "\(name) commented, \"\(text)\"",
                                     "timestamp": ServerValue.timestamp(),
                                     "unread": true] as [String : Any]]
                
                ref.updateChildValues(comment)
                
            }
            
        }
        
    }
    
    func notifyRecipient() {
        
        let text = self.messageField.text!
        let recip = feed.recipient
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(recip)/Notify")
        let refKey = ref.childByAutoId()
        let key = refKey.key
        
        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            
            if recip != uid {
                
                let comment = [key: ["author": uid!,
                                     "id": key!,
                               "text": "\(name) commented, \"\(text)\"",
                                     "timestamp": ServerValue.timestamp(),
                                     "unread": true] as [String : Any]]
                
                ref.updateChildValues(comment)
                
            }
            
        }
        
    }
    
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
            self.detailsTable.reloadData()
            
        }
        
    }
    
}
