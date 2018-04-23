//
//  TMPRecordCell.swift
//  Product
//
//  Created by WuJiezhong on 16/6/6.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class TMPRecordCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var topSeparatorLine: UIView!
    @IBOutlet weak var bottomSeparatorLine: UIView!
    
    @IBOutlet weak var topLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLineHeightConstraint: NSLayoutConstraint!
    
    var model: BodyTempRecord? {
        didSet {
            if let model = model {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                dateLabel.text = formatter.stringFromDate(model.date)
                
                let curTemp = model.temperature < 25 ? "体温 25.0-℃":model.temperature > 45 ? "体温 45.0℃":String(format: "体温 %.1f℃", model.temperature)

                tempLabel.text = curTemp
                descLabel.text = ThermometerModel.valueDescription(model.temperature)
                descLabel.textColor = ThermometerModel.valueColor(model.temperature)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topLineHeightConstraint.constant    = singleLineWidth
        bottomLineHeightConstraint.constant = singleLineWidth
    }
    
}
