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
    
    var btnTapAction1 : (()->())?
    var btnTapAction2 : (()->())?
    var btnTapAction3 : (()->())?
    
    // Outlets
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorImg: CustomizableImageView!
    @IBOutlet weak var recipientImg: CustomizableImageView!
    @IBOutlet weak var locationData: CustomizableButton!
    @IBOutlet weak var metaData: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var authBtn: UIButton!
    @IBOutlet weak var recipBtn: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.authorImg.image = nil
        self.recipientImg.image = nil
        self.metaData.text = nil
        
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
    
    func setupCell(bump: Feed) {
        
        let uid = Auth.auth().currentUser?.uid
        let ref1 = databaseRef.child("Users/\(bump.author)")
        let ref2 = databaseRef.child("Users/\(bump.recipient)")
        let ref3 = databaseRef.child("Feed/\(bump.id)/Likes/\(uid!)")

        ref1.observeSingleEvent(of: .value) { (snapshot) in
            
            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let aname = fullname.components(separatedBy: " ")[0]
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            
            self.authorImg.loadImageUsingCacheWithUrlString(urlString: img)
            
            ref2.observeSingleEvent(of: .value) { (snapshot) in

                let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let name = fullname.components(separatedBy: " ")[0]
                let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                
                if bump.author == uid {
                    
                    self.authorLabel.text = "You\nbumpd into\n\(name)"
                    
                } else if bump.recipient == uid {
                    
                    self.authorLabel.text = "\(aname)\nbumpd into\nYou"
                    
                } else {
                    
                    self.authorLabel.text = "\(aname)\nbumpd into\n\(name)"
                    
                }
                
                self.recipientImg.loadImageUsingCacheWithUrlString(urlString: img)

            }

        }
        
        locationData.setTitle("\(bump.location)", for: .normal)
        metaData.text = "\(bump.createdAt.timestampSinceNow())"
        
        ref3.observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.likeBtn.isSelected = true
                
            } else {
                
                self.likeBtn.isSelected = false
                
            }
            
        }
        
    }
    
    func setupViews() {
        
        likeBtn.addTarget(self, action: #selector(btnTapped1), for: .touchUpInside)
        
        authBtn.addTarget(self, action: #selector(btnTapped2), for: .touchUpInside)
        
        recipBtn.addTarget(self, action: #selector(btnTapped3), for: .touchUpInside)
        
    }
    
    @objc func btnTapped1() {
        
        btnTapAction1?()
        
    }
    
    @objc func btnTapped2() {
        
        btnTapAction2?()
        
    }
    
    @objc func btnTapped3() {
        
        btnTapAction3?()
        
    }

}
