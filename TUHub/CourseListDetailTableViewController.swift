//
//  CourseListDetailTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 3/15/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit

class CourseListDetailTableViewController: UITableViewController {

    var course: Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseDetailCell", for: indexPath)

         //Configure the cell...

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
