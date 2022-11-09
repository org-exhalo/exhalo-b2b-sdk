import Foundation
import HealthKit


typealias RequestAuthorizationBlock =  (Bool, ExhaloError?) -> Void
typealias FetchSleepCompletion = ([ExhSleepMeasurement]) -> Void
typealias FetchHRCompletion = ([ExhHRMeasurement]) -> Void
typealias FetchHRVCompletion = ([ExhHRVMeasurement]) -> Void
typealias FetchActivityCompletion = ([ExhActivity]) -> Void
typealias FetchMindfulnessCompletion = ([ExhMindfulness]) -> Void

typealias FethcUserDataBlock =  (ExhUserData?) -> Void
typealias FetchAgeSexCompletion = (_ age: Int, _ sex: Int) -> Void
typealias FetchWeightCompletion = (Double) -> Void
typealias FetchbodyMassKgCompletion = (Double) -> Void

let daysFetchingLimit = -4;

enum ExhaloError: Error {
    case custom(error: Error?)
    case healthDataUnAvailable
    case healthKitTypesToReadWrong


    var description: String {
        switch self {
        case .custom(let error): return error?.localizedDescription ?? "Unknow error"
        case .healthDataUnAvailable: return "HealthKit isn't available"
        case .healthKitTypesToReadWrong: return "healthKitTypesToRead is wrong ( sleepAnalysis, "
        }
    }
}

class ExhHealthKitManager {
    static let shared = ExhHealthKitManager()
    private init() { }
}

extension ExhHealthKitManager {
    func getUserData(completion: @escaping FethcUserDataBlock) {
        var userSex: Int = 0
        var userWeight: Double = 0
        var userHeight: Double = 0
        var userAge: Int = 0


        let dispathGroup = DispatchGroup()
        dispathGroup.enter()
        getAgeSex { age, sex in
            userAge = age
            userSex = sex
            dispathGroup.leave()
        }

        dispathGroup.enter()
        getWH { value in
            userHeight = value
            dispathGroup.leave()
        }

        dispathGroup.enter()
        bodyMassKg { value in
            userWeight = value
            dispathGroup.leave()
        }

        dispathGroup.notify(queue: .main) {
            let userData = ExhUserData(
                biologicalSex: userSex,
                bodyWeight: userWeight,
                height: userHeight,
                age: userAge)
            completion(userData)
        }
    }
}

extension ExhHealthKitManager {
    func getAgeSex(completion: @escaping FetchAgeSexCompletion){

      let healthKitStore = HKHealthStore()

      do {
        let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
        let biologicalSex =       try healthKitStore.biologicalSex()

        let today = Date()
        let calendar = Calendar.current
        let todayDateComponents = calendar.dateComponents([.year],
                                                            from: today)
        let thisYear = todayDateComponents.year!
        let age = thisYear - birthdayComponents.year!
        let unwrappedBiologicalSex = biologicalSex.biologicalSex

          completion(age, unwrappedBiologicalSex.rawValue)
      } catch {
          completion(0, 0)
      }
    }

    func getWH(completion: @escaping FetchWeightCompletion) {
        if let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height) {
            let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
                if let result = results?.first as? HKQuantitySample{
                    print("Height => \(result.quantity)")
                    let value = result.quantity.doubleValue(for: HKUnit.meter())
                    completion(value)
                } else{
                    completion(0)
                }
            }
            HKHealthStore().execute(query)
        }
    }

    func bodyMassKg(completion: @escaping FetchbodyMassKgCompletion) {
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            completion(0)
            return
        }

        let query = HKSampleQuery(sampleType: weightSampleType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample {
                let bodyMassKg = result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                completion(bodyMassKg)
                return
            }

            //no data
            completion(0)
        }
        HKHealthStore().execute(query)
    }
}

extension ExhHealthKitManager {

    func requestAuthorization(authorizationBlock: @escaping RequestAuthorizationBlock) {

        guard
            HKHealthStore.isHealthDataAvailable() else {
            authorizationBlock(false, .healthDataUnAvailable)
          return
        }

        guard
            let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            let healthRate = HKObjectType.quantityType(forIdentifier: .heartRate),
            let healthRateV = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            let mindfulness = HKObjectType.categoryType(forIdentifier: .mindfulSession)

        else {
            authorizationBlock(false, .healthKitTypesToReadWrong)
            return
        }

        let healthKitTypesToRead: Set<HKObjectType> = [
           sleep,
           healthRate,
           healthRateV,
           mindfulness,
           .workoutType()
        ]

        HKHealthStore().requestAuthorization(
            toShare: nil,
            read: healthKitTypesToRead)
        { (success, error) in
            authorizationBlock(success, .custom(error: error))
        }
    }
}

