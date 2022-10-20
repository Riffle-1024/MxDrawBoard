/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

public class Node: Codable {
    internal weak var meshNetwork: MeshNetwork?

    /// The state of a network or application key distributed to a mesh
    /// node by a Mesh Manager.
    public class NodeKey: Codable {
        /// The Key index for this network key.
        public internal(set) var index: KeyIndex
        /// This flag contains value set to `false`, unless a Key Refresh
        /// procedure is in progress and the network has been successfully
        /// updated.
        public internal(set) var updated: Bool
        
        internal init(index: KeyIndex, updated: Bool) {
            self.index   = index
            self.updated = updated
        }
        
        internal init(of key: Key) {
            self.index   = key.index
            self.updated = false
        }
    }
    
    /// The object represents parameters of the transmissions of network
    /// layer messages originating from a mesh node.
    public struct NetworkTransmit: Codable {
        /// Number of transmissions for network messages.
        /// The value is in range from 1 to 8.
        public let count: UInt8
        /// The interval (in milliseconds) between retransmissions
        /// (from 10 to 320 ms in 10 ms steps).
        public let interval: UInt16
        /// Number of 10-millisecond steps between transmissions.
        public var steps: UInt8 {
            return UInt8(interval / 10) - 1
        }
        /// The interval in as `TimeInterval` in seconds.
        public var timeInterval: TimeInterval {
            return TimeInterval(interval) / 1000.0
        }
        
        internal init(fix incorrectNetworkTransmit: NetworkTransmit) {
            self.count = incorrectNetworkTransmit.count
            self.interval = incorrectNetworkTransmit.interval * 10
        }
        
        internal init(_ request: ConfigNetworkTransmitSet) {
            self.count = request.count + 1
            self.interval = UInt16(request.steps + 1) * 10
        }
        
        internal init(_ status: ConfigNetworkTransmitStatus) {
            self.count = status.count + 1
            self.interval = UInt16(status.steps + 1) * 10
        }
    }
    
    /// The object represents parameters of the retransmissions of network
    /// layer messages relayed by a mesh node.
    public struct RelayRetransmit: Codable {
        /// Number of transmissions for relay messages.
        /// The value is in range from 1 to 8.
        public let count: UInt8
        /// The interval (in milliseconds) between retransmissions
        /// (from 10 to 320 ms in 10 ms steps).
        public let interval: UInt16
        /// Number of 10-millisecond steps between transmissions.
        public var steps: UInt8 {
            return UInt8(interval / 10) - 1
        }
        /// The interval in as `TimeInterval` in seconds.
        public var timeInterval: TimeInterval {
            return TimeInterval(interval) / 1000.0
        }
        
        internal init(fix incorrectRelayRetransmit: RelayRetransmit) {
            self.count = incorrectRelayRetransmit.count
            self.interval = incorrectRelayRetransmit.interval * 10
        }
        
        internal init(_ request: ConfigRelaySet) {
            self.count = request.count + 1
            self.interval = UInt16(request.steps + 1) * 10
        }
        
        internal init(_ status: ConfigRelayStatus) {
            self.count = status.count + 1
            self.interval = UInt16(status.steps + 1) * 10
        }
    }
    
