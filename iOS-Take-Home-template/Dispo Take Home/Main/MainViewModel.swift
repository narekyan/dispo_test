import Combine
import UIKit

func mainViewModel(
    cellTapped: AnyPublisher<SearchResult, Never>,
    searchText: AnyPublisher<String, Never>,
    featured: AnyPublisher<Void, Never>
) -> (
    featuredResults: AnyPublisher<[SearchResult], Never>,
    searchResults: AnyPublisher<[SearchResult], Never>,
    pushDetailView: AnyPublisher<SearchResult, Never>
) {
    let api = TenorAPIClient.live
    
    let featuredGifs = featured
        .map { api.featuredGIFs() }
        .switchToLatest()
    let searchResults = searchText
        .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.global())
        .map { api.searchGIFs($0) }
        .switchToLatest()
    
    return (
        featuredResults: featuredGifs.eraseToAnyPublisher(),
        searchResults: searchResults.eraseToAnyPublisher(),
        pushDetailView: cellTapped.eraseToAnyPublisher()
    )
}