extension ExhHealthKitManager {
    func getActivity(completion: @escaping FetchActivityCompletion) {

        getMostActivituSample(for: .workoutType()) { samples, error in
            if let _ = error {
                completion([])
                return
            }

            var activityData = [ExhActivity]()

            samples.forEach {
                if let sample = ( $0 as? HKWorkout ) {

                    var energyValue: Double = 0
                    if let totalEnergyBurned = sample.totalEnergyBurned {
                        energyValue = totalEnergyBurned.doubleValue(for: .kilocalorie())
                    }

                    var distanceValue: Double = 0
                    if let totalDistance = sample.totalDistance {
                        distanceValue = totalDistance.doubleValue(for: .mile())
                    }

                    var isUserEnteredByHimself = true
                    if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool {
                        isUserEnteredByHimself = wasUserEntered
                    }

                    let startDate = buildISO8601String(from: sample.startDate)
                    let endDate = buildISO8601String(from: sample.endDate)
                    let startDateUTC = buildUTCDateString(from: sample.startDate)
                    let endDateUTC = buildUTCDateString(from: sample.endDate)

                    let calories: Double = energyValue
                    let activityId: Int = Int(sample.workoutActivityType.rawValue)
                    let id: String = sample.uuid.uuidString
                    let sourceName: String = sample.sourceRevision.source.name
                    let sourceId: String = sample.sourceRevision.source.bundleIdentifier
                    let activityName: String = ""
                    let distance: Double = distanceValue
                    let device: String = sample.device?.name ?? "iPhone"


                    let model = ExhActivity(
                        calories: calories.truncate(places: 3),
                        activityId: activityId,
                        id: id,
                        sourceName: sourceName,
                        sourceId: sourceId,
                        activityName: activityName,
                        distance: distance.truncate(places: 3),
                        device: device,
                        startDate: startDate,
                        endDate: endDate,
                        startDateUTC: startDateUTC,
                        endDateUTC: endDateUTC,
                        isUserEnteredByHimself: isUserEnteredByHimself
                    )

                    activityData.append(model)
                }
            }
            completion(activityData)
        }
    }

    func getMostActivituSample(for sampleType: HKSampleType,
                                   completion: @escaping ([HKSample], Error?) -> Swift.Void) {

        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: daysFetchingLimit, to: Date())!,
            end: Date(),
            options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)


        let sampleQuery = HKSampleQuery(
            sampleType: sampleType,
            predicate: mostRecentPredicate,
            limit: 10000000,
            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                completion(samples ?? [], error)
        }

        HKHealthStore().execute(sampleQuery)
    }
}

//HR
extension ExhHealthKitManager {
    func getHeartRates(completion: @escaping FetchHRCompletion) {
        var hrDataArray = [ExhHRMeasurement]()

        let heartRateType:HKQuantityType = HKQuantityType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.heartRate)!

        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: daysFetchingLimit, to: Date())!,
            end: Date(),
            options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)

        var heartRateQuery:HKSampleQuery?
        heartRateQuery = HKSampleQuery(
            sampleType: heartRateType,
            predicate: mostRecentPredicate,
            limit: 10000000,
            sortDescriptors: [sortDescriptor],
            resultsHandler: { (query, results, error) in
                guard error == nil
                else {
                    completion([])
                    return
                }

                results?.forEach {
                    if let sample: HKQuantitySample = $0 as? HKQuantitySample {

                        let id: String = sample.uuid.uuidString
                        let startDate = buildISO8601String(from: sample.startDate)
                        let endDate = buildISO8601String(from: sample.endDate)
                        let startDateUTC = buildUTCDateString(from: sample.startDate)
                        let endDateUTC = buildUTCDateString(from: sample.endDate)

                        let sourceName = sample.sourceRevision.source.name
                        let sourceId = sample.sourceRevision.source.bundleIdentifier

                        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
                        let value = sample.quantity.doubleValue(for: heartRateUnit)

                        let motionContext: String = ""

                        var isUserEnteredByHimself = true
                        if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool {
                            isUserEnteredByHimself = wasUserEntered
                        }

                        let model = ExhHRMeasurement(
                            endDate: endDate,
                            id: id,
                            startDate: startDate,
                            sourceId: sourceId,
                            value: value.truncate(places: 3),
                            sourceName: sourceName,
                            startDateUTC: startDateUTC,
                            endDateUTC: endDateUTC,
                            isUserEnteredByHimself: isUserEnteredByHimself,
                            motionContext: motionContext)

                        hrDataArray.append(model)
                    }
                }
                completion(hrDataArray)
        })

        HKHealthStore().execute(heartRateQuery!)
     }
}

