//
//  MeshSDK+Proving.swift
//  MeshSDK
//
//  Created by 华峰 on 2021/1/22.
//

import Foundation
import nRFMeshProvision
import CoreBluetooth

@objc public protocol MeshSDKOOBProvisioningDelegate: AnyObject {
    
    /*
     输入交换认证信息
     @param confirmationKey  hexString
     @input   provisionerRandom hexString  可选
     @input   provisionerConfirmation  hexString 可选
     @input   authValueKey  hexString     可选
     authValueKey和provisionerConfirmation只需要传入一个
     */
    @objc optional func inputExchangeInformation(confirmationKey: String, handler: @escaping ((_ provisionerRandom: String?, _ provisionerConfirmation: String?,_ authValueKey: String?) -> Void))
    
    /*校验静态OOB设备信息
     @param provisionerRandom hexString
     @param deviceConfirmation hexString
     @param deviceRandom hexString
     */
    @objc optional func checkStaticOOBDeviceInfo(provisionerRandom : String, deviceConfirmation: String, deviceRandom : String, handler: @escaping ((Bool) -> Void))
}

@objc public protocol MeshSDKProvisionDelegate: AnyObject {
    //输入public Key
    @objc optional func inputPublicKey(handler: @escaping ((String) -> Void))
    
    //输入配网的mesh地址
    @objc optional func inputUnicastAddress(elementNum: Int, handler: @escaping ((Int) -> Void))
    
    //provision step
    @objc optional func meshProvisionProcess(step: Int)
    //provision finish
    @objc optional func meshProvisionFinish(error: NSError?)
    
}

public enum UnprovisionedDeviceProvisionStep:Int {
    case BeginBluetoothConnection = 0
    case InitialiseBluettothService = 1
    case BeginConnectingToMesh = 2
    case BeginCongifureMeshParams = 3
    case FetchDeviceIdentity = 4
}

//配网过程中的消息
extension MeshSDK {
    
