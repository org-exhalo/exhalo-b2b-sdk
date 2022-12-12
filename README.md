# ExhaloSDKPackage

Exhalo SDK lets you easily collect and monitor the health metrics of your app's audience. Currently, we support Apple Health Kit and Oura(limited). Please, look through the installation and usage guide below.

## Installation guide

First, add this repository to your app by [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) as a dependency.


Dependency rule: Exact Version

Version: `0.0.4-alpha`

<img width="1194" alt="Screenshot 2022-11-09 at 11 21 08" src="https://user-images.githubusercontent.com/23015635/200804989-5a07b219-b501-4772-8313-6abb9284264d.png">


## Import

Second, import the package.

```swift
import ExhaloSDKPackage
```

## Access

```swift
ExhDataManager.shared.{method}
```

## Usage guide

Well, the first part is completed. Hooray! Now let's start to use Exhalo SDK.

1. The first step is SDK initialization. First, call the 'initialize' method with the proper environment flag, depending on your purpose. The standard process is to start with acc environment to check that all things are settled down properly. Then contact the Exhalo development team to get prod credentials.

    ```swift
    ExhDataManager.shared.initialize(projectId: "your-project-id", environment: ExhDataEnvironment)

    public enum ExhDataEnvironment {
        case acc
        case prod
    }
    ```

2. When SDK is initialized, please request all listed permissions on the application's side. You can pick the best place up to your user flow. When the user grants permissions, let SDK know that data is ready for collection - you should do it only once by the next line of code:

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



