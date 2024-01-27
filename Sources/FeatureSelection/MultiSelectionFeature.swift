import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import Models

public struct MultiSelectionFeature<Item: SelectableItemProtocol>: Reducer {
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss

    public struct State: Equatable {
        public var title: String
        public var allItems: IdentifiedArrayOf<Item> = []
        public var filteredItems: IdentifiedArrayOf<Item> = []
        public var selectedItems: IdentifiedArrayOf<Item>

        @BindingState public var itemsSearchText = ""

        public init(
            title: String = "",
            items: IdentifiedArrayOf<Item> = [],
            selectedItems: IdentifiedArrayOf<Item> = []
        ) {
            self.title = title
            self.allItems = items
            self.selectedItems = selectedItems
        }

        public func isItemSelected(_ item: Item) -> Bool {
            selectedItems.contains(where: { $0.id == item.id })
        }
        
        public var isAllItemsSelected: Bool {
            selectedItems == allItems
        }

        public var items: IdentifiedArrayOf<Item> {
            if itemsSearchText.isEmpty {
                return allItems
            } else {
                return filteredItems
            }
        }
    }

    public enum Action: Equatable, BindableAction {
        
        public enum Delegate: Equatable {
            case publish(IdentifiedArrayOf<Item>)
        }
        
        case dismiss
        case setSelectedItem(Item)
        case selectAllItems
        case deselectAllItems
        case doneButtonTapped
        case delegate(Delegate)
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .dismiss:
                return .run { _ in await dismiss() }

            case let .setSelectedItem(item):
                if state.selectedItems.contains(item) {
                    state.selectedItems.remove(item)
                } else {
                    state.selectedItems.append(item)
                }
                return .none
                
            case .selectAllItems:
                state.selectedItems = state.items
                return .none

            case .deselectAllItems:
                state.selectedItems.removeAll()
                return .none

            case .doneButtonTapped:
                return .merge(
                    .send(.delegate(.publish(state.selectedItems))),
                    .run { _ in await dismiss() }
                )

            case .binding(\.$itemsSearchText):
                guard !state.itemsSearchText.isEmpty else {
                    return .none
                }

                state.filteredItems = state.allItems.filter { $0.title.lowercased().contains(state.itemsSearchText.lowercased()) }
                return .none
                
            case .delegate:
                // catch-all
                return .none

            case .binding:
                // catch-all
                return .none
            }
        }
    }
}
