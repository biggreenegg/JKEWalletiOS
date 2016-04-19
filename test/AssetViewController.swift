//
//  AssetViewController.swift
//  test
//
//  Created by Tim Choo on 3/18/16.
//  Copyright © 2016 Tim Choo. All rights reserved.
//

import UIKit
import Charts
import IBMMobileFirstPlatformFoundation

class AssetViewController: UIViewController, ChartViewDelegate, WLDelegate {

    @IBOutlet weak var pieChartView: PieChartView!
    
    var accountsArray = [String]()
    var balanceArray = [Float]()
    var percentageArray = [Double]()
    var initialLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.delegate = self

        // Call the Worklight Native API (called through the Objective-C bridging header JKEWallet-Bridging-Header.h
        //let invocationData = WLProcedureInvocationData(adapterName: "NativeiosAdapter", procedureName: "jkeGetAccounts")
        //WLClient.sharedInstance().invokeProcedure(invocationData, withDelegate: self)
        
        /* this was an attempt at using "simpler" REST call to a C&C api i built
        //url to Connect and Compose API of CHECK which is derived from secure gateway
        let candcURL = NSURL(string: "https://cnc-us-prd-pxy-01.integration.ibmcloud.com/connect-api-prod-9e62cb90-01d7-11e6-a4d3-f70990886058/connect_compose/9e62cb90-01d7-11e6-a4d3-f70990886058/CHECK")
        
        let request = WLResourceRequest(URL: candcURL, method: WLHttpMethodGet)
        
        //add header with C&C api key
        request.setHeaderValue("VjJBSzdTSUZGNzJVOUw5NkQ5RkJNTk1GS0VSRjUzT1ZKWkdRWFdFTw==", forName: "X-IBM-CloudInt-ApiKey")
        
        request.sendWithCompletionHandler { (response,  error) -> Void in
            if(error == nil){
                NSLog(response.responseText)
                self.onSuccess(response)
            }
            else{
                NSLog(error.description)
            }
        }
        */
        let request = WLResourceRequest(URL: NSURL(string:"/adapters/NativeiosAdapter/jkeGetAccounts"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler{
            (response, error) -> Void in
            NSLog(response.responseText)
            self.onSuccess(response)
        }
    }
    
    //----- Called by WLDelegate when the Worklight Native API call is successful
    func onSuccess(response: WLResponse!) {
        print("------onSuccess()")
        
        //let resultJson = response.getResponseJson() as NSDictionary
        /*
        let resultSet = response.getResponseJson()["resultSet"]!
        
        for i in 0...resultSet.count-1 {
            accountsArray.append(resultSet[i]["ACCOUNTNAME"] as! String)
            balanceArray.append(resultSet[i]["BALANCE"] as! Float)
        } */
        let accounts = JSON(response.getResponseJson())
        for account in accounts["resultSet"].arrayValue {
            accountsArray.append(account["ACCOUNTNAME"].stringValue)
            balanceArray.append(Float(account["BALANCE"].numberValue))
        }
     
        
        //------- Calculate the percentage for each account
        var total: Float = 0.0
        for j in 0...balanceArray.count-1 {
            total += balanceArray[j]
        }
        
        //------- Calculate the percentages for each account
        for k in 0...balanceArray.count-1 {
            percentageArray.append(Double(balanceArray[k]/total))
        }
        
        //---- Now draw the chart
        setChart(accountsArray, values: percentageArray)
    }
    
    func onFailure(response: WLFailResponse!) {
        print("-----onFailure()")
    }
    
    //------ Helper function to draw the chart
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        
        
        //---------- Set the colors for the pie chart
        var colors: [UIColor] = []
        
        let reddishcolor = UIColor(red: CGFloat(246.0/255.0), green: CGFloat(36.0/255.0), blue: CGFloat(89.0/255.0), alpha: 1.0)
        let bluishcolor = UIColor(red: CGFloat(65.0/255.0), green: CGFloat(131.0/255.0), blue: CGFloat(215.0/255.0), alpha: 1.0)
        let greenishcolor = UIColor(red: CGFloat(1.0/255), green: CGFloat(152.0/255), blue: CGFloat(117.0/255), alpha: 1.0)
        colors.append(reddishcolor)
        colors.append(bluishcolor)
        colors.append(greenishcolor)
        
        pieChartDataSet.colors = colors
        
        //------- format the % amounts
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.PercentStyle
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.percentSymbol = "%"
        pieChartData.setValueFormatter(numberFormatter)
        
        pieChartView.legend.enabled = false
        pieChartView.descriptionText = ""
        
        pieChartView.data = pieChartData
        pieChartView.animate(yAxisDuration: 1.0)
        //pieChartView.reloadInputViews()
        
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        //----- if a slice on the pie chart is clicked then display the details in the middle of the chart
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.numberStyle = .CurrencyStyle
        pieChartView.centerText = "\(accountsArray[entry.xIndex]): \(currencyFormatter.stringFromNumber(balanceArray[entry.xIndex])!)"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if initialLoad == false {
            pieChartView.animate(yAxisDuration: 1.0)
        } else {
            initialLoad = false
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
