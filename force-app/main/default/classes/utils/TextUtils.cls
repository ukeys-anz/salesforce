/**
 * @description TextUtils class contains static utility methods to take some actions related to text.
 * @author Pavan Kumar Ananta
 * @since 01/06/2020
 * @group Utils
 */
public with sharing class TextUtils {
  private static final String ACCOUNT_OR_CARD_REGEX_PATTERN = '[0-9][^a-zA-Z]{6,}[0-9]';
  private static final String TAX_REGEX_PATTERN = '[0-9][^a-zA-Z]{13,}[0-9]';
  private static final String LOG_REGEX_PATTERN = '[0-9][^a-zA-Z]{10,}[0-9]';
  private static final String LOG_KEYWORD_REGEX_PATTERN = '[0-9][^a-zA-Z]{6,}[0-9]';
  private static final Integer UNMASK_LENGTH = 4;
  private static Pattern accountOrCardPattern = Pattern.compile(
    ACCOUNT_OR_CARD_REGEX_PATTERN
  );
  private static Pattern taxPattern = Pattern.compile(TAX_REGEX_PATTERN);
  private static Pattern logPattern = Pattern.compile(LOG_REGEX_PATTERN);
  private static Pattern logKeywordPattern = Pattern.compile(
    LOG_KEYWORD_REGEX_PATTERN
  );
  /**
   * @description general method to mask certain data with a specific pattern and length
   * @param input Input string that needs to be masked if needed
   * @param patToCompile Regex pattern to match the string
   * @param digLength minimum length of digits in order to be masked
   * @return `String` masked string
   */
  public static String maskData(
    String input,
    Pattern patToCompile,
    Integer digLength
  ) {
    if (String.isNotBlank(input)) {
      Matcher matchingPattern = patToCompile.matcher(input);
      while (matchingPattern.find()) {
        String stringToMask = matchingPattern.group(0).trim();
        String digits = stringToMask.replaceAll('[^0-9]', '');
        if (digits.length() >= digLength) {
          String masked = '';
          for (Integer i = 0; i < digits.length() - UNMASK_LENGTH; i++) {
            masked = masked + '*';
          }
          masked = masked + digits.substring(digits.length() - UNMASK_LENGTH);
          Integer index = input.indexOf(stringToMask);
          if (index != -1) {
            input =
              input.subString(0, index) +
              masked +
              input.subString(index + stringToMask.length());
          }
          matchingPattern = patToCompile.matcher(input);
        }
      }
    }
    return input;
  }

  /**
   * @description maskData(input) method is used to mask if there are any card numbers in the text.
   * This method masks numbers which are 8 digits or more with spaces or dashes example 4564-6742-8732-8763 is masked as ******8763
   * @param input Input string that needs to be masked if needed
   * @return `String` masked string
   */
  public static String maskData(String input) {
    return maskData(input, accountOrCardPattern, 8);
  }

  /**
   * @description maskDataAnzx method is used to mask if there are any tax numbers in the text.
   * @param input Input string that needs to be masked if needed
   * @return `String` masked string
   */
  public static String maskDataAnzx(String input) {
    return maskData(input, taxPattern, 15);
  }

  /**
   * @description This method determines whether we need to log the content
   * Criteria is if it contains digits of more than 12 digits
   * Or contains keywords like TFN or Tax and has more than 8 digits
   * @param input Input string that we need to verify
   * @return `Boolean` whether we need to log this input
   */
  public static Boolean reactiveLogging(String input) {
    if (String.isBlank(input)) {
      return false;
    }
    String inputUpper = input.toUpperCase();
    List<String> keywords = Label.Reactive_logging_keywords.split(',');
    Boolean hasKeyword = false;
    for (String keyword : keywords) {
      if (inputUpper.contains(keyword)) {
        hasKeyword = true;
        break;
      }
    }
    Pattern patToCompile = logPattern;
    Integer digLength = 12;
    if (hasKeyword) {
      patToCompile = logKeywordPattern;
      digLength = 8;
    }

    Matcher matchingPattern = patToCompile.matcher(input);
    while (matchingPattern.find()) {
      String stringToMask = matchingPattern.group(0).trim();
      String digits = stringToMask.replaceAll('[^0-9]', '');
      if (digits.length() >= digLength) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description This method mask and logs keywords specific data
   * Criteria is if it contains digits of more than 15 digits
   * Or contains keywords like TFN or Tax and has more than 8 digits
   * @param input Input string that we need to verify
   * @param fieldName field name
   * @param record sObject record that contains data
   */
  public static void maskAndLog(
    String input,
    String fieldName,
    SObject record
  ) {
    if (String.isNotBlank(input)) {
      String inputUpper = input.toUpperCase();
      List<String> keywords = Label.Reactive_logging_keywords.split(',');
      Boolean hasKeyword = false;
      for (String keyword : keywords) {
        if (inputUpper.contains(keyword)) {
          hasKeyword = true;
          break;
        }
      }
      Pattern patToCompile = taxPattern;
      Integer digLength = 15;
      if (hasKeyword) {
        patToCompile = logKeywordPattern;
        digLength = 8;
      }
      Matcher matchingPattern = patToCompile.matcher(input);
      while (matchingPattern.find()) {
        String stringToMask = matchingPattern.group(0).trim();
        String digits = stringToMask.replaceAll('[^0-9]', '');
        if (digits.length() >= digLength) {
          String masked = '';
          for (Integer i = 0; i < digits.length() - UNMASK_LENGTH; i++) {
            masked = masked + '*';
          }
          masked = masked + digits.substring(digits.length() - UNMASK_LENGTH);
          Integer index = input.indexOf(stringToMask);
          if (index != -1) {
            input =
              input.subString(0, index) +
              masked +
              input.subString(index + stringToMask.length());
          }
          matchingPattern = patToCompile.matcher(input);
          record.put(fieldName, input);
          if (hasKeyword) {
            Id sfId = (Id) record.get('Id');
            String loggerInitialString = sfId != null
              ? sfId.getSObjectType().getDescribe().getName() == 'Case'
                  ? 'CaseNumber: ' + (String) record.get('CaseNumber') + '; '
                  : 'Id: ' + (Id) record.get('Id') + '; '
              : '';
            Logger.info(
              loggerInitialString +
              fieldName +
              ': ' +
              (String) record.get(fieldName) +
              '; Reason for logging: User entered long digits without needing to mask'
            );
            Logger.saveLog();
          }
        }
      }
    }
  }

  /**
   * @description maskSObjectData(records, fieldApiName) method is used to mask data of a given text field from a list of records.
   * This method utilizes maskData(input)
   * @param records list of records that need to mask data
   * @param fieldApiName API name of the field to be masked. Must be of type String
   */
  public static void maskSObjectData(
    List<SObject> records,
    String fieldApiName
  ) {
    for (SObject obj : records) {
      Object value = obj.get(fieldApiName);
      if (value != null && value instanceof String) {
        obj.put(fieldApiName, maskData(value.toString()));
      }
    }
  }
}
