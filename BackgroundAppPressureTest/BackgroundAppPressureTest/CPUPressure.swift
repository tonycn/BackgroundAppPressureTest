//
//  CPUPressure.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import Foundation

class CPUPressure {
    
    private let threadNum: Int
    private let idleSecond: TimeInterval
    private var running: Bool = false
    
    public func isRunning() -> Bool {
        
        return running;
    }
    
    init(_ threadNum: Int, _ idleSecond: TimeInterval) {
        self.threadNum = threadNum
        self.idleSecond = idleSecond
    }
    
    public func start() {
        if running {
            return
        }
        running = true
        for _ in 0..<threadNum {
            runOneThread()
        }
    }
    
    public func stop() {
        running = false
    }
    
    fileprivate func runOneThread() {
        DispatchQueue.global(qos: .default).async(execute: {
            while true && self.running {
                Thread.sleep(forTimeInterval: self.idleSecond)
            }
        })
    }
}
