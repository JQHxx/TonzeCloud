//
//  BPMRecordViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class BPMRecordViewController: LightStatusBarViewController  , UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var personString: String!
    
    var BPDevice: BPMeterModel!
    
    private var records: [BPRecord]!
    
    private var dataSource: [String: [BPRecord]]!
    
    private var sectionTitles: [String]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.baseTitle="设备记录"
        self.view.backgroundColor=UIColor(hex: 0xf0f0f0)

        records = [BPRecord]()
    
        
        initDataSource()
        initViews()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        BPDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
            })
        }
        startMeasure()
    }
    
    private func initViews() {
        self.tableView.registerNib(UINib(nibName: "BPMRecordDataCell", bundle: nil), forCellReuseIdentifier: "cellid")
        self.tableView.registerNib(UINib(nibName: "BPMHistoryHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerid")
        self.tableView.delegate            = self
        self.tableView.dataSource          = self
        self.tableView.separatorStyle      = .None
        self.tableView.tableHeaderView     = UIView()
        self.tableView.tableFooterView     = UIView()
        self.tableView.sectionHeaderHeight = 50
        
    }
    
    
    private func initDataSource() {
        
        self.readData()
        
        ///读取设备历史记录
        if self.BPDevice != nil && self.BPDevice.peripheral != nil{
            BTManager.sharedManager().bpmeterReceiveDeviceHistoryDataNotify(self.BPDevice.peripheral!, callback: nil)
        }
        
    }
    
    private func readData() {
        //读取数据库设备记录
//        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        let personId = self.personString == "爸爸" ? 0 : 1
        
        self.records = DBManager.shareManager().readBPRecords(self.BPDevice, loginUserId: 0, memberUserId: personId) as? [BPRecord] ?? [BPRecord]()
        
        self.noDataImageView.hidden = records.count > 0
        self.noDataLabel.hidden = records.count > 0
        
        self.reloadDataSource()
    }
    
    private func reloadDataSource() {
        self.tableView.reloadData()
    }
    
    
    
    //MARK: - BT Connect Status
    private func btConnectStatusChangeHandler(peripheral: CBPeripheral?, status: BTConnectStatus, object: AnyObject?) {

    }
    
    private func saveRecord(date: NSDate, value: Float) {

    }
    
    func startMeasure() {
        self.BPDevice?.subscribeCurrentValue({ (value, isHeartBeating) in
            dispatch_async(dispatch_get_main_queue(), {
                self.SBP = value
            })
        })
        self.BPDevice?.subscribeResultValue({ [weak self] (SBP, DBP, heartRate, isHBUneven, isUserOne) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.SBP = SBP
                self?.DBP = DBP
                self?.heartRate = heartRate
                self?.isHBUneven = isHBUneven
                self?.isUserOne = isUserOne
//                self?.reportDescLabel.text = self?.bpmeterDevice?.valueDiscription
//                self?.reportDescLabel.textColor = self?.bpmeterDevice?.valueColor
            })
            
            self?.saveRecord()
            })
        self.BPDevice?.subscribeDate({ [weak self] (date) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.date = date
            })
            self?.saveRecord()
            })
        self.BPDevice?.subscribeTime({ [weak self] (time) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.time = time
            })
            self?.saveRecord()
            })
        self.BPDevice?.subscribeErrorMessage({ [weak self] (message, tips, code) in
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: message, message: tips, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { [weak alert] (action) in
                    alert?.dismissViewControllerAnimated(true, completion: nil)
                    }))
                self?.presentViewController(alert, animated: true, completion: nil)
                self?.resetState()
            })
            })
    }
    
    private func saveRecord() {
        guard let DBP = DBP,
            let SBP = SBP,
            let heartRate = heartRate,
            let isHBUneven = isHBUneven,
            let date = date,
            let time = time,
            let isUserOne = isUserOne
            else {
                return;
        }
        let dateTimeStr = "\(date) \(time)"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let saveDate = formatter.dateFromString(dateTimeStr) {
            //根据用户1、2保存设备记录
            let record = BPRecord(deviceUUID:self.BPDevice!.BLEMacAddress!,
                                  date: saveDate,
                                  SBP: SBP,
                                  DBP: DBP,
                                  heartRate: heartRate,
                                  isHBUneven:isHBUneven,
                                  userId: isUserOne ? 0 : 1)
            let allRecord = NSMutableArray()
            if (sectionTitles != nil) {
                for key in sectionTitles {
                    let records = dataSource[key]
                    allRecord.addObjectsFromArray(records!)
                }
            }
            
            if !allRecord.containsObject(record) {
                DBManager.shareManager().insertBPRecord(record, bpMeterDevice: self.BPDevice, loginUserId: 0, memberUserId: isUserOne ? 0 : 1)
                //按照当前的用户显示设备记录
                if (self.personString == "爸爸" && isUserOne || self.personString == "妈妈" && !isUserOne) {
                    resetState()
                    self.readData()
                    self.tableView.performSelectorOnMainThread(#selector(UITableView.reloadData), withObject: nil, waitUntilDone: true)
                }
            }
        }
    }
    
    class func viewControllerFromSB() -> BPMRecordViewController {
        return UIStoryboard(name: "BPMeter", bundle: nil).instantiateViewControllerWithIdentifier("BPMRecordViewController") as! BPMRecordViewController
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
        
        let selector = #selector(self.recommendButtonClicked(_:))
        cell.rightButton.tag = indexPath.row
        cell.rightButton.removeTarget(self, action: selector, forControlEvents: .TouchUpInside)
        cell.rightButton.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
        
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
    
    
    //MARK: - setters
    
    private var date: String?
    
    private var time: String?
    
    ///收缩压
    private var SBP: UInt16?
    
    ///舒张压
    private var DBP: UInt16?
    
    ///心率
    private var heartRate: UInt16?
    
    ///心率不齐
    private var isHBUneven: Bool?
    
    ///心率不齐
    private var isUserOne: Bool?
    
    ///重置状态
    private func resetState() {
        self.DBP = nil
        self.SBP = nil
        self.heartRate = nil
        self.isHBUneven = nil
        self.date = nil
        self.time = nil
        self.isUserOne = nil
    }
    
    //MARK: - ---

}
