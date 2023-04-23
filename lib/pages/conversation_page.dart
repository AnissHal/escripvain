import 'dart:convert';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:escripvain/api/requests.dart';
import 'package:escripvain/constants.dart';
import 'package:escripvain/models/conversation.dart';
import 'package:escripvain/models/message.dart';

var boxShadow = [
  BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 5,
    blurRadius: 7,
    offset: const Offset(0, 3), // changes position of shadow
  ),
];

class ConversationPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationPage({super.key, required this.conversation});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final RecorderController _recorderController = RecorderController();
  final ScrollController _scrollController = ScrollController();

  final key = GlobalKey<ScaffoldMessengerState>();

  bool _isRecording = false;
  bool _loading = true;

  late List<Message> _messages;

  // Props Etat des messages
  Map<String, bool> isSent = {};
  Map<String, bool> isDelivred = {};
  Map<String, bool> isFailed = {};
  Map<String, bool> isMsgLoading = {};

  // Props pour les audios
  Map<String, bool> isPlaying = {};
  Map<String, bool> isLoading = {};
  Map<String, bool> isPaused = {};
  Map<String, Duration> duration = {};
  Map<String, Duration> position = {};

  final Map<String, AudioPlayer> _audioPlayer = {};

  void initPropsMsg(List<Message> msgs) {
    for (var element in msgs) {
      isSent[element.id] = false;
      isFailed[element.id] = false;
      isDelivred[element.id] = false;
      isMsgLoading[element.id] = false;

      if (element.audioLink != null) {
        _audioPlayer[element.id] = AudioPlayer();

        isPlaying[element.id] = false;
        isLoading[element.id] = false;
        isPaused[element.id] = false;
        duration[element.id] = const Duration();
        position[element.id] = const Duration();
      }
    }
  }

  _EventRecordingEnded(event) {
    // print(event);
  }

  _StopRecording(String? path) async {
    var _empty = Message.Empty();
    Message? _msg;
    if (path != null) {
      var stream =
          await sendAudio(path, widget.conversation.id, uuid as String);
      stream.listen((event) {
        if (event != null) {
          Map<String, dynamic> result = jsonDecode(event);
          if (result.containsKey("id")) {
            if (result["user_id"] != -1) {
              _msg = Message.fromJson(result);
              initPropsMsg([_msg as Message, _empty]);
              setState(() {
                _messages.add(_msg as Message);
                isSent[_msg!.id] = true;
                _messages.add(_empty);
                isMsgLoading[_empty.id] = true;
              });
              _scrollToBottom();
            } else if (result["user_id"] == -1) {
              var _msg = Message.fromJson(result);
              initPropsMsg([_msg]);
              setState(() {
                _messages.removeWhere((element) => element.id == _empty.id);
                _messages.add(_msg);
              });
              _scrollToBottom();
            }
          } else if (result.containsKey('delivered')) {
            setState(() {
              isDelivred[_msg!.id] = result['delivered'];
              _scrollToBottom();
            });
          } else {
            setState(() {
              _messages.removeWhere((element) => element.id == _empty.id);
              isFailed[_messages.last.id] = true;
            });
          }
        }
      }, onDone: () {
        _messages.removeWhere((element) => element.id == _empty.id);
      }, onError: (error) {
        _messages.removeWhere((element) => element.id == _empty.id);
      });
    }
  }

  _EventRecordingChanged(event) {
    setState(() {
      _recorderController.recorderState.isRecording
          ? _isRecording = true
          : _isRecording = false;
    });
    print('$_isRecording from listener');
  }

  recordAction() async {
    // TODO: Send Ui Feedback
    final permission = await _recorderController.checkPermission();
    final dir = await getApplicationDocumentsDirectory();

    if (permission) {
      _recorderController.sampleRate = 16000;
      _recorderController.androidOutputFormat = AndroidOutputFormat.ogg;
      _recorderController.onRecordingEnded.listen(_EventRecordingEnded);
      _recorderController.onRecorderStateChanged.listen(_EventRecordingChanged);
      print(_isRecording);
      _isRecording
          ? _StopRecording(await _recorderController.stop())
          : await _recorderController.record(path: '${dir.path}/rec.ogg');
    } else {
      print('permission error');
    }
  }

  Widget _createMessagesList() {
    if (_messages.isNotEmpty) {
      return Column(children: [
        ..._messages.asMap().keys.map((i) {
          return Column(children: [
            if (i == 0) ...[
              DateChip(date: _messages[i].date.add(Duration(hours: 1)))
            ] else if (_messages[i - 1]
                .date
                .add(const Duration(hours: 1))
                .isBefore(_messages[i].date)) ...[
              DateChip(date: _messages[i].date.add(Duration(hours: 1)))
            ] else
              ...[],
            _messages[i].audioLink != null
                ? BubbleNormalAudio(
                    id: _messages[i].id,
                    onSeekChanged: _onSeekChanged,
                    onPlayPauseButtonClick: _onPlayPauseButtonClick,
                    isPlaying: isPlaying[_messages[i].id] as bool,
                    isLoading: isLoading[_messages[i].id] as bool,
                    isPause: isPaused[_messages[i].id] as bool,
                    duration: duration[_messages[i].id]!.inSeconds.toDouble(),
                    position: position[_messages[i].id]!.inSeconds.toDouble(),
                    url: _messages[i].audioLink as String,
                    failed: isFailed[_messages[i].id] as bool,
                    sent: isSent[_messages[i].id] as bool,
                    delivered: isDelivred[_messages[i].id] as bool,
                    isSender: _messages[i].userID != -1 ? true : false,
                  )
                : BubbleNormal(
                    color: Colors.lightBlue,
                    text: _messages[i].text as String,
                    isSender: _messages[i].userID != -1 ? true : false,
                    failed: isFailed[_messages[i].id] as bool,
                    sent: isSent[_messages[i].id] as bool,
                    delivered: isDelivred[_messages[i].id] as bool,
                    loading: isMsgLoading[_messages[i].id] as bool,
                  )
          ]);
        }),
        SizedBox(
          height: 24,
        )
      ]);
    } else {
      return Container();
    }
  }

  void _fetchMessages() async {
    setState(() {
      _loading = true;
    });
    var res = await getMessages(uuid as String, widget.conversation.id);
    setState(() {
      if (res != null) {
        _messages = res.messages;
        initPropsMsg(_messages);
        _loading = false;
      }
    });
  }

  void _scrollToBottom() {
    if (_messages.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void initState() {
    _messages = List.empty(growable: true);
    _fetchMessages();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.conversation.name),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
                flex: 11,
                child: Stack(
                  children: [
                    Visibility(
                        visible: !_loading,
                        child: ListView(
                          controller: _scrollController,
                          shrinkWrap: true,
                          children: [_createMessagesList()],
                        )),
                    Visibility(
                        visible: _messages.isEmpty && !_loading,
                        child: const Center(
                            child: Text(
                          'Conversation vide\n Envoyer un message vocale pour commencer',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ))),
                    Visibility(
                        visible: _loading,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        )),
                  ],
                )),
            Expanded(
              flex: 1,
              child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24)),
                      boxShadow: boxShadow),
                  child: !_isRecording
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              width: 32,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(48)),
                                boxShadow: boxShadow,
                              ),
                              child: IconButton(
                                iconSize: 36,
                                icon: const Icon(
                                  Icons.mic,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    recordAction();
                                  });
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(48)),
                                boxShadow: boxShadow,
                              ),
                              child: IconButton(
                                iconSize: 24,
                                icon: const Icon(
                                  Icons.audio_file,
                                ),
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();

                                  if (result != null) {
                                    _StopRecording(result.files.single.path);
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 24,
                            ),
                            AudioWaveforms(
                                size: Size(
                                    MediaQuery.of(context).size.width - 140,
                                    40),
                                recorderController: _recorderController,
                                waveStyle: const WaveStyle(
                                  showDurationLabel: false,
                                  extendWaveform: true,
                                  scaleFactor: 40,
                                  waveColor: Colors.red,
                                  showMiddleLine: false,
                                  durationStyle: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                            const SizedBox(
                              width: 24,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(48)),
                                boxShadow: boxShadow,
                              ),
                              child: IconButton(
                                iconSize: 36,
                                icon: const Icon(
                                  Icons.stop,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    recordAction();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                          ],
                        )),
            )
          ],
        ),
      ),
    );
  }

  void _onPlayPauseButtonClick(String url, String id) async {
    if (isPaused[id] != null &&
        isPlaying[id] != null &&
        isLoading[id] != null &&
        duration[id] != null &&
        position[id] != null &&
        _audioPlayer[id] != null) {
      if (isPaused[id] == true) {
        await _audioPlayer[id]!.resume();
        setState(() {
          isPlaying[id] = true;
          isPaused[id] = false;
        });
      } else if (isPlaying[id] == true) {
        await _audioPlayer[id]!.pause();
        setState(() {
          isPlaying[id] = false;
          isPaused[id] = true;
        });
      } else {
        setState(() {
          isLoading[id] = true;
        });
        await _audioPlayer[id]!.play(UrlSource('$apiUrl/audio/$url'));
        setState(() {
          isPlaying[id] = true;
        });
      }

      _audioPlayer[id]!.onDurationChanged.listen((Duration d) {
        setState(() {
          duration[id] = d;
          isLoading[id] = false;
        });
      });

      _audioPlayer[id]!.onPositionChanged.listen((Duration p) {
        setState(() {
          position[id] = p;
        });
      });

      _audioPlayer[id]!.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying[id] = false;
          duration[id] = const Duration();
          position[id] = const Duration();
        });
      });
    }
  }

  void _onSeekChanged(double value) {}
}
