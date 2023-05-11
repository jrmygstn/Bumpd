//
//  feedCell.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import UIKit
import Firebase

class feedCell: UITableViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var authorImg: CustomizableImageView!
    @IBOutlet weak var recipientImg: CustomizableImageView!
    @IBOutlet weak var metaData: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.authorImg.image = nil
        self.recipientImg.image = nil
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(bump: Feed) {
        
        let ref1 = databaseRef.child("Users/\(bump.author)")
        let ref2 = databaseRef.child("Users/\(bump.recipient)")

        ref1.observe(.value) { (snapshot) in
            
            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let name = fullname.components(separatedBy: " ")[0]
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImg%2Fprofile-img%402x.png?alt=media&token=22b312c9-65e0-4463-a126-21ee2fdcdd61"
            
            self.authorLabel.text = "\(name)\nbumpd with"
            self.authorImg.loadImageUsingCacheWithUrlString(urlString: img)

        }

        ref2.observe(.value) { (snapshot) in

            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let name = fullname.components(separatedBy: " ")[0]
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImg%2Fprofile-img%402x.png?alt=media&token=22b312c9-65e0-4463-a126-21ee2fdcdd61"
            
            self.recipientLabel.text = name
            self.recipientImg.loadImageUsingCacheWithUrlString(urlString: img)

        }
        
        metaData.text = "\(bump.location)\n\(bump.createdAt.timestampSinceNow())"
        
    }

}
