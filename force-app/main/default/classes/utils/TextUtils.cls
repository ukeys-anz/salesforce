/**
 * @description TextUtils class contains static utility methods to take some actions related to text.
 * @author Pavan Kumar Ananta
 * @since 01/06/2020
 * @group Utils
 * @modified by Shivraj Kadam on 08/28/2023
 */
public with sharing class TextUtils {
  private static final String ACCOUNT_OR_CARD_REGEX_PATTERN = '[0-9][^a-zA-Z]{6,}[0-9]';
  private static final String TAX_REGEX_PATTERN = '[0-9][^a-zA-Z]{13,}[0-9]';
  private static final String LOG_REGEX_PATTERN = '[0-9][^a-zA-Z]{10,}[0-9]';
  private static final String LOG_KEYWORD_REGEX_PATTERN = '[0-9][^a-zA-Z]{6,}[0-9]';
  private static final String SANITISE_MOBILE_NUMBER_REGEX_PATTERN = '[^0-9]';
  private static final Integer UNMASK_LENGTH = 4;

  //start - added for CC-4053
  private static final String EXT_PATTERN_CC = '(?<!\\+)\\b\\d[0-9 -]{13,}\\d\\b';
  private static final String EXT_PATTERN_8PLUSLENGTH_EX_PHONE = '\\b(?<!\\+)\\b\\d(?:[ -]?\\d){7,14}\\b';
  private static final String EXT_PATTERN_PASSPORT = '\\b(?=[A-Za-z]*\\d)(?=\\d*[A-Za-z])[A-Za-z\\d]{6,15}\\b';
  private static Pattern extendRedactCCPattern = Pattern.compile(
    EXT_PATTERN_CC
  );
  private static Pattern extendRedactEightPlusExPhonePattern = Pattern.compile(
    EXT_PATTERN_8PLUSLENGTH_EX_PHONE
  );
  private static Pattern extendRedactPassportPattern = Pattern.compile(
    EXT_PATTERN_PASSPORT
  );
  //end - added for CC-4053

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
    Boolean hasKeyword = regexMatchesKeyword(input);

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
   * @param isLoggingRequired boolean to allow logging
   */
  public static void maskAndLog(
    String input,
    String fieldName,
    SObject record,
    Boolean isLoggingRequired
  ) {
    if (String.isNotBlank(input)) {
      Boolean hasKeyword = regexMatchesKeyword(input);

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
          if (hasKeyword && isLoggingRequired) {
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

  /**
   * @description Remove any non-alphanumeric characters from a string
   * @param nonAlphanumericString A string with non-alphanumeric characters
   * @return String A string without non-alphanumeric characters
   */
  public static String removeNonAlphanumericChar(String nonAlphanumericString) {
    Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
    Matcher matcher = nonAlphanumeric.matcher(nonAlphanumericString);
    return matcher.replaceAll('');
  }

  /**
   * @description checks if keywords for reactive logging label are in an input
   * @param input input to match against
   * @return `Boolean` returns if there was a match
   */
  private static Boolean regexMatchesKeyword(String input) {
    //Replace keywords with pipe to prepare for regex
    String regexWords = Label.Reactive_logging_keywords.replace(',', '|');
    //Regex to match only keyword and ignore whitespace and digits before/after word
    String regex = '(?i)(?<![^\\W\\d])(?:' + regexWords + ')(?![^\\W\\d])';
    Pattern compiledPattern = Pattern.compile(regex);
    Matcher regexMatcher = compiledPattern.matcher(input);
    return regexMatcher.find();
  }

  /**
   * @description CC-4053 Redacting sensitive customer information
   * @param sObjects List of SObjects
   * @param fieldName field name
   */
  public static void maskSObjectDataANZExtended(
    List<SObject> sObjects,
    String fieldName
  ) {
    if (sObjects.isEmpty()) {
      return;
    }
    Set<String> dataTypeNames = new Set<String>{
      'STRING',
      'TEXTAREA',
      'COMBOBOX'
    };
    String dataTypeField = getFieldType(sObjects[0], fieldName);
    for (SObject sObj : sObjects) {
      if (dataTypeNames.contains(dataTypeField)) {
        String originalText = (String) sObj.get(fieldName);
        if (String.isNotBlank(originalText)) {
          sObj.put(fieldName, maskDataANZExtended(originalText));
        }
      }
    }
  }

  /**
   * @description CC-4053 Redacting sensitive customer information
   * @param sObj object record
   * @param fieldName name of the field to get type
   * @return `String` fieldtype
   */
  private static String getFieldType(Sobject sObj, String fieldName) {
    Schema.SObjectType objectType = sObj.getSObjectType();
    Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();

    if (objectDescribe.fields.getMap().containsKey(fieldName)) {
      Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap()
        .get(fieldName)
        .getDescribe();
      return fieldDescribe.getType().name();
    }

    return '';
  }

  /**
   * @description CC-4053 Redacting sensitive customer information
   * @param originalText input text
   * @return `String` redacted string
   */
  private static String maskDataANZExtended(String originalText) {
    String redactedText = maskStringANZExtended(
      originalText,
      extendRedactCCPattern,
      4
    );

    if (regexMatchesKeyword(redactedText) == false) {
      return redactedText;
    }
    redactedText = maskStringANZExtended(
      redactedText,
      extendRedactEightPlusExPhonePattern,
      0
    );

    redactedText = maskStringANZExtended(
      redactedText,
      extendRedactPassportPattern,
      0
    );

    return redactedText;
  }

  /**
   * @description CC-4053 Redacting sensitive customer information
   * @param inputText string to redact
   * @param matchPattern pattern
   * @param unmaskLength unmaskLength
   * @return `String` redacted string
   */
  private static String maskStringANZExtended(
    String inputText,
    Pattern matchPattern,
    Integer unmaskLength
  ) {
    Matcher matcher = matchPattern.matcher(inputText);
    while (matcher.find()) {
      String origMatchedText = matcher.group();
      String matchedText = origMatchedText.remove('-').remove(' ');

      // leave the last X character of the match string unmasked, where X = unmaskedLength
      String redactedText =
        '*'
          .repeat(
            matchedText.substring(0, matchedText.length() - unmaskLength)
              .length()
          ) + matchedText.right(unmaskLength);
      inputText = inputText.replaceFirst(origMatchedText, redactedText);
    }
    return inputText;
  }

  /**
   * @description CC-4053 Redacting sensitive customer information
   * @param sObjects list of records
   * @param recordTypeIds recordtypes ids
   * @return `RecordListWrapper` list of dcrm records and other records
   */
  public static RecordListWrapper checkRecordTypeRedactionMethod(
    List<SObject> sObjects,
    List<Id> recordTypeIds
  ) {
    RecordListWrapper wrapperData = new RecordListWrapper();
    for (SObject sObj : sObjects) {
      if (recordTypeIds.contains((Id) sObj.get('RecordTypeId'))) {
        wrapperData.dcrmRecordList.add(sObj);
      } else {
        wrapperData.recordList.add(sObj);
      }
    }
    return wrapperData;
  }

  /**
   * @description This is the wrapper class for list
   * @param dcrmRecordList list of records related to dcrm
   * @param recordList records other than dcrm list
   */
  public class RecordListWrapper {
    /**
     * @description list of records related to dcrm
     */
    public List<SObject> dcrmRecordList { get; set; }
    /**
     * @description records other than dcrm list
     */
    public List<SObject> recordList { get; set; }
    /**
     * @description constructor
     */
    public RecordListWrapper() {
      dcrmRecordList = new List<SObject>();
      recordList = new List<SObject>();
    }
  }    

  /** 
   * @description sanitiseStringBasedOnPattern remove unexpected chars base on regex pattern=
   * @param input Input string that we need to sanitise
   * @param regexPattern the regex pattern uses to sanitise
   * @return `String` sanitised string
   */
  public static String sanitiseStringBasedOnPattern(
    String input,
    String regexPattern
  ) {
    if (String.isEmpty(input)) {
      return input;
    }
    return input.replaceAll(regexPattern, '');
  }

  /**
   * @description sanitiseMobileNumber remove unexpected chars of mobile number base on sanitise mobile regex pattern
   * @param input Input mobile number that we need to sanitise
   * @return `String` sanitised mobile number
   */
  public static String sanitiseMobileNumber(String input) {
    return sanitiseStringBasedOnPattern(
      input,
      SANITISE_MOBILE_NUMBER_REGEX_PATTERN
    );
  }
}
