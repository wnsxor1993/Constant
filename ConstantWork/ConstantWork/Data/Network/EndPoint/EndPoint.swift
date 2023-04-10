//
//  EndPoint.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation

enum EndPoint: EndPointable {

    case fetchList(Int)

    var scheme: String {
        return "https"
    }

    var host: String {
        switch self {
        case .fetchList:
            return Bundle.main.apiHost
        }

    }

    var path: String? {
        switch self {
        case .fetchList:
            return Bundle.main.apiPath
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .fetchList:
            return .get
        }
    }

    var contentType: [String: String]? {
        switch self {
        case .fetchList:
            return ["Content-type": "application/json",
                    "Accept": "application/json"]
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .fetchList(let page):
            return [URLQueryItem(name: "page", value: "\(page)"), URLQueryItem(name: "limit", value: "\(20)")]
        }
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = self.path ?? ""

        if self.httpMethod == .get {
            components.queryItems = self.queryItems
        }

        return components.url
    }

}
