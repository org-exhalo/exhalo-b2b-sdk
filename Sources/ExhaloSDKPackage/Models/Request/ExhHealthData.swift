import Foundation

public struct ExhHealthData: Codable {
    public let utcDate: String
    public let healthMeasurements: ExhHealthMeasurements

    enum CodingKeys: String, CodingKey {
        case healthMeasurements = "healthMeasurements"
        case utcDate = "utcDate"
    }

    public init(utcDate: String, healthMeasurements: ExhHealthMeasurements) {
        self.utcDate = utcDate
        self.healthMeasurements = healthMeasurements
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        utcDate = try values.decode(String.self, forKey: .utcDate)
        healthMeasurements = try values.decode(ExhHealthMeasurements.self, forKey: .healthMeasurements)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(healthMeasurements, forKey: .healthMeasurements)
        try container.encode(utcDate, forKey: .utcDate)
    }
}