    /// Unique Node identifier.
    public let uuid: UUID
    /// Primary Unicast Address of the Node.
    public internal(set) var unicastAddress: Address
    /// 128-bit device key for this Node.
    public let deviceKey: Data?
    /// The level of security for the subnet on which the node has been
    /// originally provisioner.
    public let security: Security
    /// An array of Node Network Key objects that include information
    /// about the Network Keys known to this node.
    internal private(set) var netKeys: [NodeKey]
    /// An array of Node Application Key objects that include information
    /// about the Application Keys known to this node.
    internal private(set) var appKeys: [NodeKey]
    /// The boolean value represents whether the Mesh Manager
    /// has finished configuring this Node. The property is set to `true`
    /// once a Mesh Manager is done completing this node's
    /// configuration, otherwise it is set to `false`.
    public var isConfigComplete: Bool = false {
        didSet {
            meshNetwork?.timestamp = Date()
        }
    }
    /// UTF-8 human-readable name of the node within the network.
    public var name: String? {
       didSet {
           meshNetwork?.timestamp = Date()
       }
   }
    /// The 16-bit Company Identifier (CID) assigned by the Bluetooth SIG.
    /// The value of this property is obtained from node composition data.
    public internal(set) var companyIdentifier: UInt16?
    /// The 16-bit vendor-assigned Product Identifier (PID).
    /// The value of this property is obtained from node composition data.
    public internal(set) var productIdentifier: UInt16?
    /// The 16-bit vendor-assigned Version Identifier (VID).
    /// The value of this property is obtained from node composition data.
    public internal(set) var versionIdentifier: UInt16?
    /// The minimum number of Replay Protection List (RPL) entries for this
    /// node. The value of this property is obtained from node composition
    /// data.
    public internal(set) var minimumNumberOfReplayProtectionList: UInt16?
    /// Node's features. See `NodeFeatures` for details.
    public internal(set) var features: NodeFeaturesState?
    /// This flag represents whether or not the node is configured to send
    /// Secure Network messages.
    public internal(set) var secureNetworkBeacon: Bool? {
       didSet {
           meshNetwork?.timestamp = Date()
       }
   }
    /// The default Time To Live (TTL) value used when sending messages.
    internal var ttl: UInt8? {
        didSet {
            meshNetwork?.timestamp = Date()
        }
    }
    /// The default Time To Live (TTL) value used when sending messages.
    /// The TTL may only be set for a Provisioner's Node, or for a Node
    /// that has not been added to a mesh network.
    ///
    /// Use `ConfigDefaultTtlGet` and `ConfigDefaultTtlSet` messages to read
    /// or set the default TTL value of a remote Node.
    public var defaultTTL: UInt8? {
        set {
            guard meshNetwork == nil || isProvisioner else {
                print("Default TTL may only be set for a Provisioner's Node. Use ConfigDefaultTtlSet(ttl) message to send new TTL value to a remote Node.")
                return
            }
            ttl = newValue
        }
        get {
            return ttl
        }
    }
    /// The object represents parameters of the transmissions of network
    /// layer messages originating from a mesh node.
    public internal(set) var networkTransmit: NetworkTransmit? {
          didSet {
              meshNetwork?.timestamp = Date()
          }
      }
    /// The object represents parameters of the retransmissions of network
    /// layer messages relayed by a mesh node.
    public internal(set) var relayRetransmit: RelayRetransmit? {
          didSet {
              meshNetwork?.timestamp = Date()
          }
      }
    /// An array of node's elements.
    public private(set) var elements: [Element]
    /// The flag is set to `true` when the Node is in the process of being
    /// deleted and is excluded from the new network key distribution
    /// during the key refresh procedure; otherwise is set to `false`.
    public var isExcluded: Bool = false {
         didSet {
             meshNetwork?.timestamp = Date()
         }
     }
    
    /// Returns list of Network Keys known to this Node.
    public var networkKeys: [NetworkKey] {
        return meshNetwork?.networkKeys.knownTo(node: self) ?? []
    }
    /// Returns list of Application Keys known to this Node.
    public var applicationKeys: [ApplicationKey] {
        return meshNetwork?.applicationKeys.knownTo(node: self) ?? []
    }
    
    /// The Heartbeat Publication object represents parameters that define
    /// sending of periodic Heartbeat transport control messages.
    public internal(set) var heartbeatPublication: HeartbeatPublication?
    /// The Heartbeat Subscription object represents parameters that define
    /// receiving of periodical Heartbeat transport control messages.
    public internal(set) var heartbeatSubscription: HeartbeatSubscription?
    
    /// A constructor needed only for testing.
    internal init(name: String?, unicastAddress: Address, elements: UInt8) {
        self.uuid = UUID()
        self.name = name
        self.unicastAddress = unicastAddress
        self.deviceKey = Data.random128BitKey()
        self.security = .secure
        // Default values.
        self.netKeys  = [ NodeKey(index: 0, updated: false) ]
        self.appKeys  = []
        self.elements = []
        
        for _ in 0..<elements {
            add(element: Element(location: .unknown))
        }
    }
    
