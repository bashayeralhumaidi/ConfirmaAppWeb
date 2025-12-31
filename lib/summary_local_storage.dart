class SummaryLocalStorage {
  static Map<int, Map<String, dynamic>> safetyAnswers = {};
  static Map<int, Map<String, dynamic>> cleanlinessAnswers = {};
  static Map<int, Map<String, dynamic>> qualityAnswers = {};
  static Map<int, Map<String, dynamic>> facilityAnswers = {};
  static Map<int, Map<String, dynamic>> equipmentAnswers = {};
  static Map<int, Map<String, dynamic>> accessAnswers = {};

  // WASTE (topic → index → answer)
  static Map<String, Map<int, Map<String, dynamic>>> wasteAnswers = {};

  static DateTime? startTime;
  static String timerText = "00:00:00";

  static List<String> currentCategoryQuestions = [];
}
