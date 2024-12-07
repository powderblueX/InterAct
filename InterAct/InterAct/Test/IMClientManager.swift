////
////  IMClientManager.swift
////  InterAct
////
////  Created by admin on 2024/12/8.
////
//
//import Foundation
//import LeanCloud
//
//class IMClientManager: NSObject {
//    static let shared = IMClientManager()
//    
//    private var client: IMClient?
//    private(set) var isClientOpen = false
//    
//    private override init() {}
//    
//    func initializeClient(for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard client == nil else {
//            completion(.success(())) // 如果已经初始化，则直接返回成功
//            return
//        }
//        
//        do {
//            let newClient = try IMClient(ID: userId)
//            newClient.delegate = self
//            self.client = newClient
//            
//            newClient.open { result in
//                switch result {
//                case .success:
//                    self.isClientOpen = true
//                    print("IMClient initialized and connected successfully.")
//                    completion(.success(()))
//                case .failure(let error):
//                    print("Failed to open IMClient: \(error.localizedDescription)")
//                    completion(.failure(error))
//                }
//            }
//        } catch {
//            print("IMClient initialization failed: \(error.localizedDescription)")
//            completion(.failure(error))
//        }
//    }
//    
//    func closeClient(completion: (() -> Void)? = nil) {
//        guard let client = client else {
//            completion?() // 如果客户端已关闭或不存在，则直接调用回调
//            return
//        }
//        
//        client.close { result in
//            switch result {
//            case .success:
//                self.isClientOpen = false
//                print("IMClient closed successfully.")
//            case .failure(let error):
//                print("Failed to close IMClient: \(error.localizedDescription)")
//            }
//            self.client = nil
//            completion?()
//        }
//    }
//    
//    func getClient() -> IMClient? {
//        return client
//    }
//    
//    // 示例：处理一些客户端的委托方法
//    func client(_ client: IMClient, event: IMClientEvent) {
//        print("Client event occurred: \(event)")
//    }
//}
//
//extension IMClientManager: IMClientDelegate {
//    func client(_ client: LeanCloud.IMClient, conversation: LeanCloud.IMConversation, event: LeanCloud.IMConversationEvent) {
//        switch event {
//        case .message(let messageEvent):
//            switch messageEvent {
//            case .received(_):
//                break
//            default:
//                break
//            }
//        default:
//            break
//        }
//    }
//}
