//
//  bumpView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import CoreLocation

class bumpView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    let geocoder = GMSGeocoder()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var usr = [Users]()
    var user = [Users]()
    var users = [Users]()
    var feed = [Feed]()
    
    // Outlets
    
    @IBOutlet weak var addBtn: CustomizableButton!
    @IBOutlet weak var textField: UILabel!
    @IBOutlet weak var bumpView: UIView!
    @IBOutlet weak var thumbnail: CustomizableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UITextField!
    @IBOutlet weak var memLocalField: UITextField!
    @IBOutlet weak var localField: UITextField!
    @IBOutlet weak var latLabel: UITextField!
    @IBOutlet weak var longLabel: UITextField!
    @IBOutlet weak var feedField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var recipField: UITextField!
    @IBOutlet weak var keyField: UITextField!
    
    @IBOutlet weak var nearCollection: UICollectionView!
    @IBOutlet weak var nearView: CustomizableView!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForBumpers()
        setupNearbyUsers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        nearCollection.backgroundColor = UIColor(red: 201/255, green: 152/255, blue: 137/255, alpha: 0.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (self.handleCloseView (_:)))
        bumpView.addGestureRecognizer(tapGesture)
        bumpView.isUserInteractionEnabled = true
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()        
    }
    
    // MARK: – Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return users.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "person", for: indexPath) as! addCVC
        
        cell.setupCell(user: users[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.thumbnail.loadImageUsingCacheWithUrlString(urlString: users[indexPath.row].img)
        self.nameLabel.text = "Looks like \(users[indexPath.row].name) is close to you, want to bump?"
        self.textField.text = users[indexPath.row].uid
        self.bumpView.isHidden = false
        self.addBtn.isHidden = false
        
    }
    
    // Actions
    
    @IBAction func addBtnTapped(_ sender: Any) {
        
        if self.nearView.isHidden == true {
            
            self.nearView.isHidden = false
            self.bottomView.isHidden = false
            
        } else {
            
            self.nearView.isHidden = true
            self.bottomView.isHidden = true
            
        }
        
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        
        self.nearView.isHidden = true
        self.bottomView.isHidden = true
        
    }
    
    @IBAction func yesBtnTapped(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            self.addToAuthor()
            self.addToRecipient()
            self.addToFeed()
            self.sendRequest()
            
        }
        
        bumpView.isHidden = true
        nearView.isHidden = true
        bottomView.isHidden = true
        
    }
    
    @IBAction func noBtnTapped(_ sender: Any) {
        
        bumpView.isHidden = true
        
    }
    
    // Functions
    
    @objc func handleCloseView(_ sender:UITapGestureRecognizer){
        
        bumpView.isHidden = true
        
    }
    
    func checkForBumpers() {
        
        let date = Date()
        let today = date.getFormattedDate(format: "YYYY-MM-dd HH:mm")
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users").observe(.value) { (snapshot) in
            
            var array = [Users]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let age = child.childSnapshot(forPath: "age").value as? String ?? ""
                let birth = child.childSnapshot(forPath: "birthday").value as? String ?? ""
                let email = child.childSnapshot(forPath: "email").value as? String ?? ""
                let gender = child.childSnapshot(forPath: "gender").value as? String ?? ""
                let img = child.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let name = child.childSnapshot(forPath: "name").value as? String ?? ""
                let user = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                if user != uid {
                    
                    let use = Users(age: age, birthday: birth, email: email, gender: gender, img: img, latitude: lat, longitude: long, name: name, uid: user)
                    array.append(use)
                    
                    self.databaseRef.child("Users/\(uid!)").observe(.value) { (snapshot) in
                        
                        let myLat = snapshot.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                        let myLong = snapshot.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                        
                        let coordinance1 = CLLocation(latitude: myLat, longitude: myLong)
                        let coordinance2 = CLLocation(latitude: lat, longitude: long)
                        let distance = coordinance2.distance(from: coordinance1)
                        let distanceInMeters: Double = Double(distance.formatted()) ?? 0.0
                        
                        // Compare how close you are to someone else
                        
                        if (distanceInMeters < 22.191969 && distanceInMeters != 0.0) {
                            
                            self.databaseRef.child("Users/\(uid!)/Bumpers/\(user)").observe(.value) { (snapshot) in
                                
                                let last = snapshot.childSnapshot(forPath: "last").value as? String ?? ""
                                
                                // Getting today's date
                                
                                let todayFormat = DateFormatter()
                                let lastFormat = DateFormatter()
                                
                                todayFormat.dateFormat = "YYYY-MM-dd HH:mm"
                                lastFormat.dateFormat = "YYYY-MM-dd HH:mm"
                                
                                let todayStr = todayFormat.date(from: today)
                                let lastStr = lastFormat.date(from: last)
                                
                                let todayStamp = todayStr?.timeIntervalSince1970
                                let lastStamp = lastStr?.timeIntervalSince1970
                                
                                // Have you bumped in the past hour?
                                
                                if todayStamp ?? 0 <= lastStamp ?? 0 {
                                    
                                    self.addBtn.isHidden = true
                                    
                                } else if todayStamp ?? 0 > lastStamp ?? 0 {
                                    
                                    self.addBtn.isHidden = false
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            self.usr = array
            
        }
        
    }
    
    func setupNearbyUsers() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users")
        
        ref.observe(.value, with: { (snapshot) in
            
            var array = [Users]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                // Feed
                let age = child.childSnapshot(forPath: "age").value as? String ?? ""
                let birth = child.childSnapshot(forPath: "birthday").value as? String ?? ""
                let email = child.childSnapshot(forPath: "email").value as? String ?? ""
                let gender = child.childSnapshot(forPath: "gender").value as? String ?? ""
                let img = child.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let name = child.childSnapshot(forPath: "name").value as? String ?? ""
                let user = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                let myLat: Double = Double(self.latLabel.text!) ?? 0.0
                let myLong: Double = Double(self.longLabel.text!) ?? 0.0
                let coordinance1 = CLLocation(latitude: myLat, longitude: myLong)
                let coordinance2 = CLLocation(latitude: lat, longitude: long)
                let distance = coordinance2.distance(from: coordinance1)
                let distanceInMeters: Double = Double(distance.formatted()) ?? 0.0
                
                if (user != uid && distanceInMeters < 22.191969 && distanceInMeters != 0.0) {
                    
                    let use = Users(age: age, birthday: birth, email: email, gender: gender, img: img, latitude: lat, longitude: long, name: name, uid: user)
                    
                    array.append(use)
                    
                }
                
            }
            
            self.users = array
            self.nearCollection.reloadData()
            
        })
        
    }
    
    func checkIfBumpd() {
        
        let date = Date()
        let today = date.getFormattedDate(format: "YYYY-MM-dd HH:mm")
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users").observeSingleEvent(of: .value) { (snapshot) in
            
            var array = [Users]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let age = child.childSnapshot(forPath: "age").value as? String ?? ""
                let birth = child.childSnapshot(forPath: "birthday").value as? String ?? ""
                let email = child.childSnapshot(forPath: "email").value as? String ?? ""
                let gender = child.childSnapshot(forPath: "gender").value as? String ?? ""
                let img = child.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let name = child.childSnapshot(forPath: "name").value as? String ?? ""
                let user = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                if user != uid {
                    
                    let use = Users(age: age, birthday: birth, email: email, gender: gender, img: img, latitude: lat, longitude: long, name: name, uid: user)
                    array.append(use)
                    
                    self.databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
                        
                        let myLat = snapshot.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                        let myLong = snapshot.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                        
                        let coordinance1 = CLLocation(latitude: myLat, longitude: myLong)
                        let coordinance2 = CLLocation(latitude: lat, longitude: long)
                        let distance = coordinance2.distance(from: coordinance1)
                        let distanceInMeters: Double = Double(distance.formatted()) ?? 0.0
                        
                        // Compare how close you are to someone else
                        
                        if (distanceInMeters < 22.191969 && distanceInMeters != 0.0) {
                            
                            self.databaseRef.child("Users/\(uid!)/Bumpers/\(user)").observeSingleEvent(of: .value) { (snapshot) in
                                
                                let last = snapshot.childSnapshot(forPath: "last").value as? String ?? ""
                                
                                // Getting today's date
                                
                                let todayFormat = DateFormatter()
                                let lastFormat = DateFormatter()
                                
                                todayFormat.dateFormat = "YYYY-MM-dd HH:mm"
                                lastFormat.dateFormat = "YYYY-MM-dd HH:mm"
                                
                                let todayStr = todayFormat.date(from: today)
                                let lastStr = lastFormat.date(from: last)
                                
                                let todayStamp = todayStr?.timeIntervalSince1970
                                let lastStamp = lastStr?.timeIntervalSince1970
                                
                                // Have you bumped in the past hour?
                                
                                if todayStamp ?? 0 <= lastStamp ?? 0 {
                                    
                                    self.bumpView.isHidden = true
                                    self.addBtn.isHidden = true
                                    
                                } else if todayStamp ?? 0 > lastStamp ?? 0 {
                                    
                                    self.addBtn.isHidden = false
                                    self.bumpView.isHidden = false
                                    
                                    self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
                                    self.nameLabel.text = "Looks like \(name) is close to you, want to bump?"
                                    self.textField.text = user
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            self.user = array
            
        }
        
    }
    
    func addToFeed() {
        
        let user = textField.text!
        let place = localField.text!
        let details = memLocalField.text!
        let uid = Auth.auth().currentUser?.uid
        
        let ref = databaseRef.child("Feed")
        let refKey = ref.childByAutoId()
        let key = refKey.key
        
        let dateForm = DateFormatter()
        let monForm = DateFormatter()
        let now = Date()
        
        dateForm.dateFormat = "EEE, MMM dd"
        monForm.dateFormat = "MMMM"
        
        let month = monForm.string(from: now)
        let lat: Double = Double(self.latLabel.text!) ?? 0.0
        let long: Double = Double(self.longLabel.text!) ?? 0.0
        
        keyField.text = key
        
        let value = [key: ["approved": false, "author": uid!, "date": "\(dateForm.string(from: now))", "details": details, "id": key!, "latitude": lat, "location": place, "longitude": long, "month": month, "recipient": user, "timestamp": ServerValue.timestamp()] as [String : Any]]
        
        ref.updateChildValues(value)
        
    }
    
    func addToAuthor() {
        
        let user = textField.text!
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)/Bumpers/\(user)")
        
        let dayForm = DateFormatter()
        dayForm.dateStyle = .medium
        dayForm.timeStyle = .medium
        
        let now = Date()
        
        dayForm.dateFormat = "YYYY-MM-dd HH:mm"
        
        let calendar = Calendar.current
        
        let todayDate = calendar.dateComponents([.month, .day, .year, .hour, .minute], from: now)
        
        let today = "\(todayDate.year!)-\(todayDate.month!)-\(todayDate.day!) \(todayDate.hour! + 1):\(todayDate.minute!)"
        
        databaseRef.child("Users/\(uid!)/Bumpers/\(user)").observeSingleEvent(of: .value) { (snapshot) in
            
            let bumps = snapshot.childSnapshot(forPath: "bumps").value as? Int ?? 0
            
            let value = ["uid": user, "bumps": bumps + 1, "last": today, "timestamp": ServerValue.timestamp()] as [String : Any]
            
            ref.updateChildValues(value)
            
        }
        
    }
    
    func addToRecipient() {
        
        let user = textField.text!
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(user)/Bumpers/\(uid!)")
        
        let dayForm = DateFormatter()
        dayForm.dateStyle = .medium
        dayForm.timeStyle = .medium
        
        let now = Date()
        
        dayForm.dateFormat = "YYYY-MM-dd HH:mm"
        
        let calendar = Calendar.current
        
        let todayDate = calendar.dateComponents([.month, .day, .year, .hour, .minute], from: now)
        
        let today = "\(todayDate.year!)-\(todayDate.month!)-\(todayDate.day!) \(todayDate.hour! + 1):\(todayDate.minute!)"
        
        databaseRef.child("Users/\(user)/Bumpers/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let bumps = snapshot.childSnapshot(forPath: "bumps").value as? Int ?? 0
            
            let value = ["uid": uid!, "bumps": bumps + 1, "last": today, "timestamp": ServerValue.timestamp()] as [String : Any]
            
            ref.updateChildValues(value)
            
        }
        
    }
    
    func sendRequest() {
        
        let fid = keyField.text!
        let user = textField.text!
        let uid = Auth.auth().currentUser?.uid
        let ref1 = databaseRef.child("Users/\(user)/Notify")
        let refKey1 = ref1.childByAutoId()
        let key1 = refKey1.key
        
        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            
            let msg = "\(name) wants to bump with you!"
            
            let value = [key1: ["approved": false, "author": uid!, "feedId": fid, "id":key1!, "text": msg, "timestamp": ServerValue.timestamp(), "unread": true] as [String : Any]]
            
            ref1.updateChildValues(value)
            
        }
        
    }

}

extension bumpView: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let lt: Double = Double(location.coordinate.latitude.formatted()) ?? 0.0
        let lng: Double = Double(location.coordinate.longitude.formatted()) ?? 0.0
        
        self.latLabel.text = "\(lt)"
        self.longLabel.text = "\(lng)"
        
        let position = CLLocationCoordinate2D(latitude: lt, longitude: lng)
        
        geocoder.reverseGeocodeCoordinate(position) { response, error in
            
            guard let address = response?.firstResult(), let loco = address.locality, let area = address.thoroughfare, let state = address.administrativeArea else {
                return
            }
            
            print("**** LOCATION: \(loco), \(state)")
            print("**** LOCATION DETAILS: \(area), \(loco)")
            
            self.localField.text = "\(loco), \(state)"
            self.memLocalField.text = "\(area), \(loco)"
            
        }
        
    }
}
