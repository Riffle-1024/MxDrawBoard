//
//  MeshSDK+ReceiveMessage.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/1/11.
//

import Foundation
import os.log
import nRFMeshProvision
import CoreBluetooth

public enum VendorMessageOpCode : String {
    case VendorMessage_Attr_Get = "10"  //获取设备属性（单播）
    case VendorMessage_Attr_Set = "11"   //设置设备属性（单播）
    case VendorMessage_Attr_Set_Unacknowledged = "12"  //透传消息（无回调）
    case VendorMessage_Attr_Status = "13"   //组播消息
    case VendorMessage_Heartbeat = "14"     //心跳消息
    case VendorMessage_Attr_Sync = "15"     //同步消息
}

public enum MeshMessageSendStatusCode : Int {
    case MeshMessageSendStatus_Success = 0      //成功
    case MeshMessageSendStatus_NoNode = 10001   //未找到节点
    case MeshMessageSendStatus_NoElement = 10002   //未找到element
    case MeshMessageSendStatus_NoModel = 10003   //未找到model
    case MeshMessageSendStatus_NoAppKey = 10004   //未找到appkey
    case MeshMessageSendStatus_NetworkKey_UnbindAppKey = 10005   //networkKey未绑定appkey
    case MeshMessageSendStatus_timeout = 20001   //超时
}

