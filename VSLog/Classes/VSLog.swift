//
//  VSLog.swift
//  VSLog
//
//  Created by StephenFang on 2022/5/26.
//

import Foundation

public final class Log {
    /// 提供默认命名空间，各业务板块需要定义自己的命名空间
    public final class `Default`: LogProtocol { }
    
    /// 枚举类型
    public struct Enum {
        /// 日志类型
        public enum Category {
            /// 蓝牙通讯等相关
            case ble
            /// 数据库
            case database
            /// 网络通讯
            case netWork
            /// 视图相关
            case view
            /// 用户行为，统计分析
            case action
            /// 崩溃
            case crash
            /// 自定义
            case custom(String)
        }
        
        /// 提供给OC使用的日志类型
        @objc public enum OCCategory: Int {
            /// 蓝牙通讯等相关
            case ble
            /// 数据库
            case database
            /// 网络通讯
            case netWork
            /// 视图相关
            case view
            /// 用户行为，统计分析
            case action
            /// 崩溃
            case crash
            /// 其他
            case other
        }
    }
}

// MARK: - OC接口扩展
extension Log.`Default` {
    @objc static func debug(categoryOC: Log.Enum.OCCategory = .other,
                            _ message: String,
                            userInfo: [String: String]?,
                            file: String = #file,
                            function: String = #function,
                            line: UInt = #line) {
        self.debug(category: .custom(categoryOC.description), message, userInfo: userInfo, file: file, function: function, line: line)
    }
    
    @objc static func info(categoryOC: Log.Enum.OCCategory = .other,
                           _ message: String,
                           userInfo: [String: String]?,
                           file: String = #file,
                           function: String = #function,
                           line: UInt = #line) {
        self.info(category: .custom(categoryOC.description), message, userInfo: userInfo, file: file, function: function, line: line)
    }
    
    @objc static func warning(categoryOC: Log.Enum.OCCategory = .other,
                              _ message: String,
                              userInfo: [String: String]?,
                              file: String = #file,
                              function: String = #function,
                              line: UInt = #line) {
        self.warning(category: .custom(categoryOC.description), message, userInfo: userInfo, file: file, function: function, line: line)
    }
    
    
    @objc static func error(categoryOC: Log.Enum.OCCategory = .other,
                            _ message: String,
                            userInfo: [String: String]?,
                            file: String = #file,
                            function: String = #function,
                            line: UInt = #line) {
        self.error(category: .custom(categoryOC.description), message, userInfo: userInfo, file: file, function: function, line: line)
    }
}
