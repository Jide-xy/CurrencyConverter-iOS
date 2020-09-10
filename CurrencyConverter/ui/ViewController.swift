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
    
    var homeView: HomeView!
    
    public var ratesViewModel: RatesViewModel!
    
    var disposeBag = DisposeBag()
    
    var rates: [CurrencyRate] = []
    
    let currencies = Util.currencyMap
    
    var manuallyEditing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initDropDown()
        bindObservables()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        homeView = HomeView()
        view = homeView
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
        homeView.sourceDropDownTF.delegate = self
        homeView.destinationDropDownTF.delegate = self
        homeView.sourceDropDownTF.addTarget(self, action: #selector(ViewController.sourceCurrencyTextChanged(_:)), for: .editingChanged)
        homeView.destinationDropDownTF.addTarget(self, action: #selector(ViewController.destinationCurrencyTextChanged(_:)), for: .editingChanged)
        homeView.sourceTextField.addTarget(self, action: #selector(ViewController.sourceAmountTextChanged(_:)), for: .editingChanged)
    }
    
    private func initDropDown(){

        homeView.sourceDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CurrencyDropDownView else { return }

           // Setup your custom UI components
            cell.flagImageView.kf.setImage(with: self.buildImageUrl(item: item))
            cell.optionLabel.text = item
        }

        homeView.destinationDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CurrencyDropDownView else { return }

           // Setup your custom UI components
            cell.flagImageView.kf.setImage(with: self.buildImageUrl(item: item))
            cell.optionLabel.text = item
        }
        
        homeView.sourceDropDown.dataSource = Array(currencies.keys).sorted()
        homeView.destinationDropDown.dataSource = Array(currencies.keys).sorted()
        
        homeView.sourceDropDown.direction = .any
        homeView.destinationDropDown.direction = .any
        
        homeView.sourceDropDown.bottomOffset = CGPoint(x: 0, y:(homeView.sourceDropDown.anchorView?.plainView.bounds.height)!)
        homeView.destinationDropDown.bottomOffset = CGPoint(x: 0, y:(homeView.destinationDropDown.anchorView?.plainView.bounds.height)!)
        
        homeView.sourceDropDown.topOffset = CGPoint(x: 0, y: -(homeView.sourceDropDown.anchorView?.plainView.bounds.height)!)
        homeView.destinationDropDown.topOffset = CGPoint(x: 0, y: -(homeView.destinationDropDown.anchorView?.plainView.bounds.height)!)
        
        homeView.sourceDropDown.selectionAction = { (index: Index, item: String) in
            self.homeView.sourceDropDownTF.text = item
            self.homeView.sourceDDCurrencyImage.kf.setImage(with: self.buildImageUrl(item: item))
            self.homeView.sourceTFCurrencyLabel.text = item
            
            
            //buildHistoricalRatesGraph(ratesTab.selectedTabPosition)
            if (self.homeView.sourceTextField.text?.isEmpty ?? true || self.homeView.sourceDropDownTF.text?.isEmpty ?? true || self.homeView.destinationDropDownTF.text?.isEmpty ?? true) {
                return
            }
            self.convertValue()
        }
        
        homeView.destinationDropDown.selectionAction = { (index: Index, item: String) in
            self.homeView.destinationDropDownTF.text = item
            self.homeView.destinationDDCurrencyImage.kf.setImage(with: self.buildImageUrl(item: item))
            self.homeView.destinationTFCurrencyLabel.text = item
            
            //buildHistoricalRatesGraph(ratesTab.selectedTabPosition)
            if (self.homeView.sourceTextField.text?.isEmpty ?? true || self.homeView.sourceDropDownTF.text?.isEmpty ?? true || self.homeView.destinationDropDownTF.text?.isEmpty ?? true) {
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

    @objc func sourceCurrencyTextChanged(_ sender: UITextField) {
        filterAndShowDropDown(newText: sender.text, dropDown: homeView.sourceDropDown)
    }
    
    @objc func destinationCurrencyTextChanged(_ sender: UITextField) {
        filterAndShowDropDown(newText: sender.text, dropDown: homeView.destinationDropDown)
    }
    
    @objc func sourceAmountTextChanged(_ sender: UITextField) {
        if (sender.text?.isEmpty ?? false) {
            homeView.destinationTextField.text = ""
            return
        }
        homeView.sourceTextField.text = formatValue(value: sender.text!)
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
        case homeView.sourceDropDownTF:
            filterAndShowDropDown(newText: textField.text, dropDown: homeView.sourceDropDown)
        case homeView.destinationDropDownTF:
            filterAndShowDropDown(newText: textField.text, dropDown: homeView.destinationDropDown)
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField {
        case homeView.sourceDropDownTF:
            filterAndHideDropDown(textField: textField, dropDown: homeView.sourceDropDown)
        case homeView.destinationDropDownTF:
            filterAndHideDropDown(textField: textField, dropDown: homeView.destinationDropDown)
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
        if let sourceCurrency = homeView.sourceDropDownTF.text, let destCurrency = homeView.destinationDropDownTF.text,
            !sourceCurrency.isEmpty, !destCurrency.isEmpty, let sourceValue = homeView.sourceTextField.text, !sourceValue.isEmpty,
            let sourceRate = rates.first(where: {$0.currencyCode == sourceCurrency}),
            let destRate = rates.first(where: {$0.currencyCode == destCurrency}),
            sourceRate.baseCurrencyCode == destRate.baseCurrencyCode
        {
            let nf = NumberFormatter()
            let sourceToNumber = nf.number(from: sourceValue.replacingOccurrences(of: ",", with: "") )?.doubleValue ?? 0.0
            let convertedValue = sourceToNumber * destRate.rate / sourceRate.rate
            
            homeView.destinationTextField.text = formatValue(value: String(format: "%f", convertedValue))
        }
    }
}

