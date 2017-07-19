//
//  CommentTableViewCell.swift
//  swiftTest
//
//  Created by Zakhar on 7/19/17.
//  Copyright © 2017 BalinaSoft. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {


    
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    @IBOutlet weak var commentView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
