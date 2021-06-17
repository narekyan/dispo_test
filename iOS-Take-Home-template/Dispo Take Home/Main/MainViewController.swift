import Combine
import UIKit
import Kingfisher

class MainViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let searchTextChangedSubject = PassthroughSubject<String, Never>()
    private let cellTappedSubject = PassthroughSubject<SearchResult, Never>()
    private let featuredSubject = PassthroughSubject<Void, Never>()
    private var results = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        collectionView.register(GifCell.self, forCellWithReuseIdentifier: "GifCell")
        
        let (
            featured,
            loadResults,
            pushDetailView
        ) = mainViewModel(
            cellTapped: cellTappedSubject.eraseToAnyPublisher(),
            searchText: searchTextChangedSubject.eraseToAnyPublisher(),
            featured: featuredSubject.eraseToAnyPublisher()
        )
        
        featured
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.results = results
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        loadResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.results = results
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        pushDetailView
            .sink { [weak self] result in
                self?.navigationController?.pushViewController(DetailViewController(searchResult: result), animated: true)
            }
            .store(in: &cancellables)
        
        featuredSubject.send()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "search gifs..."
        searchBar.delegate = self
        return searchBar
    }()
    
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
}

// MARK: UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            featuredSubject.send()
        } else {
            searchTextChangedSubject.send(searchText)
        }
    }
}

// MARK: UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as? GifCell else { fatalError() }
        cell.url = self.results[indexPath.row].gifUrl
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellTappedSubject.send(results[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width/4, height: collectionView.frame.width/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
