//
//  MeshSDK+NetworkKey.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/6/9.
//

import Foundation
import nRFMeshProvision
import CoreBluetooth

// MARK: - Network Key Components
extension MeshSDK {
    /*
    获取mesh中所有的newtwokkey
    @return Array<String *>
    */
    public func getAllNetworkKey() -> [String] {
        let networkKeys = meshNetworkManager.meshNetwork!.networkKeys
        return networkKeys.map { $0.key.hex }
    }
    
    /*
    获取networkkey对象
    @param networkKey
    */
    func getNetworkKey(networkKey: String) -> NetworkKey? {
        for nk in meshNetworkManager.meshNetwork!.networkKeys {
            if nk.key.hex == networkKey.uppercased() {
                return nk
            }
        }
        return nil
    }
    
    /*
    检查networkKey是否存在
    @param networkKey
    */
    public func isNetworkKeyExists(networkKey: String) -> Bool {
        for nk in meshNetworkManager.meshNetwork!.networkKeys {
            if nk.key.hex == networkKey.uppercased() {
                return true
            }
        }
        return false
    }
    
    /*
    创建networkkey
    @param key Hex十六进制的字符串
    @param appKey Hex十六进制的字符串
    @return Bool
    */
    public func createNetworkKey(key: String, appKey: String?) -> Bool {
        let data = Data(hex: key)
        var appKeyData : Data!
        if appKey != nil {
            let akIsExist = self.isApplicationKeyExists(appKey: appKey!)
            if akIsExist {
                return false
            }
            let applicationKeyData = Data(hex: appKey!)
            appKeyData = applicationKeyData
        } else {
            appKeyData = Data.random128BitKey()
        }
        let network = meshNetworkManager.meshNetwork!
        var networkKey = self.getNetworkKey(networkKey: key)
        if networkKey == nil {
            let index = network.networkKeys.count
            networkKey = try? network.add(networkKey: data, name: "NetworkKey \(index)")
        }
        
        let applicationKeyCount = network.applicationKeys.count
        let applicationKey = try? network.add(applicationKey: appKeyData, name: String("App Key \(applicationKeyCount+1)"))
        if let nk = networkKey, let ak = applicationKey {
            try? ak.bind(to: nk)
        }
        return meshNetworkManager.save()
    }
    
    /*
    创建networkkey
    @param key Hex十六进制的字符串
    @return Bool
    */
    public func createNetworkKey(key: String) -> Bool {
        let data = Data(hex: key)
        let network = meshNetworkManager.meshNetwork!
        let index = network.networkKeys.count

        _ = try? network.add(networkKey: data, name: "NetworkKey \(index)")
        if meshNetworkManager.save() {
            if self.createApplicationKey(networkKey: key) { //创建app key
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    /*
    删除networkkey
    @param key HexString十六进制的字符串
    @return Bool
    */
    public func deleteNetworkKey(key: String) -> Bool {
        let network = meshNetworkManager.meshNetwork!
        
        for nw in network.networkKeys where nw.key.hex == key {
            let removeNKIndex = nw.index
            _ = try? network.remove(networkKey: nw)
            for ak in network.applicationKeys where ak.boundNetworkKeyIndex == removeNKIndex {
                _ = try? network.remove(applicationKey: ak)
            }
            if meshNetworkManager.save() {
                return true
            } else {
                return false
            }
        }
        return false
    }
    /*
     设置当前的networkkey
     @param key HexString  十六进制的字符串
     */
    public func setCurrentNetworkKey(key: String) {
        for nk in meshNetworkManager.meshNetwork!.networkKeys {
            if nk.key.hex == key.uppercased() {
                currentNetworkKey = nk.key.hex
            }
        }
    }
    /*
     获取当前的networkkey
     @return HexString  十六进制的字符串
     */
    public func getCurrentNetworkKey() -> String {
        let defaultCurrentNetworkKey = meshNetworkManager.meshNetwork?.networkKeys.first?.key.hex
        return (currentNetworkKey ?? defaultCurrentNetworkKey) ?? ""
    }
    
    func getNetworkKeyIndex(networkKey: String) -> KeyIndex? {
        for nk in meshNetworkManager.meshNetwork!.networkKeys {
            if nk.key.hex == networkKey.uppercased() {
                return nk.index
            }
        }
        return nil
    }
}

// MARK: - Application Key
extension MeshSDK {
    /*
    创建appkey
    @param networkKey String
    */
    func createApplicationKey(networkKey: String) -> Bool {
        let applicationKeyData = Data.random128BitKey()
        let networkKeys = meshNetworkManager.meshNetwork!.networkKeys
        let network = meshNetworkManager.meshNetwork!
        
        let applicationKeyCount = network.applicationKeys.count
        let applicationKey = try? network.add(applicationKey: applicationKeyData, name: String("App Key \(applicationKeyCount+1)"))
        var boundToNetworkKey: NetworkKey
        for nw in networkKeys {
            if nw.key.hex == networkKey {
                boundToNetworkKey = nw
                if let ak = applicationKey {
                    try? ak.bind(to: boundToNetworkKey)
                }
            }
        }
        if meshNetworkManager.save() {
            return true
        } else {
            return false
        }
    }
    
    /*
     获取network下面所有的appkey
     @param networkKey String
     */
    public func getAllApplicationKey(networkKey: String) -> [String] {
        let applicationKeys = meshNetworkManager.meshNetwork?.applicationKeys
        let networkKeys = meshNetworkManager.meshNetwork?.networkKeys
        guard let boundedNetworkKey = networkKeys?.first(where: { (item) -> Bool in
            return item.key.hex == networkKey.uppercased()
        }) else { return [] }
        let applicationKeysInNetwork = (applicationKeys?.filter({ (item) -> Bool in
            return item.isBound(to: boundedNetworkKey)
        }))!
        var keys:[String] = []
        for applicationKey in applicationKeysInNetwork {
            keys.append(applicationKey.key.hex)
        }
        return keys
    }
    /*
    移除appkey
    @param networkKey String
    @param appKey String
    */
    private func deleteApplicationKey(appKey: String, networkKey: String) {
        let network = meshNetworkManager.meshNetwork!
        var toDeleteAppKey: ApplicationKey
        for ak in network.applicationKeys {
            if ak.key.hex == appKey {
                toDeleteAppKey = ak
                // 进行删除操作
                if toDeleteAppKey.isUsed(in: network) {
                    return
                } else {
                    try? network.remove(applicationKey: toDeleteAppKey)
                    if !meshNetworkManager.save() {
                        // 删除失败
                    }
                }
            }
        }
    }
    
    /*
    检查networkKey是否存在
    @param networkKey
    */
    func isApplicationKeyExists(appKey: String) -> Bool {
        for ak in meshNetworkManager.meshNetwork!.applicationKeys {
            if ak.key.hex == appKey.uppercased() {
                return true
            }
        }
        return false
    }
    
    func getApplicationKeyIndex(appKey: String) -> KeyIndex? {
        for ak in meshNetworkManager.meshNetwork!.applicationKeys {
            if ak.key.hex == appKey.uppercased() {
                return ak.index
            }
        }
        return nil
    }
}
