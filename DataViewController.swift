//
//  DataViewController.swift
//  Turner
//
//  Created by Jacob McLachlan on 5/6/22.
//

import UIKit

var headerLabels = ["Machine", "Minimum tube\ndiameter (in.)", "Maximum tube\ndiameter (in.)"]
let headerOffset = 140
let headerHeight = 50
let collectionViewOffset = headerOffset + headerHeight
var machine = 0

// WS
let nameWS = ["WS1\nWS101", "WS1A\nWS101A", "WS2\nWS102", "WS3\nWS103", "WS4\nWS104", "WS5\nWS105", "WS6\nWS106", "WS6HD\nWS106HD", "WS7\nWS107", "WS8\nWS108", "WS9\nWS109", "WS10\nWS1010", "WS11\nWS1011", "WS12\nWS1012"]
var minWSInch = ["0.059", "0.118", "0.236", "0.315", "0.394", "0.512", "0.591", "0.591", "0.748", "1.102", "1.575", "2.362", "2.953", "4.528"]
var maxWSInch = ["0.315", "0.630", "1.260", "1.654", "2.362", "2.953", "3.740", "3.740", "4.724", "6.693", "8.661", "10.630", "13.780", "17.717"]
var minWSMM: Array<String> = []
var maxWSMM: Array<String> = []
var coupledWSInch: Array<String> = []
var coupledWSMM: Array<String> = []

// 900
let name900 = ["911.25", "912.5", "914.5", "916", "920", "922", "924R", "926", "927", "930", "935", "940", "943", "954"]
var min900Inch = ["0.040", "0.080", "0.125", "0.188", "0.250", "0.313", "0.375", "0.438", "0.375", "0.438", "0.500", "0.750", "0.875", "1.250"]
var max900Inch = ["0.100", "0.313", "0.625", "0.875", "1.250", "1.750", "2.250", "2.500", "2.750", "3.500", "4.000", "5.500", "6.500", "9.625"]
var min900MM: Array<String> = []
var max900MM: Array<String> = []
var coupled900Inch: Array<String> = []
var coupled900MM: Array<String> = []

// A
let nameA = ["AYZ", "AY", "AYY", "AXY", "AX", "AXN", "AN", "A0", "A1", "A2"]
var minAInch = ["0.050", "0.125", "0.250", "0.250", "0.250", "0.375", "0.500", "0.500", "0.750", "1.000"]
var maxAInch = ["0.313", "0.500", "0.625", "1.125", "1.500", "2.500", "3.000", "4.000", "4.750", "5.250"]
var minAMM: Array<String> = []
var maxAMM: Array<String> = []
var coupledAInch: Array<String> = []
var coupledAMM: Array<String> = []

class DataViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var UnitSegmentedControlMD: UISegmentedControl!
    @IBOutlet weak var MachineSegmentedControlMD: UISegmentedControl!
    
    lazy var frame = CGRect(x: 0, y: collectionViewOffset, width: Int(view.frame.size.width), height: Int(view.frame.size.height) - collectionViewOffset - 80)
    lazy var collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var headerCollectionView = UICollectionView(frame: CGRect(x: 0, y: headerOffset, width: Int(view.frame.size.width), height: headerHeight), collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // restore from memory
        UnitSegmentedControlMD.selectedSegmentIndex = unitIsMM ? 1 : 0
        MachineSegmentedControlMD.selectedSegmentIndex = defaults.integer(forKey: "machine")
        headerLabels = unitIsMM ? ["Machine", "Minimum tube\ndiameter (mm)", "Maximum tube\ndiameter (mm)"] : ["Machine", "Minimum tube\ndiameter (in.)", "Maximum tube\ndiameter (in.)"]
        machineChanged("no haptic")
        unitChanged("no haptic")
        
        collectionView.tag = 0
        collectionView.register(DataCollectionViewCell.self, forCellWithReuseIdentifier: DataCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        headerCollectionView.tag = 1
        headerCollectionView.register(DataCollectionViewCell.self, forCellWithReuseIdentifier: DataCollectionViewCell.identifier)
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        view.addSubview(headerCollectionView)
        
        // create mm arrays
        arrayToMM(inch: minWSInch, mm: &minWSMM)
        arrayToMM(inch: maxWSInch, mm: &maxWSMM)
        arrayToMM(inch: min900Inch, mm: &min900MM)
        arrayToMM(inch: max900Inch, mm: &max900MM)
        arrayToMM(inch: minAInch, mm: &minAMM)
        arrayToMM(inch: maxAInch, mm: &maxAMM)
        
        // fill large arrays
        fillSingleArray(names: nameWS, min: &minWSInch, max: &maxWSInch, large: &coupledWSInch)
        fillSingleArray(names: nameWS, min: &minWSMM, max: &maxWSMM, large: &coupledWSMM)
        fillSingleArray(names: name900, min: &min900Inch, max: &max900Inch, large: &coupled900Inch)
        fillSingleArray(names: name900, min: &min900MM, max: &max900MM, large: &coupled900MM)
        fillSingleArray(names: nameA, min: &minAInch, max: &maxAInch, large: &coupledAInch)
        fillSingleArray(names: nameA, min: &minAMM, max: &maxAMM, large: &coupledAMM)
        
        // listen for unit changed in DC
        NotificationCenter.default.addObserver(self, selector: #selector(sendToUnitChanged), name: Notification.Name("unit changed: DC to MD"), object: nil)
        
    }
    
    // change unit with call from DC
    @objc func sendToUnitChanged(notification: NSNotification) {
        UnitSegmentedControlMD.selectedSegmentIndex = unitIsMM ? 1 : 0
        unitChanged("function")
    }
    
    // unit selector
    @IBAction func unitChanged(_ sender: Any) {
        if sender as? String != "no haptic" && sender as? String != "function" {
            hapticNormal.impactOccurred()
        }
        
        unitIsMM = UnitSegmentedControlMD.selectedSegmentIndex == 1
        defaults.set(unitIsMM, forKey: "unit")
        headerLabels = unitIsMM ? ["Machine", "Minimum tube\ndiameter (mm)", "Maximum tube\ndiameter (mm)"] : ["Machine", "Minimum tube\ndiameter (in.)", "Maximum tube\ndiameter (in.)"]
        
        // update CollectionViews
        self.collectionView.performBatchUpdates({ [weak self] in
            var indices: [IndexPath] = []
            for i in 0 ..< (machine == 2 ? coupledAInch.count : coupledWSInch.count) {
                indices.append(IndexPath(item: i, section: 0))
            }
            self?.collectionView.reloadItems(at: indices)
        }, completion: { (_) in })
        
        self.headerCollectionView.performBatchUpdates({ [weak self] in
            self?.headerCollectionView.reloadItems(at: [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0), IndexPath(item: 2, section: 0)])
        }, completion: { (_) in })
        
        // change unit in DC if sender was user and not DC
        if sender as? String != "function" {
            NotificationCenter.default.post(name: Notification.Name("unit changed: MD to DC"), object: nil)
        }
    }
    
    // machine selector
    @IBAction func machineChanged(_ sender: Any) {
        if sender as? String != "no haptic" {
            hapticNormal.impactOccurred()
        }
        
        machine = MachineSegmentedControlMD.selectedSegmentIndex
        defaults.set(machine, forKey: "machine")
        
        // update CollectionView
        self.collectionView.performBatchUpdates({ [weak self] in
            var indices: [IndexPath] = []
            for i in 0 ..< (machine == 2 ? coupledAInch.count : coupledWSInch.count) {
                indices.append(IndexPath(item: i, section: 0))
            }
            self?.collectionView.reloadItems(at: indices)
        }, completion: { (_) in })
    }
    
    func arrayToMM(inch inchArray: Array<String>, mm mmArray: inout Array<String>) {
        for i in 0 ..< inchArray.count {
            var value = Double(inchArray[i])! * 25.4
            value = Double(round(10 * value) / 10)
            mmArray.append(String(value))
        }
    }
    
    func fillSingleArray(names: Array<String>,  min: inout Array<String>, max: inout Array<String>, large: inout Array<String>) {
        var nameIndex = 0
        for i in 0 ..< names.count * 3 {
            if i % 3 == 0 {
                large.append(names[nameIndex])
                nameIndex += 1
            } else if i % 3 == 1 {
                large.append(min.removeFirst())
            } else if i % 3 == 2 {
                large.append(max.removeFirst())
            }
        }
    }

}

// CollectionView functions
extension DataViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = frame
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 0 ? (machine == 2 ? coupledAInch.count : coupledWSInch.count) : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DataCollectionViewCell.identifier, for: indexPath) as? DataCollectionViewCell
        if collectionView.tag == 0 {
            if machine == 0 {
                cell?.label.text = unitIsMM ? coupledWSMM[indexPath.row] : coupledWSInch[indexPath.row]
            } else if machine == 1 {
                cell?.label.text = unitIsMM ? coupled900MM[indexPath.row] : coupled900Inch[indexPath.row]
            } else if machine == 2 {
                cell?.label.text = unitIsMM ? coupledAMM[indexPath.row] : coupledAInch[indexPath.row]
            }
            cell?.backgroundColor = indexPath.row / 3 % 2 == 0 ? UIColor.systemGray5 : UIColor.systemGray6
        } else if collectionView.tag == 1 {
            cell?.label.text = headerLabels[indexPath.row]
            cell?.label.font = UIFont.systemFont(ofSize: 14)
            cell?.label.backgroundColor = UIColor.systemGray4
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (Int(view.frame.size.width) / 3), height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
