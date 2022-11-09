//
//  ExhaloReportData.swift
//  ExhaloSDK
//

import Foundation

public struct ExhReportData: Codable {
    public let value: Double
    public let description: String
    public let impactFactors: [ExhImpactFactor]


    enum CodingKeys: String, CodingKey {
        case value = "value"
        case description = "description"
        case impactFactors = "impactFactors"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        value = try values.decode(Double.self, forKey: .value)
        description = try values.decode(String.self, forKey: .description)
        impactFactors = try values.decode([ExhImpactFactor].self, forKey: .impactFactors)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(description, forKey: .description)
        try container.encode(impactFactors, forKey: .impactFactors)

    }
}
