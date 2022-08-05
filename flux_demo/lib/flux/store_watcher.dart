// Copyright 2022 Fredrick Allan Grott. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// Originally under Apache 2, 2015 by Workivaas somethin that
// Google was experimenting with. See original repo at:
// https://github.com/google/flutter_flux

// ignore_for_file: test_types_in_equals

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flux_demo/flux/store.dart';

/// Signature for a function the lets the caller listen to a store.
typedef ListenToStore = Store Function(StoreToken token,
    [ValueChanged<Store> onStoreChanged,]);

/// A widget that rebuilds when the [Store]s it is listening to change.
abstract class StoreWatcher extends StatefulWidget {
  /// Creates a widget that watches stores.
  const StoreWatcher({super.key});

  /// Override this function to build widgets that depend on the current value
  /// of the store.
  @protected
  Widget build(BuildContext context, Map<StoreToken, Store> stores,);

  /// Override this function to configure which stores to listen to.
  ///
  /// This function is called by [StoreWatcherState] during its
  /// [State.initState] lifecycle callback, which means it is called once per
  /// inflation of the widget. As a result, the set of stores you listen to
  /// should not depend on any constructor parameters for this object because
  /// if the parent rebuilds and supplies new constructor arguments, this
  /// function will not be called again.
  @protected
  void initStores(ListenToStore listenToStore);

  @override
  StoreWatcherState createState() => StoreWatcherState();
}

/// State for a [StoreWatcher] widget.
class StoreWatcherState extends State<StoreWatcher>
    with StoreWatcherMixin<StoreWatcher> {
  final Map<StoreToken, Store> _storeTokens = <StoreToken, Store>{};

  @override
  void initState() {
    widget.initStores(listenToStore);
    super.initState();
  }

  /// Start receiving notifications from the given store, optionally routed
  /// to the given function.
  ///
  /// The default action is to call setState(). In general, you want to use the
  /// default function, which rebuilds everything, and let the framework figure
  /// out the delta of what changed.
  @override
  Store listenToStore(StoreToken token, [ValueChanged<Store>? onStoreChanged,]) {
    final Store store = super.listenToStore(token, onStoreChanged!);
    _storeTokens[token] = store;
    return store;
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, _storeTokens,);
  }
}

/// Listens to changes in a number of different stores.
///
/// Used by [StoreWatcher] to track which stores the widget is listening to.
mixin StoreWatcherMixin<T extends StatefulWidget> on State<T> {
  final Map<Store, StreamSubscription<Store>> _streamSubscriptions =
      <Store, StreamSubscription<Store>>{};

  /// Start receiving notifications from the given store, optionally routed
  /// to the given function.
  ///
  /// By default, [onStoreChanged] will be called when the store changes.
  @protected
  Store listenToStore(StoreToken token, [ValueChanged<Store>? onStoreChanged,]) {
    final Store store = token._value;
    _streamSubscriptions[store] =
        store.listen(onStoreChanged ?? _handleStoreChanged);

    return store;
  }

  /// Stop receiving notifications from the given store.
  @protected
  void unlistenFromStore(Store store) {
    _streamSubscriptions[store]?.cancel();
    _streamSubscriptions.remove(store);
  }

  /// Cancel all store subscriptions.
  @override
  void dispose() {
    final Iterable<StreamSubscription<Store>> subscriptions =
        _streamSubscriptions.values;
    for (final StreamSubscription<Store> subscription in subscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    super.dispose();
  }

  void _handleStoreChanged(Store store) {
    // TODO(abarth): We cancel our subscriptions in [dispose], which means we
    // shouldn't receive this callback when we're not mounted. If that's the
    // case, we should change this check into an assert that we are mounted.
    if (!mounted) return;
    setState(() {});
  }
}

/// Represent a store so it can be returned by [StoreListener.listenToStore].
///
/// Used to make sure that callers never reference the store without calling
/// listen() first. In the example below, _itemStore would not be globally
/// available:
///
/// ```dart
/// final _itemStore = new AppStore(actions);
/// final itemStoreToken = new StoreToken(_itemStore);
/// ```
class StoreToken {
  /// Creates a store token for the given store.
  StoreToken(this._value);

  final Store _value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final StoreToken typedOther = other as StoreToken;

    return identical(_value, typedOther._value,);
  }

  @override
  int get hashCode => identityHashCode(_value);

  @override
  String toString() => '[${_value.runtimeType}(${_value.hashCode})]';
}
