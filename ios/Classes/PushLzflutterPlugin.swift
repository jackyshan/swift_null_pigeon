import Flutter
import UIKit

public class PushLzflutterPlugin: NSObject, FlutterPlugin, NativePushBridge {
    
    var flutterRouterApi: FlutterPushBridge?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
          let plugin: PushLzflutterPlugin = PushLzflutterPlugin()
          plugin.flutterRouterApi = FlutterPushBridge(binaryMessenger: registrar.messenger())
          registrar.publish(plugin)
          NativePushBridgeSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    }
    
    func initPush(param: InitRequestParam) throws -> ResponseParam {
        return ResponseParam(code: .success)
    }
    
    func connect(param: InitRequestParam, completion: @escaping (Result<ResponseParam, Error>) -> Void) {
        return completion(.success(ResponseParam(code: .success)))
    }
    
    func disconnect(param: RequestParam) throws -> ResponseParam {
        
        return ResponseParam(code: .success)
    }
    
    var messageObservers = [String: AnyObject]()
    
    func addConnStatusObserver(param: ObserverRequestParam) throws -> ResponseParam {
        var connectInfo = ConnectInfo(errorCode: 0, errorMessage: "")
        connectInfo.connStatus = .connected
        
        self.flutterRouterApi?.onConnStatusObserverCall(param: ConnStatusObserverCallParam(key: "ConnStatusObserver_onConnStatus", data: ConnStatusCall(callbackKey: "callbackKey", appId: param.data.appId, data: connectInfo)), completion: {_ in })

        return ResponseParam(code: .success)
    }
    
    func removeConnStatusObserver(param: ObserverRequestParam) throws -> ResponseParam {
        return ResponseParam(code: .success)
    }
    
    func addPushObserver(param: ObserverRequestParam) throws -> ResponseParam {
        self.flutterRouterApi?.onPushObserverCall(param: PushObserverCallParam(key: "PushObserver_onPush", data: PushCall(callbackKey: "callbackKey", appId: param.data.appId, data: PushMessageData())), completion: {_ in })

        return ResponseParam(code: .success)
    }
    
    func removePushObserver(param: ObserverRequestParam) throws -> ResponseParam {
        return ResponseParam(code: .success)
    }
    
    func setAlias(param: SetAliasRequestParam, completion: @escaping (Result<ResponseParam, Error>) -> Void) {
        completion(.success(ResponseParam(code: .success)))
    }
    
    func clearAlias(param: RequestParam, completion: @escaping (Result<ResponseParam, Error>) -> Void) {
        completion(.success(ResponseParam(code: .success)))
    }
    
    func subscribeTopic(param: RequestParam) throws -> ResponseParam {
        return ResponseParam(code: .success)
    }
    
    func unsubscribeTopic(param: RequestParam) throws -> ResponseParam {
        return ResponseParam(code: .success)
    }
    
    func addTopicsObserver(param: ObserverRequestParam) throws -> ResponseParam {
        let topicSubscribeResult = TopicSubscribeResult(status: TopicResultStatus.available, code: 0, msg: "message")
        self.flutterRouterApi?.onTopicObserverCall(param: TopicObserverCallParam(key: "TopicsObserver_onSubscribe", data: TopicCall(callbackKey: "callbackKey", appId: param.data.appId, data: TopicSubscribeData(topic: "TopicSubscribeResult", result: topicSubscribeResult)))) { _ in }

        return ResponseParam(code: .success)
    }
    
    func removeTopicsObserver(param: ObserverRequestParam) throws -> ResponseParam {   return ResponseParam(code: .success)
    }
    
    
}
