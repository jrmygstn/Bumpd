//
//  feedView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase
import CoreLocation

class feedView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var feed = [Feed]()
    var like = [Likes]()
    var users = [Users]()
    
    // Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var latLabel: UITextField!
    @IBOutlet weak var longLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        
        checkForNotifications()
        
        locationManager.delegate = self
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        setupFeed()
        setupNearUsers()
        
    }
    
    // MARK: – Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bumps", for: indexPath) as! feedCell
        
        cell.setupCell(bump: feed[indexPath.row])
        
        cell.btnTapAction1 = {
            
            () in
            
            if cell.likeBtn.isSelected == false {
                
                cell.likeBtn.isSelected = true
                
                let id = self.feed[indexPath.row].id
                let uid = Auth.auth().currentUser?.uid
                
                let ref = self.databaseRef.child("Feed/\(id)/Likes")
                
                let value = [uid: ["uid": uid!] as [String: Any]]
                
                DispatchQueue.main.async {
                    
                    ref.updateChildValues(value)
                    
                }
                
            } else if cell.likeBtn.isSelected == true {
                
                cell.likeBtn.isSelected = false
                
                let id = self.feed[indexPath.row].id
                let uid = Auth.auth().currentUser?.uid
                
                let ref = self.databaseRef.child("Feed/\(id)/Likes/\(uid!)")
                
                DispatchQueue.main.async {
                    
                    ref.removeValue()
                    
                }
                
            }
            
        }
        
        cell.btnTapAction2 = {
            
            () in
            
            let vc = self.storyboard?.instantiateViewController(identifier: "feedProfileVC") as! feedProfileTV
            vc.auth = self.feed[indexPath.row].author
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        cell.btnTapAction3 = {
            
            () in
            
            let vc = self.storyboard?.instantiateViewController(identifier: "feedProfileVC") as! feedProfileTV
            vc.recip = self.feed[indexPath.row].recipient
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(identifier: "feedDetails") as! feedDetailsView
        vc.feed = feed[indexPath.row]
        self.present(vc, animated: true, completion: nil)
        
    }
    
    // Actions
    
    @IBAction func unwindToFeed(segue:UIStoryboardSegue) {
        
    }
    
    // Functions
    
    func setupFeed() {
        
        let ref = databaseRef.child("Feed")
        
        ref.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snapshot) in
            
            var array = [Feed]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                // Feed
                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let authId = child.childSnapshot(forPath: "authId").value as? String ?? ""
                let author = child.childSnapshot(forPath: "author").value as? String ?? ""
                let bumpId = child.childSnapshot(forPath: "bumpId").value as? String ?? ""
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0
                let location = child.childSnapshot(forPath: "location").value as? String ?? ""
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0
                let recipId = child.childSnapshot(forPath: "recipId").value as? String ?? ""
                let receipt = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0
                
                // Likes
                let uids = child.childSnapshot(forPath: "uid").value as? String ?? ""
                
                // Snapshots
                
                if approve != false {
                    
                    let lke = Likes(uid: uids)
                    let feeed = Feed(approved: approve, authId: authId, author: author, bumpId: bumpId, timestamp: stamp, id: id, lat: lat, likes: lke, location: location, long: long, recipId: recipId, recipient: receipt)
                    
                    array.insert(feeed, at: 0)
                    
                }
                
            }
            
            self.feed = array
            self.tableView.reloadData()
            
        })
        
    }
    
    func setupNearUsers() {
        
        let date = Date()
        let today = date.getFormattedDate(format: "YYYY-MM-dd HH:mm")
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users").observe(.value) { (snapshot) in
            
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
                                
                                if todayStamp ?? 0 > lastStamp ?? 0 {
                                    
                                    self.addRedDot(index: 2)
                                    
                                } else if todayStamp ?? 0 <= lastStamp ?? 0 {
                                    
                                    if let items = self.tabBarController?.tabBar.items as NSArray? {
                                        let tabItem = items.object(at: 2) as! UITabBarItem
                                        tabItem.badgeValue = nil
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            self.users = array
            
        }
        
    }
    
    func checkForNotifications() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Notify").observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.addRedDot(index: 3)
                
            } else {
                
                if let items = self.tabBarController?.tabBar.items as NSArray? {
                    let tabItem = items.object(at: 3) as! UITabBarItem
                    tabItem.badgeValue = nil
                }
                
            }
            
        }
        
    }
    
    func addRedDot(index: Int) {
        
        for subview in tabBarController!.tabBar.subviews {
            
            if let subview = subview as? UIView {
                
                if subview.tag == 1234 {
                    subview.removeFromSuperview()
                    break
                }
                
            }
            
            let RedDotRadius: CGFloat = 5
            let RedDotDiameter = RedDotRadius * 2

            let TopMargin:CGFloat = 5

            let TabBarItemCount = CGFloat(self.tabBarController!.tabBar.items!.count)

            let screenSize = UIScreen.main.bounds
            let HalfItemWidth = (screenSize.width) / (TabBarItemCount * 2)

            let  xOffset = HalfItemWidth * CGFloat(index * 2 + 1)

            let imageHalfWidth: CGFloat = (self.tabBarController!.tabBar.items![index] ).selectedImage!.size.width / 2

            let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth + 3, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))

            redDot.tag = 1234
            redDot.backgroundColor = UIColor.red
            redDot.layer.cornerRadius = RedDotRadius

            self.tabBarController?.tabBar.addSubview(redDot)
            
        }
        
    }

}

extension feedView: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let lt: Double = Double(location.coordinate.latitude.formatted()) ?? 0.0
        let lng: Double = Double(location.coordinate.longitude.formatted()) ?? 0.0
        
        self.latLabel.text = "\(lt)"
        self.longLabel.text = "\(lng)"
        
        print("MY LAT & LONG ARE -->> \(self.latLabel.text!), \(self.longLabel.text!)")
        
    }
}
