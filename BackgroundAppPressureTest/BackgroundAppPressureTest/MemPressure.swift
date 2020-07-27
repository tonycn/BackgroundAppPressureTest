//
//  Pressure.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import Foundation

class MemPressure {
    
    private var running: Bool = false
    static let MB = 1024 * 1024
    private var memoryArray: Array<UnsafeMutableRawPointer> = Array<UnsafeMutableRawPointer>()
    
    public func isRunning() -> Bool {
        
        return running;
    }
    
    public func start() {
        
        
    }
    
    public func stop() {
        
    }
    
    fileprivate func addMemory(_ amount: Int) {
        let memory10M = malloc(amount * MemPressure.MB)
        memset(memory10M, 0, amount * MemPressure.MB)
        if let memory10M = memory10M {
            memoryArray.append(memory10M)
        }
    }
}

