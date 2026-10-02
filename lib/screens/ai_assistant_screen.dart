import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_state.dart';
import '../services/firestore_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage(AppState app) async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    _controller.clear();
    setState(() => _isSending = true);

    final String answer = app.lang == 'gu'
        ? 'કપાસમાં ઇયળના નિયંત્રણ માટે લીમડાનું તેલ અથવા ભલામણ કરેલ કીટનાશકનો છંટકાવ કરો.'
        : 'For pest control in cotton, spray neem oil or recommended insecticide solution.';

    try {
      await FirestoreService().saveAiChatMessage(
        question: query,
        answer: answer,
      );
    } catch (e) {
      debugPrint('Firestore error sending chat: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(app.t('aiAssistant'))),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirestoreService().getAiChatsStream(),
                  builder: (context, snapshot) {
                    final chats = snapshot.data?.docs ?? [];

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _BotBubble(
                          text: app.lang == 'gu'
                              ? 'નમસ્તે! હું તમારો AI ખેડૂત મિત્ર છું. મને પાક, હવામાન કે બજાર વિશે પૂછો.'
                              : 'Hello! I am your AI Farmer Assistant. Ask me about crops, weather, or market prices.',
                        ),
                        const SizedBox(height: 12),
                        ...chats.expand((doc) {
                          final data = doc.data();
                          final q = data['question'] as String? ?? '';
                          final a = data['answer'] as String? ?? '';
                          return [
                            if (q.isNotEmpty) ...[
                              _UserBubble(text: q),
                              const SizedBox(height: 12),
                            ],
                            if (a.isNotEmpty) ...[
                              _BotBubble(text: a),
                              const SizedBox(height: 12),
                            ],
                          ];
                        }),
                      ],
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: app.t('aiHint'),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(app),
                          onTap: () {
                            if (_controller.text.isEmpty) {
                              _controller.text = app.t('sampleQuestion');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF2E7D32),
                        child: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send, color: Colors.white),
                          onPressed: _isSending ? null : () => _sendMessage(app),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BotBubble extends StatelessWidget {
  final String text;
  const _BotBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9A825),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
