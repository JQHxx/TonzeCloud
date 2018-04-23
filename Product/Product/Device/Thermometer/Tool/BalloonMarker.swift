//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 19/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
;
import Charts;

public class BalloonMarker: ChartMarker
{
    public var color: UIColor?
    public var arrowSize = CGSize(width: 15, height: 11)
    public var font: UIFont?
    public var insets = UIEdgeInsets()
    public var minimumSize = CGSize()
    public var guardLimitValue = 37.5
    public var guardLimitColor = UIColor.redColor()
    public var valueIsAvarage: Bool = false
    
    private var value:Double?
    private var labelns: NSString?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    
    public init(color: UIColor, font: UIFont, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .Center
    }
    
    public override var size: CGSize { return _size; }
    
    public override func draw(context context: CGContext, point: CGPoint)
    {
        if (labelns == nil)
        {
            return
        }
        
        var rect = CGRect(origin: point, size: _size)
        rect.origin.x -= _size.width / 2.0
        rect.origin.y -= _size.height + 20
        
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
    
    public override func refreshContent(entry entry: ChartDataEntry, highlight: ChartHighlight)
    {
        value = entry.value
        if let dataItem = entry.data as? DataEntryItem {
            let avarageText = valueIsAvarage ? "均值":""
            labelns = NSString(format: "\(dataItem.date)\n\(avarageText)%.1f℃", entry.value)
        } else {
            labelns = NSString(format: "%.1f", entry.value)
        }
        
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