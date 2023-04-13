//
//  DataCollectionViewCell.swift
//  Turner
//
//  Created by Jacob McLachlan on 5/9/22.
//

import UIKit

class DataCollectionViewCell: UICollectionViewCell {
    static let identifier = "DataCollectionViewCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
}