    func mxProvisioningTimeStart(){
        self.provisioningNum = 0
        self.provisionTimer?.cancel()
        self.provisionTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        self.provisionTimer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(100))
        self.provisionTimer?.setEventHandler {
            DispatchQueue.main.async {
                self.provisioningNum += 1
                if self.phase == .connecting, self.provisioningNum >= 8 {
                    self.provisionConnectTimeout()
                } else if self.provisioningNum >= 30 {
                    self.provisionFail(code: 20000)
                }
            }
        }
        self.provisionTimer?.resume()
    }
    
    /*
    开始配网
    @param device 设备广播包信息
    @param peripheral CBPeripheral
    @param networkKey
    */
    public func startUnprovisionedDeviceProvision(device: UnprovisionedDevice, peripheral: CBPeripheral, networkKey: String) {
        //先断开mesh连接
        self.disconnect()
        //开始计时
        self.mxProvisioningTimeStart()
        //连接
        self.connectUnprovisionedDevice(device: device, peripheral: peripheral, networkKey: networkKey) { [weak self] (isSuccess : Bool) in
            if isSuccess {
                //设备识别
                self?.identifyNode { [weak self] (isSuccess : Bool) in
                    if isSuccess {
                        let elementNum = Int(self?.provisioningManager?.provisioningCapabilities?.numberOfElements ?? 1)
                        self?.provisionElementNum = elementNum
                        //获取地址
                        if (self?.provisionDelegate?.inputUnicastAddress?(elementNum: elementNum, handler: { [weak self] (address: Int) in
                            self?.setProvisionUnicastAddress(address: address) { [weak self] (isSuccess : Bool) in
                                if isSuccess {
                                    //开始认证
                                    self?.startProvisioning { [weak self] (isSuccess : Bool) in
                                        if isSuccess {
                                            //获取CompositionData和ttl
                                            self?.getProvisionCompositionData { [weak self] (isSuccess : Bool) in
                                                if isSuccess {
                                                    //绑定appkey
                                                    self?.bindApplicationKey { [weak self] (isSuccess: Bool) in
                                                        if isSuccess {
                                                            self?.resetPhaseToIdling()
                                                            self?.provisionDelegate?.meshProvisionFinish?(error: nil)
                                                        } else {
                                                            self?.provisionFail(code: 20007)
                                                        }
                                                    }
                                                } else {
                                                    self?.provisionFail(code: 20006)
                                                }
                                            }
                                        } else {
                                            self?.provisionFail(code: 20005)
                                        }
                                    }
                                } else {
                                    self?.provisionFail(code: 20004)
                                }
                            }
                        })) == nil {  //如果没有实现代理
                            self?.setProvisionUnicastAddress(address: 0) { [weak self] (isSuccess : Bool) in
                                if isSuccess {
                                    self?.startProvisioning { [weak self] (isSuccess : Bool) in
                                        if isSuccess {
                                            self?.getProvisionCompositionData { [weak self] (isSuccess : Bool) in
                                                if isSuccess {
                                                    self?.bindApplicationKey { [weak self] (isSuccess: Bool) in
                                                        if isSuccess {
                                                            self?.provisionDelegate?.meshProvisionFinish?(error: nil)
                                                        } else {
                                                            self?.provisionFail(code: 20007)
                                                        }
                                                    }
                                                } else {
                                                    self?.provisionFail(code: 20006)
                                                }
                                            }
                                        } else {
                                            self?.provisionFail(code: 20005)
                                        }
                                    }
                                } else {
                                    self?.provisionFail(code: 20004)
                                }
                            }
                        }
                    } else {
                        self?.provisionFail(code: 20003)
                    }
                }
            } else {
                self?.provisionFail(code: 20002)
            }
        }
    }
    
    /*
    开始配网
    @param mac 设备的mac地址
    @param networkKey
    */
    public func startUnprovisionedDeviceProvision(mac: String, networkKey: String) {
        MXMeshDeviceScan.sharedInstance.scanDevice(mac: mac, timeout: 0) { [weak self] (list : [[String : Any]]) in
            guard let deviceInfo = list.first else {
                self?.provisionFail(code: 20001)
                return
            }
            
            guard let device = deviceInfo["device"] as? UnprovisionedDevice, let peripheral = deviceInfo["peripheral"] as? CBPeripheral   else {
                self?.provisionFail(code: 20001)
                return
            }
            
            self?.startUnprovisionedDeviceProvision(device: device, peripheral: peripheral, networkKey: networkKey)
        }
    }
    
    /*
    开始配网
    @param advertisementData 广播包数据
    @param peripheral 蓝牙对象
    @param networkKey
    */
    public func startUnprovisionedDeviceProvision(advertisementData: [String : Any], peripheral: CBPeripheral, networkKey: String, provisioningDelegate: MeshSDKProvisionDelegate? = nil, oobDelegate: MeshSDKOOBProvisioningDelegate? = nil) {
        self.provisionDelegate = provisioningDelegate
        self.oobProvisioningDelegate = oobDelegate
        if let device = UnprovisionedDevice(advertisementData: advertisementData) {
            self.startUnprovisionedDeviceProvision(device: device, peripheral: peripheral, networkKey: networkKey)
        }
    }
    
    /*
    开始配网
    @param mac 设备的mac地址
    @param networkKey
    */
    public func startUnprovisionedDeviceProvision(mac: String, networkKey: String, provisioningDelegate: MeshSDKProvisionDelegate? = nil, oobDelegate: MeshSDKOOBProvisioningDelegate? = nil) {
        self.provisionDelegate = provisioningDelegate
        self.oobProvisioningDelegate = oobDelegate
        MXMeshDeviceScan.sharedInstance.scanDevice(mac: mac, timeout: 0) { [weak self] (list : [[String : Any]]) in
            guard let deviceInfo = list.first else {
                self?.provisionFail(code: 20001)
                return
            }
            
            guard let device = deviceInfo["device"] as? UnprovisionedDevice, let peripheral = deviceInfo["peripheral"] as? CBPeripheral   else {
                self?.provisionFail(code: 20001)
                return
            }
            
            self?.startUnprovisionedDeviceProvision(device: device, peripheral: peripheral, networkKey: networkKey)
        }
    }
    
    func provisionConnectTimeout() {
        self.provisionFail(code: 20010)
    }
    
    func provisionFail(code: Int) {
        var errorMsg = ""
        switch code {
        case 20000:
            errorMsg = "配网超时"
        case 20001:
            errorMsg = "未搜索到设备"
        case 20002:
            errorMsg = "连接失败"
        case 20003:
            errorMsg = "认证失败"
        case 20004:
            errorMsg = "mesh地址无效"
        case 20005:
            errorMsg = "Provisioning失败"
        case 20006:
            errorMsg = "获取CompositionData失败"
        case 20007:
            errorMsg = "绑定appKey失败"
        case 20010:
            errorMsg = "连接超时"
        default:
            errorMsg = "未知错误"
        }
        print("配网失败：\(errorMsg)")
        let error = NSError(domain: errorMsg, code: code, userInfo: nil)
        self.resetPhaseToIdling()
        self.provisionDelegate?.meshProvisionFinish?(error: error)
    }
    
    /*
    连接配网设备
    @param device 设备广播包信息
    @param peripheral CBPeripheral
    @param networkKey
    @callback Bool 是否成功
    */
    public func connectUnprovisionedDevice(device: UnprovisionedDevice, peripheral: CBPeripheral, networkKey: String, callback: @escaping MXMeshProvisionCallback) {
        MXMeshDeviceScan.sharedInstance.stopScan()
        self.provisionUUID = device.uuid.uuidString
        self.connectUnprovisionedDeviceCallback = callback
        // 首先检查是否在网络中，如果有先移除
        if let node = lookupNode(uuid: self.provisionUUID!) {
            meshNetworkManager.meshNetwork!.remove(node: node)
            _ = meshNetworkManager.save()
            
            self.connectUnprovisionedDevice(device: device, peripheral: peripheral, networkKey: networkKey, callback: callback)
            return
        }
        
        phase = .connecting // 进入连接阶段
        self.unprovisionedDevice = device
        self.provisioningNK = networkKey
        self.bearer = MXPBGattBearer(target:peripheral)
        self.bearer?.delegate = self
        self.bearer?.logger = self
        self.bearer?.open()
    }
    
    /*
    设备身份信息校验
    @callback Bool 是否成功
    */
    public func identifyNode(callback: @escaping MXMeshProvisionCallback) {
        guard (self.unprovisionedDevice) != nil else {
            callback(false)
            return
        }
        guard (self.bearer) != nil else {
            callback(false)
            return
        }
        self.identifyNodeCallback = callback
        let network = meshNetworkManager.meshNetwork!
        provisioningManager = network.provision(unprovisionedDevice: self.unprovisionedDevice!, over: self.bearer!)
        provisioningManager?.delegate = self
        provisioningManager?.logger = self
        do {
            try self.provisioningManager?.identify(andAttractFor: 5)
            phase = .identifying
        } catch {
            self.bearer?.close()
        }
    }
    
    /*
    设置配网的地址
    @param address int
    @callback Bool 是否成功
    */
    public func setProvisionUnicastAddress(address:Int, callback: @escaping MXMeshProvisionCallback) {
        if address > 0 {
            self.provisioningManager?.unicastAddress = Address(String(format: "%04X", address), radix: 16)
        } else {
            if let lastNode = meshNetworkManager.meshNetwork!.nodes.last {
                let nexAddress = lastNode.unicastAddress + 1
                self.provisioningManager?.unicastAddress = Address(String(format: "%04X", nexAddress), radix: 16)
            }
        }
        
        let addressValid = self.provisioningManager?.isUnicastAddressValid == true
        if !addressValid {
            self.provisioningManager?.unicastAddress = nil
        }
        print("Address \(self.provisioningManager?.unicastAddress?.asString() ?? "No address available")")
        
        if self.provisioningManager?.isUnicastAddressValid == false {
            print("No available Unicast Address in Provisioner's range.")
            callback(false)
            return
        }
        
        if self.provisioningManager?.isDeviceSupported == false  {
            print("Selected device is not supported.")
            callback(false)
            return
        }
        
        callback(true)
    }
    
    /*
    开始认证
    @param  networkKey
    @callback Bool 是否成功
    */
    public func startProvisioning(callback: @escaping MXMeshProvisionCallback) {
        guard let networkKey = self.provisioningNK else {
            callback(false)
            return
        }
        guard let capabilities = provisioningManager?.provisioningCapabilities else {
            callback(false)
            return
        }
        
        let publicKeyNotAvailble = capabilities.publicKeyType.isEmpty
        print("\(publicKeyNotAvailble)")
        guard publicKeyNotAvailble || publicKey != nil else {
            if self.provisionDelegate?.inputPublicKey?(handler: { (key : String) in
                let keyData = Data(hex: key)
                self.publicKey = .oobPublicKey(key: keyData)
                self.startProvisioning(callback: callback)
            }) == nil {
                // TODO: 给出一个失败的回调
                callback(false)
            }
            return
        }
        
        publicKey = publicKey ?? .noOobPublicKey
        if capabilities.staticOobType.contains(.staticOobInformationAvailable) {
            self.authenticationMethod = .staticOob
        }
        
        if self.oobProvisioningDelegate == nil {
            authenticationMethod = .noOob
        }
        
        if authenticationMethod == nil {
            authenticationMethod = .noOob
        }
        
        
        self.provisioningStatusCallback = callback
        
        if let provisioningNetworkKey: NetworkKey = meshNetworkManager.meshNetwork!.networkKeys.first(where: { $0.key.hex == networkKey.uppercased() }) {
            self.provisioningManager?.networkKey = provisioningNetworkKey
            do {
                phase = .provisioning
                try self.provisioningManager?.provision(usingAlgorithm: .fipsP256EllipticCurve,
                                                       publicKey: self.publicKey!,
                                                       authenticationMethod: self.authenticationMethod!)
            } catch {
                self.bearer?.close()
            }

        }
    }
    /*
     获取配网设备的CompositionData
     @param uuid 设备唯一标识
     */
    public func getProvisionCompositionData(callback: @escaping MXMeshProvisionCallback) {
        self.getProvisionCompositionDataCallback = callback
        self.getCompositionData(uuid: self.provisionUUID) { [weak self] (isSuccess : Bool) in
            if isSuccess {
                self?.getTtl(uuid: self?.provisionUUID, callback: { [weak self] (isSuccess : Bool) in
                    self?.getProvisionCompositionDataCallback?(isSuccess)
                    self?.getProvisionCompositionDataCallback = nil
                })
            } else {
                self?.getProvisionCompositionDataCallback?(false)
                self?.getProvisionCompositionDataCallback = nil
            }
        }
    }
    
    /*
    添加app key
    @param  uuid
    @callback Bool 是否成功
    */
    public func bindApplicationKey(callback: @escaping MXMeshProvisionCallback) {
        guard let nk = self.provisioningNK else {
            callback(false)
            return
        }
        guard let applicationKey = self.getAllApplicationKey(networkKey: nk).first else {
            callback(false)
            return
        }
        self.bindApplicationKeyCallback = callback
        self.addApplicationKeyForNode(appKey: applicationKey, uuid: self.provisionUUID) { [weak self] (isSuccess1 :Bool) in
            if isSuccess1 {
                self?.bindApplicationKeyCallback?(true)
                self?.bindApplicationKeyCallback = nil
            } else {
                self?.bindApplicationKeyCallback?(false)
                self?.bindApplicationKeyCallback = nil
            }
        }
    }
}

