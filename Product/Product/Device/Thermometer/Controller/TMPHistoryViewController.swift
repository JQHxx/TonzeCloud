//
//  TMPHistoryViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class TMPHistoryViewController: LightStatusBarViewController, UITableViewDelegate, UITableViewDataSource {

    var tempDevice: ThermometerModel!
    
    ///用户头像
    @IBOutlet weak var userImageView: UIImageView!
    ///用户名
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataLabel: UILabel!
    private var history:Bool!//历史数据只请求一次

    private var records: [BodyTempRecord]!
    private var dataSource: [String: [BodyTempRecord]]!
    private var sectionTitles: [String]!
    
    class func viewControllerFromSB() -> TMPHistoryViewController {
        return UIStoryboard(name: "Thermometer", bundle: nil).instantiateViewControllerWithIdentifier("TMPHistoryViewController") as! TMPHistoryViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseTitle = "历史纪录"
        history = true
        initDataSource()
        initViews()
    }
    
    private func initViews() {
        self.tableView.registerNib(UINib(nibName: "TMPRecordCell", bundle: nil), forCellReuseIdentifier: "cellid")
        self.tableView.registerNib(UINib(nibName: "BPMHistoryHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerid")
        self.tableView.delegate            = self
        self.tableView.dataSource          = self
        self.tableView.separatorStyle      = .None
        self.tableView.tableHeaderView     = UIView()
        self.tableView.tableFooterView     = UIView()
        self.tableView.sectionHeaderHeight = 50
        
        // 去除头部信息
        /*
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height/2
        self.userImageView.clipsToBounds   = true
        
        let url = NSURL.init(string: TonzeHelpTool.sharedTonzeHelpTool().user.photo)
        self.userImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "默认"))
        
        let userName = NSUserDefaultInfos.getValueforKey(USER_NAME)
        self.userNameLabel.text = userName ?? "用户名"
         */
    }
    
    
    private func initDataSource() {
        if history == true {
            self.reloadDataSource()

        }
    }
    
    private func reloadDataSource() {
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        if let userId = userDict["user_id"]?.integerValue{
            self.records = DBManager.shareManager().readBodyTempRecords(self.tempDevice, forOneDay:nil, dayWidth:1, loginUserId: userId, memberUserId:userId) as? [BodyTempRecord] ?? [BodyTempRecord]()
            history = false
            NSLog("%@", self.records)
        } else {
            records = [BodyTempRecord]()
        }
        self.noDataImageView.hidden = records.count > 0
        self.noDataLabel.hidden = records.count > 0
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    //MARK: - UITableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if records.count == 0 {
            return 0
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.stringFromDate(NSDate())
        let yestodayDate = NSDate(timeInterval: -60*60*24, sinceDate: NSDate())
        let yestodayStr = formatter.stringFromDate(yestodayDate)
        self.dataSource = self.records.reduce([String:[BodyTempRecord]]()) { (curDict, curRecord) -> [String:[BodyTempRecord]] in
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
                curDict[key] = [BodyTempRecord]()
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
        //倒序
        for title in sectionTitles {
            dataSource[title] = dataSource[title]?.reverse()
        }
        return sectionTitles.count
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[sectionTitles[section]]!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellid", forIndexPath: indexPath) as! TMPRecordCell
        
        cell.topSeparatorLine.hidden = indexPath.row != 0
        
        let curRecords = dataSource[sectionTitles[indexPath.section]]!
        cell.model = curRecords[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("headerid") as? BPMHistoryHeaderView
        header!.dateLabel.text = sectionTitles[section]
        
        return header
    }

}
