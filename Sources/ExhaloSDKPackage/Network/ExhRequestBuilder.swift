//
//  ExhRequestBuilder.swift
//  ExhaloSDK
//

import Foundation

struct LatestRequestBuilder {
    static func request(payload: ExhRequestModel) -> NSMutableURLRequest? {

        guard let URL = URL(string: endPoint) else {
            return nil
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(payload)
            let request = NSMutableURLRequest(url: URL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.httpBody = data

            print(String(data: data, encoding: .utf8)!)
            return request
        } catch {
            return nil
        }
    }
    private static let endPoint = ExhSharedSession.domainURL + "/healthdata/add"
}
