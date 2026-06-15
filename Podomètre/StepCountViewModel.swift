import Foundation
import HealthKit
import SwiftUI
import Combine

@MainActor
class StepCountViewModel: ObservableObject {
    @Published var stepCount: Int = 2500
    @Published var isAuthorized: Bool = false

    var progress: Double {
        min(Double(stepCount) / 10_000.0, 1.0)
    }

    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?

    func requestAuthorizationAndFetch() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        healthStore.requestAuthorization(toShare: [], read: [stepType]) { [weak self] success, _ in
            guard success else { return }
            Task { @MainActor in
                self?.isAuthorized = true
                self?.fetchTodaySteps()
                self?.startObserving()
            }
        }
    }

    func fetchTodaySteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.6)) {
                    self?.stepCount = Int(steps)
                }
            }
        }

        healthStore.execute(query)
    }

    private func startObserving() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, _ in
            Task { @MainActor in
                self?.fetchTodaySteps()
            }
        }

        if let query = observerQuery {
            healthStore.execute(query)
        }
    }

    deinit {
        if let query = observerQuery {
            healthStore.stop(query)
        }
    }
}
