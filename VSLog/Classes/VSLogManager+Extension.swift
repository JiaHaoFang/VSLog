//
//  VSLogManager+Extension.swift
//  VSLog
//
//  Created by StephenFang on 2022/5/26.
//

import Foundation
import CocoaLumberjack

// MARK: - Logger
extension VSLogManager {
    internal func log(level: Log.Enum.Level,
                      category: Log.Enum.Category,
                      message: String,
                      business: String,
                      userInfo: [String: String]?,
                      file: String,
                      function: String,
                      line: UInt) {
        self.action(level: level, category: category, message: message, business: business, userInfo: userInfo, file: file, function: function, line: line)
    }
    
    private func action(level: Log.Enum.Level,
                        category: Log.Enum.Category,
                        message: String,
                        business: String,
                        userInfo: [String: String]?,
                        file: String,
                        function: String,
                        line: UInt) {
#if DEBUG
        // 进行白名单过滤
        for type in Enum.FilterListType.allCases {
            if let enabled = self.allowListEnabled[type.key],
               let list = self.allowList[type.key],
               enabled == true {
                switch type {
                case .business:
                    guard list.contains(business) else { return }
                case .category:
                    guard list.contains(category.description) else { return }
                }
            }
        }
        // 进行黑名单过滤
        for type in Enum.FilterListType.allCases {
            if let enabled = self.denyListEnabled[type.key],
               let list = self.denyList[type.key],
               enabled == true {
                switch type {
                case .business:
                    guard !list.contains(business) else { return }
                case .category:
                    guard !list.contains(category.description) else { return }
                }
            }
        }
#endif
        var dic: [String: Any] = [:]
        dic.updateValue(category.description, forKey: VSLogManager.Enum.ConfigOption.category.description)
        dic.updateValue(business, forKey: VSLogManager.Enum.ConfigOption.business.description)
        if let userInfo = userInfo {
            dic.updateValue(userInfo, forKey: VSLogManager.Enum.ConfigOption.userInfo.description)
        }
        let msg = DDLogMessage.init(message: message,
                                    level: .info,
                                    flag: level.toFlag,
                                    context: category.context,
                                    file: file,
                                    function: function,
                                    line: line,
                                    tag: dic,
                                    options: [.copyFile, .copyFunction],
                                    timestamp: nil)
        DDLog.log(asynchronous: true, message: msg)
    }
}

// MARK: - Formatter
extension VSLogManager.Formatter {
    class console: NSObject, DDLogFormatter {
        func format(message logMessage: DDLogMessage) -> String? {
            // 组装头部必要信息
            var format: String = ""
            VSLogManager.sharedInstance().consoleConfig
                .filter({ ($0.value == true) && ($0.key != .message) && ($0.key != .userInfo) })
                .sorted(by: { $0.key.rawValue < $1.key.rawValue })
                .map({ "[\($0.key.description):\($0.key.toMessage(msg: logMessage))] " })
                .forEach({ format.append($0) })
            
            // 组装日志主体
            format.append("👉\(logMessage.message)")
            if VSLogManager.Enum.ConfigOption.userInfo.toMessage(msg: logMessage) != "" {
                format.append("🔍\(VSLogManager.Enum.ConfigOption.userInfo.toMessage(msg: logMessage))")
            }
            return format
        }
    }
    
    class file: NSObject, DDLogFormatter {
        func format(message logMessage: DDLogMessage) -> String? {
            // 组装头部必要信息
            var format: [String: Any] = [:]
            VSLogManager.sharedInstance().fileConfig
                .filter({ ($0.value == true) && ($0.key != .message)})
                .sorted(by: { $0.key.rawValue < $1.key.rawValue })
                .forEach({ format.updateValue($0.key.toMessage(msg: logMessage),
                                              forKey: $0.key.description) })
            return self.dicValueString(format)
        }
        
        /// 字典转字符串工具类
        private func dicValueString(_ dic:[String: Any]) -> String? {
            let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
            let str = String(data: data!, encoding: String.Encoding.utf8)
            return str
        }
    }
}

extension VSLogManager.Enum.FilterListType {
    var key: String {
        switch self {
        case .category:
            return "categoryFilterListKey"
        case .business:
            return "businessFilterListKey"
        }
    }
}

extension VSLogManager.Enum.ConfigOption {
    func toMessage(msg: DDLogMessage) -> String {
        switch self {
        case .timestamp:
            return self.getCurrentTime()
        case .level:
            return msg.flag.description
        case .category:
            guard let obj = msg.tag as? [String: Any],
                  let category = obj[VSLogManager.Enum.ConfigOption.category.description] as? String else { return "" }
            return category
        case .message:
            return msg.message
            // 业务板块
        case .business:
            guard let obj = msg.tag as? [String: Any],
                  let business = obj[VSLogManager.Enum.ConfigOption.business.description] as? String else { return "" }
            return business
        case .userInfo:
            guard let obj = msg.tag as? [String: Any],
                  let userInfo = obj[VSLogManager.Enum.ConfigOption.userInfo.description] as? [String: String] else { return "" }
            return "\(userInfo)"
        case .funcName:
            return msg.function ?? ""
        case .fileName:
            return msg.file
        case .lineNum:
            return "\(msg.line)"
        case .threadID:
            return msg.threadID
        case .threadName:
            return msg.threadName
        case .queueName:
            return msg.queueLabel
        case .appVersion:
            return self.getAppVersion()
        case .osVersion:
            return self.getOSVersion()
        case .enviroment:
            return ""
        }
    }
    
    var description: String {
        switch self {
        case .timestamp:
            return "time"
        case .level:
            return "level"
        case .category:
            return "category"
        case .message:
            return "message"
        case .userInfo:
            return "userInfo"
        case .business:
            return "business"
        case .appVersion:
            return "userInfo"
        case .osVersion:
            return "userInfo"
        case .enviroment:
            return "enviroment"
        case .funcName:
            return "funcName"
        case .fileName:
            return "fileName"
        case .lineNum:
            return "lineNum"
        case .threadID:
            return "threadID"
        case .threadName:
            return "threadName"
        case .queueName:
            return "queueName"
        }
    }
    
    /// 获取当前时间
    private func getCurrentTime() -> String {
        return VSLogManager.sharedInstance().dateFormatter.string(from: Date.init())
    }
    
    /// 获取APP版本
    private func getAppVersion() -> String {
        guard let kAppCurrentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        return kAppCurrentVersion
    }
    
    /// 获取系统版本
    private func getOSVersion() -> String {
        return UIDevice.current.systemName + UIDevice.current.systemVersion
    }
}

extension DDLogFlag {
    var description: String {
        switch self {
        case .verbose: return "verbose"
        case .debug: return "debug"
        case .info: return "info"
        case .warning: return "warning"
        case .error: return "error"
        default:
            return ""
        }
    }
}
