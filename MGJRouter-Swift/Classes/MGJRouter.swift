//
//  MGJRouter.swift
//  Pods
//
//  Created by hisoka0917 on 2017/9/15.
//

import Foundation

public typealias MGJRouterHandler = ([String: Any]) -> Void
public let MGJRouterParameterURL: String = "MGJRouterParameterURL"
public let MGJRouterParameterCompletion: String = "MGJRouterParameterCompletion"
public let MGJRouterParameterUserInfo: String = "MGJRouterParameterUserInfo"

public class MGJRouter {

    private var routeTable: NSMutableDictionary = NSMutableDictionary()
    static let shared = MGJRouter()
    let wildcardCharacter = "~"

    private init() {}

    public static func register(url: String, handler: @escaping MGJRouterHandler) {
        self.shared.addUrl(pattern: url, handler: handler)
    }

    public static func open(url: String) {
        self.open(url: url, completion: nil)
    }

    public static func open(url: String, completion: (() -> Void)?) {
        self.open(url: url, userInfo: nil, completion: completion)
    }

    public static func open(url: String, userInfo: [String: Any]?, completion: (() -> Void)?) {
        guard !url.isEmpty else {
            return
        }
        if let urlPath = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let parameters = self.shared.unwrapParametersFrom(urlPath)
            parameters.enumerateKeysAndObjects({ (key, obj, stop) in
                if let objString = obj as? String, let value = objString.removingPercentEncoding {
                    parameters[key] = value
                }
            })

            if let completion = completion {
                parameters[MGJRouterParameterCompletion] = completion
            }
            if let userInfo = userInfo {
                parameters[MGJRouterParameterUserInfo] = userInfo
            }
            if let handler = parameters.object(forKey: "block") as? MGJRouterHandler,
                var paramDict = parameters as? [String: Any] {
                paramDict.removeValue(forKey: "block")
                handler(paramDict)
            }
        }
    }

    // MARK: Private

    private func sortKeys(of dict: NSMutableDictionary) -> [String] {
        var keys: [String] = []
        if let allKeys = dict.allKeys as? [String] {
            keys = allKeys.sorted(by: <)
        }

        return keys
    }

    private func unwrapParametersFrom(_ url: String) -> NSMutableDictionary {
        let parameters: NSMutableDictionary = NSMutableDictionary()
        parameters[MGJRouterParameterURL] = url
        var subRoutes = self.routeTable
        let pathComponents = self.pathComponents(url)

        var isFound: Bool = false
        for path in pathComponents {
            // 对 key 进行排序，这样可以把 ~ 放到最后
            let subRoutesKeys = self.sortKeys(of: subRoutes)

            for routeKey in subRoutesKeys {
                if routeKey == path || routeKey == wildcardCharacter {
                    isFound = true
                    if let subRoute = subRoutes[routeKey] as? NSMutableDictionary {
                        subRoutes = subRoute
                    }
                    break
                } else if routeKey.hasPrefix(":") {
                    isFound = true
                    if let subRoute = subRoutes[routeKey] as? NSMutableDictionary {
                        subRoutes = subRoute
                    }
                    let indexStart = routeKey.index(routeKey.startIndex, offsetBy: 1)
                    let subKey = routeKey[indexStart...]
                    var newKey = String(subKey)
                    var newComponent = path
                    // 再做一下特殊处理，比如 :id.html -> :id
                    if let range = routeKey.rangeOfCharacter(from: CharacterSet(charactersIn: "/?&.")) {
                        // 把component后面的部分去掉
                        newKey = String(routeKey[..<range.lowerBound])
                        newComponent = newComponent.replacingCharacters(in: range.lowerBound..<newComponent.endIndex,
                                                                        with: "")
                    }
                    parameters[newKey] = newComponent
                    break
                }
            }
            // 如果没有找到该 pathComponent 对应的 handler，则以上一层的 handler 作为 fallback
            if !isFound && subRoutes["_"] == nil {
                return parameters
            }
        }

        // Extract Params From Query.
        if let queryItems = NSURLComponents(url: URL(string: url)!, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                parameters[item.name] = item.value
            }
        }
        if let subRoute = subRoutes["_"] {
            parameters["block"] = subRoute
        }

        return parameters
    }

    private func addUrl(pattern: String, handler: @escaping MGJRouterHandler) {
        let subRoutes = self.addUrl(pattern: pattern)
        subRoutes["_"] = handler
    }

    private func addUrl(pattern: String) -> NSMutableDictionary {
        let pathComponents = self.pathComponents(pattern)
        var subRoutes = self.routeTable

        for component in pathComponents {
            if subRoutes[component] == nil {
                subRoutes[component] = NSMutableDictionary()
            }
            if let subRoute = subRoutes[component] as? NSMutableDictionary {
                subRoutes = subRoute
            }
        }
        return subRoutes
    }

    private func pathComponents(_ url: String) -> [String] {
        var componentsArray: [String] = []
        var urlPath = url

        if urlPath.contains("://") {
            let pathSegments = url.components(separatedBy: "://")
            // 如果 URL 包含协议，那么把协议作为第一个元素放进去
            componentsArray.append(pathSegments[0])

            // 如果只有协议，那么放一个占位符
            urlPath = pathSegments.last!
            if urlPath.isEmpty {
                componentsArray.append(wildcardCharacter)
            }
        }

        if let components = URL(string: urlPath)?.pathComponents {
            for component in components {
                if component == "/" {
                    continue
                }
                let endIndex = component.index(component.startIndex, offsetBy: 1)
                let subString = component[..<endIndex]
                let char = String(subString)
                if char == "?" {
                    break
                }
                componentsArray.append(component)
            }
        }

        return componentsArray
    }
}
