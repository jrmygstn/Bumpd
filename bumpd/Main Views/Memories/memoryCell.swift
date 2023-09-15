//
//  memoryCell.swift
//  bumpd
//
//  Created by Jeremy Gaston on 6/14/23.
//

import UIKit
import Firebase

class memoryCell: UITableViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var btnTapAction1 : (()->())?
    var btnTapAction2 : (()->())?
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cellBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var cellEmpty: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnail.image = nil
        self.nameLabel.text = nil
        self.timeLabel.text = nil
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
        
        cellBtn.addTarget(self, action: #selector(someAction), for: .touchUpInside)
        profileBtn.addTarget(self, action: #selector(profileAction), for: .touchUpInside)
        
    }
    
    @objc func someAction(_ sender: UITapGestureRecognizer){
        
        btnTapAction1?()
        
    }
    
    @objc func profileAction(_ sender: UITapGestureRecognizer){
        
        btnTapAction2?()
        
    }
    
    func setupCell(mem: Memories) {
        
        cellEmpty.isHidden = true
        
        let uid = Auth.auth().currentUser?.uid
        
        if mem.author == uid && mem.recipient != uid {
            
            databaseRef.child("Users/\(mem.recipient)").observe(.value) { (snapshot) in
                
                let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let name = fullname.components(separatedBy: " ")[0]
                let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                
                self.nameLabel.text = "You bumpd with \(name)\nat \(mem.details)"
                self.timeLabel.text = "\(mem.date)"
                self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
                
            }
            
        } else if mem.recipient == uid && mem.author != uid {
            
            databaseRef.child("Users/\(mem.author)").observe(.value) { (snapshot) in
                
                let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let name = fullname.components(separatedBy: " ")[0]
                let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                
                self.nameLabel.text = "\(name) bumpd with you\nat \(mem.details)"
                self.timeLabel.text = "\(mem.date)"
                self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
                
            }
            
        }
        
    }

}
