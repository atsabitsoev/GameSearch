//
//  AppMetricaReporter.swift
//  GameSearch
//

import AppMetricaCore
import Foundation

public enum AppMetricaReporter {
    private static let launchCountKey = "appmetrica.launch_count"

    public static func activate() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "AppMetricaAPIKey") as? String,
              !apiKey.isEmpty
        else { return }

        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return }
        AppMetrica.activate(with: configuration)
        reportLaunchNumber()
    }

    private static func reportLaunchNumber() {
        let defaults = UserDefaults.standard
        let previous = defaults.integer(forKey: launchCountKey)
        let next = previous + 1
        defaults.set(next, forKey: launchCountKey)

        reportEvent("app_launch", parameters: [
            "launch_number": next,
            "is_first_launch": next == 1,
            "is_returning_user": next > 1
        ])
    }

    public static func reportEvent(_ name: String, parameters: [String: Any]? = nil) {
        guard AppMetrica.isActivated else { return }
        AppMetrica.reportEvent(name: name, parameters: parameters, onFailure: nil)
    }
}
