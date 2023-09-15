//
//  commentTVC.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/13/23.
//

import UIKit
import Firebase

class commentTVC: UITableViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var btnTapAction : (()->())?
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnail.image = nil
        self.messageLabel.text = nil
        self.dateLabel.text = nil
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
        
        replyBtn.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        
    }
    
    @objc func btnTapped() {
        
        btnTapAction?()
        
    }
    
    func configureCell(ct: Comments){
        
        let uid = ct.author
        
        databaseRef.child("Users/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            
        }
        
        messageLabel.text = ct.text
        dateLabel.text = ct.createdAt.sentSinceNow()
        
        
    }
    
}
