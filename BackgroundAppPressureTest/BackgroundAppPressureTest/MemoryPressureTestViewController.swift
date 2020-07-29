//
//  SecondViewController.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import UIKit

class MemoryPressureTestViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var testNameField: UITextField!
    @IBOutlet var intervalField: UITextField!
    @IBOutlet var allocUnitField: UITextField!
    @IBOutlet var memoryLeftField: UITextField!
    @IBOutlet var backgroundModeSwitch: UISwitch!
    @IBOutlet var locationBackgroundModeSwitch: UISwitch!
    
    
    @IBOutlet var freeMemoryField: UITextField!
    @IBOutlet var totalMemoryField: UITextField!
    @IBOutlet var timeField: UITextField!
    @IBOutlet var resultPositiveSwitch: UISwitch!
    
    private var memPressure: MemPressure?
    private var timer: Timer?
    private var startTS: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        testNameField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(CPUPressureTestViewController.tapAction(target:)))
        self.view.addGestureRecognizer(tap)
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (t) in
            self.updateResultFields()
        })
        let total = ProcessInfo.processInfo.physicalMemory
        totalMemoryField.text = "\(total/UInt64(MemPressure.MB))"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundModeSwitch.isOn = MusicBackgroundHelper.shared.isEnabled()
    }
    
    @objc
    public func tapAction(target: Any) {
        self.testNameField.resignFirstResponder()
        self.intervalField.resignFirstResponder()
        self.memoryLeftField.resignFirstResponder()
        self.allocUnitField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func startAction(_ sender: Any) {
        
        if memPressure?.isRunning() ?? false {
            return
        }
        let allocUnit = Int(allocUnitField.text ?? "1") ?? 10
        let memoryLeft = Int(memoryLeftField.text ?? "0.1") ?? 80
        let interval = TimeInterval(intervalField.text ?? "0.1") ?? 0.1
        startTS = CFAbsoluteTimeGetCurrent()
        memPressure?.stop()
        memPressure = MemPressure(allocUnit, memoryLeft, interval)
        memPressure?.start()
    }
    
    @IBAction func stopAction(_ sender: Any) {
        updateResultFields()
        memPressure?.stop()
        showActionSimpleConfirmSheet(controler: self) { (position) in
            self.resultPositiveSwitch.isOn = position
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
    }
    
    private func updateResultFields() {
        if let memInfo = getVMStatistics64() {
            freeMemoryField.text = "\(memInfo.freeBytes/UInt64(MemPressure.MB))"
        }
        timeField.text = "\(CFAbsoluteTimeGetCurrent()-self.startTS)"
    }

    private func getValues() -> Dictionary<String, String> {
        
        let allocUnit = Int(allocUnitField.text ?? "1") ?? 10
        let memoryLeft = Int(memoryLeftField.text ?? "0.1") ?? 80
        let interval = TimeInterval(intervalField.text ?? "0.1") ?? 0.1
        
        var values = Dictionary<String, String>()
        values["p.name"] = testNameField.text
        values["p.allocUnit"] = "\(allocUnit)"
        values["p.memoryLeft"] = "\(memoryLeft)"
        values["p.interval"] = "\(interval)"
        
        values["r.free"] = freeMemoryField.text
        values["r.time"] = timeField.text
        values["r.total"] = totalMemoryField.text
        values["r.positive"] = resultPositiveSwitch.isOn ? "positive" : "negtive"

        return values
    }

    @IBAction func backgroundSwitchAction(_ sender: Any) {
        if backgroundModeSwitch.isOn {
            if !MusicBackgroundHelper.shared.enable() {
                backgroundModeSwitch.isOn = false
            }
        } else {
            MusicBackgroundHelper.shared.disable()
        }
    }
    
    @IBAction func locationBackgroundSwitchAction(_ sender: Any) {
        if locationBackgroundModeSwitch.isOn {
            if !LocationBackgroundHelper.shared.enable() {
                locationBackgroundModeSwitch.isOn = false
            }
        } else {
            LocationBackgroundHelper.shared.disable()
        }
    }
}

