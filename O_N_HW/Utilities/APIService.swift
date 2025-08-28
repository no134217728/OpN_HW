//
//  APIService.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/28.
//

import Foundation

protocol Service {
    func fetchData<T: Decodable>(source: String, model: T.Type) async -> T?
}

class LocalAPIService: Service {
    func fetchData<T: Decodable>(source: String, model: T.Type) async -> T? {
        if let path = Bundle.main.path(forResource: source, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(T.self, from: data)
                return result
            } catch {
                print("JSON error: \(source), error: \(error)")
                return nil
            }
        } else {
            print("File not found: \(source).")
            return nil
        }
    }
}
