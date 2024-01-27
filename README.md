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
