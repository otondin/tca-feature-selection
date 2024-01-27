import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import Models
import ComponentLibrary
import Localization

public struct MultiSelectionScreen<Item: SelectableItemProtocol>: View {
    let store: StoreOf<MultiSelectionFeature<Item>>

    public init(store: StoreOf<MultiSelectionFeature<Item>>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                GeometryReader { proxy in
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
                        ToolbarItem(placement: .topBarTrailing) {
                            TextButton(
                                title: L10n.General.done,
                                action: {
                                    viewStore.send(.doneButtonTapped)
                                }
                            )
                            .disabled(viewStore.selectedItems.count == 0 ? true : false)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        ZStack {
                            Rectangle()
                                .fill(Color.Semantic.tertiaryBackground)
                            
                            PrimaryButton(
                                title: viewStore.isAllItemsSelected ? L10n.General.deselectAll : L10n.General.selectAll,
                                action: {
                                    viewStore.send(viewStore.isAllItemsSelected ? .deselectAllItems : .selectAllItems)
                                }
                            )
                        }
                        .ignoresSafeArea()
                        .frame(width: proxy.size.width, height: 68)
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

struct MultiSelectionScreen_Preview: PreviewProvider {
    static var previews: some View {
        MultiSelectionScreen<User>(
            store: Store(
                initialState: MultiSelectionFeature<User>.State(
                    items: .init(uniqueElements: User.mock ?? [])
                ),
                reducer: {
                    MultiSelectionFeature()
                }
            )
        )
    }
}