    /// Initializes the Provisioner's node.
    /// The Provisioner's node has the same name and node UUID as the Provisioner.
    ///
    /// - parameter provisioner: The Provisioner for which the node is added.
    /// - parameter address:     The unicast address to be assigned to the Node.
    internal init(for provisioner: Provisioner, withAddress address: Address) {
        self.uuid = provisioner.uuid
        self.name = provisioner.name
        self.unicastAddress = address
        self.deviceKey = Data.random128BitKey()
        self.security = .secure
        self.ttl = nil
        // iDevice can handle a lot of addresses.
        self.minimumNumberOfReplayProtectionList = Address.maxUnicastAddress
        // A flag that there is no need to perform configuration of
        // a Provisioner's node.
        self.isConfigComplete = true
        // This Provisioner does not support any of those features.
        self.features = NodeFeaturesState(relay: .notSupported,
                                     proxy: .notSupported,
                                     friend: .notSupported,
                                     lowPower: .notSupported)
        
        // Keys will ba added later.
        self.netKeys  = []
        self.appKeys  = []
        // Initialize elements.
        self.elements = []
    }
    
    /// Initializes a Node for given unprovisioned device.
    /// The Node will have the same UUID as the device in the advertising
    /// packet.
    ///
    /// - parameters:
    ///   - unprovisionedDevice: The newly provisioned device.
    ///   - n: Number of Elements on the new Node.
    ///   - deviceKey: The Device Key.
    ///   - networkKey: The Network Key.
    ///   - address: The Unicast Address to be assigned to the Node.
    internal convenience init(for unprovisionedDevice: UnprovisionedDevice,
                              with n: UInt8, elementsDeviceKey deviceKey: Data,
                              andAssignedNetworkKey networkKey: NetworkKey,
                              andAddress address: Address) {
        self.init(name: unprovisionedDevice.name, uuid: unprovisionedDevice.uuid,
                  deviceKey: deviceKey, andAssignedNetworkKey: networkKey,
                  andAddress: address)
        // Elements will be queried with Composition Data.
        // Let's just add n empty Elements to reserve addresses.
        for _ in 0..<n {
            add(element: Element(location: .unknown))
        }
    }
    
    internal init(name: String?, uuid: UUID, deviceKey: Data,
                  andAssignedNetworkKey networkKey: NetworkKey, andAddress address: Address) {
        self.uuid = uuid
        self.name = name
        self.unicastAddress = address
        self.deviceKey = deviceKey
        self.security  = .secure
        // Composition Data were not obtained.
        self.isConfigComplete = false
        
        // The updated flag is set to true if the Node was provisioned using
        // a Network Key in Phase 2 (Using New Keys).
        let updated = networkKey.phase == .usingNewKeys
        self.netKeys  = [NodeKey(index: networkKey.index, updated: updated)]
        self.appKeys  = []
        self.elements = []
    }
    
    internal init(copy node: Node, withDeviceKey keepDeviceKey: Bool,
                  andTruncateTo networkKeys: [NetworkKey],
                  applicationKeys: [ApplicationKey], nodes: [Node], groups: [Group]) {
        self.uuid = node.uuid
        self.name = node.name
        self.unicastAddress = node.unicastAddress
        self.deviceKey = keepDeviceKey ? node.deviceKey : nil
        self.security = node.security
        self.isConfigComplete = node.isConfigComplete
        self.isExcluded = node.isExcluded
        self.networkTransmit = node.networkTransmit
        self.relayRetransmit = node.relayRetransmit
        self.companyIdentifier = node.companyIdentifier
        self.productIdentifier = node.productIdentifier
        self.versionIdentifier = node.versionIdentifier
        self.minimumNumberOfReplayProtectionList = node.minimumNumberOfReplayProtectionList
        self.features = node.features
        self.ttl = node.ttl
        self.secureNetworkBeacon = node.secureNetworkBeacon
        
        self.netKeys = node.netKeys.filter { nodeKey in
            networkKeys.contains { nodeKey.index == $0.index }
        }
        self.appKeys = node.appKeys.filter { nodeKey in
            applicationKeys.contains { nodeKey.index == $0.index }
        }
        self.elements = node.elements.map {
            Element(copy: $0, andTruncateTo: applicationKeys, nodes: nodes, groups: groups)
        }
        if let heartbeatPublication = node.heartbeatPublication,
              (heartbeatPublication.address.isUnicast &&
                nodes.contains(where: { $0.hasAllocatedAddress(heartbeatPublication.address) })) ||
              (heartbeatPublication.address.isGroup &&
                groups.contains(where: { $0.address.address == heartbeatPublication.address })) {
            self.heartbeatPublication = node.heartbeatPublication
        }
        if let heartbeatSubscription = node.heartbeatSubscription,
           nodes.contains(where: { $0.hasAllocatedAddress(heartbeatSubscription.source) }),
           (heartbeatSubscription.destination.isUnicast &&
             nodes.contains(where: { $0.hasAllocatedAddress(heartbeatSubscription.destination) })) ||
           (heartbeatSubscription.destination.isGroup &&
             groups.contains(where: { $0.address.address == heartbeatSubscription.destination })) {
            self.heartbeatSubscription = node.heartbeatSubscription
        }
        self.elements.forEach {
            $0.parentNode = self
        }
    }
    
