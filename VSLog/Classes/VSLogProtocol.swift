//
//  VSLogProtocol.swift
//  VSLog
//
//  Created by StephenFang on 2022/5/26.
//

import Foundation

public protocol LogProtocol {
    /// 命名空间，与业务名称business对应
    static func nameSpace() -> String
        
    /// debug等级的日志
    static func debug(category: Log.Enum.Category,
                      _ message: String,
                      userInfo: [String: String]?,
                      file: String,
                      function: String,
                      line: UInt)
    
    /// info等级的日志
    static func info(category: Log.Enum.Category,
                     _ message: String,
                     userInfo: [String: String]?,
                     file: String,
                     function: String,
                     line: UInt)
    
    /// warning等级的日志
    static func warning(category: Log.Enum.Category,
                        _ message: String,
                        userInfo: [String: String]?,
                        file: String,
                        function: String,
                        line: UInt)
    
    /// error等级的日志
    static func error(category: Log.Enum.Category,
                      _ message: String,
                      userInfo: [String: String]?,
                      file: String,
                      function: String,
                      line: UInt)
}

// MARK: - 协议的默认实现
extension LogProtocol {
    public static func nameSpace() -> String {
        let defaultName = "Default"
        if let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String,
           "\(Self.self)" == defaultName {
            return bundleName
        } else {
            return "\(Self.self)"
        }
    }
    
    // MARK: - swift接口
    public static func debug(category: Log.Enum.Category = .custom("other"),
                             _ message: String,
                             userInfo: [String: String]? = nil,
                             file: String = #file,
                             function: String = #function,
                             line: UInt = #line) {
        VSLogManager.sharedInstance().log(level: .debug,
                                   category: category,
                                   message: message,
                                   business: Self.nameSpace(),
                                   userInfo: userInfo,
                                   file: file,
                                   function: function,
                                   line: line)
    }
    
    public static func info(category: Log.Enum.Category = .custom("other"),
                            _ message: String,
                            userInfo: [String: String]? = nil,
                            file: String = #file,
                            function: String = #function,
                            line: UInt = #line) {
        VSLogManager.sharedInstance().log(level: .info,
                                   category: category,
                                   message: message,
                                   business: Self.nameSpace(),
                                   userInfo: userInfo,
                                   file: file,
                                   function: function,
                                   line: line)
    }
    
    public static func warning(category: Log.Enum.Category = .custom("other"),
                               _ message: String,
                               userInfo: [String: String]? = nil,
                               file: String = #file,
                               function: String = #function,
                               line: UInt = #line) {
        VSLogManager.sharedInstance().log(level: .warning,
                                   category: category,
                                   message: message,
                                   business: Self.nameSpace(),
                                   userInfo: userInfo,
                                   file: file,
                                   function: function,
                                   line: line)
    }
    
    public static func error(category: Log.Enum.Category = .custom("other"),
                             _ message: String,
                             userInfo: [String: String]? = nil,
                             file: String = #file,
                             function: String = #function,
                             line: UInt = #line) {
        VSLogManager.sharedInstance().log(level: .error,
                                   category: category,
                                   message: message,
                                   business: Self.nameSpace(),
                                   userInfo: userInfo,
                                   file: file,
                                   function: function,
                                   line: line)
    }
}
