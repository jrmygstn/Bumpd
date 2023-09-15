//
//  allTVC.swift
//  bumpd
//
//  Created by Jeremy Gaston on 9/13/23.
//

import UIKit
import Firebase

class allTVC: UITableViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var btnTapAction : (()->())?
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.thumbnail.image = nil
        self.usernameLabel.text = nil
        self.nameLabel.text = nil
        self.moreBtn.isSelected = false
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupViews()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Functions
    
    func setupViews() {
        
        moreBtn.addTarget(self, action: #selector(someAction), for: .touchUpInside)
        
    }
    
    @objc func someAction(_ sender: UITapGestureRecognizer){
        
        btnTapAction?()
        
    }
    
    func setupCell(bum: Bumpers) {
        
        let user = bum.uid
        
        databaseRef.child("Users/\(user)").observeSingleEvent(of: .value) { (snap) in
            
            let img = snap.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            let usern = snap.childSnapshot(forPath: "username").value as? String ?? "newuser"
            let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            self.usernameLabel.text = usern
            self.nameLabel.text = name
            
        }
        
    }

}
