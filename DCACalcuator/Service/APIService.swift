//
//  APIService.swift
//  DCACalcuator
//
//  Created by JeongminKim on 2021/07/23.
//

import Foundation
import Combine

struct APIService {
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    let keys = ["33MXYA1FRYTL5X4B", "V0Q4TW50G67QA6J6", "1MRVK40TW4KJV6E9"]
    
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        let url = URL(string: urlString)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
