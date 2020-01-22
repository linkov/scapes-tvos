//
//  SimpleTableViewCell.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import EasyPeasy
import BadgeSwift

class SimpleTableViewCell: UITableViewCell {

    var iconImageView: UIImageView?
    var badge: BadgeSwift?
    var cellTitle : String? {
        didSet {
            self.textLabel?.text  = cellTitle
            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

         self.textLabel?.font = UIFont(name: "RobotoMono-Regular", size: 32);
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//
//
//
//
//
//    }

}
