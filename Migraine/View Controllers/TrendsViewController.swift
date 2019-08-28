//
//  TrendsViewController.swift
//  Migraine
//
//  Created by Peter Kamm on 8/8/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import UIKit
import Charts

class TrendsViewController: UIViewController {

    var chartVCs:[TrendsChartViewController] = []
    
    var numberOfDays:Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
         resetCharts(numberOfDays: numberOfDays)
    }
    
    @IBAction func segmentedControllerToggled(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            numberOfDays = 30
        } else {
            numberOfDays = 7
        }
        resetCharts(numberOfDays: numberOfDays)
    }
    
    func resetCharts(numberOfDays: Int){
        DiaryService.sharedInstance.getDiaryEntries { (entries) in
            var filteredEntries = [DiaryEntry]()
            if let allEntries = entries,
                let startingDate = Calendar.current.date(byAdding: .day, value: -self.numberOfDays, to: Date()){
                for entry in allEntries{
                    if startingDate < entry.date {
                        filteredEntries.append(entry)
                    }
                }
            }
            for chartVC in self.chartVCs {
                chartVC.resetChartData(entries: filteredEntries, numberOfBins: numberOfDays)
            }
            
        }
        
    }
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TrendsChartViewController {
            chartVCs.append(destination)
        }
    }
 

}

protocol TrendsChartViewController {
    
    var chartView: BarChartView! {get set}
    func resetChartData(entries:[DiaryEntry], numberOfBins: Int)

}


extension TrendsChartViewController {
    
    func stylizeChart(){
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.chartDescription?.text = ""
        chartView.noDataText = "Not enough diary entries"
        chartView.backgroundColor = UIColor.clear
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.drawLimitLinesBehindDataEnabled = true
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        chartView.xAxis.labelTextColor = UIColor.majorTextColor()
        chartView.legend.enabled = false
        chartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 12)
        chartView.leftAxis.labelTextColor = UIColor.majorTextColor()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.axisMinValue = 0
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.axisMinValue = 0
        chartView.leftAxis.granularityEnabled = true
        chartView.leftAxis.granularity = 1.0

    }
    
    func createDayBins(numberOfDays: Int, endDate: Date)->[Date] {

        var dayBins = [Date]()
        for i in 0..<numberOfDays {
            let nextDate = Calendar.current.date(byAdding: .day, value: -i, to: endDate)!
            dayBins.insert(nextDate, at: 0)
        }
        return dayBins
    }
    
    func setUpChartBins(numberOfBins: Int) -> [Date] {
        guard let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return [] }
        let beginningOfTomorrow = Calendar.current.startOfDay(for: tomorrowDate)
        chartView.xAxis.labelCount = numberOfBins
        if let date = Calendar.current.date(byAdding: .day, value: -numberOfBins, to: beginningOfTomorrow){
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dM", options: 0, locale: NSLocale.current)
            chartView.xAxis.valueFormatter = ChartXAxisFormatter(referenceDate: date, dateFormatter: formatter)
            chartView.xAxis.granularity = 1.0
            chartView.xAxis.granularityEnabled = true
            chartView.xAxis.labelCount = 7
        }
        return createDayBins(numberOfDays: numberOfBins, endDate: beginningOfTomorrow)
    }
    
}

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var referenceDate: Date?
    
    convenience init(referenceDate: Date, dateFormatter: DateFormatter) {
        self.init()
        self.referenceDate = referenceDate
        self.dateFormatter = dateFormatter
    }
}


extension ChartXAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
            let referenceDate = referenceDate
            else {
                return ""
        }
        let date = Calendar.current.date(byAdding: .day, value: Int(value), to: referenceDate)
        return dateFormatter.string(from: date!)
    }
    
}