// MARK: - Provision
extension MeshSDK: ProvisioningDelegate {
    
    public func authenticationActionRequired(_ action: AuthAction) {
        switch action {
        case let .provideStaticKey(callback: callback):
            
            if let confirmation_key = self.provisioningManager?.getConfirmationKey() {
                self.oobProvisioningDelegate?.inputExchangeInformation?(confirmationKey: confirmation_key, handler: { [weak self] (random : String?, confirmation: String?, authValue: String? ) in
                    if let provisionerRandom = random {
                        let randomData = Data(hex: provisionerRandom)
                        self?.provisioningManager?.updateProvisionerRandom(random: randomData)
                    }
                    
                    if let provisionerConfirmation = confirmation {
                        let confirmationData = Data(hex: provisionerConfirmation)
                        self?.provisioningManager?.sendProvisionerConfirmation(confirmation: confirmationData)
                    } else if  let key = authValue {
                        let keyData = Data(hex: key)
                        callback(keyData)
                    } else {
                        
                    }
                })
            }
            
            self.provisioningManager?.setOOBCheckCallBack(callback: { [weak self] (provisionerRandom : Data, deviceConfirmation: Data, deviceRandom : Data) in
                
                if self?.oobProvisioningDelegate?.checkStaticOOBDeviceInfo?(provisionerRandom: provisionerRandom.hex, deviceConfirmation: deviceConfirmation.hex, deviceRandom: deviceRandom.hex, handler: { [weak self] (isSuccess: Bool) in
                    if isSuccess {
                        self?.provisioningManager?.checkStaticOOBInfoSuccess()
                    } else {
                        self?.provisioningStatusCallback?(false)
                        self?.provisioningStatusCallback = nil
                    }
                }) == nil {
                    self?.provisioningStatusCallback?(false)
                    self?.provisioningStatusCallback = nil
                }
            })
            break
        case .provideNumeric(maximumNumberOfDigits: _, outputAction: _, callback: _):
            break
        case .provideAlphanumeric(maximumNumberOfCharacters: _, callback: _):
            break
        case .displayNumber(_, inputAction: _):
            break
        case .displayAlphanumeric(_):
            break
        }
    }
    
