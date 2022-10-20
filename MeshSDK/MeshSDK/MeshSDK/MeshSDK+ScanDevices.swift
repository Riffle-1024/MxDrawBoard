//
//  MeshSDK+ScanDevices.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/1/27.
//

import Foundation
import nRFMeshProvision
import CoreBluetooth

@objcMembers
open class MXMeshDeviceScan: NSObject, CBCentralManagerDelegate {
    public static let sharedInstance = MXMeshDeviceScan()
    
    var centralManager: CBCentralManager!
    var disposedDiscoveredReadableDevices = [[String: Any]]()
    //发现设备的回调
    public typealias DisposedScanResultReadableCallback = ([[String: Any]]) -> ()
    var disposedScanResultReadableCallback: DisposedScanResultReadableCallback?
    
    var provisionScanMac : String?
    
    var scanTimer : Timer!
    var scanTimerNum : Int = 0
    let defaultScanTimeout : Int = 30
    var scanTimeout : Int = 30
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /*
     搜索设备
     @param mac  MAC地址（搜索指定设备）
     @param timeout 超时时间（只有搜索指定设备才有效）
     @callback  [String:Any]  device: UnprovisionedDevice, peripheral: CBPeripheral uuid: String name: String rssi:Int
     */
    public func scanDevice(mac: String?, timeout:Int, callback: @escaping DisposedScanResultReadableCallback) {
        disposedDiscoveredReadableDevices.removeAll()
        centralManager.delegate = self
        disposedScanResultReadableCallback = callback
        self.provisionScanMac = mac
        if timeout > 0 {
            self.scanTimeout = timeout
        }
        if mac != nil || timeout > 0 {
            self.setupScanTimer()
        }
        centralManager.scanForPeripherals(withServices: [MeshProvisioningService.uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    //停止扫描
    public func stopScan() {
        self.provisionScanMac = nil
        self.scanTimeout = self.defaultScanTimeout
        if self.scanTimer != nil {
            self.scanTimer.fireDate = Date.distantFuture// 计时器暂停
            self.scanTimer.invalidate()
            self.scanTimer = nil
        }
        centralManager.stopScan()
    }
    
    func setupScanTimer() {
        if self.scanTimer != nil {
            self.scanTimer.fireDate = Date.distantFuture// 计时器暂停
            self.scanTimer.invalidate()
            self.scanTimer = nil
        }
        self.scanTimerNum = 0
        self.scanTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.scanTimerNum += 1
            if self.scanTimerNum >= self.scanTimeout {
                self.disposedScanResultReadableCallback?(self.disposedDiscoveredReadableDevices)
                self.disposedScanResultReadableCallback = nil
                self.stopScan()
                
            }
        })
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let unprovisionedDevice = UnprovisionedDevice(advertisementData: advertisementData) {
            
            //if self.isMxchipDevice(uuid: unprovisionedDevice.uuid.uuidString) {
                let uuidString = unprovisionedDevice.uuid.uuidString
                let macStr = MeshSDK.sharedInstance.getDeviceMacAddress(uuid: uuidString)
                let productId = MeshSDK.sharedInstance.getDeviceProductId(uuid: uuidString)
                let newlyAddDevice = ["device":unprovisionedDevice, "uuid": uuidString, "rssi": RSSI.intValue, "name": peripheral.name ?? "","peripheral":peripheral,"mac":macStr,"productId":productId] as [String : Any]
            
                guard let mac = self.provisionScanMac  else {
                    if disposedDiscoveredReadableDevices.firstIndex(where: { $0["peripheral"] as! NSObject == peripheral } ) == nil {
                        disposedDiscoveredReadableDevices.append(newlyAddDevice)
                    }
                    disposedScanResultReadableCallback?(disposedDiscoveredReadableDevices)
                    return
                }
                if mac == MeshSDK.sharedInstance.getNodeMacAddress(uuid: uuidString) {
                    disposedDiscoveredReadableDevices.removeAll()
                    disposedDiscoveredReadableDevices.append(newlyAddDevice)
                    disposedScanResultReadableCallback?(disposedDiscoveredReadableDevices)
                    self.disposedScanResultReadableCallback = nil
                    self.stopScan()
                }
            //}

        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            
        } else {
            
        }
    }
}
