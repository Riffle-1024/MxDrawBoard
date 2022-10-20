//
//  MeshSDK+DeviceMessage.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/1/22.
//

import Foundation
import nRFMeshProvision

// MARK: - 对设备发送控制指令
extension MeshSDK {
    
    /*
    获取设备的三元组
    @param uuid 设备的uuid/mac地址
    @callback [String: Any] 返回数据有pk,ps,dn,ds,pid
    */
    public func fetchDeviceTriplet(uuid: String, callback: @escaping FetchTripletCallback) {
        self.provisionDelegate?.meshProvisionProcess?(step: UnprovisionedDeviceProvisionStep.FetchDeviceIdentity.rawValue)
        var attrStr = String(format: "%04X", UInt16(bigEndian: 0x0003).littleEndian)
        if (self.getFeatureFlag(uuid: uuid) >> 1) == 2 {
            attrStr = String(format: "%04X", UInt16(bigEndian: 0x0019).littleEndian)
        }
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Get.rawValue, uuid: uuid, message: attrStr, retryCount:0, timeout: 5) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback([String : Any]())
                return
            }
            let quintupleString = attrStr.suffix(attrStr.count - 2)
            let array = quintupleString.split(separator: " ")
            let arrayStrings: [String] = array.compactMap { "\($0)" }
            var quintupleDic = [String: Any]()
            if arrayStrings.count == 1 {
                quintupleDic["dn"] = arrayStrings[0]
            } else if arrayStrings.count >= 5 {
                quintupleDic["pk"] = arrayStrings[0]
                quintupleDic["ps"] = arrayStrings[1]
                quintupleDic["dn"] = arrayStrings[2]
                quintupleDic["ds"] = arrayStrings[3]
                quintupleDic["pid"] = arrayStrings[4]
            }
            callback(quintupleDic)
        }
    }
    
    /*
    获取设备的三元组
    @param uuid 设备的uuid/mac地址
    @callback [String: Any] 返回数据有pk,dn,sign
    */
    public func fogDeviceTriplet(uuid: String, callback: @escaping FetchTripletCallback) {
        self.provisionDelegate?.meshProvisionProcess?(step: UnprovisionedDeviceProvisionStep.FetchDeviceIdentity.rawValue)
        
        let value = UInt16(bigEndian: 0x0030)
        let attrStr = String(format: "%04X", value.littleEndian)
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Get.rawValue, uuid: uuid, message: attrStr, retryCount:0, timeout: 5) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback([String : Any]())
                return
            }
            
            let msgBytes = [UInt8](Data(hex: attrStr))
            var quintupleDic = [String: Any]()
            guard msgBytes.count >= 18 else {
                callback([String : Any]())
                return
            }
            
            var pkHex: String = ""
            for i in 2 ..< 6 {
                pkHex += String(format: "%02x", msgBytes[i])
            }
            quintupleDic["pk"] = pkHex
            
            var dnHex: String = ""
            for i in 6 ..< 10 {
                dnHex += String(format: "%02x", msgBytes[i])
            }
            quintupleDic["dn"] = dnHex
            
            var dsHex: String = ""
            for i in 10 ..< 18 {
                dsHex += String(format: "%02x", msgBytes[i])
            }
            quintupleDic["ds"] = dsHex
            
            callback(quintupleDic)
        }
    }
    
    /*
    发送同步消息,调用此方法，会通知networkkey下面所有设备上报状态
    @param networkKey
    */
    public func sendSyncMessage(networkKey: String) {
        let parameters = String(format: "%04X", UInt16(bigEndian: 0x0001).littleEndian) + "01" + "0200" //延迟2s
        self.sendGroupMessage(address: "D002", opCode: VendorMessageOpCode.VendorMessage_Attr_Sync.rawValue, message: parameters, networkKey: networkKey)
    }
    
    /*设备重启
     @param uuid 设备唯一标识/mac地址
    */
    public func rebootDevice(uuid: String) {
        let attrStr = String(format: "%04X", UInt16(bigEndian: 0x0006).littleEndian) + "00000000"
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr, retryCount:0, callback: nil)
    }
    
    /*
    获取固件版本号
    @param uuid 设备的uuid/mac地址
    @callbackString 如1.0.0
    */
    public func fetchDeviceFirmwareVersion(uuid: String, callback: @escaping FetchDeviceFirmwareVersionCallback) {
        let attrStr =  String(format: "%04X", UInt16(bigEndian: 0x0005).littleEndian)
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Get.rawValue, uuid: uuid, message: attrStr, retryCount:0, timeout: 2) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback("")
                return
            }
            var version = ""
            if attrStr.count >= 10 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                
                let frist_range = attrValue.index(attrValue.startIndex, offsetBy: 0)..<attrValue.index(attrValue.startIndex, offsetBy: 1*2)
                let frist_value = Int(String(attrValue[frist_range]), radix: 16)
                version = version + String(frist_value!) + "."
                
                let mind_range = attrValue.index(attrValue.startIndex, offsetBy: 1*2)..<attrValue.index(attrValue.startIndex, offsetBy: 2*2)
                let mind_value = Int(String(attrValue[mind_range]), radix: 16)
                version = version + String(mind_value!) + "."
                
                let last_range = attrValue.index(attrValue.startIndex, offsetBy: 2*2)..<attrValue.index(attrValue.startIndex, offsetBy: 3*2)
                let last_value = Int(String(attrValue[last_range]), radix: 16)
                version = version + String(last_value!)
            }
            callback(version)
        }
    }
    
    /*
    模拟设备执行操作,上报一条消息
    @param opCodeString设备物理按键对应的attrType
    @param opValue String 设备物理按键执行对应的attrValue
    @param uuid 设备的uuid/mac地址
    @param networkkey
    @param repeatNum 执行次数
    */
    public func simulateDeviceOperation(opCode: String,opValue: String,uuid: String, elementIndex: Int = 0, networkKey: String, repeatNum: Int) {
        guard let hexToInt = UInt16(opCode, radix: 16) else {
            return
        }
        let attrType = UInt16(bigEndian: (hexToInt | 0x8000)) //位运算将最高位bit15变成1
        let parameters = String(format: "%04X", attrType.littleEndian) + opValue
        self.sendGroupMessage(address: "D003", opCode: VendorMessageOpCode.VendorMessage_Attr_Status.rawValue, uuid: uuid, elementIndex: elementIndex, message: parameters, networkKey: networkKey, repeatNum: repeatNum)
    }
    
    /*执行虚拟按钮
    @param vid 虚拟按钮ID
    @param networkKey
    @param repeatNum 执行次数
    */
    public func triggerVirtualButton(vid: String, networkKey: String, repeatNum: Int) {
        let attrType = UInt16(bigEndian: (0x0007 | 0x8000)) //位运算将最高位bit15变成1
        let parameters = String(format: "%04X", attrType.littleEndian) + vid
        self.sendGroupMessage(address: "D003", opCode: VendorMessageOpCode.VendorMessage_Attr_Status.rawValue, uuid: nil, message: parameters, networkKey: networkKey, repeatNum: repeatNum)
    }
    
    /*
    给设备发送联动规则
    @param uuid 设备的uuid/mac地址
    @param rule 联动规则指令
    @callback Bool 成功或者失败
    默认超时时间为5秒
    */
    public func writeLinkageRulesToDevice(uuid: String, rule: String, callback: @escaping SendCommandCallback) {
        let attrType = UInt16(bigEndian: 0x0004)
        let attrStr = String(format: "%04X", attrType.littleEndian) + rule
        let ruleCount = rule.count/32
        let time = max(5.0, 1.5*Double(ruleCount))
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr, retryCount:0, timeout: time) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
    
    /*
    给设备发送联动规则V2
    @param uuid 设备的uuid/mac地址
    @param rule 联动规则指令
    @param ruleId 当前规则的ID
    @callback Bool 成功或者失败
    默认超时时间为5秒
    */
    public func writeRules(uuid: String,  ruleId: Int, rule: String = "", callback: @escaping SendCommandCallback) {
        let attrType = UInt16(bigEndian: 0x0017)
        let attrStr = String(format: "%04X", attrType.littleEndian) + (rule.count > 0 ? "00" : "01") + String(format: "%02X", ruleId) + rule
        let time = 5.0
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr, retryCount:0, timeout: time) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
    
    /*
     发送wifi密码给设备
     @param  uuid 设备uuid/mac地址
     @param  ssid 连接Wi-Fi的ssid
     @param  password 连接Wi-Fi的密码
     @callback  Bool
     @mark  底层消息的callback会多次回调，会返回Wi-Fi连接中的状态
     */
    public func sendWiFiPasswordToDevice(uuid: String, ssid: String, password: String, callback: @escaping WiFiConfigStatusCallback) {
        // Generate an End Data
        
        let endData = Data.init([0x00])
        
        let ssidData = ssid.data(using: .utf8, allowLossyConversion: true)
        let passwordData = password.data(using: .ascii, allowLossyConversion: true)
        
        // Generate the final Data to pass, now it just has ssid data
        var finalData = ssidData
        
        // Append end data after ssid data
        finalData?.append(endData)
        
        // Append password data after end data
        finalData?.append(passwordData!)
        
        // Append end data after password
        finalData?.append(endData)
        
        let attrType = UInt16(bigEndian: 0x0011)
        var valueData = Data(hex: String(format: "%04X", attrType.littleEndian))
        valueData.append(finalData!)
        print("发送的密码hex = \(valueData.hex)")
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: valueData, retryCount: 0, timeout: 30, isHoldCallback: true) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrType = attrStr.prefix(4)
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if attrType == "1300" {
                    let status = UInt8(attrValue, radix: 16)! & 0x03  //位运算只取bit0和bit1
                    if status > 0 {
                        callback(status == 1 ? true : false)
                        if let tid = result["tid"] as? String {
                            self.meshMessageDict.removeValue(forKey: tid+uuid)
                        }
                    }
                }
            }
        }
    }
    
    /*
    设备添加进组
    @param uuid 设备的uuid/mac地址
    @param groups 群组信息
    */
    public func groupAddDevice(uuid:String, groups:[[String : Any]]? = nil, callback: @escaping SendCommandCallback) {
        let attrType = UInt16(bigEndian: 0x000D)
        var attrStr = String(format: "%04X", attrType.littleEndian)
        if let list = groups {
            list.forEach { (item:[String : Any]) in
                if let service = item["service"] as? Int,
                    let address = item["address"] as? String,
                    let isMaster = item["isMaster"] as? Bool {
                    let groupStr = (isMaster ? "1" : "0") + String(format: "%X", service) + hexToBigEndian(hex: address)
                    attrStr.append(groupStr)
                }
            }
        }
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr, retryCount:0) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
    /*
    群组删除设备
    @param uuid 设备的uuid/mac地址
    @param groups 群组信息
    */
    public func groupDeleteDevice(uuid:String, groups:[[String : Any]]? = nil,  callback: @escaping SendCommandCallback) {
        let attrType = UInt16(bigEndian: 0x000E)
        var attrStr = String(format: "%04X", attrType.littleEndian)
        if let list = groups {
            list.forEach { (item:[String : Any]) in
                if let service = item["service"] as? Int,
                    let address = item["address"] as? String,
                    let isMaster = item["isMaster"] as? Bool {
                    let groupStr = (isMaster ? "1" : "0") + String(format: "%X", service) + hexToBigEndian(hex: address)
                    attrStr.append(groupStr)
                }
            }
        }
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr, retryCount:0) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
    /*
    清除设备群组设置
    @param uuid 设备的uuid/mac地址
    */
    public func resetDeviceGroupSetting(uuid:String, groups:[[String : Any]]? = nil, callback: @escaping SendCommandCallback) {
        let attrType = UInt16(bigEndian: 0x000F)
        var attrStr = String(format: "%04X", attrType.littleEndian)
        if let list = groups {
            list.forEach { (item:[String : Any]) in
                if let service = item["service"] as? Int,
                    let address = item["address"] as? String,
                    let isMaster = item["isMaster"] as? Bool {
                    let groupStr = (isMaster ? "1" : "0") + String(format: "%X", service) + hexToBigEndian(hex: address)
                    attrStr.append(groupStr)
                }
            }
        }
        self.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuid, message: attrStr, retryCount:0) { (result: [String : Any]) in
            guard  let attrStr = result["message"] as? String else {
                callback(false)
                return
            }
            if attrStr.count > 4 {
                let attrValue = String(attrStr.suffix(attrStr.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    callback(true)
                    return
                }
            }
            callback(false)
        }
    }
}
