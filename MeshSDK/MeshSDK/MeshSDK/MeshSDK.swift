//
//  MeshSDK.swift
//  nRFSingleTon
//
//  Created by wuzhengbin on 2019/12/19.
//  Copyright © 2019 wuzhengbin. All rights reserved.
//

import Foundation
import os.log
import nRFMeshProvision
import CoreBluetooth
import UIKit

enum DeviceConfigurationPhase {
    case scanning
    case connecting
    case identifying
    case provisioning
    case configuring
    case appKeyBinding
    case groupAdding
    case idling
}

struct RuntimeVendorMessage: VendorMessage {
    let opCode: UInt32
    let parameters: Data?
    
    var isSegmented: Bool = false
    var security: MeshMessageSecurity = .low
    
    init(opCode: UInt8, for model: Model, parameters: Data?) {
        self.opCode = (UInt32(0xC0 | opCode) << 16) | UInt32(model.companyIdentifier!.bigEndian)
        self.parameters = parameters
    }
    
    init?(parameters: Data) {
        // This init will never be used, as it's used for incoming messages.
        return nil
    }
}

struct MultiCastVendorMessage: VendorMessage {
    let opCode: UInt32
    let parameters: Data?
    
    init(opCode: UInt8, parameters: Data?) {
        self.opCode = (UInt32(0xC0 | opCode) << 16) | UInt32(MeshSDK.sharedInstance.companyId.bigEndian)
        self.parameters = parameters
    }
    
    init?(parameters: Data) {
        return nil
    }
	
}

extension RuntimeVendorMessage: CustomDebugStringConvertible {

    var debugDescription: String {
        let hexOpCode = String(format: "%2X", opCode)
        return "RuntimeVendorMessage(opCode: \(hexOpCode), parameters: \(String(describing: parameters?.hex)), isSegmented: \(isSegmented), security: \(security))"
    }
    
}

@objcMembers
open class MeshSDK: NSObject {
    public static let sharedInstance = MeshSDK()
    
    var companyId = UInt16(2338)  //cid
    
    public var isSegmented :Bool = false  //是否强制分片
    
    public var meshNetworkManager: MeshNetworkManager!
    var connection: NetworkConnection!
    var currentNetworkKey: String?
    
    var phase: DeviceConfigurationPhase = .idling
    
    var provisioningManager: ProvisioningManager?
    var capabilitiesReceived = false
    var unprovisionedDevice: UnprovisionedDevice?
//    var bearer: ProvisioningBearer!
    var bearer: MXPBGattBearer?
    
    var publicKey: PublicKey?
    var authenticationMethod: AuthenticationMethod?
    
    //发送消息缓存
    public typealias MeshMessageCallBack = ([String : Any]) -> ()
    //根据tid+uuid存储的发送消息
    var meshMessageDict : [String : Any] = [:]
    
    // 设备的信息回调(key为设备的uuid）
    public typealias DevicePropertysCallback = ([String: Any]) -> ()
    //根据uuid存储的监听设备的回调
    var subscribedMessageCallback: DevicePropertysCallback?
    
    //nodes信息的回调
    public typealias LocalProvisionedDevicesCallback = ([[String: Any]]) -> ()
    //配网过程中的回调
    public typealias MXMeshProvisionCallback = (Bool) -> ()
    var provisionUUID : String?
    var provisioningNK: String?
    var provisionElementNum : Int = 1
    //配网代理
    public weak var provisionDelegate : MeshSDKProvisionDelegate?
    public weak var oobProvisioningDelegate : MeshSDKOOBProvisioningDelegate?
    
    //配网连接回调
    var connectUnprovisionedDeviceCallback: MXMeshProvisionCallback?
    var identifyNodeCallback: MXMeshProvisionCallback?
    var provisioningStatusCallback: MXMeshProvisionCallback?
    //获取CompositionData回调
    var getProvisionCompositionDataCallback:MXMeshProvisionCallback?
    var configCompositionDataStatusCB:MXMeshProvisionCallback?
    var getTTLCallback:MXMeshProvisionCallback?
    //配置ApplicationKey回调
    var bindApplicationKeyCallback:MXMeshProvisionCallback?
    var applicationKeyStatusForNodeCallback: MXMeshProvisionCallback?
    var advBindApplicationKeyCallback: MXMeshProvisionCallback?
    var advSubscriptionCallback: MXMeshProvisionCallback?
    var advPublicationsCallback: MXMeshProvisionCallback?
    
