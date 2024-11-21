
import UIKit
class CoinDataDownloader {
    var decodedCoinData:DownloadedCoinData!
    var delegate : UIViewController!
    var selectedCoin:String!
    
    func performRequest(completion: @escaping (Result<Double, Error>) -> Void){
        let urlString = "https://api.binance.com/api/v3/ticker/price?symbol=\(self.selectedCoin!)USDT"
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
            let decodedData = try decoder.decode(DownloadedCoinData.self, from: data)
            guard let conversionRate = decodedData.price else {
                completion(.failure(NSError(domain: "Currency not found", code: 404, userInfo: nil)))
                return
            }
            completion(.success(Double(conversionRate)!))
        } catch {
            completion(.failure(error))
        }
    }
}

