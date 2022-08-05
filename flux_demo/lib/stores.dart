// Copyright 2022 Fredrick Allan Grott. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// Originally under Apache 2, 2015 by Workivaas somethin that
// Google was experimenting with. See original repo at:
// https://github.com/google/flutter_flux


import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flux_demo/flux/flux_action.dart';
import 'package:flux_demo/flux/store.dart';
import 'package:flux_demo/flux/store_watcher.dart';

class ChatUser {
  ChatUser({this.name, this.color,});
  final String? name;
  final Color? color;
}

class ChatMessage {
  ChatMessage({this.sender, this.text,});
  final ChatUser? sender;
  final String? text;
}

class ChatMessageStore extends Store {
  ChatMessageStore() {
    triggerOnAction(setCurrentMessageAction, (String value) {
      _currentMessage = value;
    },);
    triggerOnAction(commitCurrentMessageAction, (ChatUser me) {
      final ChatMessage message =
          ChatMessage(sender: me, text: _currentMessage,);
      _messages.add(message);
      _currentMessage = '';
    },);
  }

  final List<ChatMessage> _messages = <ChatMessage>[];
  String _currentMessage = '';

  List<ChatMessage> get messages =>
      new List<ChatMessage>.unmodifiable(_messages);
  String get currentMessage => _currentMessage;

  bool get isComposing => _currentMessage.isNotEmpty;
}

class ChatUserStore extends Store {
  ChatUserStore() {
    final String name = "Guest${Random().nextInt(1000)}";
    final Color? color =
        Colors.accents[Random().nextInt(Colors.accents.length)][700];
    _me = ChatUser(name: name, color: color,);
    // This store does not currently handle any actions.
  }

  late ChatUser _me;
  ChatUser get me => _me;
}

final StoreToken messageStoreToken = StoreToken(ChatMessageStore());
final StoreToken userStoreToken = StoreToken(ChatUserStore());

final FluxAction<String> setCurrentMessageAction = FluxAction<String>();
final FluxAction<ChatUser> commitCurrentMessageAction = FluxAction<ChatUser>();
