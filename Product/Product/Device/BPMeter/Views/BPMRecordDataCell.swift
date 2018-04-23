//
//  BPMRecordDataswift
//  Product
//
//  Created by WuJiezhong on 16/6/6.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class BPMRecordDataCell: UITableViewCell {

    @IBOutlet weak var topSeparatorLine: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var descTitleLabel: UILabel!
    @IBOutlet weak var sbpTitleLabel: UILabel!
    @IBOutlet weak var dbpTitleLabel: UILabel!
    @IBOutlet weak var heartRateTitleLabel: UILabel!
    @IBOutlet private weak var lineHeightConstraint: NSLayoutConstraint!
    
    
    ///model
    var model: BPRecord!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineHeightConstraint.constant = singleLineWidth
        rightButton.hidden = true
    }
    
    func setModel(model: BPRecord, row: Int) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text           = formatter.stringFromDate(model.date)
        descTitleLabel.text      = BPMeterModelHelper.BPvalueDescription(model.DBP, HPvalue: model.SBP)
        descTitleLabel.textColor = BPMeterModelHelper.BPvalueColor(model.DBP, HPvalue: model.SBP)
        sbpTitleLabel.text       = "高压  \(model.SBP)mmHg"
        dbpTitleLabel.text       = "低压  \(model.DBP)mmHg"
        heartRateTitleLabel.text = "心率  \(model.heartRate)次/分钟"
        rightButton.setTitle("食材推荐 >>", forState: .Normal)
        
        topSeparatorLine.hidden = row != 0
    }
}
