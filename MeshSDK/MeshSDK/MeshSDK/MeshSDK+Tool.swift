//
//  MeshSDK+Tool.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/1/13.
//

import Foundation

extension MeshSDK {
    //Mark uint16大小端转换
    public func hexToBigEndian(hex: String) -> String {
        if hex.count == 4 {
            if let hexToInt = UInt16(hex, radix: 16) {
                let value = UInt16(littleEndian: hexToInt)
                let newStr =  String(format: "%0\(hex.count)X", value.bigEndian)
                return newStr
            }
        }

//        else if hex.count == 8 {
//            let hexToInt = UInt32(hex, radix: 16)
//            let value = UInt32(littleEndian: hexToInt!)
//            let newStr =  String(format: "%0\(hex.count)X", value.bigEndian)
//            return newStr
//        } else if hex.count == 16 {
//            let hexToInt = UInt64(hex, radix: 16)
//            let value = UInt64(littleEndian: hexToInt!)
//            let newStr =  String(format: "%0\(hex.count)X", value.bigEndian)
//            return newStr
//        }
        return hex
    }
    
    /*
     获取FeatureFlag来判断是否支持只获取dn
     */
    public func getFeatureFlag(uuid: String) -> UInt8 {
        let uuidStr = uuid.replacingOccurrences(of: "-", with: "")
        let uuidBytes = [UInt8](Data(hex: uuidStr))
        guard uuidBytes.count == 16 else {
            return 0
        }
        return uuidBytes[13]
    }
    
    /*
     判断是否是MX的设备
     */
    public func isMxchipDevice(uuid: String) -> Bool {
        let uuidStr = uuid.replacingOccurrences(of: "-", with: "")
        let uuidBytes = [UInt8](Data(hex: uuidStr))
        guard uuidBytes.count == 16 else {
            return false
        }
        let cidStr = String(format: "%02X%02X", uuidBytes[1],uuidBytes[0])
        return UInt16(cidStr, radix: 16) == self.companyId
        
    }
    /*
    通过uuid获取设备的mac地址
    @param uuid 设备的uuid
    @return String设备的mac地址（不带冒号分开的）
    */
    func getNodeMacAddress(uuid: String) -> String {
        let uuidStr = uuid.replacingOccurrences(of: "-", with: "")
        let uuidBytes = [UInt8](Data(hex: uuidStr))
        guard uuidBytes.count == 16 else {
            return ""
        }
        let macStr = String(format: "%02x%02x%02x%02x%02x%02x", uuidBytes[12],uuidBytes[11],uuidBytes[10],uuidBytes[9],uuidBytes[8],uuidBytes[7])
        return macStr
    }
    /*
    通过uuid获取设备的mac地址
    @param uuid 设备的uuid
    @return String设备的mac地址（带冒号分开的）
    */
    public func getDeviceMacAddress(uuid: String) -> String {
        let uuidStr = uuid.replacingOccurrences(of: "-", with: "")
        let uuidBytes = [UInt8](Data(hex: uuidStr))
        guard uuidBytes.count == 16 else {
            return ""
        }
        let macStr = String(format: "%02x:%02x:%02x:%02x:%02x:%02x", uuidBytes[12],uuidBytes[11],uuidBytes[10],uuidBytes[9],uuidBytes[8],uuidBytes[7])
        return macStr
    }
    
    /*
    通过uuid获取设备的productId
    @param uuid 设备的uuid
    @return Int
    */
    public func getDeviceProductId(uuid: String) -> Int {
        let uuidStr = uuid.replacingOccurrences(of: "-", with: "")
        let uuidBytes = [UInt8](Data(hex: uuidStr))
        guard uuidBytes.count == 16 else {
            return 0
        }
        let productIdStr = String(format: "%02x%02x%02x%02x", uuidBytes[6],uuidBytes[5],uuidBytes[4],uuidBytes[3])
        return Int(productIdStr, radix: 16) ?? 0
    }
    
    public func getCurrentTid() -> String {
        self.tidNum += 1
        if self.tidNum >= 255 {
            self.tidNum = 1
        }
        return String(format: "%02X", self.tidNum)
    }
    
}

// MARK: 获取 TID
extension Date {
    var tid: String {
        let timeInteval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInteval)
        let tid = String(format: "%02X", timeStamp % 255)
        return tid
    }
}

extension Collection {
    var pairs: [SubSequence] {
        var startIndex = self.startIndex
        let count = self.count
        let n = count/2 + count % 2
        return (0..<n).map { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return self[startIndex..<endIndex]
        }
    }
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.dropFirst().reversed()
            where distance(to: index).isMultiple(of: n) {
                insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}
