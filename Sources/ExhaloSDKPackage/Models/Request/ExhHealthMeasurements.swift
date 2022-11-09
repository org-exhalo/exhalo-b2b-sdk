import Foundation

public struct ExhHealthMeasurements: Codable {
    public let activities: [ExhActivity]
    public let hr: [ExhHRMeasurement]
    public let hrv: [ExhHRVMeasurement]
    public let sleep: [ExhSleepMeasurement]
    public let mindfulnessMinutes: [ExhMindfulness]

    enum CodingKeys: String, CodingKey {
        case activities = "activities"
        case hr = "hr"
        case hrv = "hrv"
        case sleep = "sleep"
        case mindfulnessMinutes = "mindfulnessMinutes"
    }

    public init(
        activities: [ExhActivity],
        hrMeasurements: [ExhHRMeasurement],
        hrvMeasurements: [ExhHRVMeasurement],
        sleepMeasurements: [ExhSleepMeasurement],
        mindfulnessMinutes: [ExhMindfulness]
    ) {
        self.activities = activities
        self.hr = hrMeasurements
        self.hrv = hrvMeasurements
        self.sleep = sleepMeasurements
        self.mindfulnessMinutes = mindfulnessMinutes
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        activities = try values.decode([ExhActivity].self, forKey: .activities)
        hr = try values.decode([ExhHRMeasurement].self, forKey: .hr)
        hrv = try values.decode([ExhHRVMeasurement].self, forKey: .hrv)
        sleep = try values.decode([ExhSleepMeasurement].self, forKey: .sleep)
        mindfulnessMinutes = try values.decode([ExhMindfulness].self, forKey: .mindfulnessMinutes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(activities, forKey: .activities)
        try container.encode(hr, forKey: .hr)
        try container.encode(hrv, forKey: .hrv)
        try container.encode(sleep, forKey: .sleep)
        try container.encode(mindfulnessMinutes, forKey: .mindfulnessMinutes)

    }
}
