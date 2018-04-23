//
//  BPMHistoryViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class BPMHistoryViewController: LightStatusBarViewController, UITableViewDelegate, UITableViewDataSource {
    
    ///用户头像
    @IBOutlet weak var userImageView: UIImageView!
    ///用户名
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var bpmeterDevice: BPMeterModel!
    
    ///所有记录
    var records = [BPRecord]()
    ///key是
    var dataSource: [String: [BPRecord]]!
    
    private var sectionTitles: [String]!
    
    class func viewControllerFromSB() -> BPMHistoryViewController {
        return UIStoryboard(name: "BPMeter", bundle: nil).instantiateViewControllerWithIdentifier("BPMHistoryViewController") as! BPMHistoryViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.baseTitle="历史记录"
        
        initViews()
        // 刷新数据
        self .reloadDataSource();
    }
    
    private func initViews() {
        self.tableView.registerNib(UINib(nibName: "BPMRecordDataCell", bundle: nil), forCellReuseIdentifier: "cellid")
        self.tableView.registerNib(UINib(nibName: "BPMHistoryHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerid")
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.sectionHeaderHeight = 50
        
        // 去除头部信息
        /*
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = self.userImageView.bounds.width/2
        
        let url = NSURL.init(string: TonzeHelpTool.sharedTonzeHelpTool().user.photo)
        self.userImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "默认"))
        
        let userName = NSUserDefaultInfos.getValueforKey(USER_NAME)
        self.userNameLabel.text = userName ?? "用户名"
        */
    }
    
    
    private func reloadDataSource() {
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        if let userId = userDict["user_id"]?.integerValue {
            self.records = DBManager.shareManager().readBPRecords(self.bpmeterDevice, loginUserId: userId, memberUserId: userId) as? [BPRecord] ?? [BPRecord]()
        } else {
            records = [BPRecord]()
        }
        self.noDataImageView.hidden = records.count > 0
        self.noDataLabel.hidden = records.count > 0
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if records.count == 0 {
            return 0
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.stringFromDate(NSDate())
        let yestodayDate = NSDate(timeInterval: -60*60*24, sinceDate: NSDate())
        let yestodayStr = formatter.stringFromDate(yestodayDate)
        self.dataSource = self.records.reduce([String:[BPRecord]]()) { (curDict, curRecord) -> [String:[BPRecord]] in
            var curDict = curDict
            let dateStr = formatter.stringFromDate(curRecord.date)
            let key:String
            switch dateStr {
            case todayStr:
                key = "今天"
            case yestodayStr:
                key = "昨天"
            default:
                key = dateStr
            }
            if curDict[key] == nil {
                curDict[key] = [BPRecord]()
            }
            curDict[key]!.append(curRecord)
            return curDict
        }
        sectionTitles = [String](self.dataSource.keys)
        sectionTitles = sectionTitles.sort {
            if $0 == "今天" { return true }
            if $1 == "今天" { return false }
            if $0 == "昨天" && $1 != "今天" { return true }
            if $1 == "昨天" && $0 != "今天" { return false }
            return $0 > $1
        }
        return sectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[sectionTitles[section]]!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48*4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellid", forIndexPath: indexPath) as! BPMRecordDataCell
        
        // 去除食材推荐
        /*
        let selector = #selector(self.recommendButtonClicked(_:))
        cell.rightButton.tag = indexPath.row
        cell.rightButton.removeTarget(self, action: selector, forControlEvents: .TouchUpInside)
        cell.rightButton.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
        */
        
        let curRecords = dataSource[sectionTitles[indexPath.section]]!
        cell.setModel(curRecords[indexPath.row], row: indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("headerid") as? BPMHistoryHeaderView
        header!.dateLabel.text = sectionTitles[section]
        return header
    }
    
    ///食材推荐
    func recommendButtonClicked(button: UIButton) {
        NSLog("section : \(button.tag)")

        let foodVC = UIStoryboard(name: "BPMeter", bundle: nil).instantiateViewControllerWithIdentifier("FoodListViewController") as! FoodListViewController
        
        let curRecords = dataSource[sectionTitles[0]]!
        let model = curRecords[button.tag]
        
        let tem = BPMeterModel()
        tem.SBP = model.SBP
        tem.DBP = model.DBP
        
        foodVC.discriptionString = tem.valueDiscription
        self.navigationController?.pushViewController(foodVC, animated: true)
    }
}
