//
//  memoriesView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase
import FSCalendar

class memoriesView: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {

    // Variables
    
    fileprivate lazy var formatted: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd"
        return formatter
    }()
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var memory = [Memories]()
    var memories = [Memories]()
    
    // Outlets
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var memoryTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        calendar.scope = .month
        calendar.scrollDirection = .horizontal
        
        let cellNib = UINib(nibName: "AppointmentCell", bundle: nil)
        memoryTable.register(cellNib, forCellReuseIdentifier: "memory")
        
        memoryTable.sectionFooterHeight = 60
        
//        setupCalendar()
//        checkMemories()
        
    }
    
    // MARK: – Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        memory.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memory", for: indexPath) as! memoryCell
        
//        cell.setupCell(mem: memory[indexPath.row])
        
        return cell
        
    }
    
    // MARK: – Calendar
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let user = Auth.auth().currentUser?.uid
        let dateString = self.formatted.string(from: date)
        let ref = self.databaseRef.child("Users/\(user!)/Bumps")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            var array = [Memories]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let month = child.childSnapshot(forPath: "month").value as? String ?? ""
                let recip = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                
                let memo = Memories(author: auth, timestamp: stamp, date: date, id: id, lat: lat, location: local, long: long, month: month, recipient: recip)
                array.append(memo)
                
                self.memory = array
                
            }
            
        }
        
        for data in memory {
            
            if data.date.contains(dateString) {

                return 1

            }
            
        }
        
        return 0
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        return [appearance.eventDefaultColor]
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
    // Functions
    
    func setupCalendar() {
        
        let user = Auth.auth().currentUser?.uid
        let ref = self.databaseRef.child("Users/\(user!)/Bumps")
        
        ref.observe(.value) { (snapshot) in
            
            var memArray = [Memories]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let month = child.childSnapshot(forPath: "month").value as? String ?? ""
                let recip = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                
                let memos = Memories(author: auth, timestamp: stamp, date: date, id: id, lat: lat, location: local, long: long, month: month, recipient: recip)
                memArray.append(memos)
                
                self.memories = memArray
                self.calendar.reloadData()
            }
            
        }
        
    }
    
    func checkMemories(){
        
        let date = Date()
        let uid = Auth.auth().currentUser?.uid
        let mo = date.getFormattedDate(format: "MMMM")
        let ref = databaseRef.child("Users/\(uid!)/Bumps/")
        
        ref.queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in

            var memoArray = [Memories]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let month = child.childSnapshot(forPath: "month").value as? String ?? ""
                let recip = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                
                if month == mo {
                    
                    let memry = Memories(author: auth, timestamp: stamp, date: date, id: id, lat: lat, location: local, long: long, month: month, recipient: recip)
                    memoArray.append(memry)
                    
                }

            }
            
            DispatchQueue.main.async {
                
                self.memory = memoArray
                self.memoryTable.reloadData()
                
            }

        }
        
    }

}

extension Date {
    
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
   }
    
}
