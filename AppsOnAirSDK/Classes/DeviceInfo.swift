//
//  File.swift
//  AppsOnAir
//
//  Created by vishal-zaveri-us on 19/05/24.
//

import Foundation
import UIKit

class MyDevice {
    
    
    func getInfo() -> [String: Any] {
        var deviceInfo = [String: Any]()
        
        // Device Model
        // let deviceModel = "\(UIDevice.current.model) \(UIDevice.current.name)"
        let deviceModel = "\(UIDevice.current.name)"
        
        let device = UIDevice()
        let modelIdentifier = device.modelIdentifier
        print("---> Model Identifier: \(modelIdentifier)")
           
        deviceInfo["deviceModel"] = "\(deviceModel)"
        
        // OS Version
        deviceInfo["deviceOsVersion"] = UIDevice.current.systemVersion
            
        // Battery Level
        let batteryLevel = UIDevice.current.batteryLevel
        deviceInfo["deviceBatteryLevel"] =  batteryLevel <= 0 ?  "\(batteryLevel)%" : "\(Int(batteryLevel * 100))%"
           
           
        // Device Memory
        deviceInfo["deviceMemory"] =  "\(Double(ProcessInfo.processInfo.physicalMemory) / pow(1024, 3)) GB"
        
        // Get the used memory by the app
        if let usedMemoryInMB = getUsedMemory() {
            deviceInfo["appMemoryUsage"] = "\(usedMemoryInMB) MB"
        }
        
        if let countryCode = Locale.current.regionCode,
           let countryName = Locale.current.localizedString(forRegionCode: countryCode) {
            deviceInfo["deviceRegionCode"] = "\(countryCode)"
            deviceInfo["deviceRegionName"] = "\(countryName)"
        }
        
        // Storage
        if let storageInfo = getDeviceStorageInfo() {
            deviceInfo["deviceTotalStorage"] = storageInfo.totalSpace
            deviceInfo["deviceUsedStorage"] = storageInfo.usedSpace
        } else {
            print("Failed to retrieve storage information.")
        }
        
        // Screen Size
        if let screenMode = UIScreen.main.currentMode?.size {
            deviceInfo["deviceScreenSize"] = "\(screenMode.width)x\(screenMode.height)"
        }
        
        // Screen orientation
        let orientation = UIDevice.current.orientation
        deviceInfo["deviceOrientation"] =  orientation.isPortrait ? "Portrait" : "Landscape"
        
            
        // Timestamp
        deviceInfo["timestamp"] = Date()
        
        /// App Information
        deviceInfo["appNme"] = Bundle.main.appName
        
        deviceInfo["bundleIdentifier"] = Bundle.main.bundleIdentifier
        
        deviceInfo["releaseVersionNumber"] = Bundle.main.releaseVersionNumber
        
        deviceInfo["buildVersionNumber"] = Bundle.main.buildVersionNumber
        
        deviceInfo["appsOnAirSDKVersion"] = Bundle(identifier: "org.cocoapods.AppsOnAir")?.buildVersionNumber
        
        return deviceInfo
    }

    func formatSize(_ size: Int64) -> String {
        let byteFormatter = ByteCountFormatter()
        byteFormatter.allowedUnits = [.useGB, .useMB]
        byteFormatter.countStyle = .file
        return byteFormatter.string(fromByteCount: size)
    }

    func getDeviceStorageInfo() -> (totalSpace: String, usedSpace: String)? {
        let fileManager = FileManager.default
        do {
            let systemAttributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            
            if let totalSize = systemAttributes[.systemSize] as? NSNumber, let freeSize = systemAttributes[.systemFreeSize] as? NSNumber {
                let totalSpace = totalSize.int64Value
                let freeSpace = freeSize.int64Value
                let usedSpace = totalSpace - freeSpace
                return (formatSize(totalSpace), formatSize(usedSpace))
            } else {
                print("Error: Couldn't retrieve storage information.")
                return nil
            }
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    func getUsedMemory() -> UInt64? {
            var taskInfo = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
            let kerr = withUnsafeMutablePointer(to: &taskInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                }
            }
            
            guard kerr == KERN_SUCCESS else { return nil }
            
            return taskInfo.resident_size / (1024 * 1024) // Convert to MB
        }
    

}
