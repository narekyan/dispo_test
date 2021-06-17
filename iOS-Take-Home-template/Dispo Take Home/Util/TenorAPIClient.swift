import Combine
import UIKit

struct TenorAPIClient {
    var gifInfo: (_ gifId: String) -> AnyPublisher<GifInfo, Never>
    var searchGIFs: (_ query: String) -> AnyPublisher<[SearchResult], Never>
    var featuredGIFs: () -> AnyPublisher<[SearchResult], Never>
}

// MARK: - Live Implementation

extension TenorAPIClient {
    static let live = TenorAPIClient(
        gifInfo: { gifId in
            var components = URLComponents(
                url: URL(string: "https://g.tenor.com/v1/gifs")!,
                resolvingAgainstBaseURL: false
            )!
            components.queryItems = [
                .init(name: "ids", value: gifId),
                .init(name: "key", value: Constants.tenorApiKey),
                .init(name: "limit", value: "30"),
            ]
            let url = components.url!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: APIGifResponse.self, decoder: JSONDecoder())
                .map { response in
                    guard let item = response.results.first else { return GifInfo.Dummy }
                    return GifInfo(
                        id: item.id,
                        gifUrl: item.media[0].gif.url,
                        text: item.h1_title ?? "no title",
                        shares: item.shares,
                        backgroundColor: .white,
                        tags: item.tags)
                }
                .replaceError(with: GifInfo.Dummy)
                .share()
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        },
        searchGIFs: { query in
            var components = URLComponents(
                url: URL(string: "https://g.tenor.com/v1/search")!,
                resolvingAgainstBaseURL: false
            )!
            components.queryItems = [
                .init(name: "q", value: query),
                .init(name: "key", value: Constants.tenorApiKey),
                .init(name: "limit", value: "30"),
            ]
            let url = components.url!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: APIListResponse.self, decoder: JSONDecoder())
                .map { response in
                    response.results.map {
                        SearchResult(
                            id: $0.id,
                            gifUrl: $0.media[0].gif.url,
                            text: $0.h1_title ?? "no title"
                        )
                    }
                }
                .replaceError(with: [])
                .share()
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        },
        featuredGIFs: {
            var components = URLComponents(
                url: URL(string: "https://g.tenor.com/v1/trending")!,
                resolvingAgainstBaseURL: false
            )!
            components.queryItems = [
                .init(name: "key", value: Constants.tenorApiKey),
                .init(name: "limit", value: "30"),
            ]
            let url = components.url!
            
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return element.data
                }
                .decode(type: APIListResponse.self, decoder: JSONDecoder())
                .map { response in
                    response.results.map {
                        SearchResult(
                            id: $0.id,
                            gifUrl: $0.media[0].gif.url,
                            text: $0.h1_title ?? "no title"
                        )
                    }
                }
                .replaceError(with: [])
                .share()
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    )
}

private struct APIListResponse: Codable {
    var results: [Result]
    
    struct Result: Codable {
        var id: String
        var media: [Media]
        var h1_title: String?
        
        struct Media: Codable {
            var gif: MediaData
            
            struct MediaData: Codable {
                var url: URL
            }
        }
    }
}

private struct APIGifResponse: Codable {
    var results: [Result]
    
    struct Result: Codable {
        var id: String
        var shares: Int
        var h1_title: String?
        var media: [Media]
        var tags: [String]
        
        struct Media: Codable {
            var gif: MediaData
            
            struct MediaData: Codable {
                var url: URL
            }
        }
    }
}
