//
//  ShaderCell.swift
//  Fvnction TV
//
//  Created by Alex Linkov on 1/21/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import UIKit
import Kingfisher

class ShaderCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var unfocusedConstraint: NSLayoutConstraint!
    
    var focusedConstraint: NSLayoutConstraint!
    
    
    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            
            return formatter
        }()
        
        override func awakeFromNib() {
            super.awakeFromNib()
            focusedConstraint = titleLabel.topAnchor.constraint(equalTo: imageView.focusedFrameGuide.bottomAnchor, constant: 16)
        }
        
        override func updateConstraints() {
            super.updateConstraints()
            focusedConstraint?.isActive = isFocused
            unfocusedConstraint?.isActive = !isFocused
        }
        
        func configure(_ shader: Shader) {
            imageView.kf.indicatorType = .activity
            imageView.image = UIImage.init(named: shader.imageURL)
            titleLabel.font = UIFont(name: "Exo-SemiBold", size: 38);
            titleLabel.text = shader.title
            

        }
        
        override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
            super.didUpdateFocus(in: context, with: coordinator)
            
            setNeedsUpdateConstraints()
            coordinator.addCoordinatedAnimations({
                self.layoutIfNeeded()
            }, completion: nil)
        }
}
