//
//  ValuePickerView.swift
//  Product
//
//  Created by WuJiezhong on 16/5/27.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import UIKit

let valuePickerViewHeight: CGFloat = 234

public enum ValuePickerStyle {
    ///体温温差
    case TempDiff
    ///时间间隔
    case TimeInterval
    ///报警体温
    case BodyTemp
}

public protocol ValuePickerViewDelegate: class {
    func numberOfComponentsInPickerView(pickerView: ValuePickerView) -> Int
    //    func pickerView(pickerView: ValuePickerView, numberOfRowsInComponent component: Int) -> Int
    //    func pickerView(pickerView: ValuePickerView, titleForRow row: Int, forComponent component: Int) -> String?
    func pickerView(pickerView: ValuePickerView, tailTitleForComponent component: Int) -> String?
    
    func minValueInPickerView(pickerView: ValuePickerView) -> Float
    func maxValueInPickerView(pickerView: ValuePickerView) -> Float
    func stepValueInPickerView(pickerView: ValuePickerView) -> Float
    func formatStringInPickerView(pickerView: ValuePickerView) -> String
    //点击Done回调
    func clickDoneInPickerView(pickerView: ValuePickerView)
}

public class ValuePickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public var title: String = "选择" {
        didSet {
            self.titleLabel.text = title
        }
    }
    public var style: ValuePickerStyle = .TimeInterval
    public weak var delegate: ValuePickerViewDelegate?
    public var currentValue: Float = 0
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var okButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet weak var lineHeightConstraints: NSLayoutConstraint!
    
    private var backgroundView: UIControl? {
        didSet {
            backgroundView?.addTarget(self, action: #selector(self.dismiss), forControlEvents: .TouchUpInside)
        }
    }
    private var tailTitles: [String] {
        switch style {
        case .TempDiff, .BodyTemp:
            return [".", "℃"]
        case .TimeInterval:
            return ["分钟"]
        }
    }
    
    override public func awakeFromNib() {
        self.tintColor = UIColor(hex: 0xFF8314)
        self.okButton.tintColor = self.tintColor
        self.lineHeightConstraints.constant = singleLineWidth
    }
    
    private var label0: UILabel!
    private var label1: UILabel?
    lazy private var labelFont = UIFont.systemFontOfSize(16)
    private var rowWidth: CGFloat = 40
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let titles = tailTitles
        switch style {
        case .TempDiff where label0 == nil || label1 == nil:
            label0 = UILabel()
            label0.text = titles[0]
            label0.font = labelFont
            label0.sizeToFit()
            label0.center = pickerView.center
            
            label1 = UILabel()
            label1!.text = titles[1]
            label1!.font = labelFont
            label1!.sizeToFit()
            label1!.center = CGPointMake(pickerView.center.x + rowWidth + label1!.bounds.midX, pickerView.center.y)
            
            self.addSubview(label0)
            self.addSubview(label1!)
            
        case .TimeInterval where label0 == nil:
            label0 = UILabel()
            label0.text = titles[0]
            label0.font = labelFont
            label0.sizeToFit()
            label0.center = CGPointMake(pickerView.center.x + rowWidth/2 + label0!.bounds.midX, pickerView.center.y)
            self.addSubview(label0)
            
        case .BodyTemp where label0 == nil || label1 == nil:
            label0 = UILabel()
            label0.text = titles[0]
            label0.font = labelFont
            label0.sizeToFit()
            label0.center = pickerView.center
            
            label1 = UILabel()
            label1!.text = titles[1]
            label1!.font = labelFont
            label1!.sizeToFit()
            label1!.center = CGPointMake(pickerView.center.x + rowWidth + label1!.bounds.midX, pickerView.center.y)
            
            self.addSubview(label0)
            self.addSubview(label1!)
        default:
            break
        }
        label0.textColor  = self.tintColor
        label1?.textColor = self.tintColor
        
        self.setPickerCurrentValue(currentValue, animated: false)
        
//        setCurrentValue(currentValue, animated: false)
//        self.performSelector(#selector(ValuePickerView.setCurrentValue(_:animated:)), withObject: [currentValue, false])
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.setCurrentValue(self.currentValue, animated: false)
//        });
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        dismiss()
    }
    
    @IBAction func okButtonClicked(sender: UIButton) {
        dismiss()
        if ((self.delegate?.clickDoneInPickerView) != nil) {
            self.delegate?.clickDoneInPickerView(self)
        }
    }
    
    func dismiss() {
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.backgroundView?.alpha = 0
            self.center.y = self.center.y + self.bounds.height
            }, completion: { _ in
                self.removeFromSuperview()
                self.backgroundView?.removeFromSuperview()
        })
        
    }
    
    //MARK: - PickerView Datasource
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch style {
        case .TempDiff:
            return 2
        case .TimeInterval:
            return 1
        case .BodyTemp:
            return 2
        }
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch style {
        case .TempDiff where component == 0:
            return 6
        case .TempDiff where component == 1:
            return 10
            
        case .TimeInterval:
            return 60
            
        case .BodyTemp where component == 0:    //35.0 - 41.0
            return 7
        case .BodyTemp where component == 1:
            return 10
        default:
            return 0
        }
    }
    
    public func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return rowWidth
    }
    
    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.textAlignment = .Center
        }
        label?.font = labelFont
        label?.text = textForComponent(component, row: row)
        label?.sizeToFit()
        
        return label!
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let label = pickerView.viewForRow(row, forComponent: component) as? UILabel {
            label.textColor = self.tintColor
        }
        
        currentValue = self.getPickerCurrentValue()
        
        self.checkLimit()
    }
    
    private func checkLimit() {
        switch style {
        case .TempDiff where currentValue > 5.0:
            currentValue = 5.0
            self.setPickerCurrentValue(currentValue, animated: true)
        case .TempDiff where currentValue < 0.1:
            currentValue = 0.1
            self.setPickerCurrentValue(currentValue, animated: true)
        case .BodyTemp where currentValue > 41.0:
            currentValue = 41.0
            self.setPickerCurrentValue(currentValue, animated: true)
        default:
            return
        }
    }
    
    private func textForComponent(component: Int, row: Int) -> String {
        switch style {
        case .TempDiff where component == 0:    //0.1 - 5.0
            return "\(row)"
        case .TempDiff where component == 1:
            return "\(row)"
            
        case .TimeInterval:
            return "\(row + 1)"
            
        case .BodyTemp where component == 0:    //35.0 - 41.0
            return "\(row + 35)"
        case .BodyTemp where component == 1:
            return "\(row)"
        default:
            return ""
        }
    }
    
    private func setPickerCurrentValue(value: Float, animated: Bool) {
        switch style {
        case .TempDiff:
            let unit = Int(value * 10) / 10
            let decimal = Int(value * 10) % 10
            pickerView.selectRow(unit, inComponent: 0, animated: animated)
            pickerView.selectRow(decimal, inComponent: 1, animated: animated)
            
            self.pickerView(pickerView, didSelectRow: unit, inComponent: 0)
            self.pickerView(pickerView, didSelectRow: decimal, inComponent: 1)
            
        case .TimeInterval:
            var unit = Int(value)
            unit = unit > 1 ? unit-1:0
            pickerView.selectRow(unit, inComponent: 0, animated: animated)
            
            self.pickerView(pickerView, didSelectRow: unit, inComponent: 0)
            
        case .BodyTemp:
            var unit = Int(value * 10) / 10
            let decimal = Int(value * 10) % 10
            unit = unit > 35 ? unit-35:0
            pickerView.selectRow(unit, inComponent: 0, animated: animated)
            pickerView.selectRow(decimal, inComponent: 1, animated: animated)
            
            self.pickerView(pickerView, didSelectRow: unit, inComponent: 0)
            self.pickerView(pickerView, didSelectRow: decimal, inComponent: 1)
        }
    }
    
    private func getPickerCurrentValue() -> Float {
        switch style {
        case .TempDiff:
            let unit    = pickerView.selectedRowInComponent(0)
            let decimal = pickerView.selectedRowInComponent(1)
            
            return Float(unit) + Float(decimal)/10
            
        case .TimeInterval:
            let unit = pickerView.selectedRowInComponent(0)
            return Float(unit+1)
            
        case .BodyTemp:
            let unit    = pickerView.selectedRowInComponent(0)
            let decimal = pickerView.selectedRowInComponent(1)
            
            return Float(unit+35) + Float(decimal)/10
        }
    }
    
    
    //MARK: - static method
    
    class func show(style: ValuePickerStyle, title: String, currentValue: Float?, delegate: ValuePickerViewDelegate?) {
        if let window = UIApplication.sharedApplication().keyWindow {
            let picker = NSBundle.mainBundle().loadNibNamed("ValuePickerView", owner: self, options: nil).first as! ValuePickerView
            picker.frame = CGRectMake(0, window.bounds.height, window.bounds.width, valuePickerViewHeight)
            picker.style          = style
            picker.title          = title
            picker.currentValue   = currentValue ?? 0
            picker.delegate       = delegate
            picker.backgroundView = UIControl(frame: window.bounds)
            picker.backgroundView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            picker.backgroundView?.alpha = 0
            window.addSubview(picker.backgroundView!)
            window.addSubview(picker)
            
            //出现动画
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                picker.backgroundView!.alpha = 1
                picker.center.y = window.bounds.height - picker.bounds.midY
                }, completion: nil)
            
        } else {
            assert(true, "Has no keyWindow in application instance.")
        }
        
    }
}