    var deleteApplicationKeyForNodeCallback: MXMeshProvisionCallback?
    //获取三元组回调
	public typealias FetchTripletCallback = ([String: Any]) -> ()
    // WiFi 连接状态回调
	public typealias WiFiConfigStatusCallback = (Bool) -> ()
	//获取版本号
	public typealias FetchDeviceFirmwareVersionCallback = (String) -> ()
    //联动指令写入设备回调
	public typealias SendCommandCallback = (Bool) -> ()
    
    //设备状态的回调
    public typealias DeviceStatusOfflineCallback = ([String : [String]]) -> ()
    var deviceStatusOfflineCallback: DeviceStatusOfflineCallback?
    
    //mesh连接状态
    public typealias MeshProxyConnectStatusCallback = (Int) -> ()
    public var meshConnectStatusCallback: MeshProxyConnectStatusCallback?
    
    public typealias MeshSequencesUpdateCallback = () -> ()
    var meshSequenceUpdateCallback: MeshSequencesUpdateCallback?
    
    // 设备缓存失效回调(参数为uuid）
    public typealias DeviceCacheInvalidCallback = (String) -> ()
    var subscribedDeviceCacheInvalidCallback: DeviceCacheInvalidCallback?
    
    //装载一直在线的设备
    var connectedDeviceHeart =  [String: Any]()
    var disConnectedDevices : Array<String>! = nil
    
    //监听的设备
    public var listenResult = [String : Any]()
    //标记是否删除了mesh直连的设备
	var isConnectedDirectly: Bool! = false
    
    var provisionTimer: DispatchSourceTimer?
    var provisioningNum: Int = 0  //配网过程中的计数器
    
    var timer : DispatchSourceTimer?
    public var heartTimeout : TimeInterval = 240.0  //心跳超时时间
    public var StatusCacheTimeout : TimeInterval = 120.0  //设备状态缓存超时时间
    var reconnectTimerCount: Int = 0   //重连超时
    var isMeshReconnect: Bool = false  //是否是自己发起的重连
    public var messageDuration: TimeInterval = 0.2
    
    var tidNum : Int = Int(Date().timeIntervalSince1970) % 255
    
    var currentSeq : UInt32 = 0
    var seqUpdateInterval : UInt32 = 50
    
    var sendMessageQueue: OperationQueue!  //发送的单播消息队列
    
    //指定Gatt直连设备
    //public var gattDeviceName : String!
    
    public override init() {
        super.init()
        
        self.sendMessageQueue = OperationQueue()
        self.sendMessageQueue.maxConcurrentOperationCount = 1
    }
    
