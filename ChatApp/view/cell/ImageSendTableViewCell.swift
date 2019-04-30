//
//  ImageTableViewCell.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import UIKit
import MaterialComponents

class ImageSendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageSend: UIImageView!
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewText: MDCCard!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        viewText.isInteractable = false
        viewText.setShadowElevation(.cardResting, for: .normal)
        viewText.setShadowColor(.black, for: .normal)
        viewText.cornerRadius = 5
        viewText.translatesAutoresizingMaskIntoConstraints = false
        viewText.backgroundColor = MDCPalette.indigo.tint50
    }
}