    public func inputComplete() {
        print("inputComplete\nProvisioning...")
    }
    
    public func provisioningState(of unprovisionedDevice: UnprovisionedDevice, didChangeTo state: ProvisioningState) {
        switch state {
        case .requestingCapabilities:
            print("Identifying...")
            self.provisionDelegate?.meshProvisionProcess?(step: UnprovisionedDeviceProvisionStep.BeginConnectingToMesh.rawValue)
        case .capabilitiesReceived(let capabilities):
            print("\(capabilities.numberOfElements)")
            print("\(capabilities.algorithms)")
            print("\(capabilities.publicKeyType)")
            print("\(capabilities.staticOobType)")
            print("\(capabilities.outputOobSize)")
            print("\(capabilities.outputOobActions)")
            print("\(capabilities.inputOobSize)")
            print("\(capabilities.inputOobActions)")
            //let capabilitiesWereAlreadyReceived = self.capabilitiesReceived
            self.capabilitiesReceived = true
            self.identifyNodeCallback?(true)
            self.identifyNodeCallback = nil
            
            
        case .complete:
            print("[MeshSDK] Provisioning Complete")
//            self.bearer.close()
            if ((self.bearer?.switchToProxyBearer()) != nil) {
//                self.provisioningManager.bearer(self.bearer, didClose: nil)
//                connection.use(proxy: self.bearer)
                self.provisioningManager?.removeBearer()
            } else {
                self.bearer?.close()
            }
        case let .fail(error):
            print(error)
            self.provisioningStatusCallback?(false)
            self.provisioningStatusCallback = nil
        default:
            break
        }
    }
}

