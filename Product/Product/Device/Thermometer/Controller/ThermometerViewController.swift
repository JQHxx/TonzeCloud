//
//  ThermometerViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/26.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

class ThermometerViewController: LightStatusBarViewController, UITextFieldDelegate {
    
    var tempDevice: ThermometerModel?
    private var warnAlert:UIAlertController?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerScrollView: UIScrollView!
    ///连接状态
    @IBOutlet weak var connectStateLabel: UILabel!
    ///当前体温的描述
    @IBOutlet weak var curTempDescLabel: UILabel!
    ///报告的时间
    @IBOutlet weak var reportDateLabel: UILabel!
    ///当前体温
    @IBOutlet weak var currentTempLabel: UILabel!
    ///最高体温
    @IBOutlet weak var highestTempLabel: UILabel!
    ///平均体温
    @IBOutlet weak var averageTempLabel: UILabel!
    ///最低体温
    @IBOutlet weak var lowestTempLabel: UILabel!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var tempIndicatorImage: UIImageView!
    
    ///水平线的高度
    @IBOutlet weak var lineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descLabelWidthConstraint: NSLayoutConstraint!
    
    private var warningAlert:UIAlertController!
       ///是否正在配对
    private var isPairing = false
    
    ///记录上一次保存温度计的时间与温度值
    private var lastDate:NSDate!
    private var lastValue:Float!
    
    ///上次保存到设备历史的实时数据
    private var tempDate:NSDate!
    private var tempValue:Float!
    private var tempChange:Bool!//表示是否达到了温差
    private var tempConnect:Bool!//是否重连

    
    
    ///时间和值
    private var dateAndValue: (NSDate, Float)? {
        didSet {
            guard let dateAndValue = dateAndValue else {
                return
            }
            let date = dateAndValue.0
            let value = dateAndValue.1
            let formatter = NSDateFormatter()
            formatter.dateFormat = "测量时间：yyyy-MM-dd HH:mm"
            
            let curTemp = value < 25 ? "25.0-":value > 45 ? "45.0+":String(format: "%.1f", value)
            
            self.currentTempLabel.text      = curTemp
            self.currentTempLabel.textColor = ThermometerModel.valueColor(value)
            self.reportDateLabel.text       = formatter.stringFromDate(date)
            self.reportDateLabel.hidden     = false
            self.curTempDescLabel.textColor = UIColor.whiteColor()
            self.curTempDescLabel.hidden    = false
            
            self.setTemperatureDescription(ThermometerModel.valueDescription(value))
            self.moveCursorPointer(value)
        }
    }
    
    deinit {
        NSLog(">>>>>>>>>>> ThermometerViewController deinit <<<<<<<<<")
        SVProgressHUD.dismiss()
        tempDevice?.connectStatusChangeHandler = nil;
        tempDevice?.stopScan()
        tempDevice?.disconnect()
    }
    
    class func viewControllerFromSB() -> ThermometerViewController {
        return UIStoryboard(name: "Thermometer", bundle: nil).instantiateViewControllerWithIdentifier("ThermometerViewController") as! ThermometerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.baseTitle = "蓝牙智能体温贴"
        self.rightImageName = "更多"
        
        titleLabel.text = self.tempDevice?.deviceName
        lineHeightConstraint.constant = singleLineWidth
        containerScrollView.scrollIndicatorInsets.top = 50
        moveCursorPointer(0)
        tempConnect = false
        initViews()
        
        lastDate = NSDate()
        lastValue = 0
        
        
        //连接蓝牙
        if BTManager.isBLEEnable() {
            connectStateLabel.text = "扫描中..."
        }else{
            connectStateLabel.text = "蓝牙不可用"
        }
        tempDevice?.connectBLEDeviceModel(tempDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
            self.tempDevice?.connectStatusChangeHandler = nil
            self.tempDevice?.peripheral = peripheral
            self.tempDevice?.uuid = peripheral?.identifier.UUIDString;
            self.tempDevice?.connect()
            self.tempDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
                dispatch_async(dispatch_get_main_queue(), {
                    self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
                })
            }
        })
        
    }
    func connect(){
        //重连
        if tempConnect == true {
            tempDevice?.connectBLEDeviceModel(tempDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
                self.tempDevice?.peripheral = peripheral
                self.tempDevice?.uuid = peripheral?.identifier.UUIDString;
                self.tempDevice?.connect()
                self.tempDevice?.connectStatusChangeHandler = nil
                self.tempDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
                    })
                }
            })
            SVProgressHUD.dismiss()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ThermometerViewController.connect), name:"kConnectThermometer", object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kConnectThermometer", object: nil)