    /// Creates a low security Node with given Device Key, Network Key and Unicast Address.
    /// Usually, a Node is added to a network during provisioning. However, for debug
    /// purposes, or to add an already provisioned Node, one can use this method.
    /// A Node created this way will have security set to `.low`.
    ///
    /// Use `meshNetwork.add(node: Node)` to add the Node. Other parameters must be
    /// read from the Node using Configuration messages.
    ///
    /// - parameters:
    ///   - name: Optional Node name.
    ///   - n: Number of Elements. Elements must be read using
    ///        `ConfigCompositionDataGet` message.
    ///   - deviceKey: The 128-bit Device Key.
    ///   - networkKey: The Network Key known to this device.
    ///   - address: The primary Unicast Address of the Node.
    public init?(insecureNode name: String?, with n: UInt8, elementsDeviceKey deviceKey: Data,
                andAssignedNetworkKey networkKey: NetworkKey, andAddress address: Address) {
        guard address.isUnicast else {
            return nil
        }
        self.uuid = UUID()
        self.name = name
        self.unicastAddress = address
        self.deviceKey = deviceKey
        self.security = .insecure
        // Composition Data were not obtained.
        self.isConfigComplete = false
        
        self.netKeys  = [NodeKey(index: networkKey.index, updated: false)]
        self.appKeys  = []
        // Elements will be queried with Composition Data.
        // But we have to mark how many Elements there will be to validate the
        // Unicast address when adding a Node.
        self.elements = []
        for _ in 0..<n {
            add(element: Element(location: .unknown))
        }
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case unicastAddress
        case deviceKey
        case security
        case netKeys
        case appKeys
        case isConfigComplete = "configComplete"
        case name
        case companyIdentifier = "cid"
        case productIdentifier = "pid"
        case versionIdentifier = "vid"
        case minimumNumberOfReplayProtectionList = "crpl"
        case features
        case secureNetworkBeacon
        case ttl = "defaultTTL"
        case networkTransmit
        case relayRetransmit
        case elements
        case isExcluded = "excluded"
        case heartbeatPublication  = "heartbeatPub"
        case heartbeatSubscription = "heartbeatSub"
        // Legacy keys, deprecated in nRF Mesh Provision library in version 3.0.
        case legacyIsBlacklisted = "blacklisted" // replaced with "excluded"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let unicastAddressAsString = try container.decode(String.self, forKey: .unicastAddress)
        guard let unicastAddress = UInt16(unicastAddressAsString, radix: 16) else {
            throw DecodingError.dataCorruptedError(forKey: .unicastAddress, in: container,
                                                   debugDescription: "Address must be 4-character hexadecimal string.")
        }
        guard unicastAddress.isUnicast else {
            throw DecodingError.dataCorruptedError(forKey: .unicastAddress, in: container,
                                                   debugDescription: "\(unicastAddressAsString) is not a unicast address.")
        }
        let keyHex = try container.decodeIfPresent(String.self, forKey: .deviceKey)
        if let keyHex = keyHex {
            deviceKey = Data(hex: keyHex)
            guard !deviceKey!.isEmpty else {
                throw DecodingError.dataCorruptedError(forKey: .deviceKey, in: container,
                                                       debugDescription: "Device Key must be 32-character hexadecimal string.")
            }
        } else {
            self.deviceKey = nil
        }
        
        // In version 3.0 of this library the Node's UUID format has changed
        // from 32-character hexadecimal String to standard UUID format (RFC 4122).
        if let uuidStr = try? container.decodeIfPresent(String.self, forKey: .uuid) {
            if let result = UUID(uuidString: uuidStr) {
                self.uuid = result
            } else if let result = UUID(hex: uuidStr) {
                self.uuid = result
            } else {
                self.uuid = UUID()
            }
        } else {
            self.uuid = try container.decode(UUID.self, forKey: .uuid,
                                             orConvert: MeshUUID.self, forKey: .uuid, using: { $0.uuid })
        }
        
        self.unicastAddress = unicastAddress
        self.security = (try? container.decode(Security.self, forKey: .security)) ?? Security.secure
        self.netKeys = try container.decode([NodeKey].self, forKey: .netKeys)
        self.appKeys = try container.decode([NodeKey].self, forKey: .appKeys)
        self.isConfigComplete = (try? container.decode(Bool.self, forKey: .isConfigComplete)) ?? false
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        if let companyIdentifierAsString = try container.decodeIfPresent(String.self, forKey: .companyIdentifier) {
            if let companyIdentifier = UInt16(hex: companyIdentifierAsString) {
                self.companyIdentifier = companyIdentifier
            }
        }
        if let productIdentifierAsString = try container.decodeIfPresent(String.self, forKey: .productIdentifier) {
            if let productIdentifier = UInt16(hex: productIdentifierAsString) {
                self.productIdentifier = productIdentifier
            }
        }
        if let versionIdentifierAsString = try container.decodeIfPresent(String.self, forKey: .versionIdentifier) {
            if let versionIdentifier = UInt16(hex: versionIdentifierAsString) {
                self.versionIdentifier = versionIdentifier
            }
        }
        if let crplAsString = try container.decodeIfPresent(String.self, forKey: .minimumNumberOfReplayProtectionList) {
            if let crpl = UInt16(hex: crplAsString) {
                self.minimumNumberOfReplayProtectionList = crpl
            }
        }
        self.features = try container.decodeIfPresent(NodeFeaturesState.self, forKey: .features)
        self.secureNetworkBeacon = try container.decodeIfPresent(Bool.self, forKey: .secureNetworkBeacon)
        let ttl = try container.decodeIfPresent(UInt8.self, forKey: .ttl)
        guard ttl == nil || ttl! <= 127 else {
            throw DecodingError.dataCorruptedError(forKey: .ttl, in: container,
                                                   debugDescription: "Default TTL must be in range 0-127.")
        }
        self.ttl = ttl
        self.networkTransmit = try container.decodeIfPresent(NetworkTransmit.self, forKey: .networkTransmit)
        if let networkTransmit = networkTransmit {
            if networkTransmit.interval == 0 || networkTransmit.count == 0 {
                self.networkTransmit = nil
            } else {
                guard networkTransmit.count >= 1 && networkTransmit.count <= 8 else {
                    throw DecodingError.dataCorruptedError(forKey: .networkTransmit, in: container,
                                                           debugDescription: "Network Transmit count must be in range 1-8.")
                }
                // Some versions of nRF Mesh lib for Android were exporting interval
                // as number of steps, not the interval, therefore we can try to fix that.
                // However, values exported as a multiply of 10 will not be converted as they
                // match the proper field definition.
                if networkTransmit.interval % 10 != 0 && networkTransmit.interval <= 32 {
                    self.networkTransmit = NetworkTransmit(fix: networkTransmit)
                } else {
                    guard networkTransmit.interval % 10 == 0 && networkTransmit.interval <= 320 else {
                        throw DecodingError.dataCorruptedError(forKey: .networkTransmit, in: container,
                                                               debugDescription: "Network Transmit interval must be in range 10-320 ms with a step of 10 ms.")
                    }
                }
            }
        }
        self.relayRetransmit = try container.decodeIfPresent(RelayRetransmit.self, forKey: .relayRetransmit)
        if let relayRetransmit = relayRetransmit {
            if relayRetransmit.interval == 0 || relayRetransmit.count == 0 {
                self.relayRetransmit = nil
            } else {
                guard relayRetransmit.count >= 1 && relayRetransmit.count <= 8 else {
                    throw DecodingError.dataCorruptedError(forKey: .relayRetransmit, in: container,
                                                           debugDescription: "Relay Retransmit count must be in range 1-8.")
                }
                // Some versions of nRF Mesh lib for Android were exporting interval
                // as number of steps, not the interval, therefore we can try to fix that.
                // However, values exported as a multiply of 10 will not be converted as they
                // match the proper field definition.
                if relayRetransmit.interval % 10 != 0 && relayRetransmit.interval <= 32 {
                    self.relayRetransmit = RelayRetransmit(fix: relayRetransmit)
                } else {
                    guard relayRetransmit.interval % 10 == 0 && relayRetransmit.interval <= 320 else {
                        throw DecodingError.dataCorruptedError(forKey: .relayRetransmit, in: container,
                                                               debugDescription: "Relay Retransmit interval must be in range 10-320 ms with a step of 10 ms.")
                    }
                }
            }
        }
        self.elements = try container.decode([Element].self, forKey: .elements)
        
        // "blacklisted" was replaced by "excluded" in version 3.0.
        self.isExcluded = (try? container.decode(Bool.self, forKey: .isExcluded, or: .legacyIsBlacklisted)) ?? false
        
        self.heartbeatPublication = try container.decodeIfPresent(HeartbeatPublication.self,
                                                                  forKey: .heartbeatPublication)
        guard heartbeatPublication == nil || netKeys[heartbeatPublication!.networkKeyIndex] != nil else {
            throw DecodingError.dataCorruptedError(forKey: .heartbeatPublication, in: container,
                                                   debugDescription: "Network Key with index \(heartbeatPublication!.networkKeyIndex) "
                                                                   + "is unknown to node with address 0x\(unicastAddress.hex).")
        }
        self.heartbeatSubscription = try container.decodeIfPresent(HeartbeatSubscription.self,
                                                                   forKey: .heartbeatSubscription)
        
        elements.forEach {
            $0.parentNode = self
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(unicastAddress.hex, forKey: .unicastAddress) // <- HEX value encoded
        try container.encodeIfPresent(deviceKey?.hex, forKey: .deviceKey) // <- HEX value encoded
        try container.encode(security, forKey: .security)
        try container.encode(netKeys, forKey: .netKeys)
        try container.encode(appKeys, forKey: .appKeys)
        try container.encode(isConfigComplete, forKey: .isConfigComplete)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(companyIdentifier?.hex, forKey: .companyIdentifier)
        try container.encodeIfPresent(productIdentifier?.hex, forKey: .productIdentifier)
        try container.encodeIfPresent(versionIdentifier?.hex, forKey: .versionIdentifier)
        try container.encodeIfPresent(minimumNumberOfReplayProtectionList?.hex, forKey: .minimumNumberOfReplayProtectionList)
        try container.encodeIfPresent(features, forKey: .features)
        try container.encodeIfPresent(secureNetworkBeacon, forKey: .secureNetworkBeacon)
        try container.encodeIfPresent(ttl, forKey: .ttl)
        try container.encodeIfPresent(networkTransmit, forKey: .networkTransmit)
        try container.encodeIfPresent(relayRetransmit, forKey: .relayRetransmit)
        try container.encode(elements, forKey: .elements)
        try container.encode(isExcluded, forKey: .isExcluded)
        try container.encodeIfPresent(heartbeatPublication, forKey: .heartbeatPublication)
        try container.encodeIfPresent(heartbeatSubscription, forKey: .heartbeatSubscription)
    }
}

public extension Node {
    
