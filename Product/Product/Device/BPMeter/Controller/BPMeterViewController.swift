//
//  BPMeterViewController.swift
//  Product
//
//  Created by WuJiezhong on 16/5/25.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit


class BPMeterViewController: LightStatusBarViewController, UIActionSheetDelegate, UITextFieldDelegate{
    
    var bpmeterDevice: BPMeterModel?
    ///app在本界面时保存数据到本地数据库，不在本界面则不保存
    var shouldSaveRecord : Bool!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    ///指针
    @IBOutlet weak var pointerImage: UIImageView!
    ///连接状态
    @IBOutlet weak var connectStateLabel: UILabel!
    ///报告描述
    @IBOutlet weak var reportDescLabel: UILabel!
    ///报告的时间
    @IBOutlet weak var reportDateLabel: UILabel!
    ///高压值
    @IBOutlet weak var highPressureLabel: UILabel!
    ///低压值
    @IBOutlet weak var lowPressureLabel: UILabel!
    ///心率值
    @IBOutlet weak var heartRateLabel: UILabel!
    ///心率值描述图片
    @IBOutlet weak var heartRateDescImage: UIImageView!
    
    ///食材推荐图片
    @IBOutlet var recommendImages: [UIImageView]!
    @IBOutlet var recommendLabels: [UILabel]!
    @IBOutlet weak var recommendLab: UILabel!
    @IBOutlet weak var changeBut: UIButton!
    
    
    ///竖线的宽度
    @IBOutlet weak var verticalLineWidth: NSLayoutConstraint!
    ///水平线的高度
    @IBOutlet weak var horizLineHeight: NSLayoutConstraint!
    
    
    private var recommends : NSMutableDictionary?{
        didSet {
            if let commends = recommends {
                
                ///恢复默认状态
                for image in recommendImages {
                    image.image = UIImage()
                    if ((image.gestureRecognizers) != nil) {
                        for ges in image.gestureRecognizers! {
                            image.removeGestureRecognizer(ges)
                        }
                    }
                }
                for label in recommendLabels {
                    label.text = ""
                }
                recommendLab.hidden = true
                changeBut.hidden = true
                
                if commends.count > 0 {
                    recommendLab.hidden = false
                    changeBut.hidden = false
                    ///显示新内容
                    let coms:NSArray = commends.objectForKey("list") as! NSArray
                    
                    for comDict in coms {
                        let index = coms.indexOfObject(comDict)
                        let commentImage = recommendImages[index]
                        let commentLabel = recommendLabels[index]
                        commentImage.tag = index
                        let url:NSString = comDict.objectForKey("images")?.firstObject as! NSString
                        
                        commentImage.sd_setImageWithURL(NSURL(string: url as String), placeholderImage: UIImage(named: "菜谱默认图.png"))
                        commentLabel.text = comDict.objectForKey("name") as? String
                        let ges = UITapGestureRecognizer()
                        ges.addTarget(self, action: #selector(BPMeterViewController.touchImage(_:)))
                        commentImage.addGestureRecognizer(ges)
                        commentImage.userInteractionEnabled = true
                    }
                }
            }
        }
    }

    
    @objc private func touchImage(ges:UITapGestureRecognizer){
        let index = ges.view?.tag
        if let commends = recommends {
            let coms:NSArray = commends.objectForKey("list") as! NSArray
            let comDict:NSDictionary = coms[index!] as! NSDictionary
            let foodVC = FoodDetailViewController.instantiateOfStoryboard()
            foodVC.foodDic = comDict as [NSObject : AnyObject]
            self.navigationController?.pushViewController(foodVC, animated: true)
        }
    }
    
    
    //MARK: - UIViewController
    
    class func viewControllerFromSB() -> BPMeterViewController {
        return UIStoryboard(name: "BPMeter", bundle: nil).instantiateViewControllerWithIdentifier("BPMeterViewController") as! BPMeterViewController
    }
    
    deinit{
        NSLog(">>>>>>>>>>> BPMeterViewController deinit <<<<<<<<<")
        SVProgressHUD.dismiss()
        self.bpmeterDevice?.stopScan()
        self.bpmeterDevice?.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.baseTitle=self.bpmeterDevice?.deviceName
        self.rightImageName="更多"
        
        

        verticalLineWidth.constant = singleLineWidth
        horizLineHeight.constant   = singleLineWidth
        
        containerScrollView.scrollIndicatorInsets.top = 50
        pointerImage.layer.anchorPoint = CGPointMake(0.5, (pointerImage.bounds.height - pointerImage.bounds.midX) / pointerImage.bounds.height)
        
        
        resetState()
        
        //连接蓝牙
        if BTManager.isBLEEnable() {
            connectStateLabel.text = "扫描中..."
        }else{
            connectStateLabel.text = "蓝牙不可用"
        }
        self.bpmeterDevice?.connectBLEDeviceModel(self.bpmeterDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
            self.bpmeterDevice?.peripheral = peripheral
            self.bpmeterDevice?.uuid = peripheral?.identifier.UUIDString;
            self.bpmeterDevice?.connect()
            self.bpmeterDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
                dispatch_async(dispatch_get_main_queue(), {
                    self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
                })
            }
        })

