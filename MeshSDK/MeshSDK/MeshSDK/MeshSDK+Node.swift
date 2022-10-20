//
//  MeshSDK+Node.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/6/9.
//

import Foundation
import nRFMeshProvision
import CoreBluetooth

extension MeshSDK {
    
    func lookupNode(uuid: String) -> Node? {
        let newUuid = uuid.uppercased().replacingOccurrences(of: ":", with: "");
        let network = meshNetworkManager.meshNetwork!
        for node in network.nodes where node.uuid.uuidString == newUuid || self.getNodeMacAddress(uuid: node.uuid.uuidString) == newUuid {
            return node
        }
        return nil
    }
    
    /*
    添加节点\节点移动
    @params jsonObject
    */
    public func addNode(jsonObject: Dictionary<String,Any>) -> Bool {
        var dict = jsonObject
        guard let appKeys = dict["appKeys"] as? Array<Dictionary<String,Any>> else {
            return false
        }
        var newAppKeys = Array<[String : Any]>()
        var newNKs = Array<[String : Any]>()
        for keyDict in appKeys {
            if let ak = keyDict["key"] as? String, let nk = keyDict["netKey"] as? String {
                var nk_dict = [String : Any]()
                var ak_dict = [String : Any]()
                if  let nkIndex = self.getNetworkKeyIndex(networkKey: nk)  {
                    nk_dict["index"] = nkIndex
                    nk_dict["updated"] = false
                }
                
                if  let akIndex = self.getApplicationKeyIndex(appKey: ak)  {
                    ak_dict["index"] = akIndex
                    ak_dict["updated"] = false
                }
                
                if ak_dict.count > 0 && ak_dict.count > 0 {
                    newAppKeys.append(ak_dict)
                    newNKs.append(nk_dict)
                }
            }
        }
        
        if newAppKeys.count > 0 && newNKs.count > 0 {
            dict["appKeys"] = newAppKeys
            dict["netKeys"] = newNKs
        }
        
        var modelBind = Array<KeyIndex>()
        for ak in newAppKeys {
            modelBind.append(ak["index"] as! KeyIndex)
        }
        
        let model_cid = String(format: "%04X0000", self.companyId)
        var newElements = Array<[String : Any]>()
        if let elements =  dict["elements"] as? Array<[String : Any]> {
            for element  in elements {
                var elementDict = element
                var newModels = Array<[String : Any]>()
                if let models = elementDict["models"] as? Array<[String : Any]> {
                    for model in models {
                        var modelDict = model
                        var bindList = [KeyIndex]()
                        if let modelId = modelDict["modelId"] as? String, modelId == model_cid {
                            if let mbList = modelDict["bind"] as? Array<String> {
                                bindList = self.fetchModelBind(mbList)
                            }
                        }
                        if bindList.count <= 0 {
                            bindList = modelBind
                        }
                        modelDict["bind"] = bindList
                        modelDict["subscribe"] = []
                        newModels.append(modelDict)
                    }
                    elementDict["models"] = newModels
                } else {
                    var modelDict = [String : Any]()
                    modelDict["bind"] = modelBind
                    modelDict["modelId"] = model_cid
                    modelDict["subscribe"] = []
                    newModels.append(modelDict)
                }
                elementDict["models"] = newModels
                elementDict["index"] = element["index"] ?? newElements.count
                newElements.append(elementDict)
            }
            
        } else {
            var elementDict = [String : Any]()
            var newModels = Array<[String : Any]>()
            
            var modelDict = [String : Any]()
            modelDict["bind"] = modelBind
            modelDict["modelId"] = model_cid
            modelDict["subscribe"] = []
            newModels.append(modelDict)
            
            elementDict["models"] = newModels
            elementDict["index"] = 0
            elementDict["location"] = "0000"
            
            newElements.append(elementDict)
        }
        dict["elements"] = newElements
        if let cid = dict["cid"] as? String, cid.count > 0 {
            
        } else {
            dict["cid"] = String(format: "%04X", self.companyId)
        }
        print("nodeinfo = \(dict)")
        guard let jsonData: Data = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.fragmentsAllowed) else {
            return false
        }
        
