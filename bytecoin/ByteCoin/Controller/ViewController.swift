
import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    let coinManager = CoinManager()
    var currencyDataDownloader = CurrencyDataDownloader()
    var coinDataDownloader = CoinDataDownloader()
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pickerOutlet: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyDataDownloader.delegate = self
        coinDataDownloader.delegate = self
        pickerOutlet.dataSource = self
        pickerOutlet.delegate = self
        doRequests("USD", "BTC")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return coinManager.currencyArray.count
        }else {
            return coinManager.coinsArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return coinManager.currencyArray[row]
        }else {
            return coinManager.coinsArray[row]
        }    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let component0selection = pickerView.selectedRow(inComponent: 0)
        let component1selection = pickerView.selectedRow(inComponent: 1)
        doRequests(coinManager.currencyArray[component0selection],coinManager.coinsArray[component1selection])
    }
    
    func doRequests(_ currencyString: String, _ coinString: String) {
        currencyDataDownloader.selectedCurrency = currencyString
        coinDataDownloader.selectedCoin = coinString
        currencyDataDownloader.performRequest() { [self] currencyResult in
            switch currencyResult {
            case .success(let currencyPrice):
                coinDataDownloader.performRequest() { coinResult in
                    switch coinResult {
                    case .success(let coinPrice):
//                        print("Coin Price: \(coinPrice)")
//                        print("Currency Price: \(currencyPrice)")
                        
                        DispatchQueue.main.async {
                            self.updateUI(coinPrice, currencyPrice)
                        }
                    case .failure(let error):
                        print("Error fetching coin data: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error fetching currency data: \(error.localizedDescription)")
            }
        }
    }
    
    func updateUI(_ coinPrice: Double, _ currencyPrice: Double) {
       
            let finalPrice = coinPrice * currencyPrice
            priceLabel.text = String( format : "%.2f",finalPrice)
        usdLabel.text = currencyDataDownloader.selectedCurrency
        coinImage.image = UIImage(named: coinDataDownloader.selectedCoin)
       
        }
    }
