//
//  mySketchesCollectionViewCell.swift
//  Sketch It
//
//  Created by kamlesh on 27/08/20.
//  Copyright © 2020 kamlesh. All rights reserved.
//

import UIKit

class mySketchesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        AutoLayoutForAllViews()
    }
    
     lazy var imgViewSketches : UIImageView = {
        let sketch = UIImageView()
        return sketch
    }()
    
    private func AutoLayoutForAllViews() {
        
        self.contentView.addSubview(imgViewSketches)
        
        imgViewSketches.snp.makeConstraints { (make) in
            make.trailing.leading.bottom.top.equalTo(self.contentView)
        }
        
    }
    
}
