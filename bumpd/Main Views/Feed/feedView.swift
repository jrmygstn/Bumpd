//
//  feedView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase
import CoreLocation

extension feedView :UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class feedView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var feed = [Feed]()
    var like = [Likes]()
    var users = [Users]()
    var feedData: [String: [String: Any]] = [:]
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var refreshControl: UIRefreshControl!
    var refreshButton: RefreshButton!
    var refreshButtonTopAnchor: NSLayoutConstraint!
    
    // Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var latLabel: UITextField!
    @IBOutlet weak var longLabel: UITextField!

    @IBOutlet weak var heightMarginTableview: NSLayoutConstraint!

    var lastVelocityYSign = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.delegate = self
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        checkForNotifications()
        setupFeed()
        setupNearUsers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var layoutGuide: UILayoutGuide!
        layoutGuide = view.safeAreaLayoutGuide
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        tableView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        refreshButton = RefreshButton()
        view.addSubview(refreshButton)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        refreshButtonTopAnchor = refreshButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44.0)
        refreshButtonTopAnchor.isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        refreshButton.widthAnchor.constraint(equalToConstant: 125.0).isActive = true
        refreshButton.button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 121/255, green: 138/255, blue: 167/255, alpha: 1.0)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        
        if tableView.isDragging, tableView.isDecelerating || tableView.isTracking {
            print("load")
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     let currentVelocityY =  scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y
     let currentVelocityYSign = Int(currentVelocityY).signum()
     if currentVelocityYSign != lastVelocityYSign &&
        currentVelocityYSign != 0 {
            lastVelocityYSign = currentVelocityYSign
     }
        if lastVelocityYSign < 0 {
            print("SCROLLING DOWN")
            if let tabBarController =  self.navigationController?.topViewController?.parent?.tabBarController as? UITabBarController {
                self.heightMarginTableview.constant = -70
                tabBarController.tabBar.isHidden = true
                
            }
        } else if lastVelocityYSign > 0 {
            print("SCOLLING UP")
            if let tabBarController =  self.navigationController?.topViewController?.parent?.tabBarController as? UITabBarController {
                self.heightMarginTableview.constant = 0
                tabBarController.tabBar.isHidden = false
            }
        }
    }

    
    // MARK: – Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bumps", for: indexPath) as! feedCell
        
        let id = feed[indexPath.row].id
        let uid = Auth.auth().currentUser?.uid
        
        cell.setupCell(bump: feed[indexPath.row])
        
        cell.btnTapAction1 = {
            
            () in
            
            if cell.likeBtn.isSelected == false {
                
                cell.likeBtn.isSelected = true
                
                let ref = self.databaseRef.child("Feed/\(id)/Likes")
                
                let value = [uid: ["uid": uid!] as [String: Any]]
                
                DispatchQueue.main.async {
                    
                    ref.updateChildValues(value)
                    
                }
                
            } else if cell.likeBtn.isSelected == true {
                
                cell.likeBtn.isSelected = false
                
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
        vc.feed = self.feed[indexPath.row]
        self.present(vc, animated: true, completion: nil)
        
    }
    
    // Actions
    
    @IBAction func unwindToFeed(segue:UIStoryboardSegue) {
        
    }
    
    // Functions
    
    @objc func handleRefresh() {
        
        toggleRefreshButton(hidden: true)
        
        refreshFeed()
        print("IT IS REFRESHING!!!!")
        
    }
    
    func toggleRefreshButton(hidden: Bool) {
        
        if hidden {
            
            // hide it
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.refreshButtonTopAnchor.constant = -44.0
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            
            // show it
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.refreshButtonTopAnchor.constant = 12
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
    func setupFeed() {
        
        let ref = databaseRef.child("Feed")
        
        ref.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (snapshot) in
            
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
            
        }
        
    }
    
    func refreshFeed() {
        
        let ref = databaseRef.child("Feed")
        
        ref.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
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
            
            self.feed.insert(contentsOf: array, at: 0)
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            
            
            
        })
        
    }
    
    func listenForNewBumps() {
        
        let ref = databaseRef.child("Feed")
        
        ref.queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) in
            
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
                
                if snapshot.key != self.feed.first?.id {
                    
                    self.toggleRefreshButton(hidden: false)
                    
                } else {
                    
                    self.toggleRefreshButton(hidden: true)
                    
                }
                
            }
            
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
                                    
                                    self.addRedDot(index: 2, shouldShow: true)
                                    
                                } else if todayStamp ?? 0 <= lastStamp ?? 0 {
                                    
                                    self.addRedDot(index: 2, shouldShow: false)
                                    
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
                
                self.addRedDot(index: 3, shouldShow: true)
                self.showConfirmAccept(items: snapshot.children.allObjects as? [DataSnapshot] ?? [])
            } else {
                
                self.addRedDot(index: 3, shouldShow: false)
                
            }
            
          
        }
        
    }
    
    func showConfirmAccept(items: [DataSnapshot]){
       // for child in snapshot.children.allObjects as! [DataSnapshot]
        let uid = Auth.auth().currentUser?.uid
        var array = [Notify]()
        
        for child in items {
            
            let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
            let author = child.childSnapshot(forPath: "author").value as? String ?? ""
            let time = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
            let text = child.childSnapshot(forPath: "text").value as? String ?? ""
            let fid = child.childSnapshot(forPath: "feedId").value as? String ?? ""
            let id = child.childSnapshot(forPath: "id").value as? String ?? ""
            let unread = child.childSnapshot(forPath: "unread").value as? Bool ?? true
            
            let noty = Notify(approved: approve, timestamp: time, message: text, author: author, fid: fid, id: id, unread: unread)
             
            if(text.contains("accepted your bump!") && !unread){
                   
                let ref0 = self.databaseRef.child("Feed/\(fid)")
                let ref1 = self.databaseRef.child("Users/\(uid!)/Notify/\(id)")
                let ref2 = self.databaseRef.child("Users/\(author)/Notify")
                let refKey = ref2.childByAutoId()
                let key = refKey.key
                
                let value0 = ["approved": true]
                
                self.databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
                    
                    let name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                    
                    let value2 = [key: ["author": uid!, "id": key!, "text": "\(name) accepted your bump!", "timestamp": ServerValue.timestamp(), "unread": true] as [String : Any]]
                    
                    ref2.updateChildValues(value2)
                    
                }
                
                ref0.updateChildValues(value0)
                ref1.removeValue()
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "confirmView") as! confirmView
                vc.notify = noty
                self.present(vc, animated: true)
            }
            
        }
    }
    
    func addRedDot(index: Int, shouldShow: Bool) {
        guard let tabBarItems = self.tabBarController?.tabBar.items, index < tabBarItems.count else {
            return
        }

        // Obtener el frame del UITabBarItem
        let tabBarItem = tabBarItems[index]
        let tabBarButton = tabBarItem.value(forKey: "view") as? UIView

        // Buscar y eliminar cualquier redDot existente
        for subview in tabBarButton?.subviews ?? [] {
            if subview.tag == 1234 {
                subview.removeFromSuperview()
            }
        }

        // Si no debemos mostrar el punto rojo, salimos de la función
        if !shouldShow {
            return
        }

        // Crear y agregar el redDot
        let RedDotRadius: CGFloat = 5
        let RedDotDiameter = RedDotRadius * 2
        let TopMargin: CGFloat = 5
        let itemWidth: CGFloat = index == 2 ? 25 : 10
        let redDot = UIView(frame: CGRect(x: tabBarButton!.frame.width / 2 + itemWidth, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))
        redDot.tag = 1234
        redDot.backgroundColor = UIColor.red
        redDot.layer.cornerRadius = RedDotRadius
        tabBarButton?.addSubview(redDot)
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
        
        print("*******MY LAT & LONG ARE -->> \(self.latLabel.text!), \(self.longLabel.text!)")
        
    }
}
