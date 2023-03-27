//
//  PTCheckTestFlight.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 27/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import PooTools
import AppStoreConnect_Swift_SDK

class PTCheckTestFlight: NSObject {

    static let share = PTCheckTestFlight()
    
    func checkFunction(testFilghtBlock:@escaping ((_ canUpdate:Bool)->Void)) {
        let apiKeyId = "DKGQD3CMW2"
        let apiIssuerId = "bf26b524-2ecb-4350-88a9-f1e73f6a8d83"
        let privateKey = "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgNUw0GqOFa10kLOsYuTIckUmRKV8RpUryUw8fsHNy6WCgCgYIKoZIzj0DAQehRANCAASTx4tjX+/MGAOtQ7l/olVGVCg22iU42HC3vWjgMMUdhig2DbjIfHk4pn/y10cEUGvT3ilJSAlbnwQOFGHvgghJ"

        let configuration = APIConfiguration(issuerID: apiIssuerId, privateKeyID: apiKeyId, privateKey: privateKey)
        let request = APIEndpoint
            .v1
            .apps
            .id(AppAppStoreID)
            .get(parameters: .init(
                include:[.builds,.betaAppLocalizations,.betaLicenseAgreement,.betaGroups,.appInfos,.betaAppReviewDetail],
                fieldsBetaGroups: [.builds,.app,.publicLink],
                fieldsBuilds: [.version,.appStoreVersion,.lsMinimumSystemVersion,.buildBetaDetail,.betaBuildLocalizations],
                fieldsBetaAppLocalizations: [.description]
            ))

        let provider: APIProvider = APIProvider(configuration: configuration)

        Task.init {
            do {
                let apps = try await provider.request(request)
//                PTNSLogConsole("attributes:>>>>>\(String(describing: apps.data.attributes))")
                                
                for (index,value) in apps.included!.enumerated() {
//                    PTNSLogConsole("included:>>>>>\(value)")
                    switch value {
                    case .betaAppReviewDetail( _):break
//                        PTNSLogConsole("betaAppReviewDetail:>>>>\(String(describing: x.attributes.debugDescription))")
                    case .betaAppLocalization( _):break
//                        PTNSLogConsole("betaAppLocalization:>>>>\(String(describing: x.attributes?.description))")
                    case .betaGroup( _):break
//                        PTNSLogConsole("betaGroup:>>>>\(String(describing: x.attributes?.publicLink))")
                    case .build(let x):
//                        PTNSLogConsole("build:>>>>\(String(describing: x.attributes!.version))")
                        if x.attributes!.version!.int! > kAppBuildVersion!.int! {
                            testFilghtBlock(true)
                            break
                        }
                    default:
                        break
                    }
                    if index == (apps.included!.count - 1) {
                        testFilghtBlock(false)
                    }
                }
            } catch {
                PTNSLogConsole("Something went wrong fetching the apps: \(error.localizedDescription)")
                testFilghtBlock(false)
            }
        }
    }
}
