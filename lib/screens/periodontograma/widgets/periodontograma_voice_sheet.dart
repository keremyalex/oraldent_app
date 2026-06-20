import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:odontologia_app/models/periodontograma_ai.dart';
import 'package:odontologia_app/providers/periodontograma_provider.dart';
import 'package:odontologia_app/services/periodontograma_ai_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class PeriodontogramaVoiceSheet extends StatefulWidget {
  const PeriodontogramaVoiceSheet({super.key});

  @override
  State<PeriodontogramaVoiceSheet> createState() =>
      _PeriodontogramaVoiceSheetState();
}

class _PeriodontogramaVoiceSheetState extends State<PeriodontogramaVoiceSheet> {
  static const _amplitudeInterval = Duration(milliseconds: 200);
  static const _silenceDbThreshold = -35.0;
  static const _minSpeechMs = 700;
  static const _silenceHoldMs = 1000;
  static const _maxSegmentMs = 12000;

  final _recorder = AudioRecorder();
  final _aiService = PeriodontogramaAiService();

  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Future<void> _processingQueue = Future.value();

  bool _isMicActive = false;
  bool _isDictating = true;
  bool _isStoppingSegment = false;
  bool _isProcessing = false;
  int _pendingSegments = 0;
  int _speechMs = 0;
  int _silenceMs = 0;
  int _segmentMs = 0;
  double _currentDb = -160;
  String _transcription = '';
  String? _currentPath;
  String? _errorMessage;
  PeriodontogramaAiResult? _result;

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    unawaited(_recorder.stop());
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeriodontogramaProvider>();
    final canApply = _result?.hasData == true && !provider.isSaving;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F7FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dictado por voz',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isStoppingSegment ? null : _closeSheet,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Cerrar dictado',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _isMicActive ? _stopSession : _startSession,
                  icon: Icon(
                    _isMicActive ? Icons.stop_rounded : Icons.mic_rounded,
                  ),
                  label: Text(_isMicActive ? 'Apagar micrófono' : 'Activar'),
                ),
                OutlinedButton.icon(
                  onPressed: !_isMicActive
                      ? null
                      : () => setState(() => _isDictating = !_isDictating),
                  icon: Icon(
                    _isDictating
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                  label: Text(_isDictating ? 'Pausar' : 'Retomar'),
                ),
                OutlinedButton.icon(
                  onPressed: _isMicActive || _isProcessing ? null : _clear,
                  icon: const Icon(Icons.cleaning_services_rounded),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            if (_isMicActive) ...[
              const SizedBox(height: 14),
              _VoiceMeter(currentDb: _currentDb, isDictating: _isDictating),
            ],
            if (_isProcessing) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              _VoiceNotice(message: _errorMessage!, isError: true),
            ],
            const SizedBox(height: 16),
            _VoiceSection(
              title: 'Texto reconocido',
              child: Text(
                _transcription.isEmpty
                    ? 'Aún no hay texto reconocido.'
                    : _transcription,
                style: TextStyle(
                  color: _transcription.isEmpty
                      ? AppColors.secondary
                      : AppColors.inverted,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _VoiceSection(
              title: 'Texto útil para aplicar',
              child: Text(
                _usefulText,
                style: TextStyle(
                  color: _result?.hasData == true
                      ? AppColors.inverted
                      : AppColors.secondary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _VoiceSection(
              title: 'Datos detectados',
              child: _AiPreview(result: _result),
            ),
            if (_result?.unparsedSegments.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _VoiceSection(
                title: 'Texto ignorado',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _result!.unparsedSegments
                      .map(
                        (segment) => Chip(
                          label: Text(segment),
                          backgroundColor: const Color(0xFFFFF7ED),
                          side: const BorderSide(color: Color(0xFFFED7AA)),
                          labelStyle: TextStyle(color: Colors.orange.shade900),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canApply ? _applyResult : null,
                icon: provider.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: const Text('Aplicar al periodontograma'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusText {
    if (_isProcessing && _pendingSegments > 0) {
      return 'Procesando $_pendingSegments segmento${_pendingSegments == 1 ? '' : 's'}...';
    }
    if (!_isMicActive) {
      return 'Activa el micrófono y dicta una pieza.';
    }
    if (!_isDictating) {
      return 'Pausado. Di "iniciar" o toca Retomar.';
    }
    return 'Escuchando. Pausa un segundo para procesar.';
  }

  String get _usefulText {
    final result = _result;
    if (result == null || !result.hasData) {
      return 'Todavía no hay datos útiles detectados.';
    }

    final parts = <String>[];
    for (final entry in result.byTooth.entries) {
      final labels = entry.value
          .where((item) => item.action != 'tooth_id')
          .map(_actionText)
          .where((text) => text.isNotEmpty)
          .toList();
      if (labels.isEmpty) {
        continue;
      }
      parts.add('Pieza ${entry.key}: ${labels.join(', ')}');
    }

    return parts.isEmpty
        ? 'Todavía no hay datos útiles detectados.'
        : parts.join('\n');
  }

  String _actionText(PeriodontogramaAiItem item) {
    final target = _targetText(item);
    return switch (item.action) {
      'probing' => '${item.surface ?? 'superficie'} ${item.values.join(' ')}',
      'gingival_margin' => 'margen gingival$target ${item.values.join(' ')}',
      'bleeding' => 'sangrado$target ${item.positive == true ? 'si' : 'no'}',
      'plaque' => 'placa$target ${item.positive == true ? 'si' : 'no'}',
      'suppuration' =>
        'supuracion$target ${item.positive == true ? 'si' : 'no'}',
      'mobility' => 'movilidad ${item.grade}',
      'furca' => 'furca$target ${item.grade}',
      'recession' => 'margen/recesion$target ${item.mm} mm',
      _ => '',
    };
  }

  String _targetText(PeriodontogramaAiItem item) {
    if (item.sites.isNotEmpty) {
      return ' ${item.sites.join(', ')}';
    }
    if (item.surface != null) {
      return ' ${item.surface}';
    }
    return '';
  }

  Future<void> _startSession() async {
    setState(() => _errorMessage = null);
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() {
        _errorMessage = 'No se concedio permiso para usar el microfono.';
      });
      return;
    }

    setState(() {
      _isMicActive = true;
      _isDictating = true;
      _resetSegmentCounters();
    });
    _amplitudeSubscription ??= _recorder
        .onAmplitudeChanged(_amplitudeInterval)
        .listen(_handleAmplitude);
    await _startSegment();
  }

  Future<void> _startSegment() async {
    if (!_isMicActive) {
      return;
    }

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/periodontograma_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentPath = path;
    _resetSegmentCounters();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  void _handleAmplitude(Amplitude amplitude) {
    if (!_isMicActive || _isStoppingSegment || !mounted) {
      return;
    }

    final currentDb = amplitude.current.isFinite ? amplitude.current : -160.0;
    final isSpeaking = currentDb > _silenceDbThreshold;

    _segmentMs += _amplitudeInterval.inMilliseconds;
    if (isSpeaking) {
      _speechMs += _amplitudeInterval.inMilliseconds;
      _silenceMs = 0;
    } else {
      _silenceMs += _amplitudeInterval.inMilliseconds;
    }

    setState(() => _currentDb = currentDb);

    final speechDone =
        _speechMs >= _minSpeechMs && _silenceMs >= _silenceHoldMs;
    final tooLong = _segmentMs >= _maxSegmentMs;
    if (speechDone || tooLong) {
      unawaited(_finishSegment(restart: true));
    }
  }

  Future<void> _finishSegment({
    required bool restart,
    bool processIfShort = false,
  }) async {
    if (_isStoppingSegment) {
      return;
    }

    try {
      _isStoppingSegment = true;
      final hadSpeech =
          _speechMs >= _minSpeechMs || (processIfShort && _speechMs > 0);
      final path = await _recorder.stop();

      if (_isMicActive && restart && mounted) {
        await _startSegment();
      }

      if (!hadSpeech) {
        return;
      }
      final segmentPath = path ?? _currentPath;
      if (segmentPath == null || !File(segmentPath).existsSync()) {
        if (mounted) {
          setState(
            () => _errorMessage = 'No se pudo obtener el audio grabado.',
          );
        }
        return;
      }
      _enqueueSegment(segmentPath);
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo cortar el segmento de audio: $error';
        });
      }
    } finally {
      _isStoppingSegment = false;
    }
  }

  void _enqueueSegment(String path) {
    setState(() {
      _pendingSegments += 1;
      _isProcessing = true;
      _errorMessage = null;
    });

    _processingQueue = _processingQueue
        .then((_) => _processSegment(path))
        .catchError((_) {})
        .whenComplete(() {
          if (!mounted) {
            return;
          }
          setState(() {
            final nextPending = _pendingSegments - 1;
            _pendingSegments = nextPending < 0 ? 0 : nextPending;
            _isProcessing = _pendingSegments > 0;
          });
        });
  }

  Future<void> _processSegment(String path) async {
    try {
      final transcription = await _aiService.transcribirAudio(path);
      final text = transcription.text.trim();
      if (text.isEmpty) {
        _setSoftError('No se reconocio texto en el audio.');
        return;
      }
      if (_isSuspiciousTranscription(text)) {
        _setSoftError('Se ignoro un segmento con ruido o texto no util.');
        return;
      }

      await _processText(text);
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo procesar el audio: $error';
        });
      }
    } finally {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  Future<void> _processText(String text) async {
    final command = _detectCommand(text);
    if (command == _VoiceCommand.clear) {
      if (mounted) {
        _clear();
      }
      return;
    }
    if (command == _VoiceCommand.start) {
      if (mounted) {
        setState(() => _isDictating = true);
      }
      return;
    }
    if (command == _VoiceCommand.stop) {
      if (mounted) {
        setState(() => _isDictating = false);
      }
      return;
    }

    if (!_isDictating) {
      return;
    }

    try {
      final nextText = [
        _transcription,
        text,
      ].where((value) => value.trim().isNotEmpty).join(' ');
      final parsed = await _aiService.parsearTexto(nextText);
      if (!parsed.hasData && parsed.unparsedSegments.isNotEmpty) {
        _setSoftError('Se ignoro texto que no corresponde al periodontograma.');
        return;
      }
      if (mounted) {
        setState(() {
          _transcription = nextText;
          _result = parsed;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo interpretar el texto: $error';
        });
      }
    }
  }

  Future<void> _stopSession() async {
    setState(() {
      _isMicActive = false;
      _currentDb = -160;
    });
    await _finishSegment(restart: false, processIfShort: true);
  }

  Future<void> _closeSheet() async {
    if (_isMicActive) {
      await _stopSession();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _applyResult() async {
    final result = _result;
    if (result == null) {
      return;
    }

    final message = await context
        .read<PeriodontogramaProvider>()
        .aplicarResultadoIa(result);
    if (!mounted) {
      return;
    }
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos aplicados al periodontograma.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _clear() {
    setState(() {
      _transcription = '';
      _result = null;
      _errorMessage = null;
    });
  }

  void _setSoftError(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _errorMessage = message);
  }

  void _resetSegmentCounters() {
    _speechMs = 0;
    _silenceMs = 0;
    _segmentMs = 0;
  }

  _VoiceCommand? _detectCommand(String text) {
    final words = text.trim().split(RegExp(r'\s+')).where((word) {
      return word.isNotEmpty;
    }).toList();
    if (words.length > 3) {
      return null;
    }

    final normalized = _normalize(text);
    if (RegExp(
      r'\b(iniciar|inicia|inicio|empezar|empieza|comenzar|comienza)\b',
    ).hasMatch(normalized)) {
      return _VoiceCommand.start;
    }
    if (RegExp(
      r'\b(fin|finalizar|finaliza|terminar|termina|detener)\b',
    ).hasMatch(normalized)) {
      return _VoiceCommand.stop;
    }
    if (RegExp(r'\b(limpiar|limpia|borrar|borra)\b').hasMatch(normalized)) {
      return _VoiceCommand.clear;
    }
    return null;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u');
  }

  bool _isSuspiciousTranscription(String text) {
    final normalized = _normalize(text)
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.length < 4) {
      return true;
    }

    final tokens = normalized.split(' ').where((token) => token.isNotEmpty);
    final tokenList = tokens.toList();
    if (tokenList.isEmpty) {
      return true;
    }

    final usefulWords = RegExp(
      r'\b(pieza|diente|vestibular|palatino|lingual|mesial|distal|sangrado|placa|supuracion|furca|furcacion|movilidad|margen|recesion|sondaje)\b',
    );
    if (usefulWords.hasMatch(normalized)) {
      return false;
    }

    final numericTokens = tokenList
        .where((token) => RegExp(r'^\d+$').hasMatch(token))
        .length;
    final uniqueTokens = tokenList.toSet().length;
    final mostlyNumbers = numericTokens / tokenList.length >= 0.75;
    final highlyRepeated = tokenList.length >= 8 && uniqueTokens <= 3;

    return mostlyNumbers || highlyRepeated;
  }
}

enum _VoiceCommand { start, stop, clear }

class _VoiceMeter extends StatelessWidget {
  const _VoiceMeter({required this.currentDb, required this.isDictating});

  final double currentDb;
  final bool isDictating;

  @override
  Widget build(BuildContext context) {
    final normalized = ((currentDb + 60) / 60).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            isDictating
                ? Icons.graphic_eq_rounded
                : Icons.pause_circle_outline_rounded,
            color: isDictating ? AppColors.primary : AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                color: isDictating ? AppColors.primary : AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${currentDb.toStringAsFixed(0)} dB',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceSection extends StatelessWidget {
  const _VoiceSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.inverted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _VoiceNotice extends StatelessWidget {
  const _VoiceNotice({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFEBEE) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? const Color(0xFFFFCDD2) : const Color(0xFFFED7AA),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Colors.red.shade800 : Colors.orange.shade900,
          height: 1.35,
        ),
      ),
    );
  }
}

class _AiPreview extends StatelessWidget {
  const _AiPreview({required this.result});

  final PeriodontogramaAiResult? result;

  @override
  Widget build(BuildContext context) {
    final current = result;
    if (current == null || !current.hasData) {
      return const Text(
        'No hay datos detectados todavía.',
        style: TextStyle(color: AppColors.secondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: current.byTooth.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pieza ${entry.key}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value
                    .where((item) => item.action != 'tooth_id')
                    .map(_ActionChip.new)
                    .toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip(this.item);

  final PeriodontogramaAiItem item;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label),
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  String get _label {
    final target = _targetText;
    return switch (item.action) {
      'probing' => '${item.surface}: ${item.values.join(' ')}',
      'gingival_margin' => 'margen gingival$target: ${item.values.join(' ')}',
      'bleeding' => 'sangrado$target: ${item.positive == true ? 'si' : 'no'}',
      'plaque' => 'placa$target: ${item.positive == true ? 'si' : 'no'}',
      'suppuration' =>
        'supuracion$target: ${item.positive == true ? 'si' : 'no'}',
      'mobility' => 'movilidad: ${item.grade}',
      'furca' => 'furca$target: ${item.grade}',
      'recession' => 'margen/recesion$target: ${item.mm} mm',
      _ => item.action,
    };
  }

  String get _targetText {
    if (item.sites.isNotEmpty) {
      return ' ${item.sites.join(', ')}';
    }
    if (item.surface != null && item.action != 'probing') {
      return ' ${item.surface}';
    }
    return '';
  }
}