    /// Adds the given Element to the Node.
    ///
    /// - parameter element: The Element to be added.
    func add(element: Element) {
        let index = UInt8(elements.count)
        elements.append(element)
        element.parentNode = self
        element.index = index
    }
    
    /// Adds given list of Elements to the Node.
    ///
    /// - parameter element: The list of Elements to be added.
    func add(elements: [Element]) {
        elements.forEach {
            add(element: $0)
        }
    }
    
    /// Sets given list of Elements to the Node.
    ///
    /// - parameter element: The new list of Elements to be added.
    func set(elements: [Element]) {
        for e in 0..<min(self.elements.count, elements.count) {
            let oldElement = self.elements[e]
            let newElement = elements[e]
            for m in 0..<min(oldElement.models.count, newElement.models.count) {
                let oldModel = oldElement.models[m]
                let newModel = newElement.models[m]
                if oldModel.modelId == newModel.modelId {
                    newModel.copy(from: oldModel)
                    // If at least one Model matches, assume the Element didn't
                    // change much and copy the name of it.
                    if let oldName = oldElement.name {
                        newElement.name = oldName
                    }
                }
            }
        }
        self.elements.forEach {
            $0.parentNode = nil
            $0.index = 0
        }
        self.elements.removeAll()
        elements.forEach {
            add(element: $0)
        }
    }
    
