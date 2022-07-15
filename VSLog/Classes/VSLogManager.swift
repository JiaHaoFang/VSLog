//
//  VSLogManager.swift
//  VSLog
//
//  Created by StephenFang on 2022/3/28.
//

import Foundation
import CocoaLumberjack

public final class VSLogManager: NSObject {
    // MARK: - 命名空间及变量
    /// 枚举
    public struct Enum { }
    /// 格式化类
    struct Formatter { }
    
    // MARK: - 变量
    /// 日志文件最大大小，默认为10mb
    private var maxFileSize: UInt64 = 1024*1024*10
    /// 日志文件最大个数
    private var maxFileNum: UInt = 10
    /// 白名单列表
    private(set) var allowList: [String: [String]] = [:]
    /// 白名单开关状态
    private(set) var allowListEnabled: [String: Bool] = [:]
    /// 黑名单列表
    private(set) var denyList: [String: [String]] = [:]
    /// 黑名单开关状态
    private(set) var denyListEnabled: [String: Bool] = [:]
    
    /// 控制台输出的信息选项
    var consoleConfig: [VSLogManager.Enum.ConfigOption: Bool] = {
        var param: [VSLogManager.Enum.ConfigOption: Bool] = [:]
        for option in VSLogManager.Enum.ConfigOption.allCases {
            switch option {
            case .timestamp, .level, .category, .message, .userInfo, .business:
                param.updateValue(true, forKey: option)
            default:
                param.updateValue(false, forKey: option)
            }
        }
        return param
    }()
    
    /// 日志文件输出的信息选项
    var fileConfig: [VSLogManager.Enum.ConfigOption: Bool] = {
        var param: [VSLogManager.Enum.ConfigOption: Bool] = [:]
        for option in VSLogManager.Enum.ConfigOption.allCases {
            switch option {
            case .timestamp, .level, .category, .message, .userInfo, .appVersion, .osVersion, .enviroment:
                param.updateValue(true, forKey: option)
            default:
                param.updateValue(false, forKey: option)
            }
        }
        return param
    }()
    /// 日期格式
    lazy var dateFormatter: DateFormatter = {
        let item = DateFormatter()
        item.dateFormat = "yyyy-MM-dd HH:mm:ss"
        item.timeZone = TimeZone.current
        return item
    }()
    
    // MARK: -  生命周期
    private static var _sharedInstance: VSLogManager?
    private override init() {
        // 控制台
        if let tty = DDTTYLogger.sharedInstance {
            tty.logFormatter = VSLogManager.Formatter.console()
#if DEBUG
            DDLog.add(tty, with: Log.Enum.Level.debug.toLevel)
#else
            DDLog.add(tty, with: Log.Enum.Level.info.toLevel)
#endif
        }
        
        // 文件
        let path = NSHomeDirectory().appending("/Documents/VSLogger")
        let def = DDLogFileManagerDefault.init(logsDirectory: path)
        let fileLogger: DDFileLogger = DDFileLogger.init(logFileManager: def)
        fileLogger.logFormatter = VSLogManager.Formatter.file()
        fileLogger.maximumFileSize = self.maxFileSize
        fileLogger.rollingFrequency = 0
        fileLogger.logFileManager.maximumNumberOfLogFiles = self.maxFileNum
        DDLog.add(fileLogger, with: Log.Enum.Level.info.toLevel)
        
#if DEBUG
        // 黑名单白名单初始化
        self.allowList = [Enum.FilterListType.category.key: [],
                          Enum.FilterListType.business.key: []]
        self.denyList = [Enum.FilterListType.category.key: [],
                         Enum.FilterListType.business.key: []]
        self.allowListEnabled = [Enum.FilterListType.category.key: false,
                                 Enum.FilterListType.business.key: false]
        self.allowListEnabled = [Enum.FilterListType.category.key: false,
                                 Enum.FilterListType.business.key: false]
#endif
    }
    /// 获取单例对象
    public class func sharedInstance() -> VSLogManager {
        guard let instance = _sharedInstance else {
            _sharedInstance = VSLogManager()
            return _sharedInstance!
        }
        return instance
    }
}

