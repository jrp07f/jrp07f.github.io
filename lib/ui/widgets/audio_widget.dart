import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:care_dart_sdk/analytics/metrics_provider.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:care_dart_sdk/services/service_api.dart';
import 'package:care_dart_sdk/services/service_locator.dart';
import 'package:care_dart_sdk/ui/shared/ginger_typography.dart';
import 'package:care_dart_sdk/utilities/environment_config.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:mini_ginger_web/analytics/event.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';
import 'package:mini_ginger_web/commons/ginger_typography.dart';
import 'package:mini_ginger_web/commons/headspace_palette.dart';
import 'package:care_dart_sdk/generated/l10n.dart';
import 'package:mini_ginger_web/services/local_service_api.dart';
import 'package:rxdart/streams.dart';

class AudioWidget extends StatefulWidget {
  const AudioWidget({
    Key key,
  }) : super(key: key);

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> with WidgetsBindingObserver {
  final Logger log = Logger('_AudioWidgetState');
  final MetricsProvider metrics = serviceLocator.get<MetricsProvider>();
  static const FEELING_OVERWHELMED_AUDIO = "https://assets.ctfassets.net/51rv07bk89f0/HS20200910094800003054/13c26c75a9a0f34b1a4dc5bdc75fec37/single-sos-feeling_overwhelmed-3m-en-170627__1508283269894.mp3";
  static const FEELING_OVERWHELMED_AUDIO_SPANISH = "https://assets.ctfassets.net/51rv07bk89f0/HS20200910094800003057/16c7c130b144cd15665c8254748129f7/intl-sos-feeling_overwhelmed-3m-l_es_-g_m_-n_javi_-20190731_finalmix__1564690265794.mp3";

  AudioPlayer _audioPlayer;
  StreamSubscription<ProcessingState> _audioProcessingStateSubscription;

  Duration totalAudioDuration;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _initializePlayer();
  }

  String get audioUrl {
    LocalServiceAPI api = serviceLocator.get<ServiceAPI>() as LocalServiceAPI;
    if (api.preferredLangCode == "es") {
      return FEELING_OVERWHELMED_AUDIO_SPANISH;
    }
    return FEELING_OVERWHELMED_AUDIO;
  }

