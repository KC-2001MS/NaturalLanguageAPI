//
//  Struct.swift
//  Simple Editor X
//
//  Created by 茅根啓介 on 2023/01/05.
//

import Foundation


extension Bundle {
    func decodeJSON<T: Codable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Faild to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        
        return loaded
    }
}

//Dataフォルダ内のJSONファイルをDecodeするため
struct ReadingLanguage: Codable {
    let language: String
    let code: String
}

struct GreetingandLanguage: Codable {
    let language: String
    let word: String
    let code: String
}