    /// Adds the Network Key to the Node.
    ///
    /// - parameter networkKey: The Network Key to add.
    func add(networkKey: NetworkKey) {
        add(networkKeyWithIndex: networkKey.index)
    }
    
    /// Adds the Network Key with given index to the Node.
    ///
    /// - parameter networkKeyIndex: The Network Key index to add.
    func add(networkKeyWithIndex networkKeyIndex: KeyIndex) {
        if netKeys[networkKeyIndex] == nil {
            netKeys.append(NodeKey(index: networkKeyIndex, updated: false))
            meshNetwork?.timestamp = Date()
        }
    }
    
    /// Sets the Network Keys to the Node.
    /// This will overwrite the previous keys.
    ///
    /// - parameter networkKeys: The Network Keys to set.
    func set(networkKeys: [NetworkKey]) {
        set(networkKeysWithIndexes: networkKeys.map { $0.index })
    }
    
    /// Sets the Network Keys with given indexes to the Node.
    /// This will overwrite the previous keys.
    ///
    /// - parameter networkKeyIndexes: The Network Key indexes to set.
    func set(networkKeysWithIndexes networkKeyIndexes: [KeyIndex]) {
        netKeys = networkKeyIndexes
            .map { Node.NodeKey(index: $0, updated: false) }
            .sorted()
        meshNetwork?.timestamp = Date()
    }
    
