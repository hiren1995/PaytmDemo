//
//  ViewController.swift
//  PaytmDemo
//
//  Created by APPLE MAC MINI on 27/02/18.
//  Copyright © 2018 APPLE MAC MINI. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,PGTransactionDelegate {
    

    @IBOutlet var btn_testPayment: UIButton!
    
    var txnID: String!
    var order_id: String!
    var Refund: String!
    
    
    class func generateOrderIDWithPrefix(prefix: String) -> String {
        
        srandom(UInt32(time(nil)))
        
        //let randomNo: Int = random();        //just randomizing the number
        
        //let randomNo: Int = Int(arc4random_uniform(50))
        //let orderID: String = "\(prefix)\(randomNo)"
        
        
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        let x = Int(since1970 * 1000)
        let orderID: String = "\(prefix)\(x)"
        
        return orderID
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btn_testPayment.addTarget(self, action: #selector(Pay_btn_Action(sender:)), for: UIControlEvents.touchUpInside)
    
        
    }
    
    @objc func Pay_btn_Action(sender:UIButton!) {
       
        /*
        
        let merchantConfig = PGMerchantConfiguration.default();
        
        var odrDict = [String:Any]()
        
        odrDict["MID"] = "klbGlV59135347348753"
        odrDict["CHANNEL_ID"] = "WAP"
        odrDict["INDUSTRY_TYPE_ID"] = "Retail"
        odrDict["WEBSITE"] = "worldpressplg"
        odrDict["TXN_AMOUNT"] = "1"
        odrDict["ORDER_ID"] = ViewController.generateOrderIDWithPrefix(prefix : "")
        odrDict["REQUEST_TYPE"] = "DEFAULT"
        odrDict["CUST_ID"] = "mohit.aggarwal@paytm.com"
        odrDict["CALLBACK_URL"] = "https://pguat.paytm.com/paytmchecksum/paytmCallback.jsp";
        odrDict["CHECKSUMHASH"] = "w2QDRMgp1/BNdEnJEAPCIOmNgQvsi+BhpqijfM9KvFfRiPmGSt3Ddzw+oTaGCLneJwxFFq5mqTMwJXdQE2EzK4px2xruDqKZjHupz9yXev4=";
        
        let order: PGOrder = PGOrder(params: odrDict)
        
        let transactionController = PGTransactionViewController.init(transactionFor: order)
        transactionController?.serverType = eServerTypeStaging
        transactionController?.merchant = merchantConfig
        transactionController?.delegate = self
        transactionController?.loggingEnabled = true
        self.showController(controller : transactionController!)
 
 
        */
        
 
        
        
        
        let merchant = PGMerchantConfiguration.default();
        
        merchant?.checksumGenerationURL = "http://bulale.in/paytm_integration_hiren/generateChecksum.php"
        merchant?.checksumValidationURL = "http://bulale.in/paytm_integration_hiren/verifyChecksum.php"
        
        var orderDict = [String : String]()
        orderDict["MID"] = "street87966250288380"
        orderDict["CHANNEL_ID"] = "WAP"
        orderDict["INDUSTRY_TYPE_ID"] = "Retail109"
        orderDict["WEBSITE"] = "streetWEB"
        orderDict["TXN_AMOUNT"] = "1"
        orderDict["ORDER_ID"] = ViewController.generateOrderIDWithPrefix(prefix: "Order")
        orderDict["REQUEST_TYPE"] = "DEFAULT"
        orderDict["CUST_ID"] = ViewController.generateOrderIDWithPrefix(prefix: "NukadUser")
        orderDict["CALLBACK_URL"] = "https://pguat.paytm.com/paytmchecksum/paytmCallback.jsp"
       
        
        //most important thing in checksum hash generation is its takes whole orderdict and encrypt it with merchant key at server and when same orderdict is passed in PGTransactionview controller it verifies the checksum and if all of above defined fields for orderdict are not passed for cheksum the checksum generated at server is different from checksum generated during PGTransactionalviewcontroller...!! i have wasted 3 days in finding this thing..
        
        
        let Parameters:Parameters = ["MID" : orderDict["MID"] as! String ,"ORDER_ID": orderDict["ORDER_ID"] as! String ,"CUST_ID": orderDict["CUST_ID"] as! String,"INDUSTRY_TYPE_ID": orderDict["INDUSTRY_TYPE_ID"] as! String,"CHANNEL_ID" : orderDict["CHANNEL_ID"] as! String,"TXN_AMOUNT":orderDict["TXN_AMOUNT"] as! String,"WEBSITE":orderDict["WEBSITE"] as! String,"REQUEST_TYPE" : orderDict["REQUEST_TYPE"] as! String,"CALLBACK_URL" : orderDict["CALLBACK_URL"] as! String]
        
        print(Parameters)
        
        Alamofire.request("http://bulale.in/paytm_integration_hiren/generateChecksum.php", method: .post, parameters: Parameters, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { (response) in
            if(response.result.value != nil)
            {
                
                print(JSON(response.result.value))
                
                let tempDict = JSON(response.result.value)
                
                orderDict["CHECKSUMHASH"] = tempDict["CHECKSUMHASH"].stringValue
                
                let pgOrder = PGOrder(params: orderDict )
                
                merchant?.transactionParameters(for: pgOrder)
                
                let transaction = PGTransactionViewController.init(transactionFor: pgOrder)
                
                transaction!.serverType = eServerTypeProduction
                transaction!.merchant = merchant
                transaction!.loggingEnabled = true
                transaction!.delegate = self
                self.present(transaction!, animated: true, completion: {
                    
                })
                
            }
            else
            {
                
                print("no internet")
            }
        })
        
        
        
    }
    
    func showController(controller: PGTransactionViewController) {
        
        if self.navigationController != nil {
            self.navigationController!.pushViewController(controller, animated: true)
        }
        else {
            self.present(controller, animated: true, completion: {() -> Void in
            })
        }
    }
    
    func removeController(controller: PGTransactionViewController) {
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
        else {
            controller.dismiss(animated: true, completion: {() -> Void in
            })
        }
    }

    
    
    
    func didSucceedTransaction(controller: PGTransactionViewController, response: [NSObject : AnyObject]) {
        
        // After Successful Payment
        
        print(response)
        
        //let msg: String = "Your order was completed successfully.\n Rs. \(response["TXNAMOUNT"]!)"
        
        
        //self.function.alert_for("Thank You for Payment", message: msg)
        
        self.removeController(controller : controller)
        
        
    }
    
    func didFailTransaction(controller: PGTransactionViewController, error: NSError, response: [NSObject : AnyObject]) {
        // Called when Transation is Failed
        print(response)
        
        if response.count == 0 {
            
            //self.function.alert_for(error.localizedDescription, message: response.description)
            
            print(response.description)
            
        }
        else if error != nil {
            
           // self.function.alert_for("Error", message: error.localizedDescription)
            
            print(error.localizedDescription)
            
        }
        
        self.removeController(controller : controller)
        
    }
    
    func didCancelTransaction(controller: PGTransactionViewController, error: NSError, response: [NSObject : AnyObject]) {
        
        //Cal when Process is Canceled
        var msg: String? = nil
        
        if error != nil {
            
            msg = String(format: "Successful")
        }
        else {
            msg = String(format: "UnSuccessful")
        }
        
        print(msg)
        //self.function.alert_for("Transaction Cancel", message: msg!)
        
        self.removeController(controller : controller)
        
    }
    
 
    
    
    func didFinishCASTransaction(controller: PGTransactionViewController, response: [NSObject : AnyObject]) {
        
        print(response)
         self.removeController(controller : controller)
        
    }
    
    
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
        
        print(responseString)
        
         self.removeController(controller : controller)
        
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController!) {
        
        self.removeController(controller: controller)
        
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        
        print(error.localizedDescription)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

