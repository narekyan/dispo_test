//
//  GifCell.swift
//  Dispo Take Home
//
//  Created by Narek on 16.06.21.
//

import Foundation
import UIKit

class GifCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var url: URL? {
        didSet {
            self.imageView.kf.setImage(with: url)            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