// MARK: - 日志输出相关方法
extension VSLogManager {
    /// 控制台输出的信息选项开关
    public func setConsoleConfig(option: VSLogManager.Enum.ConfigOption, enable: Bool) {
        self.consoleConfig.updateValue(enable, forKey: option)
    }
    
    /// 日志文件输出的信息选项开关
    public func setFileConfig(option: VSLogManager.Enum.ConfigOption, enable: Bool) {
        self.fileConfig.updateValue(enable, forKey: option)
    }
}

// MARK: - 白名单相关方法
extension VSLogManager {
    /// 开启/关闭白名单功能，
    public func updateAllowList(_ types: [Enum.FilterListType], state: Bool) {
        if state == true {
            types.forEach { type in
                self.allowListEnabled[type.key] = true
                self.denyListEnabled[type.key] = false
            }
        } else {
            types.forEach { type in
                self.allowListEnabled[type.key] = false
            }
        }
    }
    
    /// 设置白名单成员-Category
    public func addCategoryAllowListMember(_ value: [Log.Enum.Category]) {
        if var list = self.allowList[Enum.FilterListType.category.key] {
            list.append(contentsOf: value.map({ $0.description }).filter({ !list.contains($0) }))
            self.allowList[Enum.FilterListType.category.key] = list
        }
    }
    
    /// 设置白名单成员-Business，参数需与业务板块名称（命名空间）保持一致
    public func addBusinessAllowListMember(_ value: [String]) {
        if var list = self.allowList[Enum.FilterListType.business.key] {
            list.append(contentsOf: value.map({ $0.description }).filter({ !list.contains($0) }))
            self.allowList[Enum.FilterListType.business.key] = list
        }
    }
    
    /// 清空白名单成员
    public func removeAllAllowList() {
        if var list = self.allowList[Enum.FilterListType.category.key] {
            list.removeAll()
        }
        if var list = self.allowList[Enum.FilterListType.business.key] {
            list.removeAll()
        }
    }
}

// MARK: - 黑名单相关方法
extension VSLogManager {
    /// 开启黑名单功能
    public func updateDenyList(_ type: Enum.FilterListType, state: Bool) {
        if state == true {
            self.allowListEnabled[type.key] = false
            self.denyListEnabled[type.key] = true
        } else {
            self.denyListEnabled[type.key] = false
        }
    }
    
    /// 设置黑名单成员-Category
    public func addCategoryDenyListMember(_ value: [Log.Enum.Category]) {
        if var list = self.denyList[Enum.FilterListType.category.key] {
            list.append(contentsOf: value.map({ $0.description }).filter({ !list.contains($0) }))
        }
    }
    
    /// 设置黑名单成员-Business，参数需与业务板块名称（命名空间）保持一致
    public func addBusinessDenyListMember(_ value: [String]) {
        if var list = self.denyList[Enum.FilterListType.business.key] {
            list.append(contentsOf: value.map({ $0.description }).filter({ !list.contains($0) }))
        }
    }
    
    /// 清空黑名单成员
    public func removeAllDenyList() {
        if var list = self.denyList[Enum.FilterListType.category.key] {
            list.removeAll()
        }
        if var list = self.denyList[Enum.FilterListType.business.key] {
            list.removeAll()
        }
    }
}

// MARK: - 枚举
extension VSLogManager.Enum {
    /// 支持黑名单、白名单过滤的筛选维度
    public enum FilterListType: Int, CaseIterable {
        case category = 0
        case business
    }
    
    /// 日志输出可选项，带星号的为必选
    public enum ConfigOption: Int, CaseIterable {
        // 时间戳*
        case timestamp = 0
        // 日志等级*
        case level
        // 日志类别*
        case category
        // 信息*
        case message
        // 附加信息*, 用于日志文件输出的字典Key的索引，方便后续扩展到可视化工具
        case userInfo
        // 业务板块
        case business
        
        // app版本，用于日志文件
        case appVersion
        // iOS系统版本，用于日志文件
        case osVersion
        // app环境，用于日志文件
        case enviroment
        // 所在类名
        case funcName
        // 所在文件名
        case fileName
        // 所在行数
        case lineNum
        /// 线程ID
        case threadID
        /// 线程名
        case threadName
        /// 队列名
        case queueName
    }
}
