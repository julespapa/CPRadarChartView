//
//  CPRadarChartView.swift
//  CPRadarChartViewDemo
//
//  Created by chicpark7 on 2016. 10. 28..
//  Copyright © 2016년 chicpark7. All rights reserved.
//

import UIKit

public enum CPRadarChartBackgroundType: Int {
    case circle
    case regular_polygon
    case none
}

public struct CPRadarChartItem {
    
    public fileprivate(set) var identifier: String?
    
    public var title: String?
    public var values: [Double]
    public var fill_color: UIColor? = .clear
    public var stroke_color: UIColor?

    public init(_ title: String?, _ values: [Double], _ fillColor: UIColor?, _ strokeColor: UIColor?) {
        self.title = title
        self.values = values
        self.fill_color = fillColor
        self.stroke_color = strokeColor
    }
}

private extension String {
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

public class CPRadarChartView: UIView {
    
    public var items = [CPRadarChartItem]()
    
    public var background_type = CPRadarChartBackgroundType.regular_polygon {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var field_name_font = UIFont.boldSystemFont(ofSize: 10)
    public var field_name_color = UIColor.darkText
    public var field_saparator_color = UIColor.darkGray
    public var field_saparator_width: CGFloat = 2.0
    
    public var bg_line_color: UIColor = UIColor.darkGray
    public var show_step_number: Bool = true
    
    // MARK: Public Variable
    public var number_of_fields: Int = 0 {
        didSet(value) {
            self.setNeedsDisplay()
        }
    }
    
    public var number_of_steps: Int = 1 {
        didSet(value) {
            self.setNeedsDisplay()
        }
    }
    
    public var field_names: [String]? = nil {
        didSet(value) {
            self.setNeedsDisplay()
        }
    }
    
    public var max_value: Double = 5
    
    // MARK: Private Variable
    private let item_fields_names = [String]()
    private var shape_layers = [String: CAShapeLayer]()
    
    private var per_angle: CGFloat {
        get {
            return CGFloat(M_PI) * 2.0 / CGFloat(self.number_of_fields)
        }
    }
    
    private var radius: CGFloat {
        get {
            return min(self.frame.size.width, self.frame.size.height) * 0.3
        }
    }
    
    private var devide_length: CGFloat {
        get {
            return radius * 1.1
        }
    }
    
    // MARK: Public Functions
    
    public func add( item: inout CPRadarChartItem) {
        
        while true {
            let new_identifier = String.random()
            if let _ = items.first(where: {$0.identifier == new_identifier}) {
                continue
            }
            else {
                item.identifier = new_identifier
                break
            }
        }
        
        items.append(item)

        let start_path = zero_path()
        let cgPath = path_by(item: item)
        
        let shape_layer = CAShapeLayer()
        shape_layer.path = cgPath
        shape_layer.fillColor = item.fill_color?.cgColor
        shape_layer.strokeColor = item.stroke_color?.cgColor

        self.shape_layers[item.identifier!] = shape_layer
        self.layer.addSublayer(shape_layer)
        
        let path_ani = CABasicAnimation(keyPath: "path")
        path_ani.duration = 0.5
        path_ani.fromValue = start_path
        path_ani.toValue = cgPath
        path_ani.isRemovedOnCompletion = true
        path_ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shape_layer.add(path_ani, forKey: path_ani.keyPath)

    }
    
    public func set(item: inout CPRadarChartItem, forIdentifier identifier: String!) {
        
        if let index = items.index(where: {$0.identifier == identifier}),
            let shape_layer = shape_layers[identifier] {
            
            let cgPath = path_by(item: item)
            
            let path_ani = CABasicAnimation(keyPath: "path")
            path_ani.duration = 0.5
            path_ani.fromValue = shape_layer.path
            path_ani.toValue = cgPath
            path_ani.isRemovedOnCompletion = true
            path_ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            shape_layer.add(path_ani, forKey: path_ani.keyPath)
            
            shape_layer.fillColor = item.fill_color?.cgColor
            shape_layer.strokeColor = item.stroke_color?.cgColor
            shape_layer.path = cgPath

            item.identifier = identifier
            items[index] = item
        }

    }
    
    public func remove(identifier: String) {
        
        if let index = items.index(where: {$0.identifier == identifier}),
            let shape_layer = shape_layers.removeValue(forKey: identifier) {
            
            let item = items[index]
            
            let start_path = path_by(item: item)
            let cgPath = zero_path()
            
            shape_layer.path = cgPath
            shape_layer.fillColor = item.fill_color?.cgColor
            shape_layer.strokeColor = item.stroke_color?.cgColor

            CATransaction.begin()
            
            let path_ani = CABasicAnimation(keyPath: "path")
            path_ani.duration = 0.5
            path_ani.fromValue = start_path
            path_ani.toValue = cgPath
            path_ani.isRemovedOnCompletion = true
            path_ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            
            CATransaction.setCompletionBlock({
                print("FEFWFWE")
                self.items.remove(at: index)
                shape_layer.removeFromSuperlayer()
            })

            shape_layer.add(path_ani, forKey: path_ani.keyPath)
            CATransaction.commit()
        }
        
    }

    // MARK: Drawing Chart
    
    override public func draw(_ rect: CGRect) {
        
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            switch background_type {
            case.regular_polygon:
                draw_guild_line(context, rect)
                break
            case .circle:
                draw_guild_circle(context, rect)
                break
            default:
                break
            }
            
            draw_field_saparator(context, rect)
            draw_field_text(context, rect)
            
            if show_step_number {
                draw_level_text(context, rect)
            }
        }
        
    }
    