// MARK: 2.0 版本用来解析设备上报状态
extension MeshSDK: MeshNetworkDelegate {
    /*
     发送消息
     @param opCode String 发送的消息opCode "10" 单播获取 "11" 单播设置 "12" 透传消息（无回调） "13" 状态上报消息 "14" 心跳消息 "15" 同步消息
     @param uuid  String  设备的uuid/mac地址
     @param elementIndex Int element下标
     @param Tid  String  消息唯一标识，默认不要传
     @param message  data或者Hex  消息内容（例如000101）
     @param retryCount Int  重发次数  默认0，不重发
     @param timeout TimeInterval  超时时间 默认1秒
     @param isHoldCallback Bool 是否持续回调，默认false
     @callback String
     */
    public func sendMeshMessage(opCode: String, uuid: String, elementIndex: Int = 0, Tid: String? = nil, message: Any, retryCount: Int = 0, timeout: TimeInterval = 1.0, isHoldCallback:Bool = false, networkKey:String? = nil, callback: MeshMessageCallBack? = nil) {
        guard let node = lookupNode(uuid: uuid)  else {
            print("not find device")
            var dict = [String : Any]()
            dict["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_NoNode.rawValue
            callback?(dict)
            return
        }
        if elementIndex >= node.elements.count {
            print("not finf element")
            var dict = [String : Any]()
            dict["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_NoElement.rawValue
            callback?(dict)
            return
        }
        let element = node.elements[elementIndex]
        
        print("send message: \(message)")
        let tid = Tid ?? self.getCurrentTid()
        
        let msgKey = tid+node.uuid.uuidString
        
        let timeOutStamp = Date().timeIntervalSince1970 + timeout
        var msgDict = [String : Any]()
        if opCode == "10" || opCode == "11" {
            msgDict["opCode"] = opCode
            msgDict["uuid"] = node.uuid.uuidString
            msgDict["elementIndex"] = elementIndex
            msgDict["retryCount"] = retryCount
            msgDict["tid"] = tid
            msgDict["message"] = message
            msgDict["timeout"] = timeout
            msgDict["timeOutStamp"] = timeOutStamp
            msgDict["isHoldCallback"] = isHoldCallback
            if callback != nil {
                msgDict["callback"] = callback
            }
        }
        
        var parameters = Data(hex:"\(tid)")
        if let attrHex = message as? String {
            let attrData = Data(hex: attrHex)
            parameters.append(attrData)
        } else if let attrData = message as? Data {
            parameters.append(attrData)
        }
        meshNetworkManager.delegate = self
        
        for model in element.models where model.companyIdentifier == self.companyId {
            var message = RuntimeVendorMessage(opCode: UInt8(opCode, radix: 16)!, for: model, parameters: parameters)
            message.isSegmented = self.isSegmented
            if networkKey == nil {
                // 将新任务加入任务队列，顺序执行任务
                if msgDict.count > 0 {
                    msgDict["status"] = 1
                    self.meshMessageDict[msgKey] = msgDict
                }
                let msgOperation = BlockOperation {
                    DispatchQueue.main.async {
                        _ = try? self.meshNetworkManager.send(message, to: model)
                        self.checkMeshSequencesStatus()
                    }
                    let bytesArray = [UInt8](message.parameters!)
                    var count: Int = bytesArray.count/8
                    if bytesArray.count % 8 > 0 {
                        count += 1
                    }
                    let delayTime = Double(count) * self.messageDuration
                    print("send message：\(String(describing: message.parameters?.toHexString()))，message space：\(delayTime)")
                    Thread.sleep(forTimeInterval: delayTime)
                }
                self.sendMessageQueue.addOperation(msgOperation)
            } else {
                guard let applicationKey = getAllApplicationKey(networkKey: networkKey!.uppercased()).first else {
                    print("[MeshSDK] Error: networkKey is not any Application Key")
                    var dict = [String : Any]()
                    dict["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_NetworkKey_UnbindAppKey.rawValue
                    callback?(dict)
                    return
                }
                for appKey in meshNetworkManager.meshNetwork!.applicationKeys where appKey.key.hex == applicationKey {
                    // 将新任务加入任务队列，顺序执行任务
                    if msgDict.count > 0 {
                        msgDict["status"] = 1
                        self.meshMessageDict[msgKey] = msgDict
                    }
                    let msgOperation = BlockOperation {
                        DispatchQueue.main.async {
                            _ = try? self.meshNetworkManager.send(message, from: element, to: MeshAddress(element.unicastAddress), withTtl: nil, using: appKey)
                            self.checkMeshSequencesStatus()
                        }
                        let bytesArray = [UInt8](message.parameters!)
                        var count: Int = bytesArray.count/8
                        if bytesArray.count % 8 > 0 {
                            count += 1
                        }
                        let delayTime = Double(count) * self.messageDuration
                        print("send message：\(String(describing: message.parameters?.toHexString()))，message space：\(delayTime)")
                        Thread.sleep(forTimeInterval: delayTime)
                    }
                    self.sendMessageQueue.addOperation(msgOperation)
                    return
                }
                var dict = [String : Any]()
                dict["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_NoAppKey.rawValue
                callback?(dict)
            }
            return
        }
        
        var dict = [String : Any]()
        dict["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_NoModel.rawValue
        callback?(dict)
    }
    /*
     发送组播消息
     @param address MeshAddress mesh地址
     @param opCode String 发送的消息opCode "10" 单播获取 "11" 单播设置 "12" 透传消息（无回调） "13" 状态上报消息 "14" 心跳消息 "15" 同步消息
     @param uuid  String  设备的uuid/mac地址（此参数适用于模拟设备消息）
     @param elementIndex element下标（此参数适用于模拟设备消息）
     @param message  String  消息内容（例如000101）
     @param networkKey
     */
    func sendGroupMessage(address:MeshAddress, opCode: String, uuid: String?, elementIndex: Int = 0, Tid: String?, message: Any, networkKey: String) {
        
        print("send message: \(message)")
        
        let tid = Tid ?? self.getCurrentTid()
        var parameters = Data(hex:"\(tid)")
        if let attrHex = message as? String {
            let attrData = Data(hex: attrHex)
            parameters.append(attrData)
        } else if let attrData = message as? Data {
            parameters.append(attrData)
        }
        
        meshNetworkManager.delegate = self
        let network = meshNetworkManager.meshNetwork!
        var fromElement :Element!
        if uuid != nil {
            if let node = lookupNode(uuid: uuid!) {
                if elementIndex < node.elements.count {
                    fromElement = node.elements[elementIndex]
                }
            }
        }
        let applicationKey = getAllApplicationKey(networkKey: networkKey.uppercased()).first
        for appKey in network.applicationKeys where appKey.key.hex == applicationKey {
            let message = MultiCastVendorMessage(opCode: UInt8(opCode, radix: 16)!, parameters: parameters)
            let msgOperation = BlockOperation {
                DispatchQueue.main.async {
                    _ = try? self.meshNetworkManager.send(message, from: fromElement, to: address, withTtl: nil, using: appKey)
                    self.checkMeshSequencesStatus()
                }
                let bytesArray = [UInt8](message.parameters!)
                var count: Int = bytesArray.count/8
                if bytesArray.count % 8 > 0 {
                    count += 1
                }
                let delayTime = Double(count) * self.messageDuration
                print("send message ：\(String(describing: message.parameters?.toHexString()))，message space：\(delayTime)")
                Thread.sleep(forTimeInterval: delayTime)
            }
            self.sendMessageQueue.addOperation(msgOperation)
            return
        }
    }
    
        
    /*
    发送组播消息
    @param address String mesh地址
    @param opCode String 发送的消息opCode "10" 单播获取 "11" 单播设置 "12" 透传消息（无回调） "13" 状态上报消息 "14" 心跳消息 "15" 同步消息
    @param uuid 设备的uuid/mac地址（此参数适用于模拟设备消息）
    @param elementIndex element下标（此参数适用于模拟设备消息）
    @param message 消息内容（例如000101）
    @param networkKey
    @param repeatNum 发送次数，默认1次
    */
    public func sendGroupMessage(address: String, opCode: String, uuid: String? = nil, elementIndex: Int = 0, message: Any, networkKey: String, repeatNum: Int = 1)  {
        guard let meshAddress = MeshAddress(hex: address) else { return }
        
        let tid = self.getCurrentTid()
        let count = repeatNum > 1 ? repeatNum : 1
        for _ in 0..<count {
            // 将新任务加入任务队列，顺序执行任务
            self.sendGroupMessage(address: meshAddress, opCode: opCode, uuid: uuid, elementIndex: elementIndex, Tid: tid, message: message,networkKey: networkKey)
        }
    }
    //检查seq是否需要通知业务更新到云端
    func checkMeshSequencesStatus() {
        let seq = self.getMeshNetworkSequence()
        if self.currentSeq == 0 {
            self.currentSeq = seq
        }
        
        if seq >= self.currentSeq + self.seqUpdateInterval ||  seq < self.currentSeq {
            self.meshSequenceUpdateCallback?()
            self.currentSeq = seq
        }
    }
    
    public func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: Address) {
        switch message {
        case is ConfigNodeResetStatus:
            if self.isConnectedDirectly { //重置了当前直连的设备，需要重新连接mesh
                self.disconnect()
                self.connect()
                self.isConnectedDirectly = false
            }
            break
        case is ConfigCompositionDataStatus:
            print("[MeshSDK]: Composition Data Status Complete, 这会使得我们能获取 Element ")
            configCompositionDataStatusCB?(true)
            configCompositionDataStatusCB = nil
            break
        case is ConfigDefaultTtlStatus:
            print("[MeshSDK]: TTL 获取成功");
            getTTLCallback?(true)
            getTTLCallback = nil
            break
        case is ConfigAppKeyStatus:
            print("[MeshSDK] node appkey index = \((message as! ConfigAppKeyStatus).applicationKeyIndex)")
            guard let element = getNodeElement(address: String(format: "0x%04X", source)) else {
                print("根据地址未找到element")
                return
            }
            guard let node = element.parentNode else {
                print("未找到element的node")
                return
            }
            if self.deleteApplicationKeyForNodeCallback != nil {
                node.remove(networkKeyWithIndex: (message as! ConfigAppKeyStatus).networkKeyIndex)
                node.remove(applicationKeyWithIndex: (message as! ConfigAppKeyStatus).applicationKeyIndex)
                for ele in node.elements {
                    for model in ele.models where model.companyIdentifier == self.companyId {
                        model.unbind(applicationKeyWithIndex: (message as! ConfigAppKeyStatus).applicationKeyIndex)
                    }
                }
                _ = meshNetworkManager.save()
                self.deleteApplicationKeyForNodeCallback?(true)
                self.deleteApplicationKeyForNodeCallback = nil
                
            } else {
                node.add(networkKeyWithIndex: (message as! ConfigAppKeyStatus).networkKeyIndex)
                node.add(applicationKeyWithIndex: (message as! ConfigAppKeyStatus).applicationKeyIndex)
                for ele in node.elements {
                    for model in ele.models where model.companyIdentifier == self.companyId {
                        model.bind(applicationKeyWithIndex: (message as! ConfigAppKeyStatus).applicationKeyIndex)
                    }
                }
                _ = meshNetworkManager.save()
                self.applicationKeyStatusForNodeCallback?(true)
                applicationKeyStatusForNodeCallback = nil
            }
            break
        case is ConfigModelAppList:
            print("[MeshSDK] model app list = \((message as! ConfigModelAppList).applicationKeyIndexes)")
            advBindApplicationKeyCallback?(true)
            break
        case is ConfigModelSubscriptionList:
            advSubscriptionCallback?(true)
            advSubscriptionCallback = nil
            break
        case is ConfigModelPublicationStatus:
            advPublicationsCallback?(true)
            advPublicationsCallback = nil
            break
        default:
            guard let element = getNodeElement(address: String(format: "0x%04X", source)) else {
                print("根据地址未找到element")
                return
            }
            guard let node = element.parentNode else {
                print("未找到element的node")
                return
            }
            let uuid = node.uuid.uuidString
            let mac = getNodeMacAddress(uuid: uuid)
            let opCode : String = String(format: "%X", message.opCode >> 16)
            self.connectedDeviceHeart[uuid] = Date.init().timeIntervalSince1970 + self.heartTimeout
            let elementIndex: Int = Int(element.index)
            
            if opCode == "D3" || opCode == "D4" {
                var bytesArray = [UInt8](message.parameters!)
                if bytesArray.count < 3 {
                    print("返回的消息长度不对")
                    return
                }
                var attrStr = String()
                let TID = String(format: "%02X", bytesArray[0])
                let fristAttrType = String(format: "%02X%02X", bytesArray[2],bytesArray[1])
                if fristAttrType == "0003" || fristAttrType == "0019" { //五元组
                    let tempString = String.init(data: message.parameters!, encoding: String.Encoding.ascii)
                    attrStr = String((tempString?.suffix(tempString!.count - 1))!)
                } else {
                    //移除tid
                    bytesArray.remove(at: 0)
                    for item in bytesArray {
                        attrStr.append(String(format: "%02X", item))
                    }
                }
                
                var msgParams = [String : Any]()
                msgParams["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_Success.rawValue
                msgParams["message"] = attrStr
                msgParams["elementIndex"] = elementIndex
                
                //消息回调
                if let msgDict = self.meshMessageDict[TID+uuid] as? [String: Any]  {
                    if let isHold = msgDict["isHoldCallback"] as? Bool, isHold  {
                        msgParams["tid"] = TID
                    } else {
                        self.meshMessageDict.removeValue(forKey: TID+uuid)
                    }
                    
                    if let callback = msgDict["callback"] as? MeshMessageCallBack {
                        callback(msgParams)
                    }else {
                        if fristAttrType == "0003" || fristAttrType == "0030" {  //获取5元组的消息不能走订阅回调
                            return
                        }
                        //组播消息回调
                        var callbackParams = [String : Any]()
                        callbackParams[uuid] = msgParams
                        callbackParams[mac] = msgParams
                        self.subscribedMessageCallback?(callbackParams)
                    }
                } else {
                    if fristAttrType == "0003" || fristAttrType == "0030" {  //获取5元组的消息不能走订阅回调
                        return
                    }
                    //组播消息回调
                    var callbackParams = [String : Any]()
                    callbackParams[uuid] = msgParams
                    callbackParams[mac] = msgParams
                    self.subscribedMessageCallback?(callbackParams)
                }
            }
            break
        }
    }
    
    public func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: Address) {
        print("[MeshSDK] message send success")
        guard let node = localElement.parentNode else {
            print("[MeshSDK]  can't  find node")
            return
        }
        let uuid = node.uuid.uuidString
        if message is VendorMessage {
            let bytesArray = [UInt8](message.parameters!)
            if bytesArray.count > 1 {
                let TID = String(format: "%02X", bytesArray[0])
                if var msgDict = self.meshMessageDict[TID+uuid] as? [String: Any]  {
                    msgDict["status"] = 2
                    var timeout = 1.0
                    if let time_out = msgDict["timeout"] as? TimeInterval {
                        timeout = time_out
                    }
                    let timeOutStamp = Date().timeIntervalSince1970 + timeout
                    msgDict["timeOutStamp"] = timeOutStamp
                    self.meshMessageDict[TID+uuid] = msgDict
                }
            }
        }
    }
    
    public func meshNetworkManager(_ manager: MeshNetworkManager, failedToSendMessage message: MeshMessage, from localElement: Element, to destination: Address, error: Error) {
        print("[MeshSDK] send message fail")
        guard let node = localElement.parentNode else {
            print("[MeshSDK] not find node")
            return
        }
        let uuid = node.uuid.uuidString
        if message is VendorMessage {
            let bytesArray = [UInt8](message.parameters!)
            if bytesArray.count > 1 {
                let TID = String(format: "%02X", bytesArray[0])
                if let msgDict = self.meshMessageDict[TID+uuid] as? [String: Any]  {
                    
                    let opCode = msgDict["opCode"] as! String
                    let uuid = msgDict["uuid"] as! String
                    var retryCount = msgDict["retryCount"] as! Int
                    let attr = msgDict["message"] as Any
                    let timeout = msgDict["timeout"] as! TimeInterval
                    let callback = msgDict["callback"] as! MeshMessageCallBack?
                    let tid = msgDict["tid"] as! String
                    let isHoldCallback = (msgDict["isHoldCallback"] as! Bool?) ?? false
                    let elementIdex = msgDict["elementIndex"] as! Int
                    
                    if retryCount > 0 {  //失败，有多次的继续发送
                        retryCount -= 1
                        self.sendMeshMessage(opCode: opCode, uuid: uuid, elementIndex: elementIdex, Tid: tid, message: attr, retryCount: retryCount, timeout: timeout, isHoldCallback: isHoldCallback, callback: callback)
                    } else {  //没有直接返回失败
                        if callback != nil {
                            var msgParams = [String : Any]()
                            msgParams["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_timeout.rawValue
                            msgParams["elementIndex"] = elementIdex
                            callback?(msgParams)
                        }
                        self.meshMessageDict.removeValue(forKey: TID+uuid)
                    }
                }
            }
        }
    }
}
