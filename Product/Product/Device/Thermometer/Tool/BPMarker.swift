//
//  BPMarker.swift
//  Product
//
//  Created by 梁家誌 on 16/7/21.
//  Copyright © 2016年 TianJi. All rights reserved.
//

import Foundation
;
import Charts;

class BPMarker: ChartMarker {
    internal var color: UIColor?
    internal var arrowSize = CGSize(width: 15, height: 11)
    internal var font: UIFont?
    internal var insets = UIEdgeInsets()
    internal var minimumSize = CGSize()
    internal var guardLimitValue = 240.0
    internal var guardLimitColor = UIColor.redColor()
    internal var valueIsAvarage: Bool = false
    
    private var value:Double?
    private var labelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    
    internal init(color: UIColor, font: UIFont, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .Center
    }
    
    internal override var size: CGSize { return _size; }
    
    internal override func draw(context context: CGContext, point: CGPoint)
    {
        if (labelns == nil)
        {
            return
        }
        
        var rect = CGRect(origin: point, size: _size)
        rect.origin.x -= _size.width / 2.0
//        rect.origin.y -= _size.height + 20
        rect.origin.y -= _size.height
        
        CGContextSaveGState(context)
        
        CGContextSetFillColorWithColor(context, color?.CGColor)
        CGContextBeginPath(context)
        
        /****
         CGContextMoveToPoint(context,
         rect.origin.x,
         rect.origin.y)
         CGContextAddLineToPoint(context,
         rect.origin.x + rect.width,
         rect.origin.y)
         CGContextAddArc(context, rect.origin.x + rect.width, rect.origin.y + _size.height/2, _size.height/2, CGFloat(M_PI/2 * 3), CGFloat(M_PI/2), 0)
         CGContextAddLineToPoint(context,
         rect.origin.x,
         rect.origin.y + rect.height)
         CGContextAddArc(context, rect.origin.x, rect.origin.y + _size.height/2, _size.height/2, CGFloat(M_PI/2), CGFloat(M_PI/2 * 3), 0)
         **/
        
        CGContextMoveToPoint(context,
                             rect.origin.x,
                             rect.origin.y)
        CGContextAddLineToPoint(context, rect.maxX, rect.minY)
        CGContextAddLineToPoint(context, rect.maxX, rect.maxY)
        CGContextAddLineToPoint(context, rect.midX + 8, rect.maxY)
        CGContextAddLineToPoint(context, rect.midX, rect.maxY + 7)
        CGContextAddLineToPoint(context, rect.midX - 8, rect.maxY)
        CGContextAddLineToPoint(context, rect.minX, rect.maxY)
        CGContextClosePath(context)
        
        CGContextFillPath(context)
        
        let fillColor: UIColor
        if(value >= guardLimitValue) {
            fillColor = guardLimitColor
        } else {
            fillColor = UIColor.whiteColor()
        }
        CGContextSetFillColorWithColor(context, fillColor.colorWithAlphaComponent(0.3).CGColor)
        CGContextMoveToPoint(context, point.x, point.y)
        CGContextAddArc(context, point.x, point.y, 12, 0, 2*CGFloat(M_PI), 0)
        CGContextFillPath(context)
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextMoveToPoint(context, point.x, point.y)
        CGContextAddArc(context, point.x, point.y, 8, 0, 2*CGFloat(M_PI), 0)
        CGContextFillPath(context)
        
        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        labelns?.drawInRect(rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        CGContextRestoreGState(context)
    }
    
    internal override func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        value = entry.value
//        if let dataItem = entry.data as? DataEntryItem {
//            let avarageText = valueIsAvarage ? "高压":"低压"
//            labelns = NSString(format: "\(dataItem.date)\n\(avarageText)%.fmmHg", entry.value)
//        } else {
//            labelns = NSString(format: "%.fmmHg", entry.value)
//        }
        labelns = ""
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        
        _labelSize = labelns?.sizeWithAttributes(_drawAttributes) ?? CGSizeZero
        _size.width = _labelSize.width + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)
    }
}
