//
//  ExhaloResponseModel.swift
//  ExhaloSDK
//

import Foundation

public struct ExhResponseModel: Codable {
    public let readinessToday: ExhReportData
    public let mindfulnessYesterday: ExhReportData
    public let stressLevelToday: ExhStressData
    public let status: String
    public let message: String
}
