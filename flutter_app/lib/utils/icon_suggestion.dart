class IconSuggestion {
  final String bot;
  final List<String> suggested;

  IconSuggestion({required this.bot, required this.suggested});

  factory IconSuggestion.fromJson(Map<String, dynamic> json) {
    return IconSuggestion(
      bot: json['bot'],
      suggested: List<String>.from(json['suggested']),
    );
  }
}
