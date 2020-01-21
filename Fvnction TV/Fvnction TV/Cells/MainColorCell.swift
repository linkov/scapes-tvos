//
//  MainColorCell.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import EasyPeasy
class MainColorCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    var colorSlider: ColorSlider?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutMargins = UIEdgeInsets.zero


    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        easy.layout(Edges(10.0))
//        colorSlider = ColorSlider(orientation: .horizontal, previewSide: .bottom)
//        colorSlider!.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 60)
//        addSubview(colorSlider!)
//        colorSlider!.gradientView.layer.borderWidth = 2.0
//        colorSlider!.gradientView.layer.borderColor = UIColor.white.cgColor
        
    }
    

    
    @objc func changedColor(_ slider: ColorSlider) {
        var color = slider.color
        // ...
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        if (selected) {
//
//        }
//    }

}