  void _initializePlayer() async {
    _audioPlayer = AudioPlayer();
    serviceLocator.registerLazySingleton<AudioPlayer>(() => _audioPlayer);

    if(Environment.current.type == EnvironmentType.TEST) {
      return;
    }
    try {
      _audioPlayer.setUrl(audioUrl).then((value) {
        _audioProcessingStateSubscription =
            _audioPlayer.processingStateStream.listen((state) async {
              if (state == ProcessingState.ready) {
                setState(() {});
                return;
              }

              if (state == ProcessingState.completed) {
                await _audioPlayer.stop();
                _audioPlayer.seek(const Duration(seconds: 0));
                setState(() {});
              }
            });
      });
    } catch(e) {
      log.severe('Unable to load audio file: ${e.toString()}', e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if(Environment.current.type != EnvironmentType.TEST) {
          if (_audioPlayer.playing) {
            _audioPlayer.pause();
            _audioPlayer.seek(_audioPlayer.position);
          }
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.resumed:
      default:
        break;
    }
  }

  String getSliderSemantics(Duration duration) {
    final minutes = duration.inSeconds ~/ 60;
    final seconds = duration.inSeconds - (minutes * 60);

    return R.current.semantics_audio_player_slider(minutes, seconds);
  }

  void actionPlayOrPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
      metrics.track(FeelingOverwhelmedAudioStopped());
    } else {
      _audioPlayer.play();
      metrics.track(FeelingOverwhelmedAudioPlayed());
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: HeadspacePalette.lightModeBackgroundStrong,
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(12.dp),
            child: Builder(builder: (_) {
              if (isLoading) {
                return Container(
                  height: 32.dp,
                  width: 32.dp,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: GingerCorePalette.grey15
                  ),
                );
              }

              return Semantics(
                button: true,
                onTap: actionPlayOrPause,
                excludeSemantics: true,
                child: Material(
                  color: GingerCorePalette.transparent,
                  child: InkWell(
                    onTap: actionPlayOrPause,
                    customBorder: const CircleBorder(),
                    child: Container(
                      height: 32.dp,
                      width: 32.dp,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: HeadspacePalette.lightModeInteractiveStaticDark
                      ),
                      child: Icon(
                        (!_audioPlayer.playing ? Icons.play_arrow_rounded : Icons.pause_rounded),
                        color: GingerCorePalette.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
              );
            },),
          ),
          Expanded(
            child: Container(
              height: 64.dp,
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    R.current.feeling_overwhelmed,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: DesktopGingerTypography()
                        .desktopLabel2xs
                        .copyWith(color: HeadspacePalette.lightModeText),
                  ),
                  StreamBuilder<List<Duration>>(
                    stream: CombineLatestStream.list([
                      _audioPlayer.positionStream,
                      _audioPlayer.durationStream,
                      _audioPlayer.bufferedPositionStream,
                    ]),
                    builder: (context, snapshot) {
                      final streams = snapshot.data;
                      if (streams == null) return Container();

                      final position = streams[0];
                      final duration = streams[1] ?? Duration.zero;
                      final bufferedPosition = streams[2];

                      return Semantics(
                        explicitChildNodes: true,
                        child: Builder(builder: (context) {
                          if (isLoading) {
                            return Container(
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: GingerCorePalette.grey15,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }

                          return Semantics(
                            slider: true,
                            excludeSemantics: true,
                            value: getSliderSemantics(position),
                            increasedValue: position.compareTo(duration) >= 0
                                ? getSliderSemantics(duration)
                                : getSliderSemantics(
                                Duration(seconds: position.inSeconds + 5)),
                            decreasedValue: position.compareTo(Duration.zero) <= 0
                                ? getSliderSemantics(Duration.zero)
                                : getSliderSemantics(
                                Duration(seconds: position.inSeconds - 5)),
                            onIncrease: () {
                              final newValue = Duration(seconds: position.inSeconds + 5)
                                  .compareTo(duration) >= 0
                                  ? duration
                                  : Duration(seconds: position.inSeconds + 5);

                              _audioPlayer.seek(newValue);
                            },
                            onDecrease: () {
                              final newValue =
                              Duration(seconds: position.inSeconds - 5)
                                  .compareTo(Duration.zero) <= 0
                                  ? Duration.zero
                                  : Duration(seconds: position.inSeconds - 5);

                              _audioPlayer.seek(newValue);
                            },
                            child: ProgressBar(
                              progress: position,
                              total: duration,
                              buffered: bufferedPosition,
                              barCapShape: BarCapShape.round,
                              progressBarColor: HeadspacePalette.orange500,
                              baseBarColor: HeadspacePalette.borderStrong,
                              thumbColor: HeadspacePalette.orange500,
                              bufferedBarColor: GingerCorePalette.transparent,
                              barHeight: 1.32,
                              thumbRadius: 5.0,
                              onSeek: _audioPlayer.seek,
                              timeLabelLocation: TimeLabelLocation.sides,
                              timeLabelTextStyle: DesktopGingerTypography()
                                  .desktopLabel3xs
                                  .copyWith(
                                fontSize: 8.dp,
                                color: HeadspacePalette.lightModeTextWeakest,
                              ),
                            ),
                          );
                        },),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get isLoading {
    return _audioPlayer.processingState == ProcessingState.loading;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(Environment.current.type != EnvironmentType.TEST) {
      _audioPlayer.stop();
      _audioProcessingStateSubscription?.cancel();
      _audioPlayer.dispose();
    }
    super.dispose();
  }
}