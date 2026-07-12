import SwiftUI
import SwiftData

struct MoodCalendarView: View {
    @Query private var moods: [MoodEntry]
    @State private var selectedMonth = Date()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button { prevMonth() } label: { Image(systemName: "chevron.left").font(.title3).foregroundStyle(Theme.accent) }
                Spacer()
                Text(monthFormatter.string(from: selectedMonth)).font(.headline.weight(.semibold)).foregroundStyle(Theme.text)
                Spacer()
                Button { nextMonth() } label: { Image(systemName: "chevron.right").font(.title3).foregroundStyle(Theme.accent) }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(dayLabels, id: \.self) { d in
                    Text(d).font(.caption2).foregroundStyle(Theme.muted)
                }
                let days = daysInMonth(); let start = startDayOfWeek()
                ForEach(0..<start, id: \.self) { _ in Color.clear.frame(height: 36) }
                ForEach(1...days, id: \.self) { day in
                    let date = dateFor(day: day)
                    let emoji = moods.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.emoji
                    Text(emoji ?? "\(day)")
                        .font(.system(size: 16))
                        .frame(height: 36).frame(maxWidth: .infinity)
                        .background(emoji != nil ? Theme.accent.opacity(0.1) : nil)
                        .clipShape(.circle)
                        .foregroundStyle(Calendar.current.isDateInToday(date) ? Theme.accent : Theme.text)
                }
            }
        }
        .glass()
        .navigationTitle("Calendario umore")
    }

    private func prevMonth() { selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth }
    private func nextMonth() { selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth }
    private func daysInMonth() -> Int { Calendar.current.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30 }
    private func startDayOfWeek() -> Int { (Calendar.current.component(.weekday, from: firstOfMonth()) + 5) % 7 }
    private func firstOfMonth() -> Date { Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedMonth)) ?? selectedMonth }
    private func dateFor(day: Int) -> Date { Calendar.current.date(byAdding: .day, value: day - 1, to: firstOfMonth()) ?? Date() }
    private let dayLabels = ["L", "M", "M", "G", "V", "S", "D"]
    private let monthFormatter: DateFormatter = { let f = DateFormatter(); f.locale = Locale(identifier: "it"); f.dateFormat = "MMMM yyyy"; return f }()
}
