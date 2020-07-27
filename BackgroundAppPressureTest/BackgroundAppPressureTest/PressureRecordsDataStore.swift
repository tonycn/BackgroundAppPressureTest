//
//  PressureRecordsDataStore.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//

import Foundation

class PressureRecordsDataStore {
    
    let name: String
    let userDefaults: UserDefaults
    init(_ storeName:String) {
        name = storeName
        userDefaults = UserDefaults.init(suiteName: "test_records")!
    }
    
    static var cpuStore: PressureRecordsDataStore?
    static public func cpuDataStore() -> PressureRecordsDataStore {
        if cpuStore == nil {
            cpuStore = PressureRecordsDataStore("cpu")
        }
        return cpuStore!
    }
    
    static var memoryStore: PressureRecordsDataStore?
    static public func memoryDataStore() -> PressureRecordsDataStore {
        if memoryStore == nil {
            memoryStore = PressureRecordsDataStore("memory")
        }
        return memoryStore!
    }
    
    public func addOneRecord(_ record: Dictionary<String, String>) {
        let existedArr = (userDefaults.array(forKey: self.name)  as? Array<Dictionary<String, String>>)
        var arr = existedArr ?? Array<Dictionary<String, String>>()
        arr.append(record)
        userDefaults.set(arr, forKey: self.name)
        userDefaults.synchronize()
    }
    
    public func allRecords() -> Array<Dictionary<String, String>>? {
        return userDefaults.array(forKey: self.name)  as? Array<Dictionary<String, String>>
    }
}
