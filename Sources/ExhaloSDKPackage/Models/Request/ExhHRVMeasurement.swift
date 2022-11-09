import Foundation

public class ExhHRVMeasurement: Codable {
    public let endDate: String
    public let id: String
    public let startDate: String
    public let sourceId: String
    public let value: Double
    public let sourceName: String
    public let startDateUTC: String
    public let endDateUTC: String
    public let isUserEnteredByHimself: Bool

    enum CodingKeys: String, CodingKey {
        case endDate = "endDate"
        case id = "id"
        case startDate = "startDate"
        case sourceId = "sourceId"
        case value = "value"
        case sourceName = "sourceName"
        case startDateUTC = "startDateUTC"
        case endDateUTC = "endDateUTC"
        case isUserEnteredByHimself = "isUserEnteredByHimself"
    }

    public init(
        endDate: String,
        id: String,
        startDate: String,
        sourceId: String,
        value: Double,
        sourceName: String,
        startDateUTC: String,
        endDateUTC: String,
        isUserEnteredByHimself: Bool
    ) {
        self.endDate = endDate
        self.id = id
        self.startDate = startDate
        self.sourceId = sourceId
        self.value = value
        self.sourceName = sourceName
        self.startDateUTC = startDateUTC
        self.endDateUTC = endDateUTC
        self.isUserEnteredByHimself = isUserEnteredByHimself
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        endDate = try values.decode(String.self, forKey: .endDate)
        id = try values.decode(String.self, forKey: .id)
        startDate = try values.decode(String.self, forKey: .startDate)
        sourceId = try values.decode(String.self, forKey: .sourceId)
        value = try values.decode(Double.self, forKey: .value)
        sourceName = try values.decode(String.self, forKey: .sourceName)
        startDateUTC = try values.decode(String.self, forKey: .startDateUTC)
        endDateUTC = try values.decode(String.self, forKey: .endDateUTC)
        isUserEnteredByHimself = try values.decode(Bool.self, forKey: .isUserEnteredByHimself)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(id, forKey: .id)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(sourceId, forKey: .sourceId)
        try container.encode(value, forKey: .value)
        try container.encode(sourceName, forKey: .sourceName)
        try container.encode(startDateUTC, forKey: .startDateUTC)
        try container.encode(endDateUTC, forKey: .endDateUTC)
        try container.encode(isUserEnteredByHimself, forKey: .isUserEnteredByHimself)
    }
}

extension ExhHRVMeasurement: Datable {
    func isDateSame(date: Date) -> Bool {
        guard let current = buildISO8601Date(from: startDateUTC) else { return false }
        let equal = isSameDay(date1: date, date2: current);
        return equal
    }
}
