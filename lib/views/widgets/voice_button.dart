// lib/views/widgets/voice_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/speech_controller.dart';
import '../../models/place_model.dart';

class VoiceButton extends StatefulWidget {
  final Function(String) onCommand;
  final Function(PlaceModel, String)? onPlaceSelected;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const VoiceButton({
    super.key,
    required this.onCommand,
    this.onPlaceSelected,
    this.size = 60.0,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  late SpeechController _speechController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();

    // تهيئة المتحركات
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _speechController = Provider.of<SpeechController>(context);

    // تهيئة خدمة التعرف على الكلام مبدئيًا
    if (!_speechController.isInitialized) {
      _speechController.initialize();
    }

    // مراقبة الأوامر المكتشفة
    _speechController.addListener(_onSpeechControllerChanged);
  }

  void _onSpeechControllerChanged() async {
    if (_speechController.detectedCommand != null) {
      // إبلاغ الأمر
      widget.onCommand(_speechController.detectedCommand!);

      // إذا كان الأمر متعلقًا بالبحث عن أماكن، نبدأ البحث
      final command = _speechController.detectedCommand!;

      if (command.startsWith('ابحث عن') ||
          command.startsWith('توجه إلى') ||
          command.startsWith('خذني إلى') ||
          command.startsWith('اذهب إلى') ||
          command == 'أماكن قريبة' ||
          command.contains('أقرب') ||
          (command.contains('قريب') && !command.startsWith('ابحث عن'))) {
        // عرض رسالة بالبحث
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'جارٍ البحث عن: ${_getSearchQueryFromCommand(command)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // ابدأ البحث عن الأماكن بناءً على الأمر الصوتي
        await _speechController.searchPlacesByVoiceCommand(context, command);

        // عرض نتائج البحث
        setState(() {
          _showResults = _speechController.searchResults.isNotEmpty;
        });
      } else {
        // إعادة ضبط بعد تنفيذ الأمر الآخر
        Future.delayed(const Duration(milliseconds: 500), () {
          _speechController.resetRecognition();
          setState(() {
            _showResults = false;
          });
        });
      }
    }
  }

  // استخراج استعلام البحث من الأمر لعرضه في رسالة
  String _getSearchQueryFromCommand(String command) {
    if (command.startsWith('ابحث عن')) {
      return command.substring('ابحث عن'.length).trim();
    } else if (command.startsWith('توجه إلى')) {
      return command.substring('توجه إلى'.length).trim();
    } else if (command.startsWith('خذني إلى')) {
      return command.substring('خذني إلى'.length).trim();
    } else if (command.startsWith('اذهب إلى')) {
      return command.substring('اذهب إلى'.length).trim();
    } else if (command == 'أماكن قريبة') {
      return 'الأماكن القريبة';
    } else if (command.contains('أقرب')) {
      return command;
    } else if (command.contains('قريب')) {
      return command;
    } else {
      return command;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isListening = _speechController.isListening;
    final isSearching = _speechController.isSearching;
    final searchResults = _speechController.searchResults;
    final errorMessage = _speechController.errorMessage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // عرض نتائج البحث إذا كانت متاحة
        if (_showResults && searchResults.isNotEmpty)
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // عنوان نتائج البحث
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نتائج البحث',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showResults = false;
                        });
                        _speechController.resetRecognition();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(),

                // قائمة نتائج البحث
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final place = searchResults[index];
                      return ListTile(
                        title: Text(
                          place.placeName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          place.address,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Icon(
                          Icons.place,
                          color: theme.colorScheme.primary,
                        ),
                        dense: true,
                        onTap: () {
                          // إخفاء النتائج
                          setState(() {
                            _showResults = false;
                          });

                          // استدعاء دالة الاختيار إذا كانت متاحة
                          if (widget.onPlaceSelected != null) {
                            widget.onPlaceSelected!(
                              place,
                              _speechController.searchType ?? 'general',
                            );
                          }

                          // إعادة ضبط التعرف
                          _speechController.resetRecognition();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        // عرض رسالة الخطأ إذا وجدت
        if (errorMessage != null && !isListening)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              errorMessage,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
              textAlign: TextAlign.center,
            ),
          ),

        // عرض النص المعترف به إذا كان التطبيق يستمع
        if (isListening && _speechController.recognizedText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _speechController.recognizedText,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

        // زر الميكروفون مع مؤشر التحميل
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: isListening ? _animation.value : 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSearching
                            ? Colors.orange
                            : widget.backgroundColor ??
                                theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (isSearching
                                ? Colors.orange
                                : theme.colorScheme.primary)
                            .withValues(alpha: .3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child:
                      isSearching
                          ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                          : Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: widget.iconColor ?? Colors.white,
                            size: widget.size * 0.5,
                          ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _toggleListening() {
    if (_speechController.isListening) {
      _speechController.stopListening();
    } else {
      // إعادة ضبط نتائج البحث السابقة
      setState(() {
        _showResults = false;
      });
      _speechController.resetRecognition();

      _speechController.startListening(
        onListeningComplete: () {
          // إعادة ضبط التعرف بعد انتهاء الاستماع
          _speechController.resetRecognition();
          setState(() {
            _showResults = false;
          });
        },
        onResult: (recognizedText) {
          // إبلاغ النص المعترف به
          widget.onCommand(recognizedText);
        },
      );

      // عرض رسالة بالإشارة إلى بدء الاستماع
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'جارِ الاستماع... يمكنك قول أوامر مثل "أقرب مطعم" أو "أماكن قريبة" أو "توجه إلى الجامعة"',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _speechController.removeListener(_onSpeechControllerChanged);
    _animationController.dispose();
    super.dispose();
  }
}
