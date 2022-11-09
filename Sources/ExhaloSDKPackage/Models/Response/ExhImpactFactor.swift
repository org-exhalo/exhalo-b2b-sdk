//
//  ExhaloImpactFactor.swift
//  ExhaloSDK
//

import Foundation

public struct ExhImpactFactor: Codable {
    public let label: String
    public let value: String
    public let score: Double?

    enum CodingKeys: String, CodingKey {
        case label = "label"
        case value = "value"
        case score = "score"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decode(String.self, forKey: .label)
        value = try values.decode(String.self, forKey: .value)
        score = try values.decode(Double.self, forKey: .score)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(value, forKey: .value)
        try container.encode(score, forKey: .score)
    }
}
