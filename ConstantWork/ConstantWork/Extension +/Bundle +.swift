//
//  Bundle +.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/10.
//

import Foundation

extension Bundle {
    
    var apiHost: String {
        guard let filePath: String = self.path(forResource: "PiscumInfo", ofType: "plist"), let resource: NSDictionary = NSDictionary(contentsOfFile: filePath) else { return "" }
        
        guard let key: String = resource["API_HOST"] as? String else {
            fatalError("API_HOST가 설정되어 있지 않습니다.")
        }
        
        return key
    }
    
    var apiPath: String {
        guard let filePath: String = self.path(forResource: "PiscumInfo", ofType: "plist"), let resource: NSDictionary = NSDictionary(contentsOfFile: filePath) else { return "" }
        
        guard let key: String = resource["API_PATH"] as? String else {
            fatalError("API_HOST가 설정되어 있지 않습니다.")
        }
        
        return key
    }
}
