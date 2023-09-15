//
//  notifyCell.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/26/23.
//

import UIKit
import Firebase

class notifyCell: UITableViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var btnTapAction1 : (()->())?
    var btnTapAction2 : (()->())?
    var btnTapAction3 : (()->())?
    var btnTapAction4 : (()->())?
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var readBtn: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.thumbnail.image = nil
        self.txtLabel.text = nil
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
        
        acceptBtn.addTarget(self, action: #selector(btnTapped1), for: .touchUpInside)
        
        removeBtn.addTarget(self, action: #selector(btnTapped2), for: .touchUpInside)
        
        readBtn.addTarget(self, action: #selector(btnTapped3), for: .touchUpInside)
        
        blockBtn.addTarget(self, action: #selector(btnTapped4), for: .touchUpInside)
        
    }
    
    func setupCell(noti: Notify) {
        
        let ath = noti.author
        
        databaseRef.child("Users/\(ath)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            
        }
        
        txtLabel.text = noti.message
        timeLabel.text = noti.createdAt.timestampSinceNow()
        
        if noti.fid == "" {
            
            readBtn.isHidden = false
            acceptBtn.isHidden = true
            removeBtn.isHidden = true
            blockBtn.isHidden = true
            
        } else if noti.fid != "" {
            
            readBtn.isHidden = true
            acceptBtn.isHidden = false
            removeBtn.isHidden = false
            blockBtn.isHidden = false
            
        }
        
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
    
    @objc func btnTapped4() {
        
        btnTapAction4?()
        
    }

}
