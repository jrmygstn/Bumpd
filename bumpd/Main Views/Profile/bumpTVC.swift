//
//  bumpTVC.swift
//  bumpd
//
//  Created by Jeremy Gaston on 6/7/23.
//

import UIKit
import Firebase

class bumpTVC: UITableViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var recipientImg: CustomizableImageView!
    @IBOutlet weak var metaData: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var accessLabel: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.recipientImg.image = nil
        self.metaData.text = nil
        self.timestamp.text = nil
        self.accessLabel.image = nil
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(bum: Bumps) {
        
        let uid = bum.recipient
        
        databaseRef.child("Users/\(uid)").observe(.value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let name = fullname.components(separatedBy: " ")[0]
            
            self.recipientImg.loadImageUsingCacheWithUrlString(urlString: img)
            self.metaData.text = "You bumped into \(name) at \(bum.location)"
            self.timestamp.text = "\(bum.createdAt.timestampSinceNow())"
            
        }
        
    }

}
