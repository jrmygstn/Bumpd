//
//  memoriesTableview.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/12/23.
//

import UIKit
import Firebase
import FSCalendar

class memoriesTableview: UITableViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    // Variables
    
    fileprivate lazy var formatted: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd"
        return formatter
    }()
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var mem = [Memories]()
    var memory = [Memories]()
    var memories = [Memories]()
    
    // Outlets
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCalendar()
        checkMemories()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.navigationController?.setStatusBar(backgroundColor: UIColor(red: 106/225, green: 138/255, blue: 167/255, alpha: 1.0))
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        calendar.scope = .month
        calendar.scrollDirection = .horizontal
        let cellNib = UINib(nibName: "AppointmentCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "memory")
        tableView.sectionFooterHeight = 60
        tableView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if memory.count != 0 {
            
            return memory.count
            
        }
        
        return 4
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memory", for: indexPath) as! memoryCell
        
        if memory.count == 0 {
            
            cell.cellEmpty.isHidden = false
            
        } else {
            
            let user = Auth.auth().currentUser?.uid
            let ath = self.memory[indexPath.row].author
            let rec = self.memory[indexPath.row].recipient
            
            cell.setupCell(mem: memory[indexPath.row])
            
            cell.btnTapAction1 = {
                
                () in
                
                let vc = self.storyboard?.instantiateViewController(identifier: "memoryDetails") as! memoryDetailsView
                vc.memory = self.memory[indexPath.row]
                self.present(vc, animated: true, completion: nil)
                
            }
            
            cell.btnTapAction2 = {
                
                () in
                
                if ath == user {
                    
                    let vc = self.storyboard?.instantiateViewController(identifier: "memoryProfileVC") as! memoryProfileTV
                    vc.recip = self.memory[indexPath.row].recipient
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else if rec == user {
                    
                    let vc = self.storyboard?.instantiateViewController(identifier: "memoryProfileVC") as! memoryProfileTV
                    vc.auth = self.memory[indexPath.row].author
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
            }
            
        }
        
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
        let ref = self.databaseRef.child("Feed")
        
        ref.observe(.value) { (snapshot) in
            
            var array = [Memories]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let details = child.childSnapshot(forPath: "details").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let month = child.childSnapshot(forPath: "month").value as? String ?? ""
                let recip = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                
                if auth == user && approve != false || recip == user && approve != false {
                    
                    let memo = Memories(approved: approve, author: auth, timestamp: stamp, date: date, details: details, id: id, lat: lat, location: local, long: long, month: month, recipient: recip)
                    array.append(memo)
                    
                }
                
                self.mem = array
                
            }
            
        }
        
        for data in mem {
            
            if data.date.contains(dateString) {

                return 1

            }
            
        }
        
        return 0
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        return [appearance.eventDefaultColor]
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        let currentPageDate = calendar.currentPage
        let month = Calendar.current.component(.month, from: currentPageDate)
        let monthName = DateFormatter().monthSymbols[month - 1].capitalized
        
        print("THE MONTH YOU SWIPED TO IS-->>\(monthName)")
        
        self.dateField.text = "\(monthName)"
        
        updateMemories()
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        
        
    }
    
    // Actions
    
    @IBAction func unwindToMemories(segue:UIStoryboardSegue) {
        
    }
    
    // Functions
    
    func setupCalendar() {
        
        let user = Auth.auth().currentUser?.uid
        let ref = self.databaseRef.child("Feed")
        
        ref.observe(.value) { (snapshot) in
            
            var memArray = [Memories]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let details = child.childSnapshot(forPath: "details").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let month = child.childSnapshot(forPath: "month").value as? String ?? ""
                let recip = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                
                if auth == user && approve != false || recip == user && approve != false {
                    
                    let memos = Memories(approved: approve, author: auth, timestamp: stamp, date: date, details: details, id: id, lat: lat, location: local, long: long, month: month, recipient: recip)
                    memArray.append(memos)
                    
                }
                
            }
            
            self.memories = memArray
            self.calendar.reloadData()
            
        }
        
    }
    
    func checkMemories(){
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "MMMM"
        format.timeZone = TimeZone.autoupdatingCurrent
        
        let mo = format.string(from: date)
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Feed")
        
        ref.queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in

            var memoArray = [Memories]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let details = child.childSnapshot(forPath: "details").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let month = child.childSnapshot(forPath: "month").value as? String ?? ""
                let recip = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                
                if auth == uid && month == mo && approve == true || recip == uid && month == mo && approve == true {
                    
                    let memry = Memories(approved: approve, author: auth, timestamp: stamp, date: date, details: details, id: id, lat: lat, location: local, long: long, month: month, recipient: recip)
                    memoArray.append(memry)
                    
                }

            }
            
            self.memory = memoArray
            self.tableView.reloadData()
            
        }
        
    }
    
    func updateMemories(){
        
        let day = dateField.text!
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Feed")
        
        ref.queryOrdered(byChild: "timestamp").observe(.value) { (snapshot) in

            var memoArray = [Memories]()

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let approve = child.childSnapshot(forPath: "approved").value as? Bool ?? false
                let auth = child.childSnapshot(forPath: "author").value as? String ?? ""
                let date = child.childSnapshot(forPath: "date").value as? String ?? ""
                let details = child.childSnapshot(forPath: "details").value as? String ?? ""
                let stamp = child.childSnapshot(forPath: "timestamp").value as? Double ?? 0.0
                let id = child.childSnapshot(forPath: "id").value as? String ?? ""
                let local = child.childSnapshot(forPath: "location").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let month = child.childSnapshot(forPath: "month").value as? String ?? ""
                let recip = child.childSnapshot(forPath: "recipient").value as? String ?? ""
                
                if auth == uid && month == day && approve == true || recip == uid && month == day && approve == true {
                    
                    let memry = Memories(approved: approve, author: auth, timestamp: stamp, date: date, details: details, id: id, lat: lat, location: local, long: long, month: month, recipient: recip)
                    memoArray.append(memry)
                    
                }

            }
            
            self.memory = memoArray
            self.tableView.reloadData()

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
