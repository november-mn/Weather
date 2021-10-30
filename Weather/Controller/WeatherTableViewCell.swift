//
//  WeatherTableViewCell.swift
//  Weather
//
//  Created by Sally Wang on 10/29/21.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var lblCity: UILabel!
    
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var imgWeather: UIImageView!
    
    @IBOutlet weak var imgDayNight: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
}
