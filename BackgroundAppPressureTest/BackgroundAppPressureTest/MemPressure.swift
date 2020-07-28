//
//  Pressure.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import Foundation

class MemPressure {
    
    private let allocUnit: Int
    private let memoryLeft: Int
    private let interval: TimeInterval
    private var running: Bool = false
    public static let MB = 1024 * 1024
    private var memoryArray: Array<UnsafeMutableRawPointer> = Array<UnsafeMutableRawPointer>()
    private var timer: Timer?
    
    init(_ allocUnit: Int, _ memoryLeft: Int, _ interval: TimeInterval) {
        self.allocUnit = allocUnit
        self.memoryLeft = memoryLeft
        self.interval = interval
    }

    public func isRunning() -> Bool {
        return running;
    }
    
    public func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (t) in
            let memoryInfo = getVMStatistics64()
            if let freeBytes = memoryInfo?.freeBytes,
                freeBytes > self.memoryLeft * MemPressure.MB {
                self.addMemory(self.allocUnit)
            }
        })
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
        for item in memoryArray {
            item.deallocate()
        }
        memoryArray.removeAll()
    }
    
    fileprivate func addMemory(_ amount: Int) {
        let memory = malloc(amount * MemPressure.MB)
        memset(memory, 0, amount * MemPressure.MB)
        if let memory = memory {
            memoryArray.append(memory)
        }
    }
}

