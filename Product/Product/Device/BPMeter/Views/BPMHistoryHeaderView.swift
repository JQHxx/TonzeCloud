//
//  BPMHistoryHeaderView.swift
//  Product
//
//  Created by WuJiezhong on 16/6/6.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class BPMHistoryHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(hex: 0xf3f3f3)
    }
}
