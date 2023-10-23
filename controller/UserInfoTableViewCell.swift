//
//  UserInfoTableViewCell.swift
//  proj1
//
//  Created by sam on 2023/9/27.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {


    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
