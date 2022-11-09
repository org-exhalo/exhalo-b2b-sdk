# ExhaloSDKPackage

A description of this package.

## Installation guide

Add this repository as a dependency to your app by [Swift PAckage Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

## Import
```swift
import ExhaloSDKPackage
```

## Access

```swift
ExhDataManager.shared.{method}
```

## Usage guide
1. At first you need to initialize SDK by `initialize` method

    ```swift
    ExhDataManager.shared.initialize(projectId: "your-project-id")
    ```

2. In your project, you control the health data permission process (you can request from the user whenever you want, see point 3). After you ask the user for the necessary permissions, you need to show our SDK that we can receive data from HealthKit. You can do it by `setHealthKitPermission` method with `isAccessGranted` argument.

    ```swift
    ExhDataManager.shared.setHealthKitPermission(isAccessGranted: true)
    ```

3. Required permissions from HealthKit:
    - Sleep         `HKObjectType.categoryType(forIdentifier: .sleepAnalysis)`
    - HR            `HKObjectType.quantityType(forIdentifier: .heartRate)`
    - HRV           `HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)`
    - Activities    `HKObjectType.workoutType()`
    - Mindfullness  `HKObjectType.categoryType(forIdentifier: .mindfulSession)`
    - Weight
    - Height
    - Sex
    - Age

## Additional explainer

So you need to initialize SDK every session and call `setHealthKitPermission` once after HealthKit permission are asked. Handling of background -> active is not needed cause every init SDK fetches data for last 16 days


