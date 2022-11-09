import Foundation

public class ExhMindfulness: Codable {
    public let id: String
    public let startDate: String
    public let sourceName: String
//    public let value: Int
    public let endDate: String
    public let sourceId: String
    public let startDateUTC: String
    public let endDateUTC: String


    enum CodingKeys: String, CodingKey {
        case id = "id"
        case startDate = "startDate"
        case sourceName = "sourceName"
//        case value = "value"
        case endDate = "endDate"
        case sourceId = "sourceId"
        case startDateUTC = "startDateUTC"
        case endDateUTC = "endDateUTC"
    }

    public init(
        id: String,
        startDate: String,
        sourceName: String,
//        value: Int,
        endDate: String,
        sourceId: String,
        startDateUTC: String,
        endDateUTC: String
    ){
        self.id = id
        self.startDate = startDate
        self.sourceName = sourceName
//        self.value = value
        self.endDate = endDate
        self.sourceId = sourceId
        self.startDateUTC = startDateUTC
        self.endDateUTC = endDateUTC
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        startDate = try values.decode(String.self, forKey: .startDate)
        sourceName = try values.decode(String.self, forKey: .sourceName)
//        value = try values.decode(Int.self, forKey: .value)
        endDate = try values.decode(String.self, forKey: .endDate)
        sourceId = try values.decode(String.self, forKey: .sourceId)
        startDateUTC = try values.decode(String.self, forKey: .startDateUTC)
        endDateUTC = try values.decode(String.self, forKey: .endDateUTC)

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(sourceName, forKey: .sourceName)
//        try container.encode(value, forKey: .value)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(sourceId, forKey: .sourceId)
        try container.encode(startDateUTC, forKey: .startDateUTC)
        try container.encode(endDateUTC, forKey: .endDateUTC)
    }
}

extension ExhMindfulness: Datable {
    func isDateSame(date: Date) -> Bool {
        guard let current = buildISO8601Date(from: startDateUTC) else { return false }
        let equal = isSameDay(date1: date, date2: current);
        return equal
    }
}
