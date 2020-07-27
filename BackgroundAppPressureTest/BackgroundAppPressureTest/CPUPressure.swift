//
//  CPUPressure.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import Foundation

class CPUPressure {
    
    private var running: Bool = false
    
    public func isRunning() -> Bool {
        
        return running;
    }

    
    public func start() {
        
        
    }
    
    public func stop() {
        
    }
    
    fileprivate func runFullCPU() {
        DispatchQueue.global(qos: .default).async(execute: {
            while true && self.running {
                Thread.sleep(forTimeInterval: 0.1)
            }
        })
    }
    
    fileprivate func testCPU100percentDevice() {

//        for i in 0..<cpu.processorCount {
//            runFullCPU()
//        }


    }
}