    //SDK初始化
    public func setup(config: [String :Any]?) {
        
//        let filepath:String = NSHomeDirectory() + "/Documents/PrintInfo.log"
//        let defaultManager = FileManager.default
//        try?defaultManager.removeItem(atPath: filepath)
//        
//        freopen(filepath.cString(using: String.Encoding.ascii), "a+", stdout)
//        freopen(filepath.cString(using: String.Encoding.ascii), "a+", stderr)
        
        if let meshConfig = config {
            if let provisionServiceInfo = meshConfig["provisionService"] as? [String : String] {
                if let uuid = provisionServiceInfo["uuid"] {
                    MeshProvisioningService.uuid = CBUUID(string: uuid)
                }
                if let dataInUuid = provisionServiceInfo["dataInUuid"] {
                    MeshProvisioningService.dataInUuid = CBUUID(string: dataInUuid)
                }
                if let dataOutUuid = provisionServiceInfo["dataOutUuid"] {
                    MeshProvisioningService.dataOutUuid = CBUUID(string: dataOutUuid)
                }
            }
            
            if let proxyServiceInfo = meshConfig["proxyService"] as? [String : String] {
                if let uuid = proxyServiceInfo["uuid"] {
                    MeshProxyService.uuid = CBUUID(string: uuid)
                }
                if let dataInUuid = proxyServiceInfo["dataInUuid"] {
                    MeshProxyService.dataInUuid = CBUUID(string: dataInUuid)
                }
                if let dataOutUuid = proxyServiceInfo["dataOutUuid"] {
                    MeshProxyService.dataOutUuid = CBUUID(string: dataOutUuid)
                }
            }
            
            if let cid = meshConfig["companyId"] as? String {
                if let company_id = UInt16(cid, radix: 16) {
                    self.companyId = company_id
                }
            }
        }
        
        meshNetworkManager = MeshNetworkManager()
        meshNetworkManager.acknowledgmentTimerInterval = 0.150
        meshNetworkManager.transmissionTimerInterval = 0.600
        meshNetworkManager.retransmissionLimit = 2
		meshNetworkManager.acknowledgmentMessageInterval = 5.0
        // As the interval has been increased, the timeout can be adjusted.
        // The acknowledged message will be repeated after 1.5 seconds,
        // 4.5 seconds (1.5 + 1.5 * 2), and 10.5 seconds (1.5 + 1.5 * 2 + 1.5 * 4).
        meshNetworkManager.acknowledgmentMessageTimeout = 40.0
        meshNetworkManager.logger = self
        
        //90s 监听设备离线
        listenDeviceDisConnect()
        
        NotificationCenter.default.addObserver(self, selector: #selector(proxyDidSetup), name: NSNotification.Name(rawValue: "MESH_CONNECTED"), object: nil)
        
        // Try loading the saved configuration
        var loaded = false
        do {
            loaded = try meshNetworkManager.load()
        } catch {
            print(error)
        }
        
        if !loaded {
            createNewMeshNetwork()
        } else {
            meshNetworkDidChange()
        }
        
        phase = .idling
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func createNewMeshNetwork() {
        let provisioner = Provisioner(name: UIDevice.current.name,
                                      allocatedUnicastRange: [AddressRange(0x0001...0x7FFF)],
                                      allocatedGroupRange:   [AddressRange(0xC000...0xFEFF)],
									  allocatedSceneRange:   [SceneRange(0x0001...0x3333)])
        _ = meshNetworkManager.createNewMeshNetwork(withName: "nRF Mesh Network", by: provisioner)
        _ = meshNetworkManager.save()
        
        meshNetworkDidChange()
    }
    
    private func meshNetworkDidChange() {
        connection?.close()
        
        let meshNetwork = meshNetworkManager.meshNetwork!
        
        // Set up local Elements on the phone.
        let element0 = Element(name: "Primary Element", location: .first, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        let element1 = Element(name: "Secondary Element", location: .second, models: [
            Model(sigModelId: 0x1000, delegate: GenericOnOffServerDelegate()),
            Model(sigModelId: 0x1002, delegate: GenericLevelServerDelegate()),
            Model(sigModelId: 0x1001, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: 0x1003, delegate: GenericLevelClientDelegate())
        ])
        meshNetworkManager.localElements = [element0, element1]
        
        connection = NetworkConnection(to: meshNetwork)
        connection!.dataDelegate = meshNetworkManager
        connection!.logger = self
        meshNetworkManager.transmitter = connection
        //connection!.open()
    }
    
}

// MARK: - 添加 ApplicaitonKey To Models
extension MeshSDK {
    
    /*
    node添加新的networkkey
    @param  networkKey   内部会处理是否创建，如果没有创建会去创建
    @param  appKey  可选，如果没有传入，创建NK的时候内部会创建
    @param  uuid
    @callback Bool 是否成功
    */
    public func addNetworkKeyToNode(uuid: String, networkKey: String, appKey: String?, callback: @escaping MXMeshProvisionCallback) {
        if !isNetworkKeyExists(networkKey: networkKey) {
            _ = self.createNetworkKey(key: networkKey, appKey: appKey)
            self.addNetworkKeyToNode(uuid: uuid, networkKey: networkKey, appKey: appKey, callback: callback)
            return;
        }
        
        var app_key = appKey
        if appKey == nil {
            guard let applicationKey = self.getAllApplicationKey(networkKey: networkKey).first else {
                callback(false)
                return
            }
            app_key = applicationKey
        }
        
        applicationKeyStatusForNodeCallback = callback
        let network = meshNetworkManager.meshNetwork!
        meshNetworkManager.delegate = self
        
        if let node = lookupNode(uuid: uuid) {
            for applicationKey in network.applicationKeys where applicationKey.key.hex == app_key {
                _ = try? meshNetworkManager.send(ConfigAppKeyAdd(applicationKey: applicationKey), to: node)
            }
        }
    }
    
    /*
    node删除networkkey
    @param  networkKey
    @param  appKey  可选
    @param  uuid
    @callback Bool 是否成功
    */
    public func deleteNetworkKeyToNode(uuid: String, networkKey: String, appKey: String?, callback: @escaping MXMeshProvisionCallback) {
        var app_key = appKey
        if appKey == nil {
            guard let applicationKey = self.getAllApplicationKey(networkKey: networkKey).first else {
                callback(false)
                return
            }
            app_key = applicationKey
        }
        
        self.deleteApplicationKeyForNode(appKey: app_key!, uuid: uuid) { (isSuccess1 :Bool) in
            if isSuccess1 {
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    /*
     添加appkey绑定
     @param appkey String
     @param uuid  String 设备的uuid
     @callback Bool
     */
     func addApplicationKeyForNode(appKey: String, uuid: String?, callback: @escaping MXMeshProvisionCallback) {
        guard let uuid = uuid else {
            callback(false)
            return
        }
        applicationKeyStatusForNodeCallback = callback
        let network = meshNetworkManager.meshNetwork!
        meshNetworkManager.delegate = self
        
        if let node = lookupNode(uuid: uuid) {
            for applicationKey in network.applicationKeys where applicationKey.key.hex == appKey {
                _ = try? meshNetworkManager.send(ConfigAppKeyAdd(applicationKey: applicationKey), to: node)
            }
        }
    }
    
    /*
     删除appkey绑定
     @param appkey String
     @param uuid  String 设备的uuid
     @callback Bool
     */
     func deleteApplicationKeyForNode(appKey: String, uuid: String?, callback: @escaping MXMeshProvisionCallback) {
        guard let uuid = uuid else {
            callback(false)
            return
        }
        deleteApplicationKeyForNodeCallback = callback
        let network = meshNetworkManager.meshNetwork!
        meshNetworkManager.delegate = self
        
        if let node = lookupNode(uuid: uuid) {
            for applicationKey in network.applicationKeys where applicationKey.key.hex == appKey {
                _ = try? meshNetworkManager.send(ConfigAppKeyDelete(applicationKey: applicationKey), to: node)
            }
        }
    }
    
    //model 绑定app key状态查询
    func modelBindApplicationKey(uuid: String?, elementIndex: Int = 0, callback: @escaping MXMeshProvisionCallback) {
        self.advBindApplicationKey(uuid: uuid, elementIndex: elementIndex) { [weak self] (isSuccess : Bool) in
            let elementNum = self?.provisionElementNum ?? 1
            let newIndex = elementIndex + 1
            if newIndex < elementNum {
                self?.modelBindApplicationKey(uuid: uuid, elementIndex: newIndex, callback: callback)
                return
            }
            callback(true)
            self?.advBindApplicationKeyCallback = nil
        }
    }
	
	// MARK: 新协议 获取设备的 ApplicationKey 的绑定状态
    func advBindApplicationKey(uuid: String?, elementIndex: Int = 0, callback: @escaping MXMeshProvisionCallback) {
        guard let uuid = uuid else {
            callback(false)
            return
        }
		advBindApplicationKeyCallback = callback
        if let node = lookupNode(uuid: uuid) {
            if node.elements.count <= elementIndex {
                callback(false)
                return
            }
            let element = node.elements[elementIndex];
			meshNetworkManager.delegate = self
			for model in element.models where model.companyIdentifier == self.companyId {
				let message: ConfigMessage = ConfigVendorModelAppGet(of: model)!
				_ = try? meshNetworkManager.send(message, to: model)
			}
		}
	}
	
	// MARK: 新协议 获取设备的订阅状态
    func advReloadSubscrition(uuid: String?, elementIndex: Int = 0, callback: @escaping MXMeshProvisionCallback) {
        guard let uuid = uuid else {
            callback(false)
            return
        }
		advSubscriptionCallback = callback
        if let node = lookupNode(uuid: uuid) {
            if node.elements.count <= elementIndex {
                callback(false)
                return
            }
            let element = node.elements[elementIndex];
			meshNetworkManager.delegate = self
			for model in element.models where model.companyIdentifier == self.companyId {
				let message: ConfigMessage = ConfigVendorModelSubscriptionGet(of: model)!
				_ = try? meshNetworkManager.send(message, to: model)
			}
		}
	}
	
	// MARK: 新协议 获取设备的发布状态
	func advReloadPublication(uuid: String?, elementIndex: Int = 0, callback: @escaping MXMeshProvisionCallback) {
        guard let uuid = uuid else {
            callback(false)
            return
        }
		advPublicationsCallback = callback
        if let node = lookupNode(uuid: uuid) {
            if node.elements.count <= elementIndex {
                callback(false)
                return
            }
            let element = node.elements[elementIndex];
			meshNetworkManager.delegate = self
			for model in element.models where model.companyIdentifier == self.companyId {
				let message = ConfigModelPublicationGet(for: model)!
				_ = try? meshNetworkManager.send(message, to: model)
			}
		}
	}
}



// MARK: Group 相关
extension MeshSDK {
    /*
     添加组
     @param name 名称
     @param address Mesh地址 0xC000-0xFEFF
     */
    func addGroup(name: String, address: String) -> Bool {
        let address = MeshAddress(hex: address)
        let group = try? Group(name: name, address: address!)
        let network = meshNetworkManager.meshNetwork!
        try? network.add(group: group!)
        if meshNetworkManager.save() {
            return true
        } else {
            return false
        }
    }
    //获取所有的组
    func getAllGroups() -> [String] {
        let network = meshNetworkManager.meshNetwork!
        return network.groups.map { $0.name }
    }
    
    @discardableResult
    //删除组
    func deleteGroup(name: String) -> Bool {
        let network = meshNetworkManager.meshNetwork!
        for group in network.groups where group.name == name {
            try? network.remove(group: group)
            if meshNetworkManager.save() {
                return true
            } else {
                return false
            }
        }
        return false
    }
}

//设备订阅监听
extension MeshSDK {
    /*
    订阅设备上报消息
    @callback [String:Any] key为uuidvalue为HexString
    */
    public func subscribeMeshDownMessage(callback: @escaping DevicePropertysCallback) {
        self.subscribedMessageCallback = callback
    }
    /*proxyFilter添加组播地址的监听
     @param address mesh组播地址
    */
    public func subscribeMeshProxyFilter(address: UInt16) {
        meshNetworkManager.delegate = self
        if let proxyFilter = meshNetworkManager.proxyFilter, proxyFilter.addresses.firstIndex(of: address) == nil {
            proxyFilter.add(address: address)
        }
    }
    
    /*
    订阅设备状态
    @callback [String] 离线设备的UUID数组
    */
    public func subscribeDeviceStatus(callback: @escaping DeviceStatusOfflineCallback) {
        self.deviceStatusOfflineCallback = callback
    }
    
    /*
    订阅mesh连接状态
    @callback mesh连接状态 1为连接成功，0失败
    */
    public func subscribeMeshConnectStatus(callback: @escaping MeshProxyConnectStatusCallback) {
        self.meshConnectStatusCallback = callback
        if self.isConnected() {
            self.meshConnectStatusCallback?(1)
        }
    }
    
    /*
    订阅mesh sequences 更新回调
    @callback
    */
    public func subscribeMeshSequencesUpdate(callback: @escaping MeshSequencesUpdateCallback) {
        self.meshSequenceUpdateCallback = callback
    }
    
    /*
    订阅设备缓存失效的回调
    @callback
    */
    public func subscribeDeviceCacheInvalid(callback: @escaping DeviceCacheInvalidCallback) {
        self.subscribedDeviceCacheInvalidCallback = callback
    }
}

//mesh配置
extension MeshSDK {
    /*
    导出mesh network
    @callback jsonString(完整的networkkey,appkey,Model,Element,nodes关系)
    */
    public func exportMeshNetwork(callback: (String) -> ()) {
        let data = meshNetworkManager.export()
        do {
            let name = meshNetworkManager.meshNetwork?.meshName ?? "mesh"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).json")
            try data.write(to: fileURL)
            callback(String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? "")
        } catch {
            print("Export Failed: \(error)")
        }
    }
    
    /*
    导入mesh network
    @params jsonString
    */
    public func importMeshNetwork(jsonString: String, callback:(Bool) -> ()) {
        self.resetNetwork()
        if let data = jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
            _ = try? meshNetworkManager.import(from: data)
            if !meshNetworkManager.meshNetwork!.restoreLocalProvisioner() {
                if let nextAddressRange = meshNetworkManager.meshNetwork?.nextAvailableUnicastAddressRange(ofSize: 0x7FFF),
                    let nextGroupRange = meshNetworkManager.meshNetwork?.nextAvailableGroupAddressRange(ofSize: 0x0C9A),
                    let nextSceneRange = meshNetworkManager.meshNetwork?.nextAvailableSceneRange(ofSize: 0x3334) {
                    
					let newProvisioner = Provisioner(name: UIDevice.current.name, allocatedUnicastRange: [nextAddressRange], allocatedGroupRange: [nextGroupRange], allocatedSceneRange: [nextSceneRange])
                    try? meshNetworkManager.meshNetwork?.setLocalProvisioner(newProvisioner)
                    if let address = meshNetworkManager.meshNetwork?.nextAvailableUnicastAddress(for: newProvisioner) {
                        try? meshNetworkManager.meshNetwork?.assign(unicastAddress: address, for: newProvisioner)
                    }
                }
            }
            if meshNetworkManager.save() {
                self.meshNetworkDidChange()
                self.removeRedundantProvisioners()
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    /*
    导入mesh network
    @params jsonString
    */
    public func importMeshNetworkConfig(jsonString: String, callback:(Bool) -> ()) {
        let jsonData:Data = jsonString.data(using: .utf8)!
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String:Any] else {
            callback(false)
            return
        }
        guard let nks = dict["netKeys"] as? Array<[String : Any]> else {
            callback(false)
            return
        }
        
        guard let nodes = dict["nodes"] as? Array<[String : Any]> else {
            callback(false)
            return
        }
        
        self.resetNetwork()
        for nkdict in nks {
            if let nk = nkdict["key"] as? String, let aks = nkdict["appKeys"] as? Array<String> {
                for ak in aks {
                   _ = self.createNetworkKey(key: nk, appKey: ak)
                }
            }
        }
        
        for nodeDict in nodes {
            _=self.addNode(jsonObject: nodeDict)
        }
        
        if !meshNetworkManager.meshNetwork!.restoreLocalProvisioner() {
            if let nextAddressRange = meshNetworkManager.meshNetwork?.nextAvailableUnicastAddressRange(ofSize: 0x7FFF),
                let nextGroupRange = meshNetworkManager.meshNetwork?.nextAvailableGroupAddressRange(ofSize: 0x0C9A),
                let nextSceneRange = meshNetworkManager.meshNetwork?.nextAvailableSceneRange(ofSize: 0x3334) {
                
                let newProvisioner = Provisioner(name: UIDevice.current.name, allocatedUnicastRange: [nextAddressRange], allocatedGroupRange: [nextGroupRange], allocatedSceneRange: [nextSceneRange])
                try? meshNetworkManager.meshNetwork?.setLocalProvisioner(newProvisioner)
                if let address = meshNetworkManager.meshNetwork?.nextAvailableUnicastAddress(for: newProvisioner) {
                    try? meshNetworkManager.meshNetwork?.assign(unicastAddress: address, for: newProvisioner)
                }
            }
        }
        if meshNetworkManager.save() {
            self.meshNetworkDidChange()
            self.removeRedundantProvisioners()
            callback(true)
        } else {
            callback(false)
        }
    }
    
    /*
     设置provisioner的地址
     @param  address mesh地址
     */
    public func resetProvisionerUnicastAddress(address: UInt16) {
        guard let localProvisioner = meshNetworkManager.meshNetwork?.localProvisioner else {
            return
        }
        try? meshNetworkManager.meshNetwork?.assign(unicastAddress: address, for: localProvisioner)
        _ = meshNetworkManager.save()
    }
    
    /*
    设置mesh sequenceNumber
    @param seq    mesh消息的sequenceNumber
    @param updateInterval 更新周期
    */
    public func setMeshNetworkSequence(seq: UInt32, updateInterval: UInt32) {
        guard let localNode = meshNetworkManager.meshNetwork!.nodes.first else {
            return
        }
        guard let element = localNode.elements.first else {
            return
        }
        let localSeq = getMeshNetworkSequence()
        if seq > localSeq {
            meshNetworkManager.setSequenceNumber(seq, forLocalElement: element)
            self.currentSeq = seq
        }
        if updateInterval > 0 {
            self.seqUpdateInterval = updateInterval
        }
    }
    
    /*
    获取mesh sequenceNumber
    @retrun
    */
    public func getMeshNetworkSequence() -> UInt32 {
        guard let localNode = meshNetworkManager.meshNetwork!.nodes.first else {
            return 0
        }
        guard let element = localNode.elements.first else {
            return 0
        }
        let seq = meshNetworkManager.getSequenceNumber(ofLocalElement: element) ?? 0
        return seq
    }
}

extension MeshSDK {
    /*
    断开当前的mesh连接
    */
    public func disconnect() {
        connection.currentBearerName = nil
        self.isMeshReconnect = false
        connection?.close()
    }
    /*
    连接mesh，内部有做重连机制
    */
    public func connect() {
        //connection.currentBearerName = self.gattDeviceName
        self.isMeshReconnect = true
        connection?.open()
    }
    
    /*
     获取当前mesh的连接状态
     */
    public func isConnected() -> Bool {
        return connection.isConnected
    }
    
    func checkIfConnected() {
        if self.isMeshReconnect {
            if self.isConnected() {
                self.isMeshReconnect = false
                self.reconnectTimerCount = 0
            } else {
                self.reconnectTimerCount += 1
                if self.reconnectTimerCount >= 15 {  //连接超时改成15秒，包含搜索广播包的时间
                    self.reconnectTimerCount = 0
                    self.disconnect()
                    self.connect()
                }
            }
        }
    }
    
    func meshMessageCheckCallback() {
        if self.meshMessageDict.keys.count > 0 {
            for key in self.meshMessageDict.keys {
                if let msgDict = self.meshMessageDict[key] as? [String: Any] {
                    let timeOutStamp = msgDict["timeOutStamp"] as! TimeInterval
                    let opCode = msgDict["opCode"] as! String
                    let uuid = msgDict["uuid"] as! String
                    var retryCount = msgDict["retryCount"] as! Int
                    let attr = msgDict["message"] as Any
                    let timeout = msgDict["timeout"] as! TimeInterval
                    let callback = msgDict["callback"] as! MeshMessageCallBack?
                    let tid = msgDict["tid"] as! String
                    let isHoldCallback = (msgDict["isHoldCallback"] as! Bool?) ?? false
                    let elementIdex = msgDict["elementIndex"] as! Int
                    
                    let status = (msgDict["status"] as? Int) ?? 0  //1为发送中,2为完成，0为未发送
                    
                    let duration = Date().timeIntervalSince1970 - timeOutStamp
                    if (duration > 0 && status == 2) || duration >= 5 {
                        if retryCount > 0 {
                            retryCount -= 1
                            self.sendMeshMessage(opCode: opCode, uuid: uuid, elementIndex: elementIdex, Tid: tid, message: attr, retryCount: retryCount, timeout: timeout, isHoldCallback: isHoldCallback, callback: callback)
                        } else {
                            if callback != nil {
                                var msgParams = [String : Any]()
                                msgParams["code"] = MeshMessageSendStatusCode.MeshMessageSendStatus_timeout.rawValue
                                msgParams["elementIndex"] = elementIdex
                                callback?(msgParams)
                            }
                            self.meshMessageDict.removeValue(forKey: key)
                        }
                    }
                }
            }
        }
    }
    
    func listenDeviceDisConnect(){
        self.timer?.cancel()
        self.timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        self.timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        self.timer?.setEventHandler {
            DispatchQueue.main.async {
                //检查设备状态
                self.checkDeviceHeart()
                //检查消息状态
                self.meshMessageCheckCallback()
                //检查mesh链接状态
                self.checkIfConnected()
                //矫正设备影子信息
                self.syncDeviceStatusCache()
            }
        }
        self.timer?.resume()
    }
    //清楚超时的缓存信息
    func syncDeviceStatusCache(){
        var currentMeshNodes = meshNetworkManager.meshNetwork!.nodes
        if currentMeshNodes.count > 0 {
            currentMeshNodes.remove(at: 0)
        }
        for node in currentMeshNodes {
            if let params = self.listenResult[node.uuid.uuidString] as? [String : Any],
                let timeStamp = params["updateTimestamp"] as? Double,
                Date().timeIntervalSince1970 - timeStamp > self.StatusCacheTimeout {
                self.listenResult.removeValue(forKey: node.uuid.uuidString)
                self.subscribedDeviceCacheInvalidCallback?(node.uuid.uuidString)
            }
        }
    }
    
    func checkDeviceHeart(){
        var offlineUUIDArray = [String]()
        var offlineMacArray = [String]()
        var currentMeshNodes = meshNetworkManager.meshNetwork!.nodes
        if currentMeshNodes.count > 0 {
            currentMeshNodes.remove(at: 0)
        }
        for node in currentMeshNodes {
            let device_heart_time = self.connectedDeviceHeart[node.uuid.uuidString]
            if device_heart_time != nil {
                if (device_heart_time as! Double) - Date().timeIntervalSince1970 < 0 {
                    offlineUUIDArray.append(node.uuid.uuidString)
                    offlineMacArray.append(getNodeMacAddress(uuid: node.uuid.uuidString))
                }
            } else {
                offlineUUIDArray.append(node.uuid.uuidString)
                offlineMacArray.append(getNodeMacAddress(uuid: node.uuid.uuidString))
            }
        }
        if self.disConnectedDevices != offlineUUIDArray {
            print("打印expectionArray\(offlineUUIDArray)")
            self.disConnectedDevices = offlineUUIDArray
            
            var result = [String : [String]]()
            result["uuid"] = offlineUUIDArray
            result["mac"] = offlineMacArray
            
            self.deviceStatusOfflineCallback?(result)
         }
    }
    
    public func initDeviceHeart() {
        self.connectedDeviceHeart = [String : Any]()
        var currentMeshNodes = meshNetworkManager.meshNetwork!.nodes
        if currentMeshNodes.count > 0 {
            currentMeshNodes.remove(at: 0)
        }
        for node in currentMeshNodes {
            self.connectedDeviceHeart[node.uuid.uuidString] = Date.init().timeIntervalSince1970 + self.heartTimeout
        }
    }
    
    //重新连接成功，更新下当前在线的设备的心跳时间戳
    public func updateDeviceHeart() {
        self.connectedDeviceHeart.keys.forEach { (key:String) in
            self.connectedDeviceHeart[key] = Date.init().timeIntervalSince1970 + self.heartTimeout
        }
    }
    /*
     检查设备是否在线
     */
    public func checkDeviceIsOnline(uuid : String) -> Bool {
        guard let node = lookupNode(uuid: uuid) else {
            return false
        }
        if let heartStamp = self.connectedDeviceHeart[node.uuid.uuidString] as? Double, heartStamp - Date.init().timeIntervalSince1970 > 0  {
            return true
        }
        return false
    }
    
    /*
     获取当前连接的蓝牙设备
     */
    public func getConnectPeripheral() -> CBPeripheral? {
        return self.connection.currentPeripheral
    }
}

extension MeshSDK {
	/*
     重置mesh网络，创建一个新的网络
     */
    func resetNetwork() {
        self.createNewMeshNetwork()
    }
    // MARK: 移除掉非 local 的 Provisioner
    func removeRedundantProvisioners() {
        let network = meshNetworkManager.meshNetwork!
        guard let firstProvisioner = network.provisioners.first else {
            return
        }
        for pv in network.provisioners where pv != firstProvisioner {
            try? network.remove(provisioner: pv)

			if meshNetworkManager.save() {
				
			}
        }
    }
    
    //proxyFilter添加订阅
    public func subscribeMeshDeviceProxyFilter(address:UInt16) {
        self.meshNetworkManager.proxyFilter?.add(address: address)
    }
    //proxyFilter移除订阅
    public func unsubscribeMeshDeviceProxyFilter(address:UInt16) {
        self.meshNetworkManager.proxyFilter?.remove(address: address)
    }
}

extension MeshSDK: LoggerDelegate {
    public func log(message: String, ofCategory category: LogCategory, withLevel level: LogLevel) {
//        if #available(iOS 10.0, *) {
//            os_log("%{public}@", log: category.log, type: level.type, message)
//        } else {
            NSLog("[MeshSDK]%@", message)
        //}
    }
}

extension LogLevel {
    /// Mapping from mesh log levels to system log types.
    var type: OSLogType {
        switch self {
        case .debug:       return .debug
        case .verbose:     return .debug
        case .info:        return .info
        case .application: return .default
        case .warning:     return .error
        case .error:       return .fault
        }
    }
}

extension LogCategory {
    var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: rawValue)
    }
    
}
