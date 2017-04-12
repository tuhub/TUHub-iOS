//
//  MapsDetailTableViewController.swift
//  TUHub
//
//  Created by Brijesh Nayak on 4/11/17.
//  Copyright © 2017 Temple University. All rights reserved.
//

import UIKit
import YelpAPI

class MapsDetailTableViewController: UITableViewController {
    
    var selectedBusiness: YLPBusiness?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        print(selectedBusiness!.name)
        print(selectedBusiness!.categories.count)
        print(selectedBusiness!.categories[0].alias)
        print(selectedBusiness!.categories[0].name)
        print(selectedBusiness!.categories[1].name)
        print(selectedBusiness!.categories[2].name)
        print(selectedBusiness!.identifier)
        print(selectedBusiness!.location.address)
        print(selectedBusiness!.rating)
        
        cell.textLabel?.text = selectedBusiness?.title
        
        return cell
    }

}
