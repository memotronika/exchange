

import UIKit

class CurrencyDataDownloader {
    
    let APIKey = "20302932a711db71ea5c9b95"
    
    var delegate : UIViewController!
    var selectedCurrency:String!
    var decodedCurrencyData : DownloadedCurrencyData!
    
    func performRequest(completion: @escaping (Result<Double, Error>) -> Void) {
        let urlString = "https://v6.exchangerate-api.com/v6/\(APIKey)/latest/USD"
        guard let url = URL(string: urlString)
        else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        let urlSession = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let safeData = data else {
                completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                return
            }

            self.parseJSON(safeData, completion: completion)
        }
        task.resume()
    }

     func parseJSON(_ data: Data, completion: @escaping (Result<Double, Error>) -> Void) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DownloadedCurrencyData.self, from: data)
            guard let conversionRate = decodedData.conversion_rates[selectedCurrency] else {
                completion(.failure(NSError(domain: "Currency not found", code: 404, userInfo: nil)))
                return
            }
            completion(.success(conversionRate))
        } catch {
            completion(.failure(error))
        }
    }
}
    


