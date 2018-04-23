//
//  TMPSettingsViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class TMPSettingsViewController: LightStatusBarViewController, UITableViewDelegate, UITableViewDataSource, ValuePickerViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var tempDevice: ThermometerModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseTitle = "智能设置"
    }
    
    class func viewControllerFromSB() -> TMPSettingsViewController {
        return UIStoryboard(name: "Thermometer", bundle: nil).instantiateViewControllerWithIdentifier("TMPSettingsViewController") as! TMPSettingsViewController
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        switch indexPath.section {
        case 0 where indexPath.row == 0:
            ValuePickerView.show(.TempDiff, title: "体温温差", currentValue: Float(self.tempDevice.temperatureDifference)/10.0, delegate: self)
        case 0 where indexPath.row == 1:
            ValuePickerView.show(.TimeInterval, title: "时间间隔", currentValue: Float(self.tempDevice.timeInterval)/60.0, delegate: self)
        case 1:
            ValuePickerView.show(.BodyTemp, title: "报警设置", currentValue: Float(self.tempDevice.downFever)/10.0, delegate: self)
        default:
            break
        }
    }
    
    //MARK: - UITableView DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cellid")
        
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "cellid")
            cell.textLabel?.textColor = UIColor(hex: 0x343434)
            cell.accessoryType        = .DisclosureIndicator
        }
        switch indexPath.section {
        case 0 where indexPath.row == 0:
            cell.textLabel?.text = "体温温差"
            cell.detailTextLabel?.text = "\(Float(self.tempDevice.temperatureDifference)/10.0)℃"
        case 0 where indexPath.row == 1:
            cell.textLabel?.text = "时间间隔"
            cell.detailTextLabel?.text = self.tempDevice.timeInterval>=60 ? String(format: "%d分钟", self.tempDevice.timeInterval/60) : String(format: "%d秒", self.tempDevice.timeInterval)
        case 1:
            cell.textLabel?.text = "报警设置"
            cell.detailTextLabel?.text = String(format: "%.1f℃", Float(self.tempDevice.downFever)/10.0)
        default:
            break
        }
        
        return cell
    }

    
    //MARK: - valuePicker delegate
    
    func clickDoneInPickerView(pickerView: ValuePickerView) {
        print("\(pickerView.currentValue)")

        switch pickerView.style {
        case .TempDiff:
            //体温温差
            self.tempDevice.temperatureDifference = Int16(pickerView.currentValue * 10.0)
            BTManager.sharedManager().setthermoTemperatureDifferenceAndThermoTimeInterval(self.tempDevice, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                
                self.tableView.reloadData()
                
                return true
            })
            break
        case .TimeInterval:
            //时间间隔
            self.tempDevice.timeInterval = Int16(pickerView.currentValue * 60.0)
            BTManager.sharedManager().setthermoTemperatureDifferenceAndThermoTimeInterval(self.tempDevice, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                
                self.tableView.reloadData()
                
                return true
            })
            break
        default:
            //报警体温
            self.tempDevice.downFever = Int16(pickerView.currentValue * 10.0)
            self.tempDevice.upFever = Int16(pickerView.currentValue * 10.0) + 8 //待定
            BTManager.sharedManager().setthermoThresholdOfFever(self.tempDevice, callback: { (rcvData, userInfo, error) -> Bool in
                if let err = error {
                    if err.code == BTErrorCode.Disconnected.rawValue {
                        return false
                    }
                }
                
                self.tableView.reloadData()
                
                return true
            })
            break
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: ValuePickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: ValuePickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }

    func pickerView(pickerView: ValuePickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "row\(row)"
    }
    
    func pickerView(pickerView: ValuePickerView, tailTitleForComponent component: Int) -> String? {
        if component == 0 {
            return " ."
        } else {
            return "℃"
        }
    }
    
    func minValueInPickerView(pickerView: ValuePickerView) -> Float {
        return 1
    }
    
    func maxValueInPickerView(pickerView: ValuePickerView) -> Float {
        return 60
    }
    
    func stepValueInPickerView(pickerView: ValuePickerView) -> Float {
        return 0.1
    }
    
    func formatStringInPickerView(pickerView: ValuePickerView) -> String {
        return "%.0f"
    }
}
