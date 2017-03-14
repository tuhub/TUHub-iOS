//
//  CoursesViewController.swift
//  TUHub
//
//  Created by Connor Crawford on 3/8/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import FSCalendar

class CoursesViewController: UIViewController {

    @IBOutlet weak var courseCalendarView: CourseCalendarView!
    @IBOutlet weak var courseListView: CourseListView!
    
    fileprivate var terms:[Term]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.current?.retrieveCourseOverview({ (allTerms, error) in
            if let error = error {
                
            }
            
            if let terms = allTerms {
                self.terms = terms
            }
            
            //print(self.terms!)
            print("-----------------------------")
            print(self.terms![0].name)
            print(self.terms![0].courses![0].name)
        })

    }
    
    
    override func overrideTraitCollection(forChildViewController childViewController: UIViewController) -> UITraitCollection? {
        if UI_USER_INTERFACE_IDIOM() == .pad &&
            view.bounds.width > view.bounds.height {
            
            let collections = [UITraitCollection(horizontalSizeClass: .regular),
                               UITraitCollection(verticalSizeClass: .compact)]
            return UITraitCollection(traitsFrom: collections)
            
        }
        
        return super.overrideTraitCollection(forChildViewController: childViewController)
    }

    @IBAction func didToggleSegmentedControl(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        courseCalendarView.isHidden = selectedIndex == 1
        courseListView.isHidden = selectedIndex == 0
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
