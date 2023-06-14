//
//  profileView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase

class profileView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var storageRef: StorageReference! {
        
        return Storage.storage().reference()
    }
    
    var selectedImageFromPicker: UIImage?
    var bumpers = [Bumpers]()
    var bumps = [Bumps]()
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var topCollection: UICollectionView!
    @IBOutlet weak var bumpsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (self.handleSelectProfileImageView (_:)))
        editBtn.addGestureRecognizer(tapGesture)
        editBtn.isUserInteractionEnabled = true
        
        self.topCollection.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        self.bumpsTable.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        setupProfile()
        setupTopBumps()
        setupYourBumps()
        
    }
    
    // MARK: – Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return bumpers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! topCVC
        
        cell.setupCell(bums: bumpers[indexPath.row])
        
        return cell
        
    }
    
    
    // MARK: – Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bumps.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bump", for: indexPath) as! bumpTVC
        
        cell.setupCell(bum: bumps[indexPath.row])
        
        return cell
        
    }
    
    
    // Actions
    
    @IBAction func settingBtnTapped(_ sender: Any) {
        
        presentActionSheet()
        
    }
    
    // Functions
    
    func setupProfile() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let name = fullname.components(separatedBy: " ")[0]
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            self.nameLabel.text = name
            
        }
        
    }
    
    func setupTopBumps() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Bumpers").queryOrdered(byChild: "bumps").observe(.value) { (snapshot) in
            
            var array = [Bumpers]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let bmps = child.childSnapshot(forPath: "bumps").value as? Int ?? 0
                let uid = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                let bmpr = Bumpers(uid: uid, bumps: bmps)
                
                array.insert(bmpr, at: 0)
                
            }
            
            self.bumpers = array
            self.topCollection.reloadData()
            
            if self.bumpers.count != 0 {
                
                self.countLabel.text = "Bumpers: \(self.bumpers.count)"
                
            } else {
                
                self.countLabel.text = "Bumpers: 0"
                
            }
            
        }
        
    }
    
    func setupYourBumps() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Bumps").queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in

            var array = [Bumps]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {

                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let recipient = child.childSnapshot(forPath: "recipient").value as? String ?? ""

                let bmp = Bumps(author: auth, timestamp: stamp, id: id, location: local, latitude: lat, longitude: long, recipient: recipient)

                array.insert(bmp, at: 0)

            }
            
            self.bumps = array
            self.bumpsTable.reloadData()
            
            if self.bumps.count != 0 {
                
                self.totalLabel.text = "Total bumps: \(self.bumps.count)"
                
            } else {
                
                self.totalLabel.text = "Total bumps: 0"
                
            }

        }
        
    }
    
    @objc func handleSelectProfileImageView(_ sender:UITapGestureRecognizer){
        
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
            
            self.saveChanges()
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveChanges(){
        
        print("•••THIS SHOULD BE FIRING!!!")
        
        let imageName = NSUUID().uuidString
        let user = Auth.auth().currentUser?.uid
        
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
        
    }
    
    func presentActionSheet() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Settings", style: .default) { (action:UIAlertAction) in
            self.handleEdit()
        }
        
        let logoutAction = UIAlertAction(title: "Logout", style: .default) { (action:UIAlertAction) in
            self.logout()
        }

        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        actionSheet.addAction(dismissAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(logoutAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func handleEdit() {
        
//        let vc = storyboard?.instantiateViewController(withIdentifier: "editView")
//        self.present(vc!, animated: true, completion: nil)
        
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
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
    }
    
}
