import SwiftUI

struct StepRingView: View {
    @StateObject private var viewModel = StepCountViewModel()

    private let ringDiameter: CGFloat = 240
    private let strokeWidth: CGFloat = 20
    private let goal = 10_000

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: strokeWidth)
                        .frame(width: ringDiameter, height: ringDiameter)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.teal, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                        )
                        .frame(width: ringDiameter, height: ringDiameter)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.6), value: viewModel.progress)

                    // Center content
                    VStack(spacing: 4) {
                        Text(viewModel.stepCount.formatted())
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.6), value: viewModel.stepCount)

                        Text("pas")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }
                }

                Text("Objectif : \(goal.formatted()) pas")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
        }
        .onAppear {
            viewModel.requestAuthorizationAndFetch()
        }
    }
}

#Preview {
    let vm = StepCountViewModel()
    let view = StepRingView()
    // Inject mock step count via a wrapper for preview
    return StepRingPreview(stepCount: 6432)
}

private struct StepRingPreview: View {
    let stepCount: Int

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                let progress = min(Double(stepCount) / 10_000.0, 1.0)
                let ringDiameter: CGFloat = 240
                let strokeWidth: CGFloat = 20
                let goal = 10_000

                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: strokeWidth)
                        .frame(width: ringDiameter, height: ringDiameter)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.teal, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                        )
                        .frame(width: ringDiameter, height: ringDiameter)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        Text(stepCount.formatted())
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)

                        Text("pas")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }
                }

                Text("Objectif : \(goal.formatted()) pas")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
