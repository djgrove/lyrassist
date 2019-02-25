//
//  LASearchFooterView.swift
//  lyrAssist
//
//  Created by Austin McInnis on 2/24/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

class LASearchFooterView: UIView {

    let label: UILabel = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func configureView() {
        backgroundColor = UIColor.LABurgundy
        alpha = 0.0
        
        //Configure Label
        label.textAlignment = .center
        label.textColor = .white
        addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = self.bounds
    }
    
    // MARK: - Animation
    fileprivate func hideFooter() {
//        UIView.animate(withDuration: 0.7) {
//            [unowned self] in
//            self.alpha = 0.0
//        }
        self.alpha = 0.0
    }
    
    fileprivate func showFooter() {
        UIView.animate(withDuration: 0.5) {
            [unowned self] in
            self.alpha = 1.0
        }
    }
}

extension LASearchFooterView {
    // MARK: - Public API
    
    public func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if filteredItemCount == totalItemCount {
            setNotFiltering()
        }
        else if filteredItemCount == 0 {
            label.text = "No items match your query"
        }
        else {
            label.text = "Filtering \(filteredItemCount) of \(totalItemCount)"
            showFooter()
        }
    }
}