        recommends = NSMutableDictionary()
        
        // 判断是否弹出提示框，YES不再提示 | NO则进入提示
        let flag = NSUserDefaults.standardUserDefaults().boolForKey("isNoLonger");
        if (!flag)
        {
            let measure = BPMeasureTipView(frame:CGRectMake(0, 0, screenWidth, screenHeight));
            measure.showInView(self.view) { (isNoLonger) in
                
                // YES不再提示
                // NO则进入提示
                NSUserDefaults.standardUserDefaults().setObject(isNoLonger, forKey: "isNoLonger")
            };
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UserManager.shareManager().menuFuncToken == nil {
            HttpRequest.applyMenuTokendidLoadData({ (result, error) in
                
            })
        }
        bpmeterDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
            })
        }
//        self.changeRecommendation(UIButton())
        shouldSaveRecord = true
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        shouldSaveRecord = false
        bpmeterDevice?.stopScan()
    }

    //MARK: - UI Actions
    
    override func leftButtonAction() {
        bpmeterDevice?.connectStatusChangeHandler = nil;
        shouldSaveRecord = false
        bpmeterDevice?.stopScan()
        bpmeterDevice?.disconnect()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightButtonAction() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        if self.bpmeterDevice?.isAdmin == true { //管理员为0
            sheet.addAction(UIAlertAction(title: "分享", style: .Default, handler: alertAction))
        }
        sheet.addAction(UIAlertAction(title: "历史记录", style: .Default, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "曲线分析", style: .Default, handler: alertAction))
        //sheet.addAction(UIAlertAction(title: "设备记录", style: .Default, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "重命名", style: .Default, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "删除", style: .Destructive, handler: alertAction))
        sheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: alertAction))
        
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
    
    @IBAction func changeRecommendation(sender: UIButton) {
//        doGetMenuWithOffset("0")
        var total=0
        if self.recommends?.count > 0 {
            total=(self.recommends?.objectForKey("count")!.intValue)!-4
        }
        
        if (total<0) {
            total=0
        }
        
        let randomNum=self.getRandomNumber(0, to: Int(total))
        
        self.doGetMenuWithOffset("\(randomNum)")
        
    }
    
    ///mark 根据总食材的范围算出一个随机值，用来显示“换一换”的食材
    func getRandomNumber(from:Int,to:Int) -> Int {
        let max: UInt32 = UInt32(from - to)
        return Int(arc4random_uniform(max) + UInt32(from))
    }
    
    //MARK: ---根据偏移量获取推荐食材，无血压值则显示时令食材
    func doGetMenuWithOffset(offset:NSString) {
        var str = [NSUserDefaultInfos.getMonthStrFromCurrentDate() as NSString]
        let discriptionStr = (self.bpmeterDevice?.valueDiscription)! as NSString
        
        if discriptionStr.length > 0 && self.bpmeterDevice?.SBP > 0 && self.bpmeterDevice?.DBP > 0 {
            str = [discriptionStr]
        }
        let dateDic = ["$in":str]
        let queryDic = ["properties.push_rules":dateDic]
        let order = ["created_at":"asc"]
        let token = UserManager.shareManager().menuFuncToken ?? ""
        
        
        HttpRequest.getFoodWithOffset(offset as String, withAccessToken: token, withLimit: "4", withFilter: ["name","instructions","iamges"], withQuery: queryDic, withOrder: order) { (result, err) in
            if (err != nil) {
                print("\(err.code)+err.localizedDescription")
            }else{
                print("\(result)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.recommends = result as? NSMutableDictionary
                })
            }
        }
    }
    
    //MARK : 点击弹出测量提示框
    @IBAction func onBtnTip(sender: AnyObject) {
        let measure = BPMeasureTipView(frame:CGRectMake(0, 0, screenWidth, screenHeight));
        measure.showInView(self.view) { (isNoLonger) in
            
            // YES不再提示
            // NO则进入提示
            NSUserDefaults.standardUserDefaults().setObject(isNoLonger, forKey: "isNoLonger")
        };
    }
    
    func alertAction(action: UIAlertAction) {
        switch action.title {
        case "分享"?:
            let shareVC = ShareListViewController.instantiateOfStoryboard()
            shareVC.model = self.bpmeterDevice
            self.navigationController?.pushViewController(shareVC, animated: true)
            break
        case "历史记录"?:
            let historyVC = BPMHistoryViewController.viewControllerFromSB()
            self.navigationController?.pushViewController(historyVC, animated: true)
        case "曲线分析"?:
            let chartVC = BMPChartViewController.viewControllerFromSB()
            chartVC.BPDevice = self.bpmeterDevice
            self.navigationController?.pushViewController(chartVC, animated: true)
        case "设备记录"?:

            let personListVC = UIStoryboard(name: "BPMeter", bundle: nil).instantiateViewControllerWithIdentifier("PersonListViewController") as! PersonListViewController
            personListVC.bpDevice = self.bpmeterDevice
            self.navigationController?.pushViewController(personListVC, animated: true)
            
            break
        case "重命名"?:
            self.renameDevice()
            break
        case "删除"?:
            self.deleteDevice()
            break
        default: break
        }
    }
    
    private func showAlert(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: ---重命名
    
    private var renameDoneBttonAction: UIAlertAction?
    
    private func renameDevice() {
        let renameAlert = UIAlertController(title: "重命名", message: nil, preferredStyle: .Alert)
        renameAlert.addTextFieldWithConfigurationHandler {[weak self] (textField) in
            textField.placeholder = "请输入新的名字"
            textField.returnKeyType = .Done
            textField.textAlignment = .Center
            textField.clearButtonMode = .UnlessEditing;
            textField.becomeFirstResponder()
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
        
        guard let device = self.bpmeterDevice,
//            let uuid = self.bpmeterDevice?.uuid,
            let bleMacAddress = self.bpmeterDevice?.BLEMacAddress,
            let token = userDict[XL_KEY_TOKEN] as? String else {
                
            SVProgressHUD.showErrorWithStatus("保存失败")
            return;
        }
        
        //从测量结果单例中拉取该设备的所有设备历史
        let measurements = MeasurementsManager.shareManager().getMeasurementsWithBLEAddress(self.bpmeterDevice?.BLEMacAddress)
        
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
        
        let dict = [
            "name":name,
            "mac":bleMacAddress,
            "measurements":tem,
        ]
        HttpRequest.setDevicePropertyDictionary(dict, withDeviceID: NSNumber(int: device.deviceID), withProductID: device.productID, withAccessToken: token) { (result, error) in
            dispatch_async(dispatch_get_main_queue(), {
                
                if let err = error {
                    SVProgressHUD.showErrorWithStatus("保存失败：\(err.localizedDescription)")
                    if (err.code==4031003) {
                        (UIApplication.sharedApplication().delegate as! AppDelegate).updateAccessToken()
                    }
                } else {
                    self.bpmeterDevice?.deviceName = name
                    self.baseTitle=self.bpmeterDevice?.deviceName
                    
                    for model in AutoLoginManager.shareManager().getDeviceModelArr(){
                        let deviceModel = model as! DeviceModel
                        if deviceModel.mac == device.mac{
                            deviceModel.deviceName = name
                            break
                        }
                    }
                    SVProgressHUD.showSuccessWithStatus("保存成功")
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
            self?.bpmeterDevice?.unsubscribeWithUserID(userId, accessToken:token, result: { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                    if let err = error where err.code != 4001034 {
                        self?.showAlert("提示", message: "删除失败：\(err.localizedDescription)")
                    } else {
//                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                        appDelegate.deviceVC.updateUIAfterDeleteDevice(self?.bpmeterDevice)
                        AutoLoginManager.shareManager().updateUIAfterDeleteDevice(self?.bpmeterDevice)
                        self?.bpmeterDevice?.stopScan()
                        self?.bpmeterDevice?.disconnect()
                        //从本地删除
                        DeviceHelper.deleteDeviceFromLocal(self?.bpmeterDevice?.mac)
                        //删除设备数据
                        self?.bpmeterDevice?.clearDeviceLocalData()

                        //删除用户历史数据
                        DBManager.shareManager().deleteAllBPRecords(self!.bpmeterDevice, loginUserId: userId.integerValue)
                        
                        //删除设备历史数据
                        DBManager.shareManager().deleteAllBPRecords(self!.bpmeterDevice, loginUserId: 0)
                        //停止检测测量结果
                        MeasurementsManager.shareManager().stopCheckBLEAddress(self?.bpmeterDevice?.BLEMacAddress)
                        self?.navigationController?.popViewControllerAnimated(true)
                    }
                })
            })
            }))
        self.presentViewController(deleteAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - BT Connect Status
    private func btConnectStatusChangeHandler(peripheral: CBPeripheral?, status: BTConnectStatus, object: AnyObject?) {
        switch status {
        case .Scanning:
            self.connectStateLabel.text = "扫描中"
        case .Connecting:
            if self.connectStateLabel.text != "已断开" {
                self.connectStateLabel.text = "连接中"
            }
        case .Connected:
            self.connectStateLabel.text = "连接中"
            bpmeterDevice?.initDevice()
        case .ConnectFailed:
            self.connectStateLabel.text = "连接失败"
            self.bpmeterDevice?.peripheral = nil
            //重连
            self.bpmeterDevice?.connectBLEDeviceModel(self.bpmeterDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
                self.bpmeterDevice?.peripheral = peripheral
                self.bpmeterDevice?.uuid = peripheral?.identifier.UUIDString;
                self.bpmeterDevice?.connect()
                self.bpmeterDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
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
            self.bpmeterDevice?.peripheral = nil
            //重连
            self.bpmeterDevice?.connectBLEDeviceModel(self.bpmeterDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
                self.bpmeterDevice?.peripheral = peripheral
                self.bpmeterDevice?.uuid = peripheral?.identifier.UUIDString;
                self.bpmeterDevice?.connect()
                self.bpmeterDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
                    })
                }
            })
            SVProgressHUD.dismiss()

        case .Disconnected:
            self.connectStateLabel.text = "已断开"
            self.bpmeterDevice?.peripheral = nil
            //重连
            self.bpmeterDevice?.connectBLEDeviceModel(self.bpmeterDevice! as BLEDeviceModel, withType: DeviceType(rawValue: 6)!, callbackDevice: { (peripheral, uuid) in
                self.bpmeterDevice?.peripheral = peripheral
                self.bpmeterDevice?.uuid = peripheral?.identifier.UUIDString;
                self.bpmeterDevice?.connect()
                self.bpmeterDevice?.connectStatusChangeHandler = {[weak self] (peripheral, status, object) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.btConnectStatusChangeHandler(peripheral, status: status, object: object)
                    })
                }
            })
        case .UpdateNotification:
            if let characteristic = object as? CBCharacteristic {
                switch characteristic.UUID.UUIDString {
                case "FCA1": //FCA1，数据返回通知接口通知打开
                    bpmeterDevice?.startVerify({ [weak self] (error) in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                self?.connectStateLabel.text = "已连接"
                                self?.resetState()
                                ///同步时间
                                BTManager.sharedManager().bpmeterSyncDate((self?.bpmeterDevice?.peripheral)!, callback: nil)
                                BTManager.sharedManager().bpmeterSyncTime((self?.bpmeterDevice?.peripheral)!, callback: nil)
                                
                            })
                            //开始测量
                            self?.startMeasure()
                        }
                    })
                    break
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func startMeasure() {
        bpmeterDevice?.subscribeCurrentValue({ (value, isHeartBeating) in
            dispatch_async(dispatch_get_main_queue(), {
                self.SBP = value
            })
        })
        bpmeterDevice?.subscribeResultValue({ [weak self] (SBP, DBP, heartRate, isHBUneven, isUserOne) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.SBP = SBP
                self?.DBP = DBP
                self?.heartRate = heartRate
                self?.isHBUneven = isHBUneven
                self?.isUserOne = isUserOne
                self?.reportDescLabel.text = self?.bpmeterDevice?.valueDiscription
                self?.reportDescLabel.textColor = self?.bpmeterDevice?.valueColor
            })
            
            self?.saveRecord()
        })
        bpmeterDevice?.subscribeDate({ [weak self] (date) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.date = date
            })
            self?.saveRecord()
        })
        bpmeterDevice?.subscribeTime({ [weak self] (time) in
            dispatch_async(dispatch_get_main_queue(), {
                self?.time = time
            })
            self?.saveRecord()
        })
        bpmeterDevice?.subscribeErrorMessage({ [weak self] (message, tips, code) in
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
        let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
        let userId = userDict["user_id"]?.integerValue
        guard let DBP = DBP,
            let SBP = SBP,
            let heartRate = heartRate,
            let isHBUneven = isHBUneven,
            let date = date,
            let time = time,
            let loginUserId = userId
        else {
            return;
        }
        let dateTimeStr = "\(date) \(time)"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let saveDate = formatter.dateFromString(dateTimeStr) {
            let record = BPRecord(deviceUUID:self.bpmeterDevice!.BLEMacAddress!,
                                  date: saveDate,
                                  SBP: SBP,
                                  DBP: DBP,
                                  heartRate: heartRate,
                                  isHBUneven:isHBUneven,
                                  userId: userId!)
            if shouldSaveRecord == true {
                //1.获取所有的历史记录
                let userDict = NSUserDefaultInfos.getDicValueforKey(USER_DIC)
                if let userId = userDict["user_id"]?.integerValue {
                    let records = DBManager.shareManager().readBPRecords(self.bpmeterDevice, loginUserId: userId, memberUserId: userId) as? [BPRecord] ?? [BPRecord]()
                    if !records.contains(record) {
                        NSLog("保存记录")
                        DBManager.shareManager().insertBPRecord(record, bpMeterDevice: self.bpmeterDevice, loginUserId: loginUserId, memberUserId: userId)
                        
                        //上传云端
                        let meas = MeasurementsModel.init(fromBPRecord: record)
                        meas.mac = self.bpmeterDevice?.BLEMacAddress
                        MeasurementsManager.shareManager().addAndUpdateToCloudWithNewMeasurement(meas, BLEAddress: self.bpmeterDevice?.BLEMacAddress)
                    }
                }
                //保存一次数据则更新一次食材推荐
//                self.changeRecommendation(UIButton())
            }

        }
    }
    
    //MARK: - setters
    
    private var date: String? {
        didSet {
            if let date = date, let time = time {
                self.reportDateLabel.text = "\(date) \(time)"
                self.reportDateLabel.hidden = false
            } else {
                self.reportDateLabel.hidden = true
            }
        }
    }
    private var time: String? {
        didSet {
            self.date = self.date ?? nil
        }
    }
    
    ///收缩压
    private var SBP: UInt16? {
        didSet {
            if let sbp = SBP {
                self.highPressureLabel.text = "\(sbp)"
                self.highPressureLabel.textColor = bpmeterDevice!.valueColor
                self.setPointer(sbp ?? 0, animate: true)
            } else {
                self.highPressureLabel.text = "--"
            }
        }
    }
    
    ///舒张压
    private var DBP: UInt16? {
        didSet {
            if let dbp = DBP {
                self.lowPressureLabel.text  = "\(dbp)"
                self.lowPressureLabel.textColor = bpmeterDevice!.valueColor
            } else {
                self.lowPressureLabel.text = "--"
            }
        }
    }
    
    ///心率
    private var heartRate: UInt16? {
        didSet {
            if let rate = heartRate {
                self.heartRateLabel.text    = "\(rate)"
                self.heartRateLabel.textColor = UIColor(hex: 0x8bd838)

                //获取当前时间
                let now = NSDate()
                
                // 创建一个日期格式器
                let dformatter = NSDateFormatter()
                dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                print("当前日期时间：\(dformatter.stringFromDate(now))")
                
                //当前时间的时间戳
                let timeInterval:NSTimeInterval = now.timeIntervalSince1970
                let timeStamp = Int(timeInterval)
                print("------------------：\(timeStamp)")
                
                let body = String(format: "diastolic_pressure=%@&systolic_pressure=%@&measure_time=%d&heart_rate=%@&way=2",arguments:[ self.highPressureLabel.text!, self.lowPressureLabel.text! ,timeStamp,  self.heartRateLabel.text!])
                NetworkTool.sharedNetworkTool().postMethodWithURL("webapp/blood_pressure/pressureRecord", body: body, success: { (json) in
                    print("------------------：\(json)")
                    
                }) { (erreo) in
                    print("------------------：\(erreo)")
                }
            
            } else {
                self.heartRateLabel.text = "--"
            }
        }
    }
    
    ///心率不齐
    private var isHBUneven: Bool? {
        didSet {
            self.heartRateDescImage.hidden = true
            /*
            if let uneven = isHBUneven {
                self.heartRateDescImage.hidden = false
                self.heartRateDescImage.image = UIImage(named: uneven ? "不齐":"正常")
            } else {
                self.heartRateDescImage.hidden = true
            }
 */
        }
    }
    
    private var isUserOne: Bool? {
        didSet {
            if isUserOne != nil {
                
            }else{
                
            }
        }
    }
    
    ///指针
    private func setPointer(bp: UInt16, animate: Bool) {
        //1°值为129/140, 起始角度为-120°
        let angle = (129 * CGFloat(bp)) / 140 - 120
        
        let transform = CGAffineTransformMakeRotation(angle * (CGFloat(M_PI)/180))
        
        if animate {
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveLinear, animations: {
                self.pointerImage.transform = transform
            }, completion: nil)
        } else {
            self.pointerImage.transform = transform
        }
    }
    
    ///重置状态
    private func resetState() {
        self.DBP = nil
        self.SBP = nil
        self.heartRate = nil
        self.isHBUneven = nil
        self.date = nil
        self.time = nil
        self.reportDescLabel.text = "--"
        self.setPointer(0, animate: true)
        self.reportDateLabel.hidden = true
        self.heartRateDescImage.hidden = true
        self.setPointer(0, animate: true)
    }
    
    //MARK: - ---
    
}