extension MeshSDK: GattBearerDelegate {
    public func bearer(_ bearer: Bearer, didClose error: Error?) {
        if case .complete = provisioningManager?.state {
            connection!.open()
            if meshNetworkManager.save() {
                print("[MeshSDK] Provisioning 阶段已经完成")
//                meshNetworkDidChange()
                self.provisioningStatusCallback?(true)
            } else {
                self.provisioningStatusCallback?(false)
            }
            self.provisioningStatusCallback = nil
        } else {
            if self.phase != .idling { //配网状态
                self.provisioningStatusCallback?(false)
                self.provisioningStatusCallback = nil
            }
        }
    }
    
    public func bearerDidSwitchedToProxy(_ bearer: Bearer) {
        connection.currentBearerName = bearer.name
        if self.bearer != nil {
            connection.use(proxy: self.bearer!)
            self.bearer = nil
        }
        if meshNetworkManager.save() {
            print("[MeshSDK] Provisioning 阶段已经完成")
                //meshNetworkDidChange()
            self.provisioningStatusCallback?(true)
        } else {
            self.provisioningStatusCallback?(false)
        }
        self.provisioningStatusCallback = nil
    }
    
    public func bearerDidOpen(_ bearer: Bearer) {
        if phase == .connecting {
            print("[MeshSDK] 准备进入识别阶段")
            //self.bearer = bearer as? MXPBGattBearer
            self.connectUnprovisionedDeviceCallback?(true)
            self.connectUnprovisionedDeviceCallback = nil
        }
    }
    
