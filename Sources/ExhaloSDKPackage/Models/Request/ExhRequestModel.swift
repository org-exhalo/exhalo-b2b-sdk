import Foundation

public struct ExhRequestModel: Codable {
    public let userId: String
    public let projectId: String
    public let requestLocalDateTime: String
    public let requestUtcDateTime: String
    public let healthData: [ExhHealthData]

    public init(
        userId: String,
        projectId: String,
        requestLocalDateTime: String,
        requestUtcDateTime: String,
        healthData: [ExhHealthData]
    ) {
        self.userId = userId
        self.projectId = projectId
        self.requestLocalDateTime = requestLocalDateTime
        self.requestUtcDateTime = requestUtcDateTime
        self.healthData = healthData
    }
}