//         BTManager.disconnect((tempDevice?.peripheral)!)
    }
    private func initViews() {
        curTempDescLabel.hidden = true
        reportDateLabel.hidden = true
    }
    
    //MARK: - UI Actions
    
    @IBAction func backButtonClicked(sender: UIButton) {
        SVProgressHUD.dismiss()
        tempDevice?.connectStatusChangeHandler = nil;
        tempDevice?.stopScan()
        tempDevice?.disconnect()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightButtonAction() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if self.tempDevice?.isAdmin == true { //管理员为0
            sheet.addAction(UIAlertAction(title: "分享", style: .Default, handler: alertAction))
        }
        sheet.addAction(UIAlertAction(title: "历史记录", style: .Default, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "曲线分析", style: .Default, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "智能设置", style: .Default, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "重命名", style: .Default, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "删除", style: .Destructive, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: alertAction))
        
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
    
    var currentAngle: CGFloat = 0
    
    private func moveCursorPointer(value: Float) {
        self.tempIndicatorImage.hidden = false
        let minTemp: Float = 37-7
        let maxTemp: Float = 37+7
        let angle: CGFloat
        if value < minTemp {
            angle = 0
        } else if value > maxTemp {
            angle = CGFloat(M_PI)
        } else {
            angle = CGFloat((value - minTemp) / (maxTemp - minTemp)) * CGFloat(M_PI)
        }
        let indicatorCircleRadius = (160-51)/320 * UIScreen.mainScreen().bounds.width
        self.tempIndicatorImage.layer.anchorPoint = CGPointMake( indicatorCircleRadius/(tempIndicatorImage.bounds.height) + 0.5, 0.5)
        let anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.duration = 1
        anim.fromValue = currentAngle
        anim.toValue = angle
        anim.fillMode = kCAFillModeForwards
        anim.removedOnCompletion = false
        anim.cumulative = true
        
        self.tempIndicatorImage.layer .addAnimation(anim, forKey: "rotation")
        
        currentAngle = angle
    }
    
    private func setTemperatureDescription(text: String) {
        self.curTempDescLabel.text = text
        let size = NSString(string: text).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17)])
        self.descLabelHeightConstraint.constant = size.height + 10
        self.descLabelWidthConstraint.constant = size.width + 20
        self.curTempDescLabel.layer.cornerRadius = self.descLabelHeightConstraint.constant/2
        self.curTempDescLabel.clipsToBounds      = true
        self.curTempDescLabel.backgroundColor    = self.currentTempLabel.textColor
        
        self.curTempDescLabel.updateConstraints()
    }
    
    //MARK: - ActionSheet 响应
    func alertAction(action: UIAlertAction) {
        switch action.title {
        case "分享"?:
            let shareVC = ShareListViewController.instantiateOfStoryboard()
            shareVC.model = self.tempDevice
            self.navigationController?.pushViewController(shareVC, animated: true)
            break
        case "历史记录"?:
            let historyVC = TMPHistoryViewController.viewControllerFromSB()
            historyVC.tempDevice = self.tempDevice
            self.navigationController?.pushViewController(historyVC, animated: true)
        case "曲线分析"?:
            let chartVC = TMPChartViewController.viewControllerFromSB()
            chartVC.tempDevice = self.tempDevice
            self.navigationController?.pushViewController(chartVC, animated: true)
        /*
        case "设备记录"?:
            let recordVC = TMPDeviceRecordViewController.viewControllerFromSB()
            recordVC.tempDevice = self.tempDevice
            self.navigationController?.pushViewController(recordVC, animated: true)
            break
         */
        case "智能设置"?:
            let settingsVC = TMPSettingsViewController.viewControllerFromSB()
            settingsVC.tempDevice = self.tempDevice
            self.navigationController?.pushViewController(settingsVC, animated: true)
            break
        case "重命名"?:
            self.renameDevice()
        case "删除"?:
            self.deleteDevice()
        case "取消"?:
            
            break
        default: break
        }
    }
    
    
    
    //MARK: ---重命名
    private var renameDoneBttonAction: UIAlertAction?
    
    private func renameDevice() {
        let renameAlert = UIAlertController(title: "重命名", message: nil, preferredStyle: .Alert)
        renameAlert.addTextFieldWithConfigurationHandler {[weak self] (textField) in
            textField.placeholder = "请输入新的名字"
            textField.returnKeyType = .Done
            textField.textAlignment = .Center
            textField.becomeFirstResponder()
            textField.clearButtonMode = .UnlessEditing;
            textField.delegate = self
            textField.addTarget(self, action: #selector(self?.renameTextFieldEditing(_:)), forControlEvents: .EditingChanged)
        }
        let doneAction = UIAlertAction(title: "确定", style: .Default, handler: {[weak self, weak renameAlert] (action) in
            if let textField = renameAlert?.textFields?.first {
                self?.saveNewNameToCloud(textField.text!)
            }
            })
        renameAlert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        renameAlert.addAction(doneAction)
        self.renameDoneBttonAction = doneAction
        doneAction.enabled = false
        
        self.presentViewController(renameAlert, animated: true, completion: nil)
    }
    
    @objc private func renameTextFieldEditing(textField: UITextField) {
        renameDoneBttonAction?.enabled = textField.text?.characters.count > 1
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.text?.characters.count > 1
    }
    
    private func saveNewNameToCloud(name: String) {
        SVProgressHUD.showWithStatus("正在保存...")
        
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        
        guard let device = self.tempDevice,
            ////            let uuid = self.tempDevice?.uuid,
            //            let access = (self.tempDevice?.tempAccesskey) as? NSString,
            let bleMacAddress = self.tempDevice?.BLEMacAddress,
            let token = userDict[XL_KEY_TOKEN] as? String else {
                
                SVProgressHUD.showErrorWithStatus("保存失败")
                return;
        }
        
        //从测量结果单例中拉取该设备的所有设备历史
        let measurements = MeasurementsManager.shareManager().getMeasurementsWithBLEAddress(self.tempDevice?.BLEMacAddress)
        
        //排序
        var m : [MeasurementsModel] = []
        for mea in measurements {
            m.append(mea as! MeasurementsModel)
        }
        
        m = m.sort({$0.date.compare($1.date) == .OrderedAscending})
        
        let tem = NSMutableArray()
        for meas in m {
            tem.addObject(meas.getDictionary())
        }
        
        //        let access = (self.tempDevice?.tempAccesskey)! as NSString
        
        
        let dict =
            //            access.length > 0 ? [
            //            "name":name,
            //            "mac":bleMacAddress,
            //            "check_code":access,
            //            "measurement":tem,
            //            ] :
            [
                "name":name,
                "mac":bleMacAddress,
                "measurement":tem,
                ]
        HttpRequest.setDevicePropertyDictionary(dict, withDeviceID: NSNumber(int: device.deviceID), withProductID: device.productID, withAccessToken: token) { (result, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if let err = error {
                    SVProgressHUD.showErrorWithStatus("保存失败：\(err.localizedDescription)")
                    if (err.code==4031003) {
                        (UIApplication.sharedApplication().delegate as! AppDelegate).updateAccessToken()
                    }
                } else {
                    self.tempDevice?.deviceName = name
                    self.titleLabel.text = name
                    SVProgressHUD.showSuccessWithStatus("保存成功")
                    for model in AutoLoginManager.shareManager().getDeviceModelArr(){
                        let deviceModel = model as! DeviceModel
                        if deviceModel.mac == device.mac{
                            deviceModel.deviceName = name
                            break
                        }
                    }
                    //                    (UIApplication.sharedApplication().delegate as! AppDelegate).deviceVC.updateUI()
                }
            })
        }
    }
    
    private func saveNewAccesskeyToCloud(accesskey: String) {
        //        SVProgressHUD.showWithStatus("正在保存配对码...")
        
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        
        guard let device = self.tempDevice,
            let name = self.tempDevice?.deviceName,
            //            let accesskey = self.tempDevice?.tempAccesskey,
            let bleMacAddress = self.tempDevice?.BLEMacAddress,
            let token = userDict[XL_KEY_TOKEN] as? String else {
                
                //                SVProgressHUD.showErrorWithStatus("保存配对码失败")
                return;
        }
        let dict = [
            "name":name,
            "mac":bleMacAddress,
            "check_code":accesskey,
            ]
        HttpRequest.setDevicePropertyDictionary(dict, withDeviceID: NSNumber(int: device.deviceID), withProductID: device.productID, withAccessToken: token) { (result, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if let err = error {
                    //                    SVProgressHUD.showErrorWithStatus("保存失败：\(err.localizedDescription)")
                    if (err.code==4031003) {
                        (UIApplication.sharedApplication().delegate as! AppDelegate).updateAccessToken()
                    }
                } else {
                    self.tempDevice?.deviceName = name
                    //                    SVProgressHUD.showSuccessWithStatus("保存成功")
                    //                    (UIApplication.sharedApplication().delegate as! AppDelegate).deviceVC.updateUI()
                }
            })
        }
    }
    
    //MARK: ---删除设备
    private func deleteDevice() {
        let deleteAlert = UIAlertController(title: "提示", message: "确定要删除当前设备？", preferredStyle: .Alert)
        deleteAlert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        deleteAlert.addAction(UIAlertAction(title: "删除", style: .Destructive, handler: {[weak self] (delAction) in
            let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
            let userId = userDict[XL_KEY_USER_ID] as! NSNumber
            let token = userDict[XL_KEY_TOKEN] as! String
            SVProgressHUD.show()
            self?.tempDevice?.unsubscribeWithUserID(userId, accessToken:token, result: { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if let err = error where err.code != 4001034 {
                        SVProgressHUD.showErrorWithStatus("删除失败：\(err.localizedDescription)")
                    } else {
                        SVProgressHUD.dismiss()
                        
                        //                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        //                        appDelegate.deviceVC.updateUIAfterDeleteDevice(self?.tempDevice)
                        AutoLoginManager.shareManager().updateUIAfterDeleteDevice(self?.tempDevice)
                        self!.tempDevice?.connectStatusChangeHandler = nil;
                        self?.tempDevice?.stopScan()
                        self?.tempDevice?.disconnect()
                        //从本地删除
                        DeviceHelper.deleteDeviceFromLocal(self?.tempDevice?.mac)
                        //删除设备数据
                        self?.tempDevice?.clearDeviceLocalData()
                        
                        //删除历史数据
                        DBManager.shareManager().deleteAllBodyTempRecords(self!.tempDevice, loginUserId: userId.integerValue)
                        
                        //删除设备历史数据
                        DBManager.shareManager().deleteAllBodyTempRecords(self!.tempDevice, loginUserId: 0)
                        //停止检测测量结果
                        MeasurementsManager.shareManager().stopCheckBLEAddress(self?.tempDevice?.BLEMacAddress)
                        
                        self?.navigationController?.popViewControllerAnimated(true)
                    }
                })
            })
            }))
        self.presentViewController(deleteAlert, animated: true, completion: nil)
    }
    

    private func showAlert(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    //MARK: - BT Connect Status
    private func btConnectStatusChangeHandler(peripheral: CBPeripheral?, status: BTConnectStatus, object: AnyObject?) {
        print("btConnectStatusChangeHandler 设备详情界面")
        
        switch status {
        case .Scanning:
            self.connectStateLabel.text = "扫描中"
        case .Connecting:
            self.connectStateLabel.text = "连接中"
        case .Connected:
            self.connectStateLabel.text = "连接成功"
            tempConnect = false
        case .ConnectFailed:
            self.connectStateLabel.text = "连接失败"
            self.tempDevice?.peripheral = nil
            //重连
            tempDevice?.connectBLEDeviceModel(tempDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
                self.tempDevice?.peripheral = peripheral
                self.tempDevice?.uuid = peripheral?.identifier.UUIDString;
                self.tempDevice?.connect()
                self.tempDevice?.connectStatusChangeHandler = nil
                self.tempDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
                    })
                }
            })
            SVProgressHUD.dismiss()
        case .Disable:
            self.connectStateLabel.text = "蓝牙不可用"
        case .Enable:
            self.connectStateLabel.text = "蓝牙可用"
            self.tempDevice?.peripheral = nil
            //重连
            tempDevice?.connectBLEDeviceModel(tempDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
                self.tempDevice?.peripheral = peripheral
                self.tempDevice?.uuid = peripheral?.identifier.UUIDString;
                self.tempDevice?.connect()
                self.tempDevice?.connectStatusChangeHandler = nil
                self.tempDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
                    })
                }
            })
            SVProgressHUD.dismiss()
        case .Disconnected:
            self.connectStateLabel.text = "未连接"
            tempConnect = true
            self.currentTempLabel.text = "--"
            self.tempDevice?.peripheral = nil
        case .UpdateNotification:
            if let characteristic = object as? CBCharacteristic {
                switch characteristic.UUID.UUIDString {
                case "FFF1": //FFF1，数据返回通知接口通知打开
                    self.connectStateLabel.text = "连接成功"
                    ///同步时间
                    self.tempDevice?.syncClock { success in
                        if success {
                            //实时通道
                            self.tempDevice?.enableLiveDataNotify(callback: nil)
                            //历史通道
                            BTManager.sharedManager().thermoEnableReceiveDeviceHistoryDataNotify(self.tempDevice!.peripheral!, enable: true, callback: nil)
                            self.tempDevice?.receiveDeviceHistoryData {[weak self] date, value in
//                                self?.saveDeviceHistoryDataRecord(date, value: value)
                            }
                        }
                    }
                    ///获取温度发烧的阈值
                    BTManager.sharedManager().thermoSyncThresholdOfFever((self.tempDevice?.peripheral)!, callback: { (rcvData, userInfo, error) -> Bool in
                        if let err = error {
                            if err.code == BTErrorCode.Disconnected.rawValue {
                                return false
                            }
                        }
                        if let data = rcvData where data.length >= 5 {
                            var bytes = [Byte](count: data.length, repeatedValue: 0)
                            data.getBytes(&bytes, length: data.length)
                            
                            self.tempDevice?.upFever = (Int16(bytes[4] & 0b0000_1111) << 8) + Int16(bytes[3])
                            self.tempDevice?.downFever = (Int16(bytes[2] & 0b0000_1111) << 8) + Int16(bytes[1])
                            return true
                        }
                        
                        return false
                    })
                    ///获取温差和时间间隔
                    BTManager.sharedManager().thermoSyncTemperatureDifferenceAndTimeInterval((self.tempDevice?.peripheral)!, callback: { (rcvData, userInfo, error) -> Bool in
                        if let err = error {
                            if err.code == BTErrorCode.Disconnected.rawValue {
                                return false
                            }
                        }
                        if let data = rcvData where data.length >= 5 {
                            var bytes = [Byte](count: data.length, repeatedValue: 0)
                            data.getBytes(&bytes, length: data.length)
                            
                            self.tempDevice?.timeInterval = (Int16(bytes[4] & 0b0000_1111) << 8) + Int16(bytes[3])
                            self.tempDevice?.temperatureDifference = (Int16(bytes[2] & 0b0000_1111) << 8) + Int16(bytes[1])
                            return true
                        }
                        
                        return false
                    })
                    ///获取电量
                    getBatteryLevel()
                case "FFF3": //FFF3，历史数据通知接口通知打开
                    break
                case "FFF4": //FFF4，实时数据通知接口通知打开
                    tempDevice?.subscribeNextValue {[weak self] date, value ,error in
                        if error{
                            if self?.warnAlert==nil{
                                self?.warnAlert = UIAlertController(title: "提示", message: "体温计接触不良或腋下有汗水，可能会影响测量，请保持腋下干燥并贴紧", preferredStyle: .Alert)
                                self?.warnAlert!.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: {[weak self] (delAction) in
                                       self?.warnAlert=nil
                                    }))
                                self!.presentViewController((self?.warnAlert)!, animated: true, completion: nil)
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), {
                                if ((self?.warnAlert) != nil){
                                    self?.warnAlert?.dismissViewControllerAnimated(true, completion: nil)
                                    self?.warnAlert=nil
                                }
                                
                                self?.dateAndValue = (date, value)
                            })
                            if self?.lastValue != value || self?.lastDate != date{
                                self?.saveRecord(date, value: value)
                            }
                        }
                    }
                    
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    private func getBatteryLevel () {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        ///获取电量
        BTManager.sharedManager().thermoSyncBatteryLevel((self.tempDevice?.peripheral)!) { (rcvData, userInfo, error) -> Bool in
            if let err = error {
                if err.code == BTErrorCode.Disconnected.rawValue {
                    return false
                }
            }
            if let data = rcvData where data.length >= 5 {
                var bytes = [Byte](count: data.length, repeatedValue: 0)
                data.getBytes(&bytes, length: data.length)
                
                let batteryLevel = (Int16(bytes[2] & 0b0000_1111) << 8) + Int16(bytes[1])
                print("电池电量为:",batteryLevel)
                if(batteryLevel == 0){
                    if self.warningAlert != nil {
                        self.warningAlert.dismissViewControllerAnimated(true, completion: nil)
                    }
                    let message = "电量过低，请更换电池！"
                    self.warningAlert = UIAlertController(title: "警告提示", message: message, preferredStyle: .Alert)
                    self.warningAlert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
                    self.presentViewController(self.warningAlert, animated: true, completion: nil)
                    return true
                }else{
                    self.performSelector(Selector("getBatteryLevel"), withObject: nil, afterDelay: 10*60)
                }
            }
            return false
        }
    }
    
    private func saveRecord(date: NSDate, value: Float) {
        lastDate = date
        lastValue = value
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        let userId = userDict["user_id"]?.integerValue
        guard let loginUserId = userId,
            let tempDevice = tempDevice,
            let uuid = tempDevice.uuid
            else {
                return;
        }
        let record = BodyTempRecord(deviceUUID: uuid, date: date, temperature: value, memberId: userId!)
        NSLog("实时数据 date %@ value%.1f",date,value)
        
        DBManager.shareManager().insertBodyTemperature(record, tmpMeterDevice: tempDevice, loginUserId: loginUserId, memberUserId: userId!)
        if self.tempDevice?.downFever != 0 {
            if self.tempDevice?.downFever <= Int16(value*10) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showWarning(value)
                })
                //上传云端
                let meas = MeasurementsModel.init(fromBodyTempRecord: record)
                meas.mac = self.tempDevice?.BLEMacAddress
                MeasurementsManager.shareManager().addAndUpdateToCloudWithNewMeasurement(meas, BLEAddress: self.tempDevice?.BLEMacAddress)
            }
        }
        queryTemperatures()
        
        //检测这条实时数据是否需要保存到设备历史
        //        let minutesTime = true;//以分钟计算
        let minutesTime = false;//以秒计算
        if value >= 35 && value <= 45 {
            if self.tempDevice?.timeInterval != 0 && self.tempDevice?.temperatureDifference != 0 {
                //拉取到第一天实时数据时，为空
                if tempDate == nil {
                    //默认记录第一条数据
                    NSLog("实时数据添到设备历史 %@ value%.1f",record.date,value)
                    saveDeviceRecordFromRealTime(date, value: value)
                }else{
                    if abs(value - tempValue) >= Float(self.tempDevice!.temperatureDifference)/10.0 {
                        tempChange = true
                    }
                    
                    let intervalMinute = (atoi(NSDate.getHourFromDate(date))-atoi(NSDate.getHourFromDate(tempDate)))*60+atoi(NSDate.getMinuteFromDate(date))-atoi(NSDate.getMinuteFromDate(tempDate))
                    let minutes = (self.tempDevice?.timeInterval > 60 ? (self.tempDevice?.timeInterval)!/60 : 1);
                    let second = date.timeIntervalSinceDate(tempDate)
                    
                    //修改为与5秒直接的温差与智能设置的温差进行比较
                    tempValue = value
                    //修改为与5秒直接的温差与智能设置的温差进行比较
                    
                    if minutesTime == true {
                        //按照分钟计算
                        if intervalMinute >= Int32(minutes) {
                            NSLog("实时数据添到设备历史 %@ value%.1f",record.date,value)
                            saveDeviceRecordFromRealTime(date, value: value)
                        }else{
                            if tempChange == true {
                                NSLog("实时数据添到设备历史 %@ value%.1f",record.date,value)
                                saveDeviceRecordFromRealTime(date, value: value)
                            }
                        }
                    }else{
                        //按照秒计算
                        if self.tempDevice?.timeInterval <= Int16(second) {
                            NSLog("实时数据添到设备历史 %@ value%.1f",record.date,value)
                            saveDeviceRecordFromRealTime(date, value: value)
                        }else{
                            if tempChange == true {
                                NSLog("实时数据添到设备历史 %@ value%.1f",record.date,value)
                                saveDeviceRecordFromRealTime(date, value: value)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveDeviceRecordFromRealTime(date: NSDate, value: Float) {
        tempValue = value
        tempDate = date
        saveDeviceHistoryDataRecord(tempDate, value: tempValue)
        tempChange = false
    }
    
    ///保存设备历史
    private func saveDeviceHistoryDataRecord(date: NSDate, value: Float) {
        let uuid = self.tempDevice!.uuid
        let record = BodyTempRecord(deviceUUID: uuid!, date: date, temperature: value, memberId: 0)
        
        let allRecord = DBManager.shareManager().readBodyTempRecords(self.tempDevice, forOneDay:nil, dayWidth:1000, loginUserId: 0, memberUserId: 0) as? [BodyTempRecord] ?? [BodyTempRecord]()
        
        if !allRecord.contains(record) {
            NSLog("实时数据添到设备历史 %@ value%.1f",record.date,value)
            DBManager.shareManager().insertBodyTemperature(record, tmpMeterDevice: tempDevice, loginUserId: 0, memberUserId: 0)
        }
    }
    
    ///显示警告(包括前台、后台)
    private func showWarning(value:Float){
        let nickname = NSUserDefaultInfos.getValueforKey(USER_NAME)
        
        var message = String(format: "%@体温：%.1f℃",nickname,value) //"\(curMember?.nickName)体温：\(value)℃"
        if value > 45.0 {message = String(format: "%@体温：45.0℃",nickname)} //"\(curMember?.nickName)体温：\(value)℃"
        if value < 25.0 {message = String(format: "%@体温：25.0℃-",nickname)} //"\(curMember?.nickName)体温：\(value)℃"
        
        NotificationHandler.shareHendler().makeToastWithConfigNotification(message)
        
    }
    
    private func queryTemperatures() {
        let date = NSDate()
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        let userId = userDict["user_id"]?.integerValue
        guard let loginUserId = userId,
            let tempDevice = tempDevice
            else {
                return;
        }
        //读取最高、最低、平均温度
        let max = DBManager.shareManager().queryBodyTemperature(tempDevice, forOneDay: date, dayWidth:1, function: .Max, loginUserId: loginUserId, memberUserId: userId!)
        let avg = DBManager.shareManager().queryBodyTemperature(tempDevice, forOneDay: date, dayWidth:1, function: .Avg, loginUserId: loginUserId, memberUserId: userId!)
        let min = DBManager.shareManager().queryBodyTemperature(tempDevice, forOneDay: date, dayWidth:1, function: .Min, loginUserId: loginUserId, memberUserId: userId!)
        
        dispatch_async(dispatch_get_main_queue(), {
            if max > 45{
                self.highestTempLabel.text = String(format: "%.1f", 45.0)
            }else{
                self.highestTempLabel.text = String(format: "%.1f", max)
            }
            self.averageTempLabel.text = String(format: "%.1f", avg)
            self.lowestTempLabel.text  = String(format: "%.1f", min)
            self.highestTempLabel.textColor = ThermometerModel.valueColor(Float(max))
            self.averageTempLabel.textColor = ThermometerModel.valueColor(Float(avg))
            self.lowestTempLabel.textColor  = ThermometerModel.valueColor(Float(min))
        })
    }
    
}
