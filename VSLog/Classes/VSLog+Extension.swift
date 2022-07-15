//
//  VSLogInterface.swift
//  VSLog
//
//  Created by StephenFang on 2022/3/28.
//

import Foundation
import CocoaLumberjack

// MARK: - 枚举类型扩展
extension Log.Enum {
    /// 日志等级
    enum Level {
        /// 不使用
        case verbose
        /// 在debug过程中需要使用到的日志语句，仅用作调试用
        case debug
        /// 用户行为、网络日志、视图信息、蓝牙数据、数据库等展示APP工作过程的信息
        case info
        /// APP运行过程中不希望出现的运行结果或过程，如设备配网失败，网络请求失败
        case warning
        /// 错误
        case error
    }
}

extension Log.Enum.Level {
    var toFlag: DDLogFlag {
        switch self {
        case .verbose:
            return DDLogFlag.verbose
        case .debug:
            return DDLogFlag.debug
        case .info:
            return DDLogFlag.info
        case .warning:
            return DDLogFlag.warning
        case .error:
            return DDLogFlag.error
        }
    }
    
    var toLevel: DDLogLevel {
        switch self {
        case .verbose:
            return DDLogLevel.verbose
        case .debug:
            return DDLogLevel.debug
        case .info:
            return DDLogLevel.info
        case .warning:
            return DDLogLevel.warning
        case .error:
            return DDLogLevel.error
        }
    }
}


extension Log.Enum.Category {
    var context: Int {
        switch self {
        case .ble:
            return (1 << 0)
        case .database:
            return (1 << 1)
        case .netWork:
            return (1 << 2)
        case .view:
            return (1 << 3)
        case .action:
            return (1 << 4)
        case .crash:
            return (1 << 5)
        case .custom(_):
            return (1 << 6)
        }
    }
    
    var description: String {
        switch self {
        case .ble:
            return "ble"
        case .database:
            return "database"
        case .netWork:
            return "network"
        case .view:
            return "view"
        case .action:
            return "action"
        case .crash:
            return "crash"
        case .custom(let value):
            return "custom_\(value)"
        }
    }
}

extension Log.Enum.OCCategory {
    var description: String {
        switch self {
        case .ble:
            return "ble"
        case .database:
            return "database"
        case .netWork:
            return "network"
        case .view:
            return "view"
        case .action:
            return "action"
        case .crash:
            return "crash"
        case .other:
            return "other"
        }
    }
}
