//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 11/06/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DropDown
import Kingfisher

class ViewController: UIViewController {
    
    final let FLAGS_URL = "https://www.countryflags.io/"
    final let FLAGS_URL_CONFIG = "/shiny/24.png"
    
    final let FLAG_SIZE = 24
    final let FLAG_PADDING = 8
    
    @IBOutlet weak var sourceTextField: UITextField!
    
    @IBOutlet weak var destinationTextField: UITextField!
    
    @IBOutlet weak var sourceTFCurrencyLabel: UILabel!
    @IBOutlet weak var destinationTFCurrencyLabel: UILabel!
    @IBOutlet weak var sourceDropDownTF: UITextField!
    
    @IBOutlet weak var destinationDropDownTF: UITextField!
    var sourceDDCurrencyImage: UIImageView!
    var destinationDDCurrencyImage: UIImageView!
    
    public var ratesViewModel: RatesViewModel!
    
    var disposeBag = DisposeBag()
    
    var rates: [CurrencyRate] = []
    
    var sourceDropDown: DropDown?
    var destinationDropDown: DropDown?
    
    let currencies = Util.currencyMap
    
    var manuallyEditing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initDropDown()
        bindObservables()
        // Do any additional setup after loading the view.
    }
    
    
    private func bindObservables(){
        ratesViewModel.ratesObservable.asDriver(onErrorJustReturn: .Error(message: "", data: []))
            .drive(onNext: { result in
                //print("Api result \(result)")
                switch result{
                case let .Loading(data):
                    self.rates = data ?? []
                    self.startLoading()
                case let .Success(data):
                    self.rates = data ?? []
                    self.stopLoading()
                case .Error(message: let message, data: _):
                    self.stopLoading()
                    self.showError(error: message ?? "An unknown error occurred")
                }
            }).disposed(by: disposeBag)
    }
    
    private func stopLoading(){
        
    }
    
    private func startLoading(){
        
    }
    
    private func showError(error: String){
        print("Api Error \(error)")
    }
    
    private func initViews(){
        sourceTextField.rightView = sourceTFCurrencyLabel
        destinationTextField.rightView = destinationTFCurrencyLabel
        sourceTextField.rightViewMode = .always
        destinationTextField.rightViewMode = .always
        
        sourceDDCurrencyImage = UIImageView(frame: CGRect(x: FLAG_PADDING, y: 0, width: FLAG_SIZE, height: FLAG_SIZE))
        destinationDDCurrencyImage = UIImageView(frame: CGRect(x: FLAG_PADDING, y: 0, width: FLAG_SIZE, height: FLAG_SIZE))
        
        
        let sourceViewLeft: UIView = UIView(frame: CGRect(x: FLAG_PADDING, y: 0, width: Int(sourceDDCurrencyImage.frame.width) + FLAG_PADDING, height: Int(sourceDDCurrencyImage.frame.height)))
        sourceViewLeft.addSubview(sourceDDCurrencyImage)
        
        let destViewLeft: UIView = UIView(frame: CGRect(x: FLAG_PADDING, y: 0, width: Int(destinationDDCurrencyImage.frame.width) + FLAG_PADDING, height: Int(destinationDDCurrencyImage.frame.height)))
        destViewLeft.addSubview(destinationDDCurrencyImage)
        
        sourceDropDownTF.leftView = sourceViewLeft
        destinationDropDownTF.leftView = destViewLeft
        sourceDropDownTF.leftViewMode = .always
        destinationDropDownTF.leftViewMode = .always
        
        sourceDropDownTF.delegate = self
        destinationDropDownTF.delegate = self
    }
    
    private func initDropDown(){
        sourceDropDown = DropDown()
        destinationDropDown = DropDown()
        
        sourceDropDown?.anchorView = sourceDropDownTF
        destinationDropDown?.anchorView = destinationDropDownTF
        
        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        sourceDropDown?.cellNib = UINib(nibName: "CurrencyDropDownView", bundle: nil)

        sourceDropDown?.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CurrencyDropDownView else { return }

           // Setup your custom UI components
            cell.flagImageView.kf.setImage(with: self.buildImageUrl(item: item))
            cell.optionLabel.text = item
        }
        
        destinationDropDown?.cellNib = UINib(nibName: "CurrencyDropDownView", bundle: nil)

        destinationDropDown?.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CurrencyDropDownView else { return }

           // Setup your custom UI components
            cell.flagImageView.kf.setImage(with: self.buildImageUrl(item: item))
            cell.optionLabel.text = item
        }
        
        sourceDropDown?.dataSource = Array(currencies.keys).sorted()
        destinationDropDown?.dataSource = Array(currencies.keys).sorted()
        
        sourceDropDown?.direction = .any
        destinationDropDown?.direction = .any
        
        sourceDropDown?.bottomOffset = CGPoint(x: 0, y:(sourceDropDown?.anchorView?.plainView.bounds.height)!)
        destinationDropDown?.bottomOffset = CGPoint(x: 0, y:(destinationDropDown?.anchorView?.plainView.bounds.height)!)
        
        sourceDropDown?.topOffset = CGPoint(x: 0, y: -(sourceDropDown?.anchorView?.plainView.bounds.height)!)
        destinationDropDown?.topOffset = CGPoint(x: 0, y: -(destinationDropDown?.anchorView?.plainView.bounds.height)!)
        
        sourceDropDown?.selectionAction = { (index: Index, item: String) in
            self.sourceDropDownTF.text = item
            self.sourceDDCurrencyImage.kf.setImage(with: self.buildImageUrl(item: item))
            self.sourceTFCurrencyLabel.text = item
            
            
            //buildHistoricalRatesGraph(ratesTab.selectedTabPosition)
            if (self.sourceTextField.text?.isEmpty ?? true || self.sourceDropDownTF.text?.isEmpty ?? true || self.destinationDropDownTF.text?.isEmpty ?? true) {
                return
            }
            self.convertValue()
        }
        
        destinationDropDown?.selectionAction = { (index: Index, item: String) in
            self.destinationDropDownTF.text = item
            self.destinationDDCurrencyImage.kf.setImage(with: self.buildImageUrl(item: item))
            self.destinationTFCurrencyLabel.text = item
            
            //buildHistoricalRatesGraph(ratesTab.selectedTabPosition)
            if (self.sourceTextField.text?.isEmpty ?? true || self.sourceDropDownTF.text?.isEmpty ?? true || self.destinationDropDownTF.text?.isEmpty ?? true) {
                return
            }
            self.convertValue()
        }
    }
    
    
    
    
    private func buildImageUrl(item: String) -> URL? {
        let countryCode = (self.currencies[item] as NSLocale?)?.countryCode
        let resolvedCode = (countryCode?.isEmpty ?? true) ? self.currencies[item]?.identifier ?? "" : countryCode!
        let imageUrl = "\(self.FLAGS_URL)\(resolvedCode)\(self.FLAGS_URL_CONFIG)"
        //print(imageUrl)
         return URL(string: imageUrl)
    }

    @IBAction func sourceCurrencyTextChanged(_ sender: UITextField) {
        filterAndShowDropDown(newText: sender.text, dropDown: sourceDropDown)
    }
    
    @IBAction func destinationCurrencyTextChanged(_ sender: UITextField) {
        filterAndShowDropDown(newText: sender.text, dropDown: destinationDropDown)
    }
    
    @IBAction func sourceAmountTextChanged(_ sender: UITextField) {
        if (sender.text?.isEmpty ?? false) {
            destinationTextField.text = ""
            return
        }
        sourceTextField.text = formatValue(value: sender.text!)
        convertValue()
//        if sender.text! == formatValue(value: sender.text!) {
//            convertValue()
//            return
//        }
        
    }
    
}

