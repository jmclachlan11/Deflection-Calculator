//
//  ViewController.swift
//  Turner
//
//  Created by Jacob McLachlan on 5/2/22.
//

import UIKit

// haptic feedback
let hapticSpecial = UINotificationFeedbackGenerator()
let hapticNormal = UIImpactFeedbackGenerator(style: .medium)

var unitIsMM = false

// history arrays
var inputArray: Array<String> = []
var resultArray: Array<String> = []

let defaults = UserDefaults.standard

// text field/label property arrays
let textFieldPlaceholders = ["Enter OD here", "Enter roll center here", "Enter yield here", "Enter Young's modulus here"]
let inchLabels = ["Outside diameter (in.)", "Roll center (in.)", "Yield (KSI)", "Young's modulus (KSI)"]
let mmLabels = ["Outside diameter (mm)", "Roll center (mm)", "Yield (N/mm²)", "Young's modulus (GN/mm²)"]

// machine names, values, and dictionaries
let machines = ["(Value above)", "911.25", "912.5", "914.5", "916", "920", "922", "924R", "926", "927", "930", "935", "940", "943", "954", "---", "WS1", "WS1A", "WS2", "WS3", "WS4", "WS5", "WS6", "WS6HD", "WS7", "WS8", "WS8HD", "WS9", "WS10", "WS11", "WS12", "---", "AYZ", "AY", "AYY", "AXY", "AX", "AXN", "AN", "AO", "A1", "A2", "---", "6CR1", "6CR1½", "6CR2", "6CR2½", "6CR3", "6CR4", "6CR5", "6CR6", "6CR7", "6CR8", "6CR9", "6CR10", "6CR11", "6CR12", "6CR20", "---", "2WRSS1S"]
let machineInch = [-1, 1.0, 2.0, 3.75, 5.0, 7.0, 9.0, 11.0, 13.5, 13.0, 15.0, 18.0, 23.0, 26.0, 35.0, -1, 2.28, 4.53, 9.06, 12.6, 15.98, 20.0, 23.82, 18.9, 28.54, 31.5, 28.54, 36.22, 42.13, 54.13, 66.93, -1, 2.5, 5.0, 7.0, 9.0, 12.0, 15.0, 18.0, 23.0, 26.0, 30.0, -1, 2.0, 4.5, 6.0, 9.0, 12.25, 15.5, 19.0, 24.0, 28.5, 31.0, 36.0, 42.0, 54.0, 57.0, 60.0, -1, 2.0]
let machineMM = [-1, 25.4, 50.8, 88.9, 127.0, 177.8, 228.6, 279.4, 342.9, 330.2, 381.0, 457.2, 584.2, 660.4, 889.0, -1, 58.0, 115.0, 230.0, 320.0, 406.0, 508.0, 605.0, 480.0, 725.0, 800.0, 725.0, 920.0, 1070.0, 1375.0, 1700.0, -1, 63.5, 127.0, 177.8, 228.6, 304.8, 381.0, 457.2, 584.2, 660.4, 762.0, -1, 50.8, 114.3, 152.4, 228.6, 311.15, 393.7, 482.6, 609.6, 723.9, 787.4, 914.4, 1066.8, 1371.6, 1447.8, 1524.0, -1, 50.8]
var machineDictionaryInch: [String: Double] = [:]
var machineDictionaryMM: [String: Double] = [:]

