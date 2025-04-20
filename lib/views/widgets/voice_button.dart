import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/speech_controller.dart';

class VoiceButton extends StatefulWidget {
  final Function(String) onCommand;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const VoiceButton({
    super.key,
    required this.onCommand,
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

  void _onSpeechControllerChanged() {
    if (_speechController.detectedCommand != null) {
      widget.onCommand(_speechController.detectedCommand!);

      // إعادة ضبط بعد تنفيذ الأمر
      Future.delayed(const Duration(milliseconds: 500), () {
        _speechController.resetRecognition();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isListening = _speechController.isListening;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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

        // زر الميكروفون
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
                    color: widget.backgroundColor ?? theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: .3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
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
      _speechController.startListening();

      // عرض رسالة بالإشارة إلى بدء الاستماع
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'جارِ الاستماع... قل أمرًا مثل "ابدأ التنقل" أو "ابحث عن مكان"',
          ),
          duration: Duration(seconds: 2),
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
