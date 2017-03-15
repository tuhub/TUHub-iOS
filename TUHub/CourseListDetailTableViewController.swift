//
//  CourseListDetailTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 3/15/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseListDetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var courseDescription: UILabel!
    @IBOutlet weak var semesterDate: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var course: Course?
    
    var gradeTerm: [Grade] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let title = "\((course?.name)!)-\((course?.sectionNumber)!)"
        self.title = title
        
        courseDescription.text = course?.title
        
        let mettings = course?.meetings
        
        for metting in mettings! {
            let startDate = metting.startDate
            let endDate = metting.endDate
            semesterDate.text = "\(startDate.date) to \(endDate.date)"
        }
        
        
        
    }
        
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        
        switch section {
            
        case 0:
            numberOfRows = course?.meetings?.count ?? 0
        case 1:
            numberOfRows = course?.instructors?.count ?? 0
        case 2:
            numberOfRows = 1
        case 3:
            
            // Since we are using course overview it's not gone return roster
            numberOfRows = course?.roster?.count ?? 0
            
        default:
            numberOfRows = 0
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName:String?
        
        switch section {
            
        case 0:
            sectionName = "Meeting Times"
        case 1:
            sectionName = "Faculty"
        case 2:
            sectionName = "Grades"
        case 3:
            sectionName = "Roster"
            
        default:
            sectionName = "N/A"
        }
        
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailCell", for: indexPath)
        
        switch indexPath.section {
         
        // Meeting Times
        case 0:
            
            for meeting in (course?.meetings)! {
                // TODO: Display what day is it
                cell.textLabel?.text = "\(meeting.startTime)"
                cell.detailTextLabel?.text = "\(meeting.buildingName), Room \(meeting.room)"
            }
            
        // Faculty
        case 1:
            
            for faculty in (course?.instructors)! {
                cell.textLabel?.text = faculty.formattedName
                cell.detailTextLabel?.text = nil
            }
            
        // Grades
        case 2:
            cell.textLabel?.text = "Final Grade"
            cell.detailTextLabel?.text = "updated"
//            for meeting in (term?.grades)! {
//                cell.textLabel?.text = meeting.formattedName
//                // TODO: Last updated
//                cell.detailTextLabel?.text = nil
//            }
            
        // Roster
        case 3:
            
            for roster in (course?.roster)! {
                cell.textLabel?.text = roster
                cell.detailTextLabel?.text = nil
            }
            
        default:
            debugPrint("Error")
            
        }
        
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
