import SwiftUI

struct GenericListView<T: IdentifiableItem>: View {
    @ObservedObject var viewState: ViewState<T>
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.fixed(150)), GridItem(.fixed(150))], spacing: 16) {
                if viewState.isLoading {
                    ForEach(0..<6) { _ in
                        SkeletonView()
                            .frame(width: 150, height: 100)
                            .cornerRadius(10)
                    }
                } else {
                    ForEach(sortedItems) { item in
                        ChipView(label: item.label) {
                            print("\(item.label) tapped")
                        }
                        .frame(width: 150, height: 100)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            // Simulate loading delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                viewState.isLoading = false
            }
        }
    }
    
    var sortedItems: [T] {
        viewState.items.sorted { $0.value < $1.value }
    }
}

struct ChipView: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Text(label)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .onTapGesture {
                action()
            }
    }
}

struct SkeletonView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .shimmering()
    }
}

extension View {
    func shimmering() -> some View {
        self
            .modifier(ShimmeringEffect())
    }
}

struct ShimmeringEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.4), Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .rotationEffect(.degrees(70))
                    .offset(x: phase, y: 0)
                    .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1000
                }
            }
    }
}

struct GenericListView_Previews: PreviewProvider {
    static var previews: some View {
        GenericListView(viewState: ViewState<Area>())
    }
}
