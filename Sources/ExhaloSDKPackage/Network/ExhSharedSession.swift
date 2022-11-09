import Foundation

final class ExhSharedSession {
    static let session = URLSession(configuration: .default)
    private init() {}
    static var domainURL : String {
        let env = Getter.string(.sdkEnv);
        
        if env == "prod" {
            return ExhConstants.domainProd
        } else
        if env == "acc" {
            return ExhConstants.domainAc
        } else {
            return ExhConstants.domainDev
        }
    }
}
