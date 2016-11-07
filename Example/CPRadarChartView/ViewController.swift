//
//  ViewController.swift
//  CPRadarChartView
//
//  Created by 박병혁 on 2016. 10. 28..
//  Copyright © 2016년 박병혁. All rights reserved.
//

import UIKit
import CPRadarChartView

class ViewController: UIViewController {
    
    @IBOutlet weak var chart: CPRadarChartView!
    
    public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.number_of_fields = 6
        chart.number_of_steps = 5
        chart.max_value = 5;
        chart.background_type = .circle
        chart.field_names = ["드라이버파워", "드라이버\n정확성", "숏게임\n능력", "", "퍼팅게임\n능력", "그린\n적중능력"]
        chart.bg_line_color = .green
        chart.field_name_font = .boldSystemFont(ofSize: 10)
        chart.field_name_color = .cyan
        chart.field_saparator_color = .blue
        chart.field_saparator_width = 5
        
        let colors = [UIColor.red.withAlphaComponent(0.5), UIColor.blue.withAlphaComponent(0.5), UIColor.purple.withAlphaComponent(0.5), UIColor.brown.withAlphaComponent(0.5), UIColor.cyan.withAlphaComponent(0.5)]
        for i in 0...0 {
            
            var item = CPRadarChartItem("Player \(i)", [random5float(), random5float(), random5float(), -1, random5float(), random5float()], colors[i], colors[i].withAlphaComponent(1))
            chart.add(item: &item)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func random5float() -> Double {
        
        return (Double(arc4random()) / 10.0).truncatingRemainder(dividingBy: 3.0) + 2.0
    }
    
    @IBAction func reset() {
        
        let colors = [UIColor.red.withAlphaComponent(0.5), UIColor.blue.withAlphaComponent(0.5), UIColor.purple.withAlphaComponent(0.5), UIColor.brown.withAlphaComponent(0.5), UIColor.cyan.withAlphaComponent(0.5)]
        let color = colors[Int(arc4random()) % 5]
        var item = CPRadarChartItem("Player 0", [random5float(), random5float(), random5float(), -1, random5float(), random5float()], color, color)
        if let identifier = chart.items.last?.identifier {
            chart.set(item: &item, forIdentifier: identifier)
        }
        
    }
    
    @IBAction func add() {
        
        let colors = [UIColor.red.withAlphaComponent(0.5), UIColor.blue.withAlphaComponent(0.5), UIColor.purple.withAlphaComponent(0.5), UIColor.brown.withAlphaComponent(0.5), UIColor.cyan.withAlphaComponent(0.5)]
        let color = colors[Int(arc4random()) % 5]
        var item = CPRadarChartItem("Player 0", [random5float(), random5float(), random5float(), random5float(), random5float(), random5float()], color, color)
        chart.add(item: &item)
    }
    
    @IBAction func remove_last() {
        if let identifier = chart.items.last?.identifier {
            chart.remove(identifier: identifier)
        }
    }
}

