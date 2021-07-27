//
//  APIService.swift
//  DCACalcuator
//
//  Created by JeongminKim on 2021/07/23.
//

import Foundation
import Combine

struct APIService {
    
    enum APIServiceError: Error {
        case encoding
        case badRequest
    }
    
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    let keys = ["33MXYA1FRYTL5X4B", "V0Q4TW50G67QA6J6", "1MRVK40TW4KJV6E9"]
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        // 검색 키워드에 띄어쓰기 들어갔을 때 url에 nil 들어가는 문제 방지
        guard let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIServiceError.encoding).eraseToAnyPublisher()
        }
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        
        guard let url = URL(string: urlString) else { return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher() }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
