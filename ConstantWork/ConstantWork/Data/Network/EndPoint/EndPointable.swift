//
//  EndPointable.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation

protocol EndPointable {
    
    var scheme: String {get}
    var host: String {get}
    var path: String? {get}
    var httpMethod: HTTPMethod {get}
    var contentType: [String: String]? {get}
    var queryItems: [URLQueryItem]? {get}
    var url: URL? {get}
}
