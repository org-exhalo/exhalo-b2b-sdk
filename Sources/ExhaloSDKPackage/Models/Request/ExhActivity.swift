import Foundation

public struct ExhActivity: Codable {
    public let calories: Double
    public let activityId: Int
    public let id: String
    public let sourceName: String
    public let sourceId: String
    public let activityName: String
    public let distance: Double
    public let device: String
    public let startDate: String
    public let endDate: String
    public let startDateUTC: String
    public let endDateUTC: String
    public let isUserEnteredByHimself: Bool

    enum CodingKeys: String, CodingKey {
        case calories = "calories"
        case activityId = "activityId"
        case id = "id"
        case sourceName = "sourceName"
        case sourceId = "sourceId"
        case activityName = "activityName"
        case distance = "distance"
        case device = "device"
        case startDate = "startDate"
        case endDate = "endDate"
        case startDateUTC = "startDateUTC"
        case endDateUTC = "endDateUTC"
        case isUserEnteredByHimself = "isUserEnteredByHimself"
    }

    public init(
        calories: Double,
        activityId: Int,
        id: String,
        sourceName: String,
        sourceId: String,
        activityName: String,
        distance: Double,
        device: String,
        startDate: String,
        endDate: String,
        startDateUTC: String,
        endDateUTC: String,
        isUserEnteredByHimself: Bool
    ) {
        self.calories = calories
        self.activityId = activityId
        self.id = id
        self.sourceName = sourceName
        self.sourceId = sourceId
        self.activityName = activityName
        self.distance = distance
        self.device = device
        self.startDate = startDate
        self.endDate = endDate
        self.startDateUTC = startDateUTC
        self.endDateUTC = endDateUTC
        self.isUserEnteredByHimself = isUserEnteredByHimself
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        calories = try values.decode(Double.self, forKey: .calories)
        activityId = try values.decode(Int.self, forKey: .activityId)
        id = try values.decode(String.self, forKey: .id)
        sourceName = try values.decode(String.self, forKey: .sourceName)
        sourceId = try values.decode(String.self, forKey: .sourceId)
        activityName = try values.decode(String.self, forKey: .activityName)
        distance = try values.decode(Double.self, forKey: .distance)
        device = try values.decode(String.self, forKey: .device)
        startDate = try values.decode(String.self, forKey: .startDate)
        endDate = try values.decode(String.self, forKey: .endDate)
        startDateUTC = try values.decode(String.self, forKey: .startDateUTC)
        endDateUTC = try values.decode(String.self, forKey: .endDateUTC)
        isUserEnteredByHimself = try values.decode(Bool.self, forKey: .isUserEnteredByHimself)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(calories, forKey: .calories)
        try container.encode(activityId, forKey: .activityId)
        try container.encode(id, forKey: .id)
        try container.encode(sourceName, forKey: .sourceName)
        try container.encode(sourceId, forKey: .sourceId)
        try container.encode(activityName, forKey: .activityName)
        try container.encode(distance, forKey: .distance)
        try container.encode(device, forKey: .device)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(startDateUTC, forKey: .startDateUTC)
        try container.encode(endDateUTC, forKey: .endDateUTC)
        try container.encode(isUserEnteredByHimself, forKey: .isUserEnteredByHimself)
    }
}

extension ExhActivity: Datable {
    func isDateSame(date: Date) -> Bool {
        guard let current = buildISO8601Date(from: startDateUTC) else { return false }
        let equal = isSameDay(date1: date, date2: current);
        return equal
    }
}