extension ViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case sourceDropDownTF:
            filterAndShowDropDown(newText: textField.text, dropDown: sourceDropDown)
        case destinationDropDownTF:
            filterAndShowDropDown(newText: textField.text, dropDown: destinationDropDown)
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField {
        case sourceDropDownTF:
            filterAndHideDropDown(textField: textField, dropDown: sourceDropDown)
        case destinationDropDownTF:
            filterAndHideDropDown(textField: textField, dropDown: destinationDropDown)
        default:
            break
        }
    }
    
    func filterAndHideDropDown(textField: UITextField, dropDown: DropDown?){
        manuallyEditing = true
        if let dropDown = dropDown {
            let filteredResult = setDropDownDataSource(newText: textField.text, dropDown: dropDown)
            if !filteredResult.isEmpty {
                dropDown.selectRow(at: 0)
                textField.text = filteredResult.first!.key
            } else {
                dropDown.clearSelection()
                textField.text = ""
            }
            if !dropDown.isHidden {
                dropDown.hide()
            }
        }
    }
    
    func filterAndShowDropDown(newText: String?, dropDown: DropDown?){
        if let dropDown = dropDown {
            _ = setDropDownDataSource(newText: newText, dropDown: dropDown)
            if dropDown.isHidden {
                dropDown.show()
            }
        }
    }
    
    func setDropDownDataSource(newText: String?, dropDown: DropDown)-> Dictionary<String, Locale>{
        if let input = newText, !input.isEmpty {
            let filteredResult = filterCurrencies(input: input)
            if !filteredResult.isEmpty {
                dropDown.dataSource = Array(filteredResult.keys).sorted()
            }
            else {
                dropDown.dataSource = []
            }
            return filteredResult
        } else {
            dropDown.dataSource = Array(currencies.keys).sorted()
            return [:]
        }
    }
    
    func filterCurrencies(input: String) -> [String : Locale]{
       
        return currencies.filter{
            print("input: \(input) values: \n\($0.key) || \( ($0.value as NSLocale?)?.displayName(forKey: .currencyCode, value: $0.key) ?? "") || \(($0.value as NSLocale?)?.displayName(forKey: .countryCode, value: ($0.value as NSLocale?)?.countryCode ?? "") ?? "") || locale: \($0.value.currencyCode ?? "")\n")
            return $0.key.lowercased().contains(input.lowercased()) ||
                ($0.value as NSLocale?)?.displayName(forKey: .currencyCode, value: $0.key)?.lowercased().contains(input.lowercased()) ?? false ||
                ($0.value as NSLocale?)?.displayName(forKey: .countryCode, value: ($0.value as NSLocale?)?.countryCode ?? "")?.lowercased().contains(input.lowercased()) ?? false
        }

    }

}