//HRV
extension ExhHealthKitManager {
    func getHeartRatesVariability(completion: @escaping FetchHRVCompletion) {
        var hrvDataArray = [ExhHRVMeasurement]()
        guard
            let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)
        else {
            completion([])
            return
        }

        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: daysFetchingLimit, to: Date())!,
            end: Date(),
            options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)

        var heartRateQuery:HKSampleQuery?
        heartRateQuery = HKSampleQuery(
            sampleType: heartRateType,
            predicate: mostRecentPredicate,
            limit: 10000000,
            sortDescriptors: [sortDescriptor],
            resultsHandler: { (query, results, error) in
                guard error == nil
                else {
                    completion([])
                    return
                }

                results?.forEach {
                    if let sample: HKQuantitySample = $0 as? HKQuantitySample {
                        let id: String = sample.uuid.uuidString
                        let startDate = buildISO8601String(from: sample.startDate)
                        let endDate = buildISO8601String(from: sample.endDate)
                        let startDateUTC = buildUTCDateString(from: sample.startDate)
                        let endDateUTC = buildUTCDateString(from: sample.endDate)

                        let sourceName = sample.sourceRevision.source.name
                        let sourceId = sample.sourceRevision.source.bundleIdentifier

                        let unit:HKUnit = HKUnit.second()
                        let value = sample.quantity.doubleValue(for: unit)

                        var isUserEnteredByHimself = true
                        if let wasUserEntered = sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool {
                            isUserEnteredByHimself = wasUserEntered
                        }

                        let model = ExhHRVMeasurement(
                            endDate: endDate,
                            id: id,
                            startDate: startDate,
                            sourceId: sourceId,
                            value: value.truncate(places: 3),
                            sourceName: sourceName,
                            startDateUTC: startDateUTC,
                            endDateUTC: endDateUTC,
                            isUserEnteredByHimself: isUserEnteredByHimself
                        )

                        hrvDataArray.append(model)
                    }
                }
                completion(hrvDataArray)

        })

        HKHealthStore().execute(heartRateQuery!)
     }
}


extension ExhHealthKitManager {
    func getSleepAnalysis (completion: @escaping FetchSleepCompletion) {
        guard let sleepSampleType = HKSampleType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }

        self.getMostRecentSample(for: sleepSampleType) { sample, error in
            var sleepArray = [ExhSleepMeasurement]()

            sample.forEach {
                if let categorySample = $0 as? HKCategorySample {

                    var valueString = ""
                    switch categorySample.value {
                    case HKCategoryValueSleepAnalysis.inBed.rawValue:
                        valueString = "INBED"
                        //                    case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                        //                        valueString = "ASLEEP"
                    default:
                        valueString = "UNKNOWN"
                    }

                    let id: String = categorySample.uuid.uuidString
                    let startDate = buildISO8601String(from: categorySample.startDate)
                    let sourceName = categorySample.sourceRevision.source.name
                    let value = valueString
                    let endDate = buildISO8601String(from: categorySample.endDate)
                    let sourceId = categorySample.sourceRevision.source.bundleIdentifier
                    let startDateUTC = buildUTCDateString(from: categorySample.startDate)
                    let endDateUTC = buildUTCDateString(from: categorySample.endDate)

                    let sleep = ExhSleepMeasurement(
                        id: id,
                        startDate: startDate,
                        sourceName: sourceName,
                        value: value,
                        endDate: endDate,
                        sourceId: sourceId,
                        startDateUTC: startDateUTC,
                        endDateUTC: endDateUTC
                    )
                    sleepArray.append(sleep)
                }
            }
            completion(sleepArray)
        }
    }

    func getMostRecentSample(
        for sampleType: HKSampleType,
        completion: @escaping ([HKSample], Error?) -> Swift.Void
    ) {

        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: daysFetchingLimit, to: Date())!,
            end: Date(),
            options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)

        let sampleQuery = HKSampleQuery(
            sampleType: sampleType,
            predicate: mostRecentPredicate,
            limit: 10000000,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in

            guard let samples = samples, samples.count > 0 else {
                completion([], error)
                return
            }
            DispatchQueue.main.async { completion(samples, nil) }
        }

        HKHealthStore().execute(sampleQuery)
    }
}


extension ExhHealthKitManager {
    func getMindfulness(completion: @escaping FetchMindfulnessCompletion) {

        guard let mindSampleType = HKSampleType.categoryType(forIdentifier: .mindfulSession) else {
            completion([])
            return
        }

        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: daysFetchingLimit, to: Date())!,
            end: Date(),
            options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)

        let sampleQuery = HKSampleQuery(
            sampleType: mindSampleType,
            predicate: mostRecentPredicate,
            limit: 10000000,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in

            guard let samples = samples, samples.count > 0 else {
                completion([])
                return
            }

            var dataArray = [ExhMindfulness]()

            samples.forEach {
                if let sample = $0 as? HKCategorySample {
                    let id: String = sample.uuid.uuidString
                    let startDate = buildISO8601String(from: sample.startDate)
                    let sourceName = sample.sourceRevision.source.name
                    let endDate = buildISO8601String(from: sample.endDate)
                    let sourceId = sample.sourceRevision.source.bundleIdentifier
                    let startDateUTC = buildUTCDateString(from: sample.startDate)
                    let endDateUTC = buildUTCDateString(from: sample.endDate)

                    let model = ExhMindfulness(
                        id: id,
                        startDate: startDate,
                        sourceName: sourceName,
//                        value: value,
                        endDate: endDate,
                        sourceId: sourceId,
                        startDateUTC: startDateUTC,
                        endDateUTC: endDateUTC
                    )

                    dataArray.append(model)
                }
            }

            completion(dataArray)
        }

        HKHealthStore().execute(sampleQuery)
    }
}
