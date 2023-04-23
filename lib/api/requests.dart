import 'package:escripvain/constants.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:escripvain/models/conversation.dart';
import 'package:escripvain/models/message.dart';
import 'dart:convert';
import 'dart:io';

import 'package:escripvain/models/user.dart';

String? getFileExtension(String fileName) {
  try {
    return ".${fileName.split('.').last}";
  } catch (e) {
    return null;
  }
}

Future<Stream<String>> sendAudio(
    String path, String conversation, String uuid) async {
  var audiofile = File(path);
  var bytes = audiofile.openRead();
  var length = await audiofile.length();

  var request = MultipartRequest("POST", Uri.parse('$apiUrl/message/add'));

  var multipartFile = MultipartFile('audio', bytes, length,
      filename: 'audio${getFileExtension(path)}');

  request.files.add(multipartFile);
  request.headers["Content-Type"] = 'multipart/form-data';

  request.fields['uuid'] = uuid;
  request.fields['conversation'] = conversation;

  var streamedResponse = await request.send();
  return streamedResponse.stream.toStringStream();
}

Future fetchUser(String uuid) async {
  var request = MultipartRequest('POST', Uri.parse('$apiUrl/user/get'));
  request.headers["Content-Type"] = 'multipart/form-data';
  request.fields['uuid'] = uuid;

  StreamedResponse streamedResponse = await request.send();

  var response = await Response.fromStream(streamedResponse);

  Map<String, dynamic> result = jsonDecode(response.body);

  if (result.containsKey('error')) {
    return null;
  } else {
    return User.fromApi(result);
  }
}

Future<User?> createUser(String uuid, String username) async {
  var request = MultipartRequest('POST', Uri.parse('$apiUrl/user/create'));
  request.headers["Content-Type"] = 'multipart/form-data';
  request.fields['uuid'] = uuid;
  request.fields['username'] = username;

  var streamedResponse = await request.send();

  var response = await Response.fromStream(streamedResponse);

  Map<String, dynamic> result = jsonDecode(response.body);
  print(result);
  if (result.containsKey('error')) {
    return null;
  } else {
    var prefs = await SharedPreferences.getInstance();
    User user = User.fromApi(result);
    prefs.setString('user', jsonEncode(user.toJson()));
    return user;
  }
}

Future<Conversations?> getConversations(String uuid) async {
  var request = MultipartRequest('POST', Uri.parse('$apiUrl/conversation/get'));
  request.headers["Content-Type"] = 'multipart/form-data';
  request.fields['uuid'] = uuid;

  var streamedResponse = await request.send();

  var response = await Response.fromStream(streamedResponse);

  Map<String, dynamic> result = jsonDecode(response.body);
  print(result);
  if (result.containsKey('error')) {
    return null;
  } else {
    var convs = Conversations.fromJson(result);
    print(convs);
    return convs;
  }
}

Future<Conversation?> addConversation(
  String uuid,
) async {
  var request =
      MultipartRequest('POST', Uri.parse('$apiUrl/conversation/create'));
  request.headers["Content-Type"] = 'multipart/form-data';

  request.fields['uuid'] = uuid;

  var streamedResponse = await request.send();

  var response = await Response.fromStream(streamedResponse);

  Map<String, dynamic> result = jsonDecode(response.body);

  if (result.containsKey('error')) {
    return null;
  } else {
    return Conversation(result['name'], result['id'].toString());
  }
}

Future<bool> deleteConversation(
  String uuid,
  String id,
) async {
  var request =
      MultipartRequest('POST', Uri.parse('$apiUrl/conversation/delete'));
  request.headers["Content-Type"] = 'multipart/form-data';

  request.fields['uuid'] = uuid;
  request.fields['id'] = id;

  var streamedResponse = await request.send();

  var response = await Response.fromStream(streamedResponse);

  Map<String, dynamic> result = jsonDecode(response.body);
  print(result);

  return result.containsKey('error') ? false : true;
}

Future<Messages?> getMessages(String uuid, String id) async {
  var request = MultipartRequest('POST', Uri.parse('$apiUrl/message/get'));
  request.headers["Content-Type"] = 'multipart/form-data';
  request.fields['uuid'] = uuid;
  request.fields['conversation'] = id;

  var streamedResponse = await request.send();

  var response = await Response.fromStream(streamedResponse);

  Map<String, dynamic> result = jsonDecode(response.body);

  print(result);
  if (result.containsKey('error')) {
    return null;
  } else {
    var messages = Messages.fromJson(result);
    print(messages);
    return messages;
  }
}
