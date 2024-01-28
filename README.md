# tca-feature-selection
A Single Item Selection and Multi Items Selection Feature written using The Composable Architecture

## Examples:

### Single Selection

```swift
import SwiftUI
import ComposableArchitecture
import FeatureSelection

struct MySingleSelectionScreen<Item: SelectableItemProtocol>: View {
    store: StoreOf<SingleSelectionFeature<Item>>
    
    init(store: StoreOf<SingleSelectionFeature<Item>>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 8) {
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
            .padding(8)
        }
    }
}
```

### Multi Selection

```swift
import SwiftUI
import ComposableArchitecture
import FeatureSelection

struct MyMultiSelectionScreen<Item: SelectableItemProtocol>: View {
    store: StoreOf<MultiSelectionFeature<Item>>
    
    init(store: StoreOf<MultiSelectionFeature<Item>>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 8) {
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
            .padding(8)
        }
    }
}
```

### Feature Integration

```swift
import SwiftUI
import ComposableArchitecture
import FeatureSelection

struct MySelectableItem: SeletableItemProtocol {
    let id: String
    let title: String
    
    static let mock: [Self] {
        [
            .init(id: UUID().uuidString, title: "Item 1",
            .init(id: UUID().uuidString, title: "Item 2",
            .init(id: UUID().uuidString, title: "Item 3"
        ]
    }
}

@Reducer
struct MySelectionFeature {

    @Reducer
    struct Destination {
        enum State {
            singleSelection(SingleSelectionFeature<MySelectableItem>.State)
            multiSelection(MultiSelectionFeature<MySelectableItem>.State)
        }
        
        enum Action {
            singleSelection(SingleSelectionFeature<MySelectableItem>.Action)
            multiSelection(MultiSelectionFeature<MySelectableItem>.Action)
        }
        
        var body: ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .singleSelection:
                    // catch-all
                    return .none
                    
                case .multiSelection:
                    // catch-all
                    return .none
                }
            }
            
            Scope(state: \.singleSelection, action: \.singleSelection) {
                SingleSelectionFeature()
            }
            
            Scope(state: \.multiSelection, action: \.multiSelection) {
                MultiSelectionFeature()
            }
        }   
    }

    struct State {
        var seletableItems = MySelectableItem.mock 
        var selectedItems: [MySelectableItem] = []
        var selectedItem: MySelectableitem?
        @PresentationState var destination: Destination.State?
    }

    enum Action {
        case onSelectItemButtonTapped
        case onSelectItemsButtonTapped
        case destination(Destination.Action)
    }
    
    var body: ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onSelectItemButtonTapped:
                state.destination = .singleSelect(
                    .init(
                        title: "Select Item",
                        items: state.selectableItems,
                        selectedItem: state.selectedItem
                    )
                )
                return .none
                
            case .onSelectItemsButtonTapped:
                state.destination = .multiSelect(
                    .init(
                        title: "Select Items",
                        items: state.selectableItems,
                        selectedItems: state.selectedItems
                    )
                )
                return .none
                
            case let .destination(.presented(.singleSelect(.delegate(.publish(selectedItem))))):
                state.selectedItem = selectedItem
                return .none
                
            case let .destination(.presented(.multiSelect(.delegate(.publish(selectedItems))))):
                state.selectedItems = selectedItems
                return .none
                
            case .destination:
                // catch-all
                return .none
            }
        }
    }
}

struct MySelectionScreen: View {
    let store: StoreOf<MySelectionFeature>
    
    init(store: StoreOf<MySelectionFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Text(viewStore.selectedItem.title)
                Button {
                    viewStore.send(.onSelectItemButtonTapped)
                } label: {
                    Text("Tapp to select an item")
                }
                
                ForEach(viewStore.selectecItems) { item in
                    Text(item.title)
                }
                Button {
                    viewStore.send(.onSelectItemsButtonTapped)
                } label: {
                    Text("Tapp to select items")
                }
            }
            .fullScreenCover(
                store: store.scope(
                    state: \.$destination,
                    action { .destination($0) }
                ),
                state: /MySelectionFeature.Destination.State.singleSelection,
                action: MySelectionFeature.Destination.Action.singleSelection,
            ) {
                MySingleSelectionScreen(store: $0)
            }
            .fullScreenCover(
                store: store.scope(
                    state: \.$destination,
                    action { .destination($0) }
                ),
                state: /MySelectionFeature.Destination.State.multiSelection,
                action: MySelectionFeature.Destination.Action.multiSelection,
            ) {
                MyMultiSelectionScreen(store: $0)
            }
        }
    }
}
```
