//
//  MenuTableViewController.swift
//  Life Saver tvOS
//
//  Created by Bradley Root on 6/26/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit


class MenuTableViewController: UITableViewController {


    @IBOutlet weak var mainColorCell: UITableViewCell!
    @IBOutlet weak var firstVariableCell: UITableViewCell!
    @IBOutlet weak var secondVariableCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updatedSettings()
    }

    func updatedSettings() {

    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        print((indexPath.section, indexPath.row))

    }

 
}
