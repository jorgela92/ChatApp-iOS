//
//  ImageReceiveTableViewCell.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 16/04/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import UIKit
import MaterialComponents

class ImageReceiveTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageSend: UIImageView!
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewText: MDCCard!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        configureUI()
    }
    
    private func configureUI() {
        viewText.isInteractable = false
        viewText.setShadowElevation(.cardResting, for: .normal)
        viewText.setShadowColor(.black, for: .normal)
        viewText.cornerRadius = 5
        viewText.translatesAutoresizingMaskIntoConstraints = false
        viewText.backgroundColor = MDCPalette.lime.tint50
    }
}

