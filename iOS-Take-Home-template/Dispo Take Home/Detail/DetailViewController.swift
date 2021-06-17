import Combine
import UIKit

class DetailViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let viewWillAppearSubject = PassthroughSubject<SearchResult, Never>()
    private var searchResult: SearchResult!
    
    init(searchResult: SearchResult) {
        super.init(nibName: nil, bundle: nil)
        self.searchResult = searchResult
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadResults
            = detailViewModel(
            viewWillAppear: viewWillAppearSubject.eraseToAnyPublisher()
        )
        
        loadResults
            .sink { [weak self] results in
                self?.imageView.kf.setImage(with: results.gifUrl)
                self?.sharesLabel.text = "Shares: \(results.shares)"
                self?.tagsLabel.text = "Tags: "+results.tags.joined(separator: ", ")
            }
            .store(in: &cancellables)
        
        viewWillAppearSubject.send(searchResult)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        view.addSubview(sharesLabel)
        view.addSubview(tagsLabel)
        
        imageView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            $0.right.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(30)
            $0.height.equalTo(imageView.snp.width)
        }
        
        sharesLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(40)
        }
        
        tagsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(sharesLabel.snp.bottom).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let sharesLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tagsLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
