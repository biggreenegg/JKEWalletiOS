//
//  CalendarViewController.swift
//  test
//
//  Created by Tim Choo on 3/16/16.
//  Copyright © 2016 Tim Choo. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WLDelegate {

    @IBOutlet weak var tableCalendarView: UITableView!

    
    var calendarArray = [[String]]()
    var checkOrPaymentArray = [[String]]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the Worklight Native API (called through the Objective-C bridging header JKEWallet-Bridging-Header.h
        //let invocationData = WLProcedureInvocationData(adapterName: "NativeiosAdapter", procedureName: "jkeGetAllTransactions")
        //WLClient.sharedInstance().invokeProcedure(invocationData, withDelegate: self)

        let request = WLResourceRequest(URL: NSURL(string:"/adapters/NativeiosAdapter/jkeGetAllTransactions"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler{
            (response, error) -> Void in
            NSLog(response.responseText)
            self.onSuccess(response)
        }
        
        
        
        // Do any additional setup after loading the view.
        tableCalendarView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        
        //let invocationData = WLProcedureInvocationData(adapterName: "NativeiosAdapter", procedureName: "jkeGetAllTransactions")
        //WLClient.sharedInstance().invokeProcedure(invocationData, withDelegate: self)
        
        let request = WLResourceRequest(URL: NSURL(string:"/adapters/NativeiosAdapter/jkeGetAllTransactions"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler{
            (response, error) -> Void in
            NSLog(response.responseText)
            self.onSuccess(response)
        }
        
        refreshControl.endRefreshing()
    }
    
    func onSuccess(response: WLResponse!) {
        print("------onSuccess")
        
        //let resultSet = response.getResponseJson()["resultSet"]!
        let resultSet = JSON(response.getResponseJson())
        
        var currTransactionEntry = [String]()
        var currCheckOrPaymentEntry = [String]()
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.numberStyle = .CurrencyStyle
        
        var prevDateString = ""
        var nextDateString = ""
        var nextDateStringTmp = ""
        calendarArray.removeAll()
        checkOrPaymentArray.removeAll()
        
        var i = 0
        for item in resultSet["resultSet"].arrayValue {
            prevDateString = nextDateString
            nextDateStringTmp = item["DATE"].stringValue
            nextDateString = nextDateStringTmp.substringToIndex(nextDateStringTmp.startIndex.advancedBy(10))
            if i == 0 {
                currTransactionEntry.append(prettyDateString(nextDateString))
                currTransactionEntry.append("\(currencyFormatter.stringFromNumber(Float(item["AMOUNT"].numberValue))!) - \(item["DESCRIPTION"].stringValue)")
                currCheckOrPaymentEntry.append(prettyDateString(nextDateString))
                currCheckOrPaymentEntry.append(item["TYPE"].stringValue)
                
            } else if nextDateString == prevDateString {
                currTransactionEntry.append("\(currencyFormatter.stringFromNumber(Float(item["AMOUNT"].numberValue))!) - \(item["DESCRIPTION"].stringValue)")
                currCheckOrPaymentEntry.append(item["TYPE"].stringValue)
            } else {
                calendarArray.append(currTransactionEntry)
                currTransactionEntry.removeAll()
                currTransactionEntry.append(prettyDateString(nextDateString))
                currTransactionEntry.append("\(currencyFormatter.stringFromNumber(Float(item["AMOUNT"].numberValue))!) - \(item["DESCRIPTION"].stringValue)")
                checkOrPaymentArray.append(currCheckOrPaymentEntry)
                currCheckOrPaymentEntry.removeAll()
                currCheckOrPaymentEntry.append(prettyDateString(nextDateString))
                currCheckOrPaymentEntry.append(item["TYPE"].stringValue)
            }
            i++
        }
        
        calendarArray.append(currTransactionEntry)
        checkOrPaymentArray.append(currCheckOrPaymentEntry)
        tableCalendarView.reloadData()
        
    }
    
    func prettyDateString(dateString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let tmpDate = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.stringFromDate(tmpDate!)
    }
    
    func onFailure(response: WLFailResponse!) {
        print("-----onFailure")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return calendarArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarArray[section].count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let checkImage = UIImage(named: "bank-check")
        let paymentImage = UIImage(named: "payment")
        
        if checkOrPaymentArray[indexPath.section][indexPath.row + 1] == "check" {
            cell.imageView!.image = checkImage
        } else {
            cell.imageView!.image = paymentImage
        }

        cell.textLabel?.text = calendarArray[indexPath.section][indexPath.row + 1]
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return calendarArray[section][0]
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
