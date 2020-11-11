//
//  HomeView.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 07/09/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import UIKit
import DropDown
import SnapKit

class HomeView: UIScrollView {
    
    final let FLAG_SIZE = 24
    final let FLAG_PADDING = 8
    
    final let CARET_SIZE = 14
    final let CARET_PADDING = 8
    final let CARET_IMAGE = "chevron.down"
    
    final let ICON_COLOR = UIColor(hexString: "#959595")
    
    lazy var rootView = UIView()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 24)
        label.text = "Currency\nCalculator"
        label.shadowColor = .label
        label.shadowOffset = .init(width: 1, height: -1)
        label.numberOfLines = 0
        return label
    }()

    lazy var sourceTextField: UITextField = {
        let tf = UITextField()
        tf.background = UIImage(systemName: "square.filled")
        tf.borderStyle = .roundedRect
        tf.textContentType = .telephoneNumber
        tf.textAlignment = .left
        tf.rightViewMode = .always
        
        tf.rightView = sourceTFCurrencyLabel
        tf.placeholder = "Enter Value"
        tf.font = .systemFont(ofSize: 17)
        return tf
    }()
    
    lazy var destinationTextField: UITextField = {
        let tf = UITextField()
        tf.background = UIImage(systemName: "square.filled")
        tf.borderStyle = .roundedRect
        tf.textContentType = .telephoneNumber
        tf.textAlignment = .left
        tf.rightViewMode = .always
        tf.rightView = destinationTFCurrencyLabel
        tf.font = .systemFont(ofSize: 17)
        tf.isEnabled = false
        return tf
    }()
    
    lazy var sourceTFCurrencyLabel: UILabel = {
        let label = UILabel()
//        label.frame = CGRect(x: 0.0, y: 0.0, width: 60, height: 40)
//        label.textAlignment = .left
        label.text = "---"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    lazy var destinationTFCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = "---"
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    lazy var sourceDropDownTF: UITextField = {
        let tf = UITextField()
        //tf.background = UIImage(systemName: "square.filled")
        tf.borderStyle = .roundedRect
        tf.textAlignment = .left
        let sourceViewLeft = UIView(frame: CGRect(x: FLAG_PADDING, y: 0, width: Int(sourceDDCurrencyImage.frame.width) + FLAG_PADDING, height: Int(sourceDDCurrencyImage.frame.height)))
        sourceViewLeft.addSubview(sourceDDCurrencyImage)
        tf.leftView = sourceViewLeft
        tf.leftViewMode = .always
        tf.placeholder = "Enter/Select Currency"
        tf.font = .systemFont(ofSize: 12)
        tf.rightView = generateCaretView()
        tf.rightViewMode = .always
        return tf
    }()
    
    lazy var destinationDropDownTF: UITextField = {
        let tf = UITextField()
        //tf.background = UIImage(systemName: "square.filled")
        tf.borderStyle = .roundedRect
        tf.textAlignment = .left
        let destViewLeft: UIView = UIView(frame: CGRect(x: FLAG_PADDING, y: 0, width: Int(destinationDDCurrencyImage.frame.width) + FLAG_PADDING, height: Int(destinationDDCurrencyImage.frame.height)))
        destViewLeft.addSubview(destinationDDCurrencyImage)
        tf.leftView = destViewLeft
        tf.leftViewMode = .always
        tf.placeholder = "Enter/Select Currency"
        tf.font = .systemFont(ofSize: 12)
        tf.rightView = generateCaretView()
        tf.rightViewMode = .always
        return tf
    }()
    lazy var sourceDDCurrencyImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: FLAG_PADDING, y: 0, width: FLAG_SIZE, height: FLAG_SIZE))
        
        return imageView
    }()
    lazy var destinationDDCurrencyImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: FLAG_PADDING, y: 0, width: FLAG_SIZE, height: FLAG_SIZE))
        
        return imageView
    }()
    
    lazy var sourceDropDown: DropDown = {
        let dd = DropDown()
        dd.anchorView = sourceDropDownTF
        dd.cellNib = UINib(nibName: "CurrencyDropDownView", bundle: nil)
        return dd
    }()
    lazy var destinationDropDown: DropDown = {
        let dd = DropDown()
        dd.anchorView = destinationDropDownTF
        dd.cellNib = UINib(nibName: "CurrencyDropDownView", bundle: nil)
        return dd
    }()
    
    lazy var trendsView: TrendsView = {
        let trendsView = TrendsView()
        return trendsView
    }()
    
    lazy var convertIcon = UIImageView(image: UIImage(systemName: "arrow.right.arrow.left")).apply{
        $0.tintColor = ICON_COLOR
    }
    
    private func generateCaretView() -> UIView{
        let caretImage = UIImageView( frame: CGRect(x: 0, y: 0, width: CARET_SIZE, height: CARET_SIZE)).apply{
            $0.image = UIImage(systemName: CARET_IMAGE)?.withTintColor(ICON_COLOR, renderingMode: .alwaysOriginal)
            $0.contentMode = .scaleAspectFit
        }
        let caretView =  UIView(frame: CGRect(x: 0, y: 0, width: Int(caretImage.frame.width) + CARET_PADDING, height: Int(caretImage.frame.height)))
        caretView.addSubview(caretImage)
        return caretView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addSubviews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpConstraints(){
        let root = rootView
        
        root.snp.makeConstraints{
            $0.edges.equalTo(self)
            $0.width.equalTo(self)
        }
        
        titleLabel.snp.makeConstraints{ make in
            make.top.equalTo(root.snp.top).offset(100)
            make.leading.equalTo(root.snp.leadingMargin)
        }
        sourceTextField.snp.makeConstraints{ make in
            make.top.equalTo(titleLabel.snp.bottom).offset(64)
            make.leading.equalTo(root.snp.leadingMargin)
            make.trailing.equalTo(root.snp.trailingMargin)
        }
        destinationTextField.snp.makeConstraints{ make in
            make.top.equalTo(sourceTextField.snp.bottom).offset(22)
            make.leading.equalTo(root.snp.leadingMargin)
            make.trailing.equalTo(root.snp.trailingMargin)
        }
        sourceDropDownTF.snp.makeConstraints{ make in
            make.top.equalTo(destinationTextField.snp.bottom).offset(21)
            make.leading.equalTo(root.snp.leadingMargin)
            make.width.equalTo(destinationDropDownTF)
        }
        convertIcon.snp.makeConstraints{ make in
            make.leading.equalTo(sourceDropDownTF.snp.trailing).offset(15)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.centerY.equalTo(sourceDropDownTF)
        }
        destinationDropDownTF.snp.makeConstraints{ make in
            make.top.equalTo(sourceDropDownTF)
            make.trailing.equalTo(root.snp.trailingMargin)
            make.leading.equalTo(convertIcon.snp.trailing).offset(15)
            make.width.equalTo(sourceDropDownTF)
        }
        trendsView.snp.makeConstraints{ make in
            make.top.equalTo(destinationDropDownTF.snp.bottom).offset(50)
            make.bottom.equalTo(root)
            make.trailing.leading.equalTo(root)
        }
    }
    
    func addSubviews() {
        addSubview(rootView)
        rootView.addSubviews([titleLabel, sourceTextField, destinationTextField, sourceDropDownTF, destinationDropDownTF, convertIcon, trendsView])
    }
}
