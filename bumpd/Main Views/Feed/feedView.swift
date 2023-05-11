//
//  feedView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase

class feedView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var feed = [Feed]()
    var user = [Users]()
    var like = [Likes]()
    
    // Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        
        setupFeed()
        
    }
    
    // MARK: – Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bumps", for: indexPath) as! feedCell
        
        cell.setupCell(bump: feed[indexPath.row])
        
        return cell
        
    }
    
    // Actions
    
    
    
    // Functions
    
    func setupFeed() {
        
        let ref = databaseRef.child("Feed")
        
        ref.observe(.value, with: { (snapshot) in
            
            var array = [Feed]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                // Feed
                let author = child.childSnapshot(forPath: "author").value as? String ?? ""
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let location = child.childSnapshot(forPath: "location").value as? String ?? ""
                let receipt = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0
                
                // Likes
                let uids = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                // Snapshots
                let lke = Likes(uid: uids)
                let feeed = Feed(author: author, timestamp: stamp, id: id, likes: lke, location: location, recipient: receipt)
                
                array.append(feeed)
                
            }
            
            self.feed = array
            self.tableView.reloadData()
            
        })
        
    }
    

}