// metal names, values, and dictionaries
let metals = ["(Value above)", "Steel", "Aluminum", "Copper", "Brass", "Zirconium", "Stainless steel"]
let metalInch = [-1, 30000.0, 10500.0, 17000.0, 17000.0, 14500.0, 29877.0]
let metalMM = [-1, 207.0, 72.3, 117.0, 117.0, 100.0, 206.0]
var metalDictionaryInch: [String: Double] = [:]
var metalDictionaryMM: [String: Double] = [:]

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var CalculateButtonDC: UIButton!
    @IBOutlet weak var ClearAllButtonDC: UIButton!
    @IBOutlet weak var HistoryButtonDC: UIButton!
    
    // input prompt labels
    @IBOutlet weak var ODLabelDC: UILabel!
    @IBOutlet weak var RCLabelDC: UILabel!
    @IBOutlet weak var YieldLabelDC: UILabel!
    @IBOutlet weak var YoungLabelDC: UILabel!
    
    // result labels
    @IBOutlet weak var DeflectionLabelDC: UILabel!
    @IBOutlet weak var ResultLabelDC: UILabel!
    
    @IBOutlet weak var ODTextFieldDC: UITextField!
    @IBOutlet weak var RCTextFieldDC: UITextField!
    @IBOutlet weak var YieldTextFieldDC: UITextField!
    @IBOutlet weak var YoungTextFieldDC: UITextField!
    
    @IBOutlet weak var MachinePickerViewDC: UIPickerView!
    @IBOutlet weak var MetalPickerViewDC: UIPickerView!
    
    @IBOutlet weak var UnitSegmentedControlDC: UISegmentedControl!
    
    @IBOutlet weak var ScrollViewDC: UIScrollView!
    
    lazy var buttons = [CalculateButtonDC, ClearAllButtonDC, HistoryButtonDC]
    lazy var textFields = [ODTextFieldDC, RCTextFieldDC, YieldTextFieldDC, YoungTextFieldDC]
    lazy var labels = [ODLabelDC, RCLabelDC, YieldLabelDC, YoungLabelDC]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide keyboard on tap outside
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing)))
        
        if passedNilCheck(buttons: buttons, textFields: textFields) {
            
            // set button corners
            for button in buttons {
                button?.layer.cornerRadius = 10
            }
            
            // set text field placeholders
            for (index, textField) in textFields.enumerated() {
                textField?.placeholder = textFieldPlaceholders[index]
            }
                
            self.ODTextFieldDC.delegate = self
            self.RCTextFieldDC.delegate = self
            self.YieldTextFieldDC.delegate = self
            self.YoungTextFieldDC.delegate = self
            self.MachinePickerViewDC.delegate = self
            self.MachinePickerViewDC.dataSource = self
            self.MetalPickerViewDC.delegate = self
            self.MetalPickerViewDC.dataSource = self
            
            // PickerView tags
            MachinePickerViewDC.tag = 0
            MetalPickerViewDC.tag = 1
            
            DeflectionLabelDC.isHidden = true
            ResultLabelDC.isHidden = true
            
            ScrollViewDC.showsVerticalScrollIndicator = false
            
            // restore unit
            unitIsMM = defaults.bool(forKey: "unit")
            UnitSegmentedControlDC.selectedSegmentIndex = unitIsMM ? 1 : 0
            unitChanged("function")
            
            // restore history
            inputArray = defaults.stringArray(forKey: "input") ?? []
            resultArray = defaults.stringArray(forKey: "result") ?? []
            
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        }
        
        fillDictionaries()
        
        // decimal pad toolbar
        let Toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let FlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let DoneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        let NextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextField))
        Toolbar.items = [DoneButton, FlexibleSpace, NextButton]
        Toolbar.sizeToFit()
        for textField in textFields {
            textField?.inputAccessoryView = Toolbar
        }
        
        // listen for unit changed in MD
        NotificationCenter.default.addObserver(self, selector: #selector(sendToUnitChanged), name: Notification.Name("unit changed: MD to DC"), object: nil)
        
    }
    
    // change unit with call from MD
    @objc func sendToUnitChanged(notification: NSNotification) {
        UnitSegmentedControlDC.selectedSegmentIndex = unitIsMM ? 1 : 0
        unitChanged("function")
    }
    
    // unit selector
    @IBAction func unitChanged(_ sender: Any) {
        unitIsMM = UnitSegmentedControlDC.selectedSegmentIndex == 1
        
        // change labels
        for (index, label) in labels.enumerated() {
            label?.text = unitIsMM ? mmLabels[index] : inchLabels[index]
        }
        
        // add unit to memory
        defaults.set(unitIsMM, forKey: "unit")
                
        // change unit in MD if sender was user and not MD
        if sender as? String != "function" {
            NotificationCenter.default.post(name: Notification.Name("unit changed: DC to MD"), object: nil)
        }
        
        clearAllDC(sender as? String != "function" ? self : "no haptic")
    }
    
    // toolbar done button
    @objc func done() {
        hapticNormal.impactOccurred()
        view.endEditing(true)
    }
    
    // toolbar next button
    @objc func nextField() {
        hapticNormal.impactOccurred()
        if ODTextFieldDC.isFirstResponder {
            RCTextFieldDC.becomeFirstResponder()
        } else if RCTextFieldDC.isFirstResponder {
            YieldTextFieldDC.becomeFirstResponder()
            
            // scroll to bottom of screen
            if UIDevice.current.userInterfaceIdiom != .pad {
                ScrollViewDC.setContentOffset(CGPoint(x: 0, y: ScrollViewDC.contentSize.height - ScrollViewDC.bounds.height + ScrollViewDC.contentInset.bottom), animated: true)
            }
        } else if YieldTextFieldDC.isFirstResponder {
            YoungTextFieldDC.becomeFirstResponder()
        } else if YoungTextFieldDC.isFirstResponder {
            calculateDC(self)
        } else {
            ODTextFieldDC.becomeFirstResponder()
        }
    }
    
    // history button
    @IBAction func history(_ sender: Any) {
        hapticNormal.impactOccurred()

        if inputArray == [] {
            let dialogMessage = UIAlertController(title: "History is empty", message: "", preferredStyle: .alert)
            dialogMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in }))
            self.present(dialogMessage, animated: true, completion: nil)
        } else {
            view.endEditing(true)
        }
    }
    
    // logo link to website
    @IBAction func turner(_ sender: Any) {
        if let url = NSURL(string: "http:/www.turnermachineco.com") {
            UIApplication.shared.open(url as URL)
        }
    }
    
    // clear all button
    @IBAction func clearAllDC(_ sender: Any) {
        if sender as? String != "no haptic" {
            hapticNormal.impactOccurred()
        }
        DeflectionLabelDC.isHidden = true
        ResultLabelDC.isHidden = true
        for textField in textFields {
            textField?.text = ""
        }
    }
    
    // calculate button
    @IBAction func calculateDC(_ sender: Any) {
        DeflectionLabelDC.isHidden = true
        ResultLabelDC.isHidden = false
        
        // get Strings
        let odText = ODTextFieldDC.text
        let rcText = RCTextFieldDC.text
        let yieldText = YieldTextFieldDC.text
        let youngText = YoungTextFieldDC.text
        
        if odText == "" || rcText == "" || yieldText == "" || youngText == "" {
            reportError(error: "Field cannot be empty")
        } else if !decimalsAreLegal(strings: [odText!, rcText!, yieldText!, youngText!]) {
            reportError(error: "Multiple decimal points")
        } else {
            
            // turn strings to Doubles
            let od = Double(odText!)!
            let rc = Double(rcText!)!
            let yield = Double(yieldText!)!
            let young = Double(youngText!)!
            
            if od == 0 || young == 0 {
                reportError(error: "Value cannot be zero")
            } else if od < 0.01 || rc > 99999 || yield > 999999 || young < 0.01 {
                reportError(error: "Value overflow")
            } else {
                hapticSpecial.notificationOccurred(.success)
                
                // scroll to bottom of screen
                if UIDevice.current.userInterfaceIdiom != .pad {
                    ScrollViewDC.setContentOffset(CGPoint(x: 0, y: ScrollViewDC.contentSize.height - ScrollViewDC.bounds.height + ScrollViewDC.contentInset.bottom), animated: true)
                }
                
                // calculate and round result
                var result = unitIsMM ? (yield * rc * rc) / (1500 * young * od) : (2 * yield * rc * rc) / (3 * young * od)
                result = Double(round(1000 * result) / 1000)
                
                // turn result to String and add trailing zeros if necessary
                var resultString = String(result)
                if Int(result * 100) % 10 == 0 && Int(result * 1000) % 10 == 0 {
                    resultString += "00"
                } else if Int(result * 1000) % 10 == 0 {
                    resultString += "0"
                }
                
                // add unit to result String
                let unit = unitIsMM ? "mm" : "inch"
                resultString += " \(unit)"
                
                // add inputs and result to memory
                inputArray.insert(contentsOf: ["Outside diameter:\t\t\(od) \(unit)", "Roll center:\t\t\t\t\(rc) \(unit)", "Yield:\t\t\t\t\t\(yield) \(unitIsMM ? "N/mm²" : "KSI")", "Young's modulus:\t\t\(young) \(unitIsMM ? "GN/mm²" : "KSI")"], at: 0)
                defaults.set(inputArray, forKey: "input")
                resultArray.insert("Deflection:\t\t\t\(resultString)", at: 0)
                defaults.set(resultArray, forKey: "result")
                
                ResultLabelDC.text = resultString
                DeflectionLabelDC.isHidden = false
            }
        }
        
        view.endEditing(true)
    }
    
    func reportError(error: String) {
        hapticSpecial.notificationOccurred(.error)
        
        DeflectionLabelDC.isHidden = true
        ResultLabelDC.isHidden = true
        
        let dialogMessage = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        dialogMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in }))
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func decimalsAreLegal(strings: Array<String>) -> Bool {
        for string in strings {
            if string.filter({$0 == "."}).count > 1 {
                return false
            }
        }
        return true
    }
    
    func fillDictionaries() {
        for (index, metal) in metals.enumerated() {
            metalDictionaryInch[metal] = metalInch[index]
            metalDictionaryMM[metal] = metalMM[index]
        }
        for (index, machine) in machines.enumerated() {
            machineDictionaryInch[machine] = machineInch[index]
            machineDictionaryMM[machine] = machineMM[index]
        }
    }
    
    func passedNilCheck(buttons: [UIButton?], textFields: [UITextField?]) -> Bool {
        for button in buttons {
            if button == nil {
                return false
            }
        }
        for textField in textFields {
            if textField == nil {
                return false
            }
        }
        return true
    }
    
    // filters keyboard input to only allow numbers and "."
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "1234567890.")
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }

}

// PickerView functions
extension ViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 0 ? 60 : 7
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 0 ? machines[row] : metals[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 && machineDictionaryInch[machines[row]] != -1 {
            RCTextFieldDC.text = String((unitIsMM ? machineDictionaryMM[machines[row]] : machineDictionaryInch[machines[row]]) ?? 0)
        } else if pickerView.tag == 1 && metalDictionaryInch[metals[row]] != -1 {
            YoungTextFieldDC.text = String((unitIsMM ? metalDictionaryMM[metals[row]] : metalDictionaryInch[metals[row]]) ?? 0)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = UIFont (name: "System", size: 18)
        label.text =  pickerView.tag == 0 ? machines[row] : metals[row]
        label.textAlignment = .center
        return label
    }
}

// orientation lock
struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
    }
}