    public func bearerDidDiscoverServices(_ bearer: Bearer) {
        if phase == .connecting {
//            print("Initializing...")
            print("[MeshSDK] 已经发现服务，正在初始化...");
            self.provisionDelegate?.meshProvisionProcess?(step: UnprovisionedDeviceProvisionStep.InitialiseBluettothService.rawValue)
        }
    }
    
    public func bearerDidConnect(_ bearer: Bearer) {
        self.provisionDelegate?.meshProvisionProcess?(step: UnprovisionedDeviceProvisionStep.BeginBluetoothConnection.rawValue)
        if phase == .connecting {
//            print("Discovering services...")
            print("[MeshSDK] 正在搜索发现服务...")
        }
    }

}

extension MeshSDK {
    
    @objc func proxyDidSetup() {
        self.provisioningStatusCallback?(true)
        self.provisioningStatusCallback = nil
    }
    
}

//配网过程中的消息
extension MeshSDK {
     func getProvisionedNodes(callback: @escaping LocalProvisionedDevicesCallback) {
        let network = meshNetworkManager.meshNetwork!
        let unConfiguredNodes = network.nodes.filter({ !$0.isConfigComplete && !$0.isProvisioner })
        var devices = [[String: Any]]()
        
        var elementArray = [[String: Any]]()
        unConfiguredNodes.forEach { node in
            
            node.elements.forEach { element in
                
                var elementDict = [String: Any]()
                elementDict["elementAddress"] = element.unicastAddress.asString()
                var models = [[String: Any]]()
                element.models.forEach({ model in
                    let modelDict = ["modelId": model.modelIdentifier.asString()]
                    models.append(modelDict)
                })
                elementDict["models"] = models
                elementArray.append(elementDict)
            }
            
            
            let device = ["name": node.name ?? "Unknown Device",
                          "uuid": node.uuid.uuidString,
                          "elements": elementArray] as [String : Any]
            devices.append(device as [String : Any])
        }
        callback(devices)
    }
    
    func getCompositionData(uuid: String?, callback: @escaping MXMeshProvisionCallback) {
        guard let uuid = uuid else {
            callback(false)
            return
        }
        self.provisionDelegate?.meshProvisionProcess?(step: UnprovisionedDeviceProvisionStep.BeginCongifureMeshParams.rawValue)
        phase = .configuring
        configCompositionDataStatusCB = callback
        let message = ConfigCompositionDataGet()
        meshNetworkManager.delegate = self
        if let node = lookupNode(uuid: uuid) {
            _ = try? meshNetworkManager.send(message, to: node)
        }
    }
    
    func getTtl(uuid: String?, callback: @escaping MXMeshProvisionCallback) {
        guard let uuid = uuid else {
            callback(false)
            return
        }
        self.getTTLCallback = callback
        let message = ConfigDefaultTtlGet()
        if let node = lookupNode(uuid: uuid) {
            _ = try? meshNetworkManager.send(message, to: node)
        }
    }
    //配网结束
    public func resetPhaseToIdling() {
        self.provisionTimer?.cancel()
        self.provisioningNum = 0
        phase = .idling
        self.bearer?.close()
        self.bearer = nil
        self.capabilitiesReceived = false
        self.provisionUUID = nil
        self.provisioningNK = nil
        self.unprovisionedDevice = nil
        self.provisionElementNum = 1
    }
    
    //配网结束
    public func mxMeshProvisionFinish() {
        self.resetPhaseToIdling()
        self.oobProvisioningDelegate = nil
        self.provisionDelegate = nil
    }
}

extension MeshNetwork {
    func provision(unprovisionedDevice: UnprovisionedDevice, over bearer: ProvisioningBearer) -> ProvisioningManager {
        return ProvisioningManager(for: unprovisionedDevice, over: bearer, in: self)
    }
}
