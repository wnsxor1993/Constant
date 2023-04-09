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
            return "picsum.photos"
        }

    }

    var path: String? {
        switch self {
        case .fetchList:
            return "/v2/list"
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
            return [URLQueryItem(name: "page", value: "\(page)")]
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
