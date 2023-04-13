//
//  HistoryViewController.swift
//  Turner
//
//  Created by Jacob McLachlan on 5/6/22.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var HistoryTableViewDC: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HistoryTableViewDC?.delegate = self
        HistoryTableViewDC?.dataSource = self
        
        // clear button
        let clearHistory = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearHistory))
        clearHistory.tintColor = UIColor.systemRed
        navigationItem.rightBarButtonItem = clearHistory
    }
    
    @objc func clearHistory() {
        hapticSpecial.notificationOccurred(.warning)
    
        // alert
        let dialogMessage = UIAlertController(title: "Confirm", message: "Clear history?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
            inputArray = []
            resultArray = []
            defaults.set(inputArray, forKey: "input")
            defaults.set(resultArray, forKey: "result")
            self.navigationController?.popViewController(animated: true)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    // TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = inputArray[indexPath.row + 4 * indexPath.section]
        cell.textLabel!.font = cell.textLabel!.font.withSize(14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultArray[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if let textlabel = header.textLabel {
            textlabel.font = textlabel.font.withSize(20)
            textlabel.textColor = .label
        }
    }
    
    // number of calculations in history
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultArray.count
    }
}
