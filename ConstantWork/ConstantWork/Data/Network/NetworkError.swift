//
//  NetworkError.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import Foundation

enum NetworkError: Error {
    
    case noURL
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError
    case encodingError
}
