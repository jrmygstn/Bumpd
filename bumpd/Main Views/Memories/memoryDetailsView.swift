//
//  memoryDetailsView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/14/23.
//

import UIKit
import Firebase

class memoryDetailsView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var storageRef: StorageReference! {
        
        return Storage.storage().reference()
    }
    
    var selectedImageFromPicker: UIImage?
    var memory: Memories!
    
    // Outlets
    
    @IBOutlet weak var messageField: TextViewWithPlaceholder!
    @IBOutlet weak var viewBg: UIImageView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var moreBtn: CustomizableButton!
    @IBOutlet weak var btnOne: CustomizableButton!
    @IBOutlet weak var btnTwo: CustomizableButton!
    @IBOutlet weak var btnThree: CustomizableButton!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        self.navigationController?.navigationBar.setNeedsLayout()
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.someAction (_:)))
        reportView.addGestureRecognizer(tap)
        reportView.isUserInteractionEnabled = true
        
        viewBg.darkBlur()
        
        messageField.textColor = .black
        
        checkMemory()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // .default
        return .darkContent
    }
    
    // MARK: – Data Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as? memoryDetailsTV
        vc?.memory = self.memory
        
    }
    
    // Actions
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "unwindToMemories", sender: nil)
        
    }
    
    @IBAction func captureBtnTapped(_ sender: Any) {
        
        self.handleSelectProfileImageView()
        
    }
    
    @IBAction func moreBtnTapped(_ sender: Any) {
        
        self.showOptions()
        
    }
    
    @IBAction func btnOneTapped(_ sender: Any) {
        
        if btnOne.isSelected == false {
            
            btnOne.isSelected = true
            btnTwo.isSelected = false
            btnThree.isSelected = false
            
        }
        
    }
    
    @IBAction func btnTwoTapped(_ sender: Any) {
        
        if btnTwo.isSelected == false {
            
            btnOne.isSelected = false
            btnTwo.isSelected = true
            btnThree.isSelected = false
            
        }
        
    }
    
    @IBAction func btnThreeTapped(_ sender: Any) {
        
        if btnThree.isSelected == false {
            
            btnOne.isSelected = false
            btnTwo.isSelected = false
            btnThree.isSelected = true
            
        }
        
    }
    
    @IBAction func submitBtnTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Thank You", message: "Your report was successful submitted. We will take the time to review the reported post within 12-24 hours.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        self.reportView.isHidden = true
        
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        
        if self.messageField.text != "" {
            
            self.addToMemories()
            self.notifyRecipient()
            
        }
        
        messageField.text = ""
        
    }
    
    // Functions
    
    @objc func someAction(_ sender:UITapGestureRecognizer){
        
        reportView.isHidden = true
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func checkMemory() {
        
        databaseRef.child("Feed/\(memory.id)/Memory").observeSingleEvent(of: .value) { (snap) in
            
            if snap.exists() {
                
                self.moreBtn.isHidden = false
                
            } else {
                
                self.moreBtn.isHidden = true
                
            }
            
        }
        
        
    }
    
    func addToMemories() {
        
        let text = self.messageField.text!
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Feed/\(memory.id)/Notes")
        let refKey = ref.childByAutoId()
        let key = refKey.key
        
        let comment = [key: ["author": uid!,
                       "id": key!,
                       "text": text,
                       "timestamp": ServerValue.timestamp()] as [String : Any]]
        
        ref.updateChildValues(comment)
        
    }
    
    func notifyRecipient() {
        
        let auth = memory.author
        let text = self.messageField.text!
        let recip = memory.recipient
        let uid = Auth.auth().currentUser?.uid
        let ref0 = databaseRef.child("Users/\(uid!)")
        let ref1 = databaseRef.child("Users/\(auth)/Notify")
        let refKey1 = ref1.childByAutoId()
        let key1 = refKey1.key
        
        let ref2 = databaseRef.child("Users/\(recip)/Notify")
        let refKey2 = ref2.childByAutoId()
        let key2 = refKey2.key
        
        if auth == uid && recip != uid {
            
            ref0.observeSingleEvent(of: .value) { (snapshot) in
                
                let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                
                let msg = "\(name) commented, \"\(text)\""
                
                let comment = [key2: ["author": uid!,
                                     "id": key2!,
                                     "text": msg,
                                     "timestamp": ServerValue.timestamp(),
                                     "unread": true] as [String : Any]]
                
                ref2.updateChildValues(comment)
                
            }
            
        } else if recip == uid && auth != uid {
            
            ref0.observeSingleEvent(of: .value) { (snapshot) in
                
                let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                
                let msg = "\(name) commented, \"\(text)\""
                
                let comment = [key1: ["author": uid!,
                                     "id": key1!,
                                     "text": msg,
                                     "timestamp": ServerValue.timestamp(),
                                     "unread": true] as [String : Any]]
                
                ref1.updateChildValues(comment)
                
            }
            
        }
        
    }
    
    func showOptions() {
        
        let actionSheet = UIAlertController()
        
        actionSheet.addAction(UIAlertAction(title: "Report", style: .destructive) {(action: UIAlertAction) in
            
            self.reportView.isHidden = false
            
        })
        actionSheet.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func handleSelectProfileImageView(){
        
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
            
            self.thumbnail.image = selectedImage
            
            self.saveChanges()
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func saveChanges(){
        
        let imageName = NSUUID().uuidString
        
        let storedImage = storageRef.child("memoryImage").child(imageName)
        
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
                        self.databaseRef.child("Feed/\(self.memory.id)/Memory").updateChildValues(["img" : urlText], withCompletionBlock: { (error, ref) in
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

}
