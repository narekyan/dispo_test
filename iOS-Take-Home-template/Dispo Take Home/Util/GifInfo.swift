import UIKit

struct GifInfo {
    var id: String
    var gifUrl: URL
    var text: String
    var shares: Int
    var backgroundColor: UIColor?
    var tags: [String]
    
    static var Dummy = GifInfo(
        id: "",
        gifUrl: URL(string: "//")!,
        text: "",
        shares: 0,
        backgroundColor: .white,
        tags: [String]())
}