// ConversionRegion
extension ViewController {
    private func formatValue(value: String) -> String {
        var resValue = value
        if value.last == "." && value.firstIndex(of: "." )?.utf16Offset(in: value) != value.count - 1 {
            resValue = String(value.dropLast(1))
        }
        let res = NumberFormatter.localizedString(from: NSNumber(value: Double(resValue.replacingOccurrences(of: ",", with: ""))!), number: NumberFormatter.Style.decimal)
        
        return  (String(resValue.dropLast(1)) == ".") ? "\(res)." : res
    }
    
    private func convertValue(){
        if let sourceCurrency = sourceDropDownTF.text, let destCurrency = destinationDropDownTF.text,
            !sourceCurrency.isEmpty, !destCurrency.isEmpty, let sourceValue = sourceTextField.text, !sourceValue.isEmpty,
            let sourceRate = rates.first(where: {$0.currencyCode == sourceCurrency}),
            let destRate = rates.first(where: {$0.currencyCode == destCurrency}),
            sourceRate.baseCurrencyCode == destRate.baseCurrencyCode
        {
            let nf = NumberFormatter()
            let sourceToNumber = nf.number(from: sourceValue.replacingOccurrences(of: ",", with: "") )?.doubleValue ?? 0.0
            let convertedValue = sourceToNumber * destRate.rate / sourceRate.rate
            
            destinationTextField.text = formatValue(value: String(format: "%f", convertedValue))
        }
    }
}

