
import SwiftUI
import ComposableArchitecture
import IdentifiedCollections
import Models

public struct SingleSelectionFeature<Item: SelectableItemProtocol>: Reducer {
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss

    public struct State: Equatable {
        public var title: String
        public var allItems: IdentifiedArrayOf<Item> = []
        public var filteredItems: IdentifiedArrayOf<Item> = []
        public var selectedItem: (Item)?

        @BindingState public var itemsSearchText = ""

        public init(
            title: String = "",
            items: IdentifiedArrayOf<Item> = [],
            selectedItem: Item? = nil
        ) {
            self.title = title
            self.allItems = items
            self.selectedItem = selectedItem
        }

        public func isItemSelected(_ item: Item) -> Bool {
            guard let selectedItem else { return false }

            return selectedItem.id == item.id
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
            case publish(Item?)
        }
        
        case dismiss
        case setSelectedItem(Item?)
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
                if state.selectedItem == item {
                    state.selectedItem = nil
                } else {
                    state.selectedItem = item
                }
                return .merge(
                    .send(.delegate(.publish(state.selectedItem))),
                    .send(.dismiss)
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
