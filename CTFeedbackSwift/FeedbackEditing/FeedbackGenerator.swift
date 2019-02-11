//
// Created by 和泉田 領一 on 2017/09/25.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

struct FeedbackGenerator {
    
    static func generate(configuration: FeedbackConfiguration, repository: FeedbackEditingItemsRepositoryProtocol) throws -> Feedback {
        var platform: String {
            var mib: [Int32] = [CTL_HW, HW_MACHINE]
            var len: Int     = 2
            sysctl(&mib, 2, .none, &len, .none, 0)
            var machine = [CChar](repeating: 0, count: Int(len))
            sysctl(&mib, 2, &machine, &len, .none, 0)
            let result = String(cString: machine)
            return result
        }
        
        var deviceName: String {
            guard let path = Bundle.platformNamesPlistPath,
                let dictionary = NSDictionary(contentsOfFile: path) as? [String : String]
                else { return "" }
            
            let rawPlatform = platform
            return dictionary[rawPlatform] ?? rawPlatform
        }
        
        let systemVersion : String = UIDevice.current.systemVersion
        var appName : String {
            if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
                return displayName
            }
            if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                return bundleName
            }
            return ""
        }
        
        var appVersion : String  {
            guard let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                else { return "" }
            return shortVersion
        }
        var appBuild : String {
            guard let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
                else { return "" }
            return build
        }
        let email      = repository.item(of: UserEmailItem.self)?.email
        let topic      = repository.item(of: TopicItem.self)?.selected
        let attachment = repository.item(of: AttachmentItem.self)?.media
        let body       = repository.item(of: BodyItem.self)?.bodyText ?? ""

        let subject = configuration.subject ?? generateSubject(appName: appName, topic: topic)

        let format        = configuration.usesHTML ? generateHTML : generateString
        let formattedBody = format(body,
                                   deviceName,
                                   systemVersion,
                                   appName,
                                   appVersion,
                                   appBuild,
                                   configuration.additionalDiagnosticContent)

        return Feedback(email: email,
                        to: configuration.toRecipients,
                        cc: configuration.ccRecipients,
                        bcc: configuration.bccRecipients,
                        subject: subject,
                        body: formattedBody,
                        isHTML: configuration.usesHTML,
                        jpeg: attachment?.jpegData,
                        mp4: attachment?.videoData)
    }

    private static func generateSubject(appName: String, topic: TopicProtocol?) -> String {
        return String(format: "%@: %@", appName, topic?.title ?? "")
    }

    private static func generateHTML(body: String,
                                     deviceName: String,
                                     systemVersion: String,
                                     appName: String,
                                     appVersion: String,
                                     appBuild: String,
                                     additionalDiagnosticContent: String?) -> String {
        let format          = """
        <style>td {padding-right: 20px}</style>
 <p>%@</p><br />
 <table cellspacing=0 cellpadding=0>
 <tr><td>Device:</td><td><b>%@</b></td></tr>
 <tr><td>iOS:</td><td><b>%@</b></td></tr>
 <tr><td>App:</td><td><b>%@</b></td></tr>
 <tr><td>Version:</td><td><b>%@</b></td></tr>
 <tr><td>Build:</td><td><b>%@</b></td></tr>
 </table>
 """
        var content: String = String(format: format,
                                     body.replacingOccurrences(of: "\n", with: "<br />"),
                                     deviceName,
                                     systemVersion,
                                     appName,
                                     appVersion,
                                     appBuild)
        if let additional = additionalDiagnosticContent { content.append(additional) }
        return content
    }

    private static func generateString(body: String,
                                       deviceName: String,
                                       systemVersion: String,
                                       appName: String,
                                       appVersion: String,
                                       appBuild: String,
                                       additionalDiagnosticContent: String?) -> String {
        var content: String
            = String(format: "%@\n\n\nDevice: %@\niOS: %@\nApp: %@\nVersion: %@\nBuild: %@",
                     body,
                     deviceName,
                     systemVersion,
                     appName,
                     appVersion,
                     appBuild)
        if let additional = additionalDiagnosticContent { content.append(additional) }
        return content
    }

}