    /// Marks the Network Key in the Node as updated.
    ///
    /// - parameter networkKeyIndex: The Network Key index to add.
    func update(networkKeyWithIndex networkKeyIndex: KeyIndex) {
        if let key = netKeys[networkKeyIndex] {
            key.updated = true
            meshNetwork?.timestamp = Date()
        }
    }
    
    /// Adds the Application Key to the Node.
    ///
    /// - parameter applicationKey: The Application Key to add.
    func add(applicationKey: ApplicationKey) {
        add(applicationKeyWithIndex: applicationKey.index)
    }
    
    /// Adds the Application Key with given index to the Node.
    ///
    /// - parameter applicationKeyIndex: The Application Key index to add.
    func add(applicationKeyWithIndex applicationKeyIndex: KeyIndex) {
        if appKeys[applicationKeyIndex] == nil {
            appKeys.append(NodeKey(index: applicationKeyIndex, updated: false))
            meshNetwork?.timestamp = Date()
        }
    }
    
    /// Sets the Application Keys to the Node.
    /// This will overwrite the previous keys.
    ///
    /// - parameter applicationKeys: The Application Keys to set.
    func set(applicationKeys: [ApplicationKey]) {
        set(applicationKeysWithIndexes: applicationKeys.map { $0.index })
    }
    
    /// Sets the Application Keys with given indexes to the Node.
    /// This will overwrite the previous keys.
    ///
    /// - parameter applicationKeyIndexes: The Application Key indexes to set.
    func set(applicationKeysWithIndexes applicationKeyIndexes: [KeyIndex]) {
        appKeys = applicationKeyIndexes.map { Node.NodeKey(index: $0, updated: false) }
        appKeys.sort()
        meshNetwork?.timestamp = Date()
    }
    
    /// Sets the Application Keys with given indexes to the Node.
    /// This will overwrite the previous keys bound to the given
    /// Network Key.
    ///
    /// - parameter applicationKeyIndexes: The Application Key indexes to set.
    /// - parameter networkKeyIndex: The index of a Network Key that those
    ///                              keys are bound to.
    func set(applicationKeysWithIndexes applicationKeyIndexes: [KeyIndex],
             forNetworkKeyWithIndex networkKeyIndex: KeyIndex) {
        // Leave only those App Keys, that are bound to a different
        // Network Key than in the received response.
        appKeys = appKeys.filter {
            applicationKeys[$0.index]?.boundNetworkKeyIndex != networkKeyIndex
        }
        appKeys.append(contentsOf: applicationKeyIndexes.map { Node.NodeKey(index: $0, updated: false) })
        appKeys.sort()
        meshNetwork?.timestamp = Date()
    }
    
