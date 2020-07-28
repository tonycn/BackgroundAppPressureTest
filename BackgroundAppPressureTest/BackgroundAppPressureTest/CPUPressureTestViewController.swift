//
//  FirstViewController.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import UIKit

class CPUPressureTestViewController: UIViewController {

    @IBOutlet var cpuCoreNum: UITextField!
    @IBOutlet var cpuLoad: UITextField!
    @IBOutlet var time: UITextField!
    
    @IBOutlet var testNameField: UITextField!
    @IBOutlet var threadNumField: UITextField!
    @IBOutlet var idleTimeField: UITextField!
    @IBOutlet var backgroundModeSwitch: UISwitch!
    @IBOutlet var resultPositiveSwitch: UISwitch!

    private var cpuPressure: CPUPressure?
    private var timer: Timer?
    private var startTS: CFAbsoluteTime?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CPUPressureTestViewController.tapAction(target:)))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundModeSwitch.isOn = MusicBackgroundHelper.shared.isEnabled()
    }
    
    @objc
    public func tapAction(target: Any) {
        self.testNameField.resignFirstResponder()
        self.threadNumField.resignFirstResponder()
        self.idleTimeField.resignFirstResponder()
    }

    @IBAction func startAction(_ sender: Any) {
        
        if cpuPressure?.isRunning() ?? false {
            return
        }
        
        let threadNum = Int(threadNumField.text ?? "1") ?? 1
        let idleTimeInterval = TimeInterval(idleTimeField.text ?? "0.1") ?? 0.1
        startTS = CFAbsoluteTimeGetCurrent()
        cpuPressure?.stop()
        cpuPressure = CPUPressure(threadNum, idleTimeInterval)
        cpuPressure?.start()
        cpuCoreNum.text = "\(cpuProcessorCount())"
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (t) in
            self.updateResultFields()
        })
    }
    
    @IBAction func stopAction(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        updateResultFields()
        cpuPressure?.stop()
        showActionSimpleConfirmSheet(controler: self) { (position) in
            self.resultPositiveSwitch.isOn = position
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        //todo
    }
    
    private func updateResultFields() {
        cpuLoad.text = "\(cpuUsage())"
        time.text = "\(CFAbsoluteTimeGetCurrent()-self.startTS!)"
    }

    private func getValues() -> Dictionary<String, String> {
        var values = Dictionary<String, String>()
        values["p.name"] = testNameField.text
        values["p.threadNum"] = threadNumField.text
        values["p.idle"] = idleTimeField.text
        values["p.background"] = backgroundModeSwitch.isOn ? "on" : "off"
        
        values["r.load"] = cpuLoad.text
        values["r.time"] = time.text
        values["r.cores"] = cpuCoreNum.text
        values["r.positive"] = resultPositiveSwitch.isOn ? "positive" : "negtive"

        return values
    }
    
    @IBAction func backgroundSwitchAction(_ sender: Any) {
        if backgroundModeSwitch.isOn {
            MusicBackgroundHelper.shared.enable()
        } else {
            MusicBackgroundHelper.shared.disable()
        }
    }
}