    func draw_field_saparator(_ context: CGContext, _ rect: CGRect) {
        
        if number_of_fields <= 0{
            return
        }
        
        context.saveGState()
        
        field_saparator_color.setStroke()
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        
        for i in 0..<number_of_fields {
            let path = UIBezierPath()
            path.lineWidth = field_saparator_width;
            
            path.move(to: center)
            
            let x = center.x - devide_length * sin(CGFloat(i) * per_angle)
            let y = center.y - devide_length * cos(CGFloat(i) * per_angle)
            path.addLine(to: CGPoint(x: x, y: y))
            
            path.stroke()
        }
        context.restoreGState()
        
    }
    
    func draw_guild_line(_ context: CGContext, _ rect: CGRect) {
        
        if number_of_fields <= 0 || number_of_steps < 1{
            return
        }
        
        context.saveGState()
        
        bg_line_color.setStroke()
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        
        for step in 0...number_of_steps {
            let scale = CGFloat(step) / CGFloat(number_of_steps)
            let inner_radius = scale * radius
            let path = UIBezierPath()
            
            for i in 0..<number_of_fields {
                let x = center.x - inner_radius * sin(CGFloat(i) * per_angle)
                let y = center.y - inner_radius * cos(CGFloat(i) * per_angle)
                let point = CGPoint(x: x, y: y)
                if i == 0 {
                    path.move(to: point)
                }
                else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            path.close()
            path.stroke()
        }
        
        context.restoreGState()
        
    }
    
    func draw_guild_circle(_ context: CGContext, _ rect: CGRect) {
        
        if number_of_steps < 1{
            return
        }
        
        context.saveGState()
        
        bg_line_color.setStroke()
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        
        for step in 0...number_of_steps {
            let scale = CGFloat(step) / CGFloat(number_of_steps)
            let inner_radius = scale * radius
            let path = UIBezierPath(arcCenter: center, radius: inner_radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            
            path.stroke()
        }
        context.restoreGState()
        
    }
    
    
    func draw_level_text(_ context: CGContext, _ rect: CGRect) {
        
        if number_of_steps <= 0 {
            return
        }
        
        context.saveGState()
        
        field_name_color.setStroke()
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        
        let attr = [NSForegroundColorAttributeName: UIColor.darkGray,
                    NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10)]
        
        for step in 1...number_of_steps {
            let scale = CGFloat(step) / CGFloat(number_of_steps)
            let inner_radius = scale * radius
            
            let x = center.x + 2
            let y = center.y - inner_radius
            
            let number_string = NSString(format: "%ld", step)
            let height = number_string.size(attributes: attr).height
            
            number_string.draw(at: CGPoint(x: x, y: y - height), withAttributes: attr)
        }
        
        context.restoreGState()
        
    }
    
    func draw_field_text(_ context: CGContext, _ rect: CGRect) {
        
        guard let _field_names = field_names else {
            return
        }
        
        context.saveGState()

        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        let devider_length = radius * 1.2
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attr = [NSForegroundColorAttributeName: field_name_color,
                    NSFontAttributeName: field_name_font,
                    NSParagraphStyleAttributeName: paragraph] as [String : Any]
        
        for i in 0..<_field_names.count {
            let field_string = NSString(string: _field_names[i])
            
            let text_size = field_string.size(attributes: attr)
            
            let x = center.x - devider_length * sin(CGFloat(i) * per_angle)
            let y = center.y - devider_length * cos(CGFloat(i) * per_angle)
            
            let offset_x = text_size.width * (sin(CGFloat(i) * per_angle) + 1) / 2
            let offset_y = text_size.height * (cos(CGFloat(i) * per_angle) + 1) / 2
            
            var drawing_rect = CGRect(x: x - offset_x, y: y - offset_y, width: 0, height: 0)
            drawing_rect.size = text_size
            
            field_string.draw(in: drawing_rect, withAttributes: attr)
        }
        
        context.restoreGState()
    }
    
    func path_by(item: CPRadarChartItem) -> CGPath {
        
        layoutIfNeeded()
        
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let cgPath = CGMutablePath()

        let path = UIBezierPath()
        
        for i in 0..<number_of_fields {
            guard 0 <= item.values[i] else {
                continue
            }
            let scale = CGFloat(item.values[i]) / CGFloat(max_value)
            let inner_radius = scale * radius
            
            let x = center.x - inner_radius * sin(CGFloat(i) * per_angle)
            let y = center.y - inner_radius * cos(CGFloat(i) * per_angle)
            let point = CGPoint(x: x, y: y)
            
            if path.isEmpty {
                path.move(to: point)
            }
            else {
                path.addLine(to: point)
            }
            
            let dot_path = UIBezierPath(arcCenter: point, radius: 4, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
            cgPath.addPath(dot_path.cgPath)
        }
        path.close()

        cgPath.addPath(path.cgPath)
        
        return cgPath
        
    }
    
    func zero_path() -> CGPath {
        layoutIfNeeded()
        
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let cgPath = CGMutablePath()
        
        let path = UIBezierPath()
        
        for _ in 0..<number_of_fields {
            if path.isEmpty {
                path.move(to: center)
            }
            else {
                path.addLine(to: center)
            }
            
            let dot_path = UIBezierPath(arcCenter: center, radius: 4, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
            cgPath.addPath(dot_path.cgPath)
        }
        path.close()
        
        cgPath.addPath(path.cgPath)
        
        return cgPath
    }
}