        guard let newNode = try? JSONDecoder().decode(Node.self, from: jsonData) else {
            return false
        }
        if let node = lookupNode(uuid: newNode.uuid.uuidString) {
            if node.unicastAddress == newNode.unicastAddress {
                return true
            }
            meshNetworkManager.meshNetwork!.remove(node: node)
        }
        let network = meshNetworkManager.meshNetwork!
        try? network.add(node: newNode)
        return meshNetworkManager.save()
    }
    
    //同步model绑定关系
    func fetchModelBind(_ appKeys: Array<Any>) -> Array<KeyIndex> {
        var list = Array<KeyIndex>()
        for appKey in appKeys {
            if let ak = appKey as? String  {
                if  let akIndex = self.getApplicationKeyIndex(appKey: ak)  {
                    list.append(akIndex)
                }
            }
        }
        return list
    }
    
    /*
    删除节点
    @param uuid String 设备的uuid
    */
    public func deleteNode(uuid: String) -> Bool {
        if let node = lookupNode(uuid: uuid) {
            meshNetworkManager.meshNetwork!.remove(node: node)
            return meshNetworkManager.save()
        }
        return false
    }
    
    /*
    重置设备
    @param uuid String 设备的uuid
    */
    public func resetNode(uuid: String) {
        if let node = lookupNode(uuid: uuid) {
            if connection.currentBearerName == node.name {
                isConnectedDirectly = true
            }
            
            let message = ConfigNodeReset()
            let msgOperation = BlockOperation {
                DispatchQueue.main.async {
                    _ = try? self.meshNetworkManager.send(message, to: node)
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
            self.sendMessageQueue.addOperation(msgOperation)
        }
    }
    /*
    获取当前mesh网络所有的设备uuid（用于节点同步，删除脏数据）
    @return Array<String>  设备UUID的数组
    */
    public func fetchAllNodeUUID() -> Array<String> {
        var allNodeUUID = Array<String>()
        var currentMeshNodes = meshNetworkManager.meshNetwork!.nodes
        if currentMeshNodes.count > 0 {
            currentMeshNodes.remove(at: 0)
        }
        for node in currentMeshNodes {
            allNodeUUID.append(node.uuid.uuidString)
        }
        return allNodeUUID
    }
    
    /*
     获取设备的mesh address
     @param uuid  设备唯一标识
     @return HexString
     */
    public func getNodeAddress(uuid: String) -> String {
        if let node = lookupNode(uuid: uuid) {
            return node.unicastAddress.hex
        }
        return ""
    }
    
    /*
     通过mac地址获取设备的uuid
     @param mac  设备mac地址（不带冒号）
     @return  String
     */
    public func getNodeUUID(mac: String) -> String? {
        let network = meshNetworkManager.meshNetwork!
        let newMac = mac.replacingOccurrences(of: ":", with: "")
        for node in network.nodes where self.getNodeMacAddress(uuid: node.uuid.uuidString) == newMac.uppercased() {
            return node.uuid.uuidString
        }
        return nil
    }
    
    /*
     通过mesh address获取设备的element
     @param address  HexString
     @return  Element
     */
    func getNodeElement(address: String) -> Element? {
      let network = meshNetworkManager.meshNetwork!
        for node in network.nodes {
            for element in node.elements {
                if element.unicastAddress.asString() == address {
                    return element
                }
            }
        }
        return nil
    }
    
    /*
     获取node的JsonObject
     @param uuid String 设备的uuid
     @return Dictionary JsonObject
     */
    public func getNodeInfo(uuid: String) -> Dictionary<String, Any>? {
        if let node = lookupNode(uuid: uuid) {
            return self.mx_objectKeyValue(node: node)
        }
        return nil
    }
    
    /*
     node转Dictionary
     @param Node 设备节点
     @return Dictionary JsonObject
     */
    private func mx_objectKeyValue(node: Node) -> [String:Any]? {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(node) else {
            return nil
        }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] else {
            return nil
        }
        return dict
    }
    /*
     jsonString转Dictionary
     @param jsonString
     @retrun Dictionary
     */
    private func mx_jsonKeyValue(jsonString: String) -> Dictionary<String, Any>? {
        let jsonData:Data = jsonString.data(using: .utf8)!
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String:Any] else {
            return nil
        }
        return dict
    }
}
