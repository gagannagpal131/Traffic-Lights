//
//  ViewController.swift
//  Traffic Lights
//
//  Created by Gagandeep Nagpal on 12/03/17.
//  Copyright © 2017 Gagandeep Nagpal. All rights reserved.
//

import UIKit
import AI
import Speech

class ViewController: UIViewController,UITextFieldDelegate,SFSpeechRecognizerDelegate {
    
    
    @IBOutlet weak var textInput: UITextField!
    
    @IBOutlet weak var textOutput: UILabel!
    
    @IBOutlet var viewColor: UIView!
    
    fileprivate var response: QueryResponse? = .none
  
    @IBOutlet weak var startRecordingbButton: UIButton!
    
    
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    @IBAction func startRecording(_ sender: Any) {
        
        startRecordingbButton.isHidden = true
        startRecordingbButton.isEnabled = false
        stopRecordingButton.isHidden = false
         stopRecordingButton.isEnabled = true
        
            startRecording()
        
    }
    
    func startRecording() {
        
        print("function began")
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.textInput.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                //self.startRecordingbButton.isEnabled = true
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
       
         textInput.text = "Say something, I'm listening!"
        
    }//end of startrecording()
    

    @IBAction func send(_ sender: Any) {
        
        
        audioEngine.stop()              // these two lines are to stop the audioEngine from Recording
        recognitionRequest?.endAudio()  //to end recording
        
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
        
       
        stopRecordingButton.isEnabled = false
        stopRecordingButton.isHidden = true
        startRecordingbButton.isEnabled = true
        startRecordingbButton.isHidden = false
        
        
        
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == textInput){
            
        }
        
        return false
        
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
        startRecordingbButton.isEnabled = false
        startRecordingbButton.isHidden = false
        stopRecordingButton.isEnabled = false
        stopRecordingButton.isHidden = true
        
        speechRecognizer.delegate = self
        
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.startRecordingbButton.isEnabled = isButtonEnabled
            }
        }

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

