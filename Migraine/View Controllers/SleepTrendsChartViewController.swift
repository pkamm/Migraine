//
//  SleepTrendsChartViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/21/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit
import Charts

class SleepTrendsChartViewController: UIViewController, ChartViewDelegate, TrendsChartViewController {
    
    @IBOutlet weak var chartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylizeChart()
    }
    
    func resetChartData(entries:[DiaryEntry], numberOfBins: Int) {
        let dayBins = setUpChartBins(numberOfBins: numberOfBins)
        var dataEntries: [BarChartDataEntry] = []
        var barColors: [UIColor] = []
        for i in 1..<dayBins.count {
            let firstDate = dayBins[i-1]
            let secondDate = dayBins[i]
            var sleepDuration = 0.0
            var color = UIColor.clear
            for diaryEntry in entries {
                if diaryEntry.date.isBetween(firstDate, and: secondDate) {
                    sleepDuration += diaryEntry.sleepDuration()
                    color = colorForSleepQuality(entry: diaryEntry)
                }
            }
            let dataEntry = BarChartDataEntry(x: Double(i), y:sleepDuration/3600 )
            dataEntries.append(dataEntry)
            barColors.append(color)

        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: nil)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = barColors
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.4
        chartView.data = chartData
        chartView.animate(yAxisDuration: 0.7)
        
    }
    
    func colorForSleepQuality(entry: DiaryEntry) -> UIColor {
        do{
            switch try entry.sleepQuality(){
            case 0:
                return UIColor.secondaryBackgroundColor().withAlphaComponent(0.5)
            case 1:
                return UIColor.secondaryBackgroundColor().withAlphaComponent(0.65)
            case 2:
                return UIColor.secondaryBackgroundColor().withAlphaComponent(0.75)
            case 3:
                return UIColor.secondaryBackgroundColor().withAlphaComponent(0.9)
            case 4:
                return UIColor.secondaryBackgroundColor()
            default:
                return UIColor.white.withAlphaComponent(0.5)
            }
        }catch{}
        return UIColor.white.withAlphaComponent(0.5)
    }
    
}
