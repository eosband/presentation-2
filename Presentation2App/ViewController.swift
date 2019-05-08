//
//  ViewController.swift
//  Presentation2App
//
//  Created by Eric on 5/6/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    let BASE_API = "https://country.register.gov.uk/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func reloadButtonTouchUpInside(_ sender: Any) {
        let url = URL(string: BASE_API + "records.json?page-size=1")
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        
        // If you want to send data to the server in HTTP's body,
        // this is how you do so.
        /*
        let paramToSend = "username=" + user + "&password=" + psw
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        */
        
        let task = session.dataTask(with: request as URLRequest) { // completionHandler is implied to be the code below:
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error retrieving data from server, error:")
                return
            }
            // make sure we get data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            print(responseData)
            
            // parse the result as JSON, since that's what this API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error trying to convert data to JSON 1")
                    return
                }
                print("Done")
                // now we have the todo
                self.updateLabel(data: todo)
                
                // the todo object is a dictionary from String's to Any's
                
            } catch  {
                print("error trying to convert data to JSON 2")
                print(String(data: responseData, encoding: String.Encoding.utf8) ?? "[data not convertible to string]")
                return
            }
            
            // If you would like the status code, this is how you retrieve it.
            /*
            let code = httpResponse.statusCode
            */
        }
        // This line actually calls the above task that we defined, and upon retrieval of data from the server, it runs the completionHandler code we just created above.
        task.resume()
    }
    
    
    // The data will be in a dictionary form already, as it is JSON
    func updateLabel(data: [String: Any]) {
        print(data)
        // The data is in a quite peculiar form, as you can see above see. These lines simply unpackage and retrieve the country's name.
        for key: String in data.keys {
            guard let elem: [String: Any] = data[key]! as? [String : Any] else {
                print("Error: could not get elem")
                return
            }
            guard let itemList: [[String: Any]] = elem["item"]! as? [[String: Any]] else {
                print("Error: could not get itemList")
                return
            }
            let item: [String: Any] = itemList[0]
            guard let name: String = item["official-name"] as? String else {
                print("Error: could not get name")
                return
            }
           
            // This function (updateLabel) was called from the completion handler of our dataTask – an asynchronous function off of the main thread. Any UI operations need to be handled on the main thread, so to send it back we need the following DispatchQueue wrapper around our operation.
            DispatchQueue.main.async {
                self.countryLabel.text = name
            }
        }
    }
    
    
}

