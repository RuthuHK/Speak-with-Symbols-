// class SentenceModifier {
//   static String toNegative(String sentence) {
//     final words = sentence.split(' ');
//     if (words.length > 1 && words[0].toLowerCase() == "i") {
//       return ["I", "don't", ...words.sublist(1)].join(' ');
//     }
//     return sentence;
//   }

//   static String toPositive(String sentence) {
//     return sentence
//         .replaceAll(RegExp(r"\b(don't|do not)\b", caseSensitive: false), "")
//         .replaceAll(RegExp(r"\s+"), ' ')
//         .trim();
//   }

//   static bool isNegative(String sentence) {
//     return RegExp(r"\b(don't|do not)\b", caseSensitive: false).hasMatch(sentence);
//   }

//   static bool isPositive(String sentence) {
//     return !isNegative(sentence);
//   }
// }


class SentenceModifier {
  static String toNegative(String sentence) {
    sentence = sentence.trim();
    final words = sentence.split(' ');

    if (words.length < 2) return sentence;

    String subject = words[0];
    String verb = words[1];

    final supportedSubjects = ['i', 'you', 'we', 'they'];

    if (!supportedSubjects.contains(subject.toLowerCase())) {
      return sentence;
    }

    if (sentence.toLowerCase().contains("don't") || sentence.toLowerCase().contains("do not")) {
      return sentence; // already negative
    }

    // Insert "don't" after the subject
    return '$subject don\'t ${words.sublist(1).join(' ')}';
  }

  static String toPositive(String sentence) {
    return sentence
        .replaceAll(RegExp(r"\b(don't|do not)\b", caseSensitive: false), "")
        .replaceAll(RegExp(r"\s+"), ' ')
        .trim();
  }


  static bool isNegative(String sentence) {
    return RegExp(r"\b(don't|do not)\b", caseSensitive: false).hasMatch(sentence);
  }

  static bool isPositive(String sentence) {
    return !isNegative(sentence);
  }
}
