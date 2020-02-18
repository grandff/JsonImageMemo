//
//  WeatherCell.swift
//  JsonImageMemo
//
//  Created by 김정민 on 2020/02/16.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!        

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
