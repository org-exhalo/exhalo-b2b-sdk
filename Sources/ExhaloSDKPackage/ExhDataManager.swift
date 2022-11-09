import Foundation
import Amplitude

public enum ExhDataEnvironment {
    case dev
    case acc
    case prod
}

public class ExhDataManager {
    public class var shared: ExhDataManager {
          struct Singleton {
              static let instance = ExhDataManager()
          }
          return Singleton.instance
    }

    public var showDebug = false

    private init() {}

    public func setHealthKitPermission(isAccessGranted: Bool) {
        guard isAccessGranted else {
            Setter.value(false, forKey: .hasHealthKitPermission)
            exhLog("[ExhDataManager] HealthKitPermission access not granted\nRun ExhDataManager.shared.setHealthKitPermission( true ) ")
            
            

            return
        }
        
        Amplitude.instance().logEvent("hkit_permissions_granted")

        Setter.value(isAccessGranted, forKey: .hasHealthKitPermission)
        ExhHealthKitManager.shared.requestAuthorization { [weak self] succes, error in
            guard succes else {
                let msg = error?.description ?? "unknow error"
                exhLog(msg)
                return
            }
            self?.fetchData()
        }
    }

    public func initialize(projectId: String, environment: ExhDataEnvironment) {
        if (environment != .prod) {
            Amplitude.instance().initializeApiKey("7761f8a8114949c5eaa1a1783fe259c2")
        } else {
            Amplitude.instance().initializeApiKey("b99ad693aa8410963698cd4658b1ecc5")
        }
        
        let envString =
        environment == .prod ? "prod" :
        environment == .acc ? "acc" :
        "dev";
        
        Setter.value(envString, forKey: .sdkEnv)
        
        let identify = AMPIdentify()
            .set("projectId", value: projectId as NSString)
            .set("env", value: envString as NSString)

        Amplitude.instance().identify(identify!)
        
        self.projectId = projectId

        if Getter.bool(.hasHealthKitPermission) {
            fetchData()
        } else {
            exhLog("User don't accept permission for HealthKit")
        }
    }

    public func enableLog(enable: Bool) {
        showDebug = enable
    }

    private func createUserUUIDIfNeeded() {
        if let id = ExhKeyChain.load(key: .userUUID) {
            Amplitude.instance().setUserId(id);
            
            Amplitude.instance().logEvent("sdk_launch", withEventProperties: ["first_open": true])
            
            exhLog("[ExhDataManager] user id configured \(id)")
        } else {
            let id = ExhKeyChain.save(key: .userUUID, string: ExhKeyChain.createUniqueID())
            
            Amplitude.instance().setUserId(String(id));
            
            Amplitude.instance().logEvent("sdk_launch", withEventProperties: ["first_open": false])
            
            exhLog("[ExhDataManager] User ID first init: \(id)")
        }
    }

