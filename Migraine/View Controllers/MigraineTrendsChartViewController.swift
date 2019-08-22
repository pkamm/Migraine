//
//  MigraineTrendsChartViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/9/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit
import Charts

class MigraineTrendsChartViewController: UIViewController, ChartViewDelegate, TrendsChartViewController {

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
            var migraineDuration = 0.0
            var color = UIColor.clear
            for diaryEntry in entries {
                do{
                    if try diaryEntry.wasMigraine(),
                        diaryEntry.date.isBetween(firstDate, and: secondDate),
                        let startDate = diaryEntry.migraineStartDate(),
                        let endDate = diaryEntry.migraineEndDate() {
                        
                        let timeInterval = endDate.timeIntervalSince(startDate)
                        migraineDuration += timeInterval
                        color = colorForMigraineSeverity(entry: diaryEntry)
                    }
                } catch {
                    print("maybe was migraine?")
                }
            }
            let dataEntry = BarChartDataEntry(x: Double(i), y: (migraineDuration.truncatingRemainder(dividingBy: 86400) / 3600) )
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

    func colorForMigraineSeverity(entry: DiaryEntry) -> UIColor{
        
        do{
            switch try entry.migraineSeverity(){
            case 0:
                return UIColor.secondaryBackgroundColor().withAlphaComponent(0.6)
            case 1:
                return UIColor.secondaryBackgroundColor().withAlphaComponent(0.8)
            case 2:
                return UIColor.secondaryBackgroundColor()
            default:
                return UIColor.white.withAlphaComponent(0.5)
            }
        }catch{
            
        }
        return UIColor.white
    }
    
}
