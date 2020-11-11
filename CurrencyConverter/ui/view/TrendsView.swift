//
//  TrendsView.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 12/09/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import UIKit
import SnapKit
import Charts


class TrendsView: UIView {
    
    lazy var tabView: UISegmentedControl = {
        let tabView = UISegmentedControl(items: ["Past 30 days", "Past 90 days"])
        tabView.selectedSegmentIndex = 0
        tabView.selectedSegmentTintColor = .white
        tabView.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        tabView.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        return tabView
    }()
    
    lazy var lineChart: LineChartView = {
        let lc = LineChartView()
        return lc
    }()

   override init(frame: CGRect) {
        super.init(frame: frame)
    layer.cornerRadius = 20
    layer.masksToBounds = true
    layer.backgroundColor = UIColor(hexString: "#0064d9").cgColor
        addSubviews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpConstraints(){
        let root = self
        tabView.snp.makeConstraints{ make in
            make.top.equalTo(root.snp.topMargin).offset(20)
            make.centerX.equalTo(root)
        }
        lineChart.snp.makeConstraints{ make in
            make.top.equalTo(tabView.snp.bottom).offset(20)
            make.height.equalTo(300)
            make.leading.equalTo(root.snp.leadingMargin).offset(10)
            make.trailing.equalTo(root.snp.trailingMargin).offset(-10)
        }
        root.snp.makeConstraints{ make in
            make.bottom.equalTo(lineChart).offset(50)
        }
    }

    func addSubviews() {
        addSubview(tabView)
        addSubview(lineChart)
    }
}
