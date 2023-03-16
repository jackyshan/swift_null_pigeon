import Flutter
import UIKit
import ITNetLibrary

public class PushLzflutterPlugin: NSObject, FlutterPlugin, NativePushBridge {
    
    var flutterRouterApi: FlutterPushBridge?
    var pushBridge: PushBridge?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
          let plugin: PushLzflutterPlugin = PushLzflutterPlugin()
          plugin.flutterRouterApi = FlutterPushBridge(binaryMessenger: registrar.messenger())
          registrar.publish(plugin)
          NativePushBridgeSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    }
    
    func initPush(param: InitRequestParam) throws -> ResponseParam {
        let configParam = param.data
        let pushIdentifier = PushIdentifier(hostAPP: configParam.hostApp, appID: configParam.appId, deviceID: param.data.deviceId)

        pushBridge = PushBridge(pushIdentifier)
        
        return ResponseParam(code: .success)
    }
    
    func connect(param: InitRequestParam, completion: @escaping (Result<ResponseParam, Error>) -> Void) {
        let configParam = param.data
        if configParam.defaultHosts != nil {
            let defaultHosts = configParam.defaultHosts!.filter({$0 != nil && $0?.isEmpty == false}).map({$0!})
            
            pushBridge?.defaultHosts = defaultHosts
        }
        pushBridge?.connect()
        
        return completion(.success(ResponseParam(code: .success)))
    }
    
    func disconnect(param: RequestParam) throws -> ResponseParam {
        pushBridge?.disConnect()
        
        return ResponseParam(code: .success)
    }
    
    var messageObservers = [String: AnyObject]()
    
    func addConnStatusObserver(param: ObserverRequestParam) throws -> ResponseParam {
        let callbackKey = param.data.callbackKey
        if !messageObservers.keys.contains(callbackKey) {
            let handler = { [weak self] (pushStatus: PushStatus, pushError: PushError?) in
                guard let self = self else {return}
                
                var connectInfo = ConnectInfo(errorCode: Int64(pushError?.iCode ?? 0), errorMessage: pushError?.message)
                
                switch pushStatus {
                case .connected:
                    connectInfo.connStatus = .connected
                case .connecting:
                    connectInfo.connStatus = .connecting
                case .disConnected:
                    connectInfo.connStatus = .disconnect
                default:
                    break
                }
                
                self.flutterRouterApi?.onConnStatusObserverCall(param: ConnStatusObserverCallParam(key: "ConnStatusObserver_onConnStatus", data: ConnStatusCall(callbackKey: callbackKey, appId: param.data.appId, data: connectInfo)), completion: {_ in })
            }
            let observer = pushBridge?.addStatusObserver(handler: handler)
            messageObservers[callbackKey] = observer
        }
        
        return ResponseParam(code: .success)
    }
    
    func removeConnStatusObserver(param: ObserverRequestParam) throws -> ResponseParam {
        let callbackKey = param.data.callbackKey
        if let observer = messageObservers.removeValue(forKey: callbackKey) {
            pushBridge?.removeObserver(observer: observer)
        }
        
        return ResponseParam(code: .success)
    }
    
    func addPushObserver(param: ObserverRequestParam) throws -> ResponseParam {
        let callbackKey = param.data.callbackKey
        if !messageObservers.keys.contains(callbackKey) {
            let handler = { [weak self] (pushData: PushMessage.PushData) in
                guard let self = self else {return}
                
                var deviceId: String? = nil
                var alias: String? = nil
                var topic: String? = nil
                
                switch pushData.sourceType {
                case .deviceID(let deviceID):
                    deviceId = deviceID
                case .alias(let aliaS):
                    alias = aliaS
                case .topic(let topiC):
                    topic = topiC
                }
                
                let transferData = TransferData(
                    seq: pushData.payloadSeq,
                    payloadId: pushData.payloadId,
                    payload: pushData.payload as? String,
                    timestamp: Int64(pushData.serverTimestamp ?? 0),
                    deviceId: deviceId,
                    alias: alias,
                    topic: topic
                )
                
                var pushMessageData = PushMessageData(type: pushData.sourceType.name, data: transferData)
                
                self.flutterRouterApi?.onPushObserverCall(param: PushObserverCallParam(key: "PushObserver_onPush", data: PushCall(callbackKey: callbackKey, appId: param.data.appId, data: pushMessageData)), completion: {_ in })
            }
            let observer = pushBridge?.addPushMessageObserver(handler: handler)
            messageObservers[callbackKey] = observer
        }
        
        return ResponseParam(code: .success)
    }
    
    func removePushObserver(param: ObserverRequestParam) throws -> ResponseParam {
        let callbackKey = param.data.callbackKey
        if let observer = messageObservers.removeValue(forKey: callbackKey) {
            pushBridge?.removeObserver(observer: observer)
        }
        
        return ResponseParam(code: .success)
    }
    
    func setAlias(param: SetAliasRequestParam, completion: @escaping (Result<ResponseParam, Error>) -> Void) {
        let alias = param.data.alias.filter({$0 != nil && $0?.isEmpty == false}).map({$0!})
        pushBridge?.setAlias(alias: alias, completion: { error in
            if let error = error {
                completion(.success(ResponseParam(code: .fail, message: error.description)))
            }
            else {
                completion(.success(ResponseParam(code: .success)))
            }
        })
    }
    
    func clearAlias(param: RequestParam, completion: @escaping (Result<ResponseParam, Error>) -> Void) {
        pushBridge?.clearAlias(completion: { error in
            if let error = error {
                completion(.success(ResponseParam(code: .fail, message: error.description)))
            }
            else {
                completion(.success(ResponseParam(code: .success)))
            }
        })
    }
    
    func subscribeTopic(param: RequestParam) throws -> ResponseParam {
        pushBridge?.subscribe(topic: param.data?["topic"] as? String ?? "")
        
        return ResponseParam(code: .success)
    }
    
    func unsubscribeTopic(param: RequestParam) throws -> ResponseParam {
        pushBridge?.unsubscribe(topic: param.data?["topic"] as? String ?? "")
        
        return ResponseParam(code: .success)
    }
    
    func addTopicsObserver(param: ObserverRequestParam) throws -> ResponseParam {
        let callbackKey = param.data.callbackKey
        if !messageObservers.keys.contains(callbackKey) {
            let handler = { [weak self] (topic: String, pushTopicStatus: PushTopicStatus) in
                guard let self = self else {return}
                
                var topicResultStatus = TopicResultStatus(rawValue: 0)
                var code = 0
                var message: String? = ""
                switch pushTopicStatus {
                case .Invalid(let errorr):
                    topicResultStatus = .invalid
                    if let error = errorr {
                        code = error.iCode
                        message = error.message
                    }
                case .Processing(let errorr):
                    topicResultStatus = .processing
                    if let error = errorr {
                        code = error.iCode
                        message = error.message
                    }
                case .Available:
                    topicResultStatus = .available
                }
                
                let topicSubscribeResult = TopicSubscribeResult(status: topicResultStatus!, code: Int64(code), msg: message)
                self.flutterRouterApi?.onTopicObserverCall(param: TopicObserverCallParam(key: "TopicsObserver_onSubscribe", data: TopicCall(callbackKey: callbackKey, appId: param.data.appId, data: TopicSubscribeData(topic: topic, result: topicSubscribeResult)))) { _ in }
            }
            let observer = pushBridge?.addTopicStatuObserver(handler: handler)
            messageObservers[callbackKey] = observer
        }
        
        return ResponseParam(code: .success)
    }
    
    func removeTopicsObserver(param: ObserverRequestParam) throws -> ResponseParam {
        let callbackKey = param.data.callbackKey
        if let observer = messageObservers.removeValue(forKey: callbackKey) {
            pushBridge?.removeObserver(observer: observer)
        }
        
        return ResponseParam(code: .success)
    }
    
    
}