    /// Marks the Application Key in the Node as updated.
    ///
    /// - parameter applicationKeyIndex: The Application Key index to add.
    func update(applicationKeyWithIndex applicationKeyIndex: KeyIndex) {
        if let key = netKeys[applicationKeyIndex] {
            key.updated = true
            meshNetwork?.timestamp = Date()
        }
    }
    
    /// Removes the Network Key with given index and all Application Keys
    /// bound to it from the Node. This method also removes all Model bindings
    /// that point any of the removed Application Keys and the publications
    /// that are using this key, including Heartbeat publication.
    ///
    /// - parameter networkKeyIndex: The Key Index of Network Key to be removed.
    func remove(networkKeyWithIndex networkKeyIndex: KeyIndex) {
        if let index = netKeys.firstIndex(where: { $0.index == networkKeyIndex }) {
            // Remove the Key Index from 'appKeys'.
            netKeys.remove(at: index)
            // Remove all Application Keys bound to the removed Network Key.
            applicationKeys
                .filter { $0.boundNetworkKeyIndex == networkKeyIndex }
                .forEach { key in remove(applicationKeyWithIndex: key.index) }
            // Remove Heartbeat publication, if set to use the removed Network Key.
            if heartbeatPublication?.networkKeyIndex == networkKeyIndex {
                heartbeatPublication = nil
            }
            meshNetwork?.timestamp = Date()
        }
    }
    
    /// Removes the Application Key with given index and all Model bindings
    /// that point to it and the publications that are using this key.
    ///
    /// - parameter applicationKeyIndex: The Key Index of Application Key to be removed.
    func remove(applicationKeyWithIndex applicationKeyIndex: KeyIndex) {
        if let index = appKeys.firstIndex(where: { $0.index == applicationKeyIndex }) {
            // Remove the Key Index from 'appKeys'.
            appKeys.remove(at: index)
            // Remove all bindings with given Key Index from all models.
            elements.flatMap { $0.models }.forEach { model in
                // Remove the Key Index from bound keys.
                // This will also clear the publication if it was using
                // the same Application Key.
                model.unbind(applicationKeyWithIndex: applicationKeyIndex)
            }
            meshNetwork?.timestamp = Date()
        }
    }
    
    /// Applies the result of Composition Data to the Node.
    ///
    /// This method does nothing if the Node already was configured
    /// or the Composition Data Status does not have Page 0.
    ///
    /// - parameter compositionData: The result of Config Composition Data Get
    ///                              with page 0.
    func apply(compositionData: ConfigCompositionDataStatus) {
        guard let page0 = compositionData.page as? Page0 else {
            return
        }
        companyIdentifier = page0.companyIdentifier
        productIdentifier = page0.productIdentifier
        versionIdentifier = page0.versionIdentifier
        minimumNumberOfReplayProtectionList = page0.minimumNumberOfReplayProtectionList
        features = page0.features
        // And set the Elements received.
        set(elements: page0.elements)
        meshNetwork?.timestamp = Date()
    }
    
    var ensureFeatures: NodeFeaturesState {
        if features == nil {
            features = NodeFeaturesState()
        }
        meshNetwork?.timestamp = Date()
        return features!
    }
    
}

internal extension Array where Element == Node.NodeKey {
    
    subscript(keyIndex: KeyIndex) -> Node.NodeKey? {
        return first {
            $0.index == keyIndex
        }
    }
    
}

extension Node.NodeKey: Comparable {
    
    public static func < (lhs: Node.NodeKey, rhs: Node.NodeKey) -> Bool {
        return lhs.index < rhs.index
    }
    
    public static func == (lhs: Node.NodeKey, rhs: Node.NodeKey) -> Bool {
        return lhs.index == rhs.index
    }
    
    public static func != (lhs: Node.NodeKey, rhs: Node.NodeKey) -> Bool {
        return lhs.index != rhs.index
    }
    
}

extension Node.NodeKey: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Key Index: \(index), updated: \(updated)"
    }
    
}

extension Node: Equatable {
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.uuid == rhs.uuid
    }    
    
}
