//
//  TMPDeviceRecordViewController.swift
//  Product
//
//  Created by 梁家誌 on 16/8/10.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class TMPDeviceRecordViewController: LightStatusBarViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var tempDevice: ThermometerModel!
    
    private var records: [BodyTempRecord]!

    private var dataSource: [String: [BodyTempRecord]]!
    
    private var sectionTitles: [String]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseTitle = "设备纪录"
        records = [BodyTempRecord]()
        
        self.records = DBManager.shareManager().readBodyTempRecords(self.tempDevice, forOneDay:nil, dayWidth:1, loginUserId: 0, memberUserId: 0) as? [BodyTempRecord] ?? [BodyTempRecord]()
        self.noDataImageView.hidden = records.count > 0
        self.noDataLabel.hidden = records.count > 0
        
        initDataSource()
        initViews()
        
    }

    deinit {
        NSLog(">>>>>>>>>>> TMPDeviceRecordViewController deinit <<<<<<<<<")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        if self.tempDevice != nil && self.tempDevice.peripheral != nil {
//            BTManager.sharedManager().thermoEnableReceiveDeviceHistoryDataNotify(self.tempDevice.peripheral!, enable: false, callback: nil)
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    }
    
    
    private func initDataSource() {
        
    }
    
    private func reloadDataSource() {
        self.tableView.reloadData()
    }

    
    class func viewControllerFromSB() -> TMPDeviceRecordViewController {
        return UIStoryboard(name: "Thermometer", bundle: nil).instantiateViewControllerWithIdentifier("TMPDeviceRecordViewController") as! TMPDeviceRecordViewController
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - UITableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if records.count == 0 {
            return 0
        }
        self.noDataImageView.hidden = records.count > 0
        self.noDataLabel.hidden = records.count > 0
        
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
