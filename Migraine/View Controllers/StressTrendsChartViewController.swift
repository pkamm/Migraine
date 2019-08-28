//
//  StressTrendsChartViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/21/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit
import Charts

class StressTrendsChartViewController: UIViewController, ChartViewDelegate, TrendsChartViewController {
    
    @IBOutlet weak var chartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylizeChart()
        self.chartView.leftAxis.axisMaximum = 5
    }
    
    func resetChartData(entries:[DiaryEntry], numberOfBins: Int) {
        let dayBins = setUpChartBins(numberOfBins: numberOfBins)
        var dataEntries: [BarChartDataEntry] = []
        for i in 1..<dayBins.count {
            let firstDate = dayBins[i-1]
            let secondDate = dayBins[i]
            var stressValue = 0
            for diaryEntry in entries {
                if diaryEntry.date.isBetween(firstDate, and: secondDate) {
                    do{
                        stressValue = try diaryEntry.stressLevel()
                    } catch {
                        
                    }
                }
            }
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(stressValue) )
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: nil)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = [UIColor.secondaryBackgroundColor()]
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.4
        chartView.data = chartData
        chartView.animate(yAxisDuration: 0.7)
        
    }
    
    
}