    private func fetchData() {
        createUserUUIDIfNeeded()
        
        let dispatchGroup = DispatchGroup()

        var sleepData = [ExhSleepMeasurement]()
        var hrData = [ExhHRMeasurement]()
        var hrvData = [ExhHRVMeasurement]()
        var activityData = [ExhActivity]()
        var mindfulnessMinutes = [ExhMindfulness]()

        dispatchGroup.enter()
        ExhHealthKitManager.shared.getSleepAnalysis { sleep in
            sleepData = sleep
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        ExhHealthKitManager.shared.getHeartRates { heartRates in
            dispatchGroup.leave()
            hrData = heartRates
        }

        dispatchGroup.enter()
        ExhHealthKitManager.shared.getHeartRatesVariability { heartRatesVariability in
            dispatchGroup.leave()
            hrvData = heartRatesVariability
        }

        dispatchGroup.enter()
        ExhHealthKitManager.shared.getActivity { activity in
            dispatchGroup.leave()
            activityData = activity
        }

        dispatchGroup.enter()
        ExhHealthKitManager.shared.getMindfulness { mindfulness in
            dispatchGroup.leave()
            mindfulnessMinutes = mindfulness
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard
                let self,
                let projectId = self.projectId,
                let userId = ExhKeyChain.load(key: .userUUID)
            else {
                return
            }

            let requestLocalDateTime = buildISO8601String(from: Date())
            let requestUtcDateTime = buildUTCDateString(from: Date())
            let healthData = self.prepareHealthData(
                sleepData: sleepData,
                hrData: hrData,
                hrvData: hrvData,
                activityData: activityData,
                mindfulnessMinutes: mindfulnessMinutes
            )
            let model = ExhRequestModel(
                userId: userId,
                projectId: projectId,
                requestLocalDateTime: requestLocalDateTime,
                requestUtcDateTime: requestUtcDateTime,
                healthData: healthData
            )

            self.send(model: model, completion: { data, error in
                if let error {
                    exhLog(error.localizedDescription)
                    return
                } else {
                    exhLog("Success")
                }
            })


            ExhHealthKitManager.shared.getUserData { user in
                if let user = user {
                    print("User a, w, h, s: \(user.age), \(user.bodyWeight), \(user.height), \(user.biologicalSex)")
                    
                    let identify = AMPIdentify()
                        .set("age", value: user.age as NSNumber)
                        .set("sex", value: user.biologicalSex as NSNumber)
                        .set("weight_kg", value: user.bodyWeight as NSNumber)
                        .set("height_cm", value: user.height as NSNumber)

                    Amplitude.instance().identify(identify!)
                }
            }
        }
    }

    private func prepareHealthData(
        sleepData: [ExhSleepMeasurement],
        hrData: [ExhHRMeasurement],
        hrvData: [ExhHRVMeasurement],
        activityData: [ExhActivity],
        mindfulnessMinutes: [ExhMindfulness]
    ) -> [ExhHealthData] {
        let dates = getDatesArray()

        var healthDataArray = [ExhHealthData]()
        dates.forEach { date in

            var activities: [ExhActivity] = []
            var hrMeasurements: [ExhHRMeasurement] = []
            var hrvMeasurements: [ExhHRVMeasurement] = []
            var sleepMeasurements: [ExhSleepMeasurement] = []
            var mindfulness: [ExhMindfulness] = []

            let activity = activityData.filter({ $0.isDateSame(date: date) })
                activity.forEach {
                    activities.append($0)
                }

            let hr = hrData.filter({ $0.isDateSame(date: date) })
                hr.forEach {
                    hrMeasurements.append($0)
                }

            let hrv = hrvData.filter({ $0.isDateSame(date: date) })
                hrv.forEach {
                    hrvMeasurements.append($0)
                }

            let sleep = sleepData.filter({ $0.isDateSame(date: date) })
                sleep.forEach {
                    sleepMeasurements.append($0)
                }

            let mind = mindfulnessMinutes.filter({ $0.isDateSame(date: date) })
                mind.forEach {
                    mindfulness.append($0)
                }


            let utcDate = buildUTCDateString(from: date)
            let healthMeasurements = ExhHealthMeasurements(activities: activities, hrMeasurements: hrMeasurements, hrvMeasurements: hrvMeasurements, sleepMeasurements: sleepMeasurements, mindfulnessMinutes: mindfulness)
            let model = ExhHealthData(utcDate: utcDate, healthMeasurements: healthMeasurements)
            healthDataArray.append(model)
        }


        return healthDataArray
    }

    private func getDatesArray() -> [Date] {
        let utcString = buildUTCDateString(from: Date())
        let utcDate = buildUTCDate(from: utcString)
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        var startTime = utcDate!
        var dateArray = [Date]()

        dateArray.append(startTime)
        for _ in 0 ..< abs(daysFetchingLimit) {
            var dayComponent    = DateComponents()
            dayComponent.day    = -1
            if let prevDate        = calendar.date(byAdding: dayComponent, to: startTime) {
                startTime = prevDate
                dateArray.append(startTime)
            }
        }
        return dateArray
    }
    private func send(model: ExhRequestModel, completion: @escaping ExhResponseCompletion) {
        guard let request = LatestRequestBuilder.request(payload: model) else {
            completion(nil, NetworkError.description(str: "Wrong request data"))
            return
        }
        ExhNetwork.run(request: request, completion: completion)
    }
    private var projectId: String?
}

