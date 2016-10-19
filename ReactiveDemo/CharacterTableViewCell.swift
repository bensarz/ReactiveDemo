//
//  CharacterTableViewCell.swift
//  ReactiveDemo
//
//  Created by Benoit Sarrazin on 2016-10-18.
//  Copyright © 2016 Berzerker IO. All rights reserved.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Rendering
    
    func render(character: Character?) {
        guard let c = character else {
            idLabel.text = nil
            nameLabel.text = nil
            return
        }
        idLabel.text = "\(c.id)"
        nameLabel.text = c.name
    }
    
}
