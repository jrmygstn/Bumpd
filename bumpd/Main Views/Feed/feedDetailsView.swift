//
//  feedDetailsView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/23/23.
//

import UIKit
import Firebase

class feedDetailsView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var feed: Feed!
    var like = [Likes]()
    
    // Outlets
    
    @IBOutlet weak var authorImg: CustomizableImageView!
    @IBOutlet weak var recipientImg: CustomizableImageView!
    @IBOutlet weak var likeCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        likeCollection.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        setupBump()
        setupLikes()
        
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
            
            if like.count >= 5 {
                
                print("IT'S GREATER THAN OR EQUAL TO 5!!!!")
                
                cell.countLabel.isHidden = false
                
            } else if like.count <= 4 {
                
                print("IT'S LESS THAN OR EQUAL TO 4!!!!")
                
                cell.countLabel.isHidden = true
                
            }
            
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
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "groupVC") as! groupView
//            self.navigationController?.pushViewController(vc, animated: true)
            print("***This person's profile was selected!!")
        case 1:
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "groupVC") as! groupView
//            self.navigationController?.pushViewController(vc, animated: true)
            print("***You selected to see everyone who liked this!!")
        default:
            break
        }
        
    }
    
    // Actions
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "unwindToFeed", sender: nil)
        
    }
    
    // Functions
    
    func setupBump() {
        
        databaseRef.child("Users/\(feed.author)").observe(.value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImg%2Fprofile-img%402x.png?alt=media&token=22b312c9-65e0-4463-a126-21ee2fdcdd61"
            
            self.authorImg.loadImageUsingCacheWithUrlString(urlString: img)
            
        }
        
        databaseRef.child("Users/\(feed.recipient)").observe(.value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImg%2Fprofile-img%402x.png?alt=media&token=22b312c9-65e0-4463-a126-21ee2fdcdd61"
            
            self.recipientImg.loadImageUsingCacheWithUrlString(urlString: img)
            
        }
        
    }
    
    func setupLikes() {
        
        databaseRef.child("Feed/\(feed.id)/Likes").queryLimited(toFirst: 4).observe(.value) { (snapshot) in
            
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
    
}
