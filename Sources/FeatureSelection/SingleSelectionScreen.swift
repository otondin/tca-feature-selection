import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import Models
import ComponentLibrary
import Localization

public struct SingleSelectionScreen<Item: SelectableItemProtocol>: View {
    let store: StoreOf<SingleSelectionFeature<Item>>

    public init(store: StoreOf<SingleSelectionFeature<Item>>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        if viewStore.items.isEmpty {
                            Spacer()
                            ProgressView()
                            Spacer()
                        } else {
                            list
                        }
                    }
                    .padding(Spacing.padding2)
                }
                .fullBleedBackground(Color.Semantic.primaryBackground)
                .navigationTitle(viewStore.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        CircleButton(
                            description: L10n.General.dismiss,
                            style: .secondary,
                            icon: {
                                Image(systemName: "chevron.down")
                            },
                            action: {
                                viewStore.send(.dismiss)
                            }
                        )
                    }
                }
            }
            .searchable(text: viewStore.$itemsSearchText)
        }
    }

    private var list: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: Spacing.padding2) {
                ForEach(viewStore.items) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        if viewStore.state.isItemSelected(item) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.setSelectedItem(item))
                    }
                    Divider()
                }
            }
        }
    }
}

struct SingleSelectionScreen_Preview: PreviewProvider {
    static var previews: some View {
        SingleSelectionScreen<SelfInspection>(
            store: Store(
                initialState: SingleSelectionFeature<SelfInspection>.State(
                    items: .init(uniqueElements: [])
                ),
                reducer: {
                    SingleSelectionFeature()
                }
            )
        )
    }
}
