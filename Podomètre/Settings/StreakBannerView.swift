import SwiftUI

/// Bannière affichant la série de jours consécutifs où l'objectif a été atteint.
struct StreakBannerView: View {
    let streak: Int
    @ObservedObject var viewModel: StepCountViewModel

    var body: some View {
        HStack(spacing: 12) {
            Text("🔥")
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(viewModel.ringColor)
                    Text(streak == 1 ? "jour" : "jours")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("de suite")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let viewModel = StepCountViewModel()
    return List {
        Section {
            StreakBannerView(streak: 7, viewModel: viewModel)
        }
    }
}
