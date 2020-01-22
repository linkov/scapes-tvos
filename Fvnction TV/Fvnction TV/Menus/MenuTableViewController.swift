//
//  MenuTableViewController.swift
//  Life Saver tvOS
//
//  Created by Bradley Root on 6/26/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit


class MenuTableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "SimpleTableViewCell")
        updatedSettings()
    }

    func updatedSettings() {

    }

//    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print((indexPath.section, indexPath.row))
//
//    }

 
}
