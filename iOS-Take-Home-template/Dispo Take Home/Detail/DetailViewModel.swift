import Combine
import UIKit

func detailViewModel(
    viewWillAppear: AnyPublisher<SearchResult, Never>
) -> (
    AnyPublisher<GifInfo, Never>
) {
    let api = TenorAPIClient.live
    
    let searchResults = viewWillAppear
        .map({ api.gifInfo($0.id) })
        .switchToLatest()
    
    // show featured gifs when there is no search query, otherwise show search results
    let loadResults = searchResults
        .eraseToAnyPublisher()
    
    return loadResults
}
