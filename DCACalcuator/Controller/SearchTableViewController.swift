//
//  SearchTableViewController.swift
//  DCACalcuator
//
//  Created by JeongminKim on 2021/07/23.
//

import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController, UIAnimatable {
    
    private enum Mode {
        case onboarding
        case search
    }

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
    private var searchResults: SearchResults?
    @Published private var mode: Mode = .onboarding
    @Published private var searchQuery = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        observeForm()
    }

    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title = "Search"
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
    }
    
    private func observeForm() {
        // 검색결과로 서칭할 때 매 순간 검색이 들어가면 비효율적이므로 0.75초마다 검색하도록 설정
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] searchQuery in
                guard !searchQuery.isEmpty else { return }
                showLoadingAnimation()
                print("observeForm - searchQuery: \(searchQuery)")
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink { completion in
                    hideLoadingAnimation()
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("observeForm - error: \(error.localizedDescription)")
                    }
                } receiveValue: { searchResults in
                    print("observeForm - receiveValue: \(searchResults)")
                    self.searchResults = searchResults
                    self.tableView.reloadData()
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)
        
        $mode.sink { [unowned self] mode in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
            case .search:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchTableViewCell
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.configure(with: searchResult)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = self.searchResults {
            let symbol = searchResults.items[indexPath.row].symbol
            handleSelection(for: symbol)
        }
    }
    
    private func handleSelection(for symbol: String) {
        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(keywords: symbol).sink { completionResult in
            switch completionResult {
            case .failure(let error):
                print("handleSelection - error: \(error)")
            case .finished:
                break
            }
        } receiveValue: { timeSeriesMonthlyAdjusted in
            print("handleSelection - success: \(timeSeriesMonthlyAdjusted.getMonthInfos())")
        }.store(in: &subscribers)

//        performSegue(withIdentifier: "showCalculator", sender: nil)
    }

}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        print("updateSearchResults: \(searchQuery)")
        self.searchQuery = searchQuery
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
}
