//
//  ViewController.swift
//  Traffic Lights
//
//  Created by Gagandeep Nagpal on 12/03/17.
//  Copyright © 2017 Gagandeep Nagpal. All rights reserved.
//

import UIKit
import AI

class ViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var textOutput: UILabel!
    
    @IBOutlet var viewColor: UIView!
    
    
    
    fileprivate var response: QueryResponse? = .none
  
    
    @IBAction func send(_ sender: Any) {
        
        
        AI.sharedService.textRequest(textInput.text ?? "").success {(response) -> Void in
            
            self.response = response
            DispatchQueue.main.async {
                
                print(response.result.fulfillment?.speech ?? "none")
                
                let output = response.result.fulfillment?.speech
                
                //print(response.result.parameters!)
                //print(response)
                print(response.result.metadata.intentName ?? "none")
                //print(response.result.parameters?["colors"] ?? "none")
                //print(response.result.action)
                
                if (response.result.metadata.intentName == "change.color"){
                    
                    
                    
                    let newColor = response.result.parameters?["colors"] as! String
                    print(newColor)
                    
                    self.textOutput.text = output
                    
                    if( newColor == "red"){
                        
                        self.viewColor.backgroundColor = UIColor.red
                    }else if(newColor == "green"){
                        
                        self.viewColor.backgroundColor = UIColor.green
                        
                    }else if(newColor == "yellow"){
                        
                        self.viewColor.backgroundColor  = UIColor.yellow
                    }
                    
                    
                }else{
                    
                    self.viewColor.backgroundColor = UIColor.white
                    self.textOutput.text = output
                    
                }
                
                
               
                
                
            }
            }.failure { (error) -> Void in
                DispatchQueue.main.async {
                    
                    
                    let alert = UIAlertController(title: "Please Enter Some Input", message: "Please try again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.textOutput.text = ""
                    
        
                    
                    
                }
                
                
        }

        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
         self.textInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

