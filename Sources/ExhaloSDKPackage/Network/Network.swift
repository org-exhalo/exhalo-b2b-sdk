import Foundation
import Amplitude

let defaultNetworkError = "Oops... Please, try again later"

enum NetworkError: Error {
    case description(str: String)
}

class ExhNetwork {

    static func run(request: NSMutableURLRequest, completion block: @escaping ExhResponseCompletion) {
        let task = ExhSharedSession.session.dataTask(with: request as URLRequest) { (
            data, response, error) in

            if let httpResponse = response as? HTTPURLResponse {
                if let u = httpResponse.url?.absoluteString {
                    if ExhDataManager.shared.showDebug {
                        exhLog(u + " | status code: " + "\(httpResponse.statusCode)")
                    }
                    if ExhDataManager.shared.showDebug {
                        if let data = data {
                            if let result = String(bytes: data, encoding: .utf8) {
                                print(result)
                            }
                        }
                    }
                }


                if httpResponse.statusCode != 200 {                    
                    Amplitude.instance().logEvent("add_healthdata_request_completed", withEventProperties: [
                        "error_code": httpResponse.statusCode,
                        "successful_result": false
                    ])
                    
                    block(nil, NetworkError.description(str: defaultNetworkError))
                    
                    return
                }
                
                Amplitude.instance().logEvent("add_healthdata_request_completed", withEventProperties: [
                    "successful_result": true,
                    "error_code": 0
                ])
            }

            guard let result = data, let _:URLResponse = response, error == nil else {
                block(nil, NetworkError.description(str: defaultNetworkError))
                exhLog("FAIL data")
                return
            }

            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(ExhResponseModel.self, from: result)
                block(model, nil)
            }
            catch {
                exhLog(error.localizedDescription)
                block(nil, NetworkError.description(str: "Fail to parse data"))
            }
        }

        task.resume()
    }
}
