//
//  SearchTableViewController.swift
//  DCACalcuator
//
//  Created by JeongminKim on 2021/07/23.
//

import UIKit
import Combine

class SearchTableViewController: UITableViewController {

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        performSearch()
    }

    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func performSearch() {
        apiService.fetchSymbolsPublisher(keywords: "S&P500").sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print("performSearch - error: \(error.localizedDescription)")
            }
        } receiveValue: { searchResults in
            print("performSearch - receiveValue: \(searchResults)")
        }.store(in: &subscribers)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        return cell
    }

}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}
