import SwiftUI

/// Sheet de prévisualisation d'un trajet.
/// Affiche les étapes dans l'ordre et propose les actions de démarrage ou de reprise en bas.
struct JourneyPreviewSheet: View {
    let journey: Journey
    /// Si `true`, un autre trajet est en cours — "Commencer" affichera une confirmation d'abandon.
    let requiresAbandon: Bool
    /// Appelé après confirmation quand l'utilisateur démarre ce trajet pour la première fois.
    let onStart: () -> Void
    /// Appelé quand l'utilisateur reprend un trajet déjà en cours.
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showAbandonAlert = false

    /// `true` si le trajet a déjà une progression (determiné via le contexte du picker).
    private var hasProgress: Bool { !requiresAbandon && onContinue != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    milestonesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .overlay(alignment: .bottom) {
                bottomActions
            }
            .alert("Abandonner le trajet en cours ?", isPresented: $showAbandonAlert) {
                Button("Abandonner", role: .destructive) {
                    dismiss()
                    onStart()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Ta progression actuelle sera perdue.")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Text(journey.emoji)
                    .font(.largeTitle)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text(journey.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }

            HStack(spacing: 20) {
                statBadge(icon: "arrow.left.and.right", value: String(format: "%.0f km", journey.totalKm))
                statBadge(icon: "mappin.circle", value: "\(journey.milestones.count) étapes")
                statBadge(icon: "tag", value: journey.category.rawValue)
            }
            .padding(.top, 4)
        }
    }

    private func statBadge(icon: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
        }
        .foregroundStyle(Color.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.08))
        .clipShape(Capsule())
    }

    // MARK: - Liste des étapes

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Étapes du trajet")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .kerning(0.8)
                .padding(.bottom, 14)

            ForEach(Array(journey.sortedMilestones.enumerated()), id: \.offset) { index, milestone in
                MilestonePreviewRow(
                    milestone: milestone,
                    index: index,
                    isLast: index == journey.sortedMilestones.count - 1
                )
            }
        }
    }

    // MARK: - Actions en bas

    private var bottomActions: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)

            VStack(spacing: 10) {
                // Bouton principal : Commencer (avec gestion abandon) ou Continuer
                Button {
                    if requiresAbandon {
                        showAbandonAlert = true
                    } else {
                        dismiss()
                        onStart()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.subheadline)
                        Text("Commencer le trajet")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Bouton secondaire : Continuer si trajet déjà en cours
                Button {
                    dismiss()
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.walk")
                            .font(.subheadline)
                        Text("Continuer le trajet")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.secondary.opacity(0.1))
                    .foregroundStyle(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - MilestonePreviewRow

/// Ligne de la timeline de prévisualisation.
private struct MilestonePreviewRow: View {
    let milestone: Milestone
    let index: Int
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.accentColor.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 28, height: 28)

                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.accentColor)
                }
                .padding(.top, 2)

                if !isLast {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 1.5)
                        .frame(minHeight: 44)
                }
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(milestone.label)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Spacer()

                    Text(String(format: "%.0f km", milestone.km))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }

                Text(milestone.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : 20)
        }
    }
}

// MARK: - Preview

#Preview("Nouveau trajet") {
    JourneyPreviewSheet(
        journey: allJourneys[0],
        requiresAbandon: false,
        onStart: {},
        onContinue: {}
    )
}

#Preview("Trajet en cours") {
    JourneyPreviewSheet(
        journey: allJourneys[0],
        requiresAbandon: false,
        onStart: {},
        onContinue: {}
    )
}

#Preview("Abandon requis") {
    JourneyPreviewSheet(
        journey: allJourneys[1],
        requiresAbandon: true,
        onStart: {},
        onContinue: {}
    )
}
