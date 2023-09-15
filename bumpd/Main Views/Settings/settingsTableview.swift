//
//  settingsTableview.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/27/23.
//

import UIKit
import Firebase

class settingsTableview: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var storageRef: StorageReference! {
        
        return Storage.storage().reference()
    }
    
    var selectedImageFromPicker: UIImage?
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var editBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (self.handleUpdateProfile (_:)))
        thumbnail.addGestureRecognizer(tapGesture)
        thumbnail.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector (self.handleUpdateProfile (_:)))
        editBtn.addGestureRecognizer(tapGesture2)
        editBtn.isUserInteractionEnabled = true
        
        setupProfile()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }
    
    // Actions
    
    @IBAction func unwindToSettings(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "unwindToProfile", sender: nil)
        
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        
        self.saveProfile()
        
        self.performSegue(withIdentifier: "unwindToProfile", sender: nil)
        
    }
    
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        
        self.logout()
        
    }
    
    @IBAction func privacyBtn(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "privacyNav")
        self.present(vc!, animated: true)
        
    }
    
    @IBAction func shareBtnTapped(_ sender: Any) {
        
        let textToShare = "Let's use Bumpd to share some of our favorite experiences!"
        
        if let myApp = NSURL(string: "https://apps.apple.com/us/app/bumpd-app/id6449561535") {
            let objectsToShare = [textToShare, myApp] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.print, UIActivity.ActivityType.saveToCameraRoll, UIActivity.ActivityType.markupAsPDF]
            
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func rateBtnTapped(_ sender: Any) {
        
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id6449561535?action=write-review") else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func communityBtnTapped(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "communityNav")
        self.present(vc!, animated: true)
        
    }
    
    @IBAction func policyBtnTapped(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "policyNav")
        self.present(vc!, animated: true)
        
    }
    
    @IBAction func termsBtnTapped(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "termsNav")
        self.present(vc!, animated: true)
        
    }
    
    @IBAction func accountBtnTapped(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "accountNav")
        self.present(vc!, animated: true)
        
    }
    
    @IBAction func helpBtnTapped(_ sender: Any) {
        
        
        
    }
    
    // Functions
    
    func setupProfile() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            self.nameLabel.text = name
            
        }
        
    }
    
    @objc func handleUpdateProfile(_ sender:UITapGestureRecognizer){
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        let actionSheet = UIAlertController()
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            thumbnail.image = selectedImage
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveProfile(){
        
        let imageName = NSUUID().uuidString
        let user = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(user!)")
        
        let storedImage = storageRef.child("profileImage").child(imageName)
        
        if let uploadData = self.thumbnail.image!.jpegData(compressionQuality: 0.6) {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        self.databaseRef.child("Users/\(user!)").updateChildValues(["img" : urlText], withCompletionBlock: { (error, ref) in
                            if error != nil{
                                print(error!)
                                return
                            }
                        })
                    }
                })
            })
        }
        
        let value = ["name": self.nameLabel.text!]
        
        ref.updateChildValues(value)
        
    }
    
    func logout(){
        
        do {
            try Auth.auth().signOut()
            
            if Auth.auth().currentUser == nil {
                UserDefaults.standard.removeObject(forKey: "uid")
                UserDefaults.standard.synchronize()
            }
            let controller = storyboard?.instantiateViewController(withIdentifier: "landingView")
            self.present(controller!, animated: false, completion: nil)
        } catch {
            print(error)
        }
        
    }

}
