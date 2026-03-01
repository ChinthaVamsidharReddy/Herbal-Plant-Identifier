class PredictionUtils {
  static List<Map<String, dynamic>> getTopK(
    List<double> probs,
    List<String> labels,
    int k,
  ) {
    final indexed = probs.asMap().entries.toList();

    indexed.sort((a, b) => b.value.compareTo(a.value));

    return indexed.take(k).map((e) {
      return {"label": labels[e.key], "confidence": e.value};
    }).toList();
  }

  static String confidenceMessage(double c) {
    if (c > 0.8) return "High confidence";
    if (c > 0.6) return "Moderate confidence";
    return "Low confidence — try clearer leaf image";
  }
}
