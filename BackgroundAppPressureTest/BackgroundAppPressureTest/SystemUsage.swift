//
//  SystemUsage.swift
//  BackgroundAppPressureTest
//
//  Created by jianjun on 2020-07-27.
//  Copyright © 2020 Jianjun. All rights reserved.
//


/*
 
 CPU usage func is from:
 - https://stackoverflow.com/a/44134397/554084
 - https://github.com/beltex/SystemKit/blob/master/SystemKit/System.swift
 
 Memory usage func referenced from https://gist.github.com/algal/cd3b5dfc16c9d577846d96713f7fba40
 
 */

import Foundation

  fileprivate func hostBasicInfo() -> host_basic_info {
      // TODO: Why is host_basic_info.max_mem val different from sysctl?
      let HOST_BASIC_INFO_COUNT         : mach_msg_type_number_t =
      UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
      var size     = HOST_BASIC_INFO_COUNT
      let hostInfo = host_basic_info_t.allocate(capacity: 1)
      
      let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
          host_info(mach_host_self(), HOST_BASIC_INFO, $0, &size)
      }

      let data = hostInfo.move()
        hostInfo.deallocate()
      return data
  }

var cpuCount:UInt32 = 0

public func cpuProcessorCount() -> UInt32 {
    if cpuCount == 0 {
        cpuCount = UInt32(hostBasicInfo().physical_cpu)
    }
    return cpuCount
}

public func cpuUsage() -> Double {
    var kr: kern_return_t
    var task_info_count: mach_msg_type_number_t
    
    task_info_count = mach_msg_type_number_t(TASK_INFO_MAX)
    var tinfo = [integer_t](repeating: 0, count: Int(task_info_count))
    
    kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &task_info_count)
    if kr != KERN_SUCCESS {
        return -1
    }
    
    var thread_list: thread_act_array_t? = UnsafeMutablePointer(mutating: [thread_act_t]())
    var thread_count: mach_msg_type_number_t = 0
    defer {
        if let thread_list = thread_list {
            vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(thread_list).pointee), vm_size_t(thread_count))
        }
    }
    
    kr = task_threads(mach_task_self_, &thread_list, &thread_count)
    
    if kr != KERN_SUCCESS {
        return -1
    }
    
    var tot_cpu: Double = 0
    
    if let thread_list = thread_list {
        
        for j in 0 ..< Int(thread_count) {
            var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
            var thinfo = [integer_t](repeating: 0, count: Int(thread_info_count))
            kr = thread_info(thread_list[j], thread_flavor_t(THREAD_BASIC_INFO),
                             &thinfo, &thread_info_count)
            if kr != KERN_SUCCESS {
                return -1
            }
            
            let threadBasicInfo = convertThreadInfoToThreadBasicInfo(thinfo)
            
            if threadBasicInfo.flags != TH_FLAGS_IDLE {
                tot_cpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
            }
        } // for each thread
    }
    
    return tot_cpu
}

fileprivate func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
    var result = thread_basic_info()
    
    result.user_time = time_value_t(seconds: threadInfo[0], microseconds: threadInfo[1])
    result.system_time = time_value_t(seconds: threadInfo[2], microseconds: threadInfo[3])
    result.cpu_usage = threadInfo[4]
    result.policy = threadInfo[5]
    result.run_state = threadInfo[6]
    result.flags = threadInfo[7]
    result.suspend_count = threadInfo[8]
    result.sleep_time = threadInfo[9]
    
    return result
}


func hostCPULoadInfo() -> host_cpu_load_info? {
    let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride
    var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
    var cpuLoadInfo = host_cpu_load_info()
    
    let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
        }
    }
    if result != KERN_SUCCESS{
        print("Error  - \(#file): \(#function) - kern_result_t = \(result)")
        return nil
    }
    return cpuLoadInfo
}

func getVMStatistics64() -> vm_statistics64?
{
  // the port number of the host (the current machine)  http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_host_self.html
  let host_port: host_t = mach_host_self()

  // size of a vm_statistics_data in integer_t's
  var host_size: mach_msg_type_number_t = mach_msg_type_number_t(UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size))

  var returnData:vm_statistics64 = vm_statistics64.init()
  let succeeded = withUnsafeMutablePointer(to: &returnData) {
    (p:UnsafeMutablePointer<vm_statistics64>) -> Bool in

    // host_statistics64() gives us a vm_statistics64 value, but it
    // returns this via an out pointer of type integer_t, so we need to rebind our
    // UnsafeMutablePointer<vm_statistics64> in order to use the function
    return p.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
      (pp:UnsafeMutablePointer<integer_t>) -> Bool in

      let retvalue = host_statistics64(host_port, HOST_VM_INFO64,
                                       pp, &host_size)
      return retvalue == KERN_SUCCESS
    }
  }

  return succeeded ? returnData : nil
}


/// Wrapper for `host_page_size`
///
/// - Returns: system's virtual page size, in bytes
///
/// Reference: http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/host_page_size.html
func getPageSize() -> UInt
{
  // the port number of the host (the current machine)  http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_host_self.html
  let host_port: host_t = mach_host_self()
  // the page size of the host, in bytes http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/host_page_size.html
  var pagesize: vm_size_t = 0
  host_page_size(host_port, &pagesize)
  // assert: pagesize is initialized
  return pagesize
}

extension vm_statistics64 {
  var pageSizeInBytes:UInt64 { return UInt64(getPageSize()) }

  var freeBytes:UInt64 { return UInt64(self.free_count) * self.pageSizeInBytes }
  var activeBytes:UInt64 { return UInt64(self.active_count) * self.pageSizeInBytes }
  var inactiveBytes:UInt64 { return UInt64(self.inactive_count) * self.pageSizeInBytes }
  var wireBytes:UInt64 { return UInt64(self.wire_count) * self.pageSizeInBytes }
  var zero_fillBytes:UInt64 { return UInt64(self.zero_fill_count) * self.pageSizeInBytes }
  var purgeableBytes:UInt64 { return UInt64(self.purgeable_count) * self.pageSizeInBytes }
  var speculativeBytes:UInt64 { return UInt64(self.speculative_count) * self.pageSizeInBytes }
  var throttledBytes:UInt64 { return UInt64(self.throttled_count) * self.pageSizeInBytes }
  var externalBytes:UInt64 { return UInt64(self.external_page_count) * self.pageSizeInBytes }
  var internalBytes:UInt64 { return UInt64(self.internal_page_count) * self.pageSizeInBytes }

  func debugString() -> String
  {
    let pageSizeInBytes:UInt64 = UInt64(getPageSize())

    let d:[String:UInt64] = [
      "free":UInt64(self.free_count),
      "active":UInt64(self.active_count),
      "inactive":UInt64(self.inactive_count),
      "wire":UInt64(self.wire_count),
      "zero_fill":self.zero_fill_count,
      "purgeable":UInt64(self.purgeable_count),
      "speculative":UInt64(self.speculative_count),
      "throttled":UInt64(self.throttled_count),
      "external":UInt64(self.external_page_count),
      "internal":UInt64(self.internal_page_count)
    ]
    var s = "Bytes associated with pages:\n"
    for k in d.keys.sorted() {
      let pageString = "\(k) pages:".padding(toLength: 30, withPad: " ", startingAt: 0)
      let value = "\(d[k]! * pageSizeInBytes) B"
      let prefixPad = repeatElement(" ", count: Swift.max(30 - value.count, 0)).joined()
      let valueLeftPad = prefixPad + value
      s.append("\(pageString) \t\t\(valueLeftPad)\n")
    }
    return s
  }
}

