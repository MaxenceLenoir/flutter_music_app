import 'dart:async';

import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayer2/audioplayer2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coda Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Coda Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Music> myMusicList = [
    Music('Theme Swift', 'Codabee', 'assets/un.jpg', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    Music('Theme Flutter', 'Codabee', 'assets/deux.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  Music actualMusic;
  Duration position = Duration(seconds: 0);
  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Duration duree = Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    actualMusic = myMusicList[index];
    configurationAudioPlayer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 9,
              child: Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: Image.asset(actualMusic.imagePath)
              ),
            ),
            textWithStyle(actualMusic.titre, 1.5),
            textWithStyle(actualMusic.artiste, 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                button((statut == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 30.0, (statut == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                button(Icons.fast_forward, 30.0, ActionMusic.forward)
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textWithStyle(fromDuration(position), 0.8),
                textWithStyle(fromDuration(duree), 0.8)
              ]
            ),
            Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                onChanged: (double d) {
                  setState(() {
                    Duration newDuration = Duration(seconds: d.toInt());
                    audioPlayer.seek(d);
                  });
                })
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  IconButton button(IconData icon, double size, ActionMusic action) {
    return IconButton(
      iconSize: size,
      color: Colors.white,
      icon: Icon(icon),
      onPressed: () {

        switch (action) {
          case ActionMusic.play:
            play();
            break;
          case ActionMusic.pause:
            pause();
            break;
          case ActionMusic.forward:
            forward();
            break;
          case ActionMusic.rewind:
            rewind();
            break;
        }
      }
    );
  }

  Text textWithStyle(String data, double scale) {
    return Text(
      data,
      textScaleFactor: scale,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  void configurationAudioPlayer () {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState (() => position = pos)
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() => duree = audioPlayer.duration);
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() => statut = PlayerState.stopped);
      }
    }, onError: (message) {
      print('erreur: $message');
      setState(() {
      statut = PlayerState.stopped;
      duree = Duration(seconds: 0);
      position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(actualMusic.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
    }
  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() {
    if (index == myMusicList.length - 1) {
      index = 0;
    } else {
      index++;
    }
    actualMusic = myMusicList[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = myMusicList.length - 1;
      } else {
        index--;
      }
      actualMusic = myMusicList[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused
}
