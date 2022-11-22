/**
 * @author Olivier Saier
 * @since 10/2021
 * @group CCRM (Commercial CRM)
 * @description AbnAcnUtil is the utilitary class to check ABN and ACN are correctly formatted
 * @runTests AbnAcnUtilTest
 */
public with sharing class AbnAcnUtil {
  private static final String ABN_11_DIGIT_VALIDATION_ERROR = 'ABN should be 11 digits, optionally with spaces as separators.';
  private static final String ACN_9_DIGIT_VALIDATION_ERROR = 'ACN should be 9 digits, optionally with spaces as separators.';
  private static final String ARBN_9_DIGIT_VALIDATION_ERROR = 'ARBN should be 9 digits, optionally with spaces as separators.';
  private static final String ABN_NOT_VALID_ERROR = ' is not a valid ABN.';
  private static final String ACN_NOT_VALID_ERROR = ' is not a valid ACN.';
  private static final String REGEX_ACN = '^(\\d *){9}$';
  /**
   * @description Check if the lead's ABN is valid and if so, format it to the recommended pattern
   * @name validateABN
   * @param records leads to check
   * @param oldMap contains the map which holds the previous values of lead record
   */
  public static void validateABN(Lead[] records, Map<Id, Lead> oldMap) {
    for (Lead record : records) {
      if (isABNValueEntered(record, oldMap?.get(record.Id))) {
        validateAndFormatRecordABN(record, 'ABN__c');
      }
    }
  }

  /**
   * @description Check if the lead's ACN is valid and if so, format it to the recommended pattern
   * @name validateACN
   * @param records leads to check
   * @param oldMap contains the map which holds the previous values of lead record
   */
  public static void validateACN(Lead[] records, Map<Id, Lead> oldMap) {
    for (Lead record : records) {
      if (isACNValueEntered(record, oldMap?.get(record.Id))) {
        validateAndFormatRecordACN(record, 'ACN__c');
      }
    }
  }

  /**
   * @description Validate ABN format of a single record, then format if it's valid, otherwise raise error
   * @name validateAndFormatRecordABN
   * @param record record to check
   * @param fieldName the API name of the ABN field on record
   */
  public static void validateAndFormatRecordABN(
    SObject record,
    String fieldName
  ) {
    try {
      record.put(fieldName, formatABN((String) record.get(fieldName)));
    } catch (Exception e) {
      record.addError(fieldName, e.getMessage());
    }
  }

  /**
   * @description Validate ACN format of a single record, then format if it's valid, otherwise raise error
   * @name validateAndFormatRecordACN
   * @param record record to check
   * @param fieldName the API name of the ACN field on record
   */
  public static void validateAndFormatRecordACN(
    SObject record,
    String fieldName
  ) {
    try {
      record.put(fieldName, formatACN((String) record.get(fieldName)));
    } catch (Exception e) {
      record.addError(fieldName, e.getMessage());
    }
  }

  /**
   * @description Validate ARBN format of a single record, then format if it's valid, otherwise raise error
   * @name validateAndFormatRecordARBN
   * @param record record to check
   * @param fieldName the API name of the ARBN field on record
   */
  public static void validateAndFormatRecordARBN(
    SObject record,
    String fieldName
  ) {
    try {
      record.put(fieldName, formatARBN((String) record.get(fieldName)));
    } catch (Exception e) {
      record.addError(fieldName, e.getMessage());
    }
  }

  /**
   * @description Check if the lead's ABN is added or changed
   * @param record lead record from the trigger
   * @param oldRec lead record with previous values from the trigger
   * @return true is valid, false otherwise
   */
  public static Boolean isABNValueEntered(Lead record, Lead oldRec) {
    if (
      String.isNotBlank(record.ABN__c) &&
      (oldRec == null ||
      record.ABN__c != oldRec.ABN__c ||
      oldRec.Not_Registered__c)
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if the lead's ACN is added or changed
   * @param record lead record from the trigger
   * @param oldRec lead record with previous values from the trigger
   * @return true is valid, false otherwise
   */
  public static Boolean isACNValueEntered(Lead record, Lead oldRec) {
    if (
      String.isNotBlank(record.ACN__c) &&
      (oldRec == null ||
      record.ACN__c != oldRec.ACN__c ||
      oldRec.Not_Registered__c)
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Check if the ABN is valid as per https://abr.business.gov.au/Help/AbnFormat.
   * @name validateAbnString
   * @param abn the ABN to check
   * @return error message if ABN is invalid, null otherwise
   */
  private static String validateAbnString(String abn) {
    if (!Pattern.matches('^(\\d *){11}$', abn)) {
      return ABN_11_DIGIT_VALIDATION_ERROR;
    }
    Integer[] weight = new List<Integer>{
      10,
      1,
      3,
      5,
      7,
      9,
      11,
      13,
      15,
      17,
      19
    };
    // remove spaces and split into an array of digits
    Integer[] digits = new List<Integer>();
    abn = abn.replace(' ', '');
    for (Integer i = 0; i < 11; i++) {
      digits.add(Integer.valueOf(abn.substring(i, i + 1)));
    }
    //Subtract 1 from the first (left-most) digit of the ABN to give a new 11 digit number
    digits[0] = digits[0] - 1;
    //Multiply each of the digits in this new number by a "weighting factor" based on its position
    for (Integer i = 0; i < 11; i++) {
      digits[i] = digits[i] * weight[i];
    }
    //Sum the resulting 11 products
    Integer sum = 0;
    for (Integer d : digits) {
      sum += d;
    }
    //Divide the sum total by 89, if the remainder is zero the number is a valid ABN
    return math.mod(sum, 89) == 0 ? null : (abn + ABN_NOT_VALID_ERROR);
  }

  /**
   * @description Properly format the ABN
   * @name formatABN
   * @param abn the ABN to format
   * @return the formatted ABN
   */
  private static String formatABN(String abn) {
    String error = validateAbnString(abn);
    if (error != null) {
      throw new AbnAcnArbnValidationException(error);
    }
    if (!Pattern.matches('^\\d{2} \\d{3} \\d{3} \\d{3}$', abn)) {
      abn = abn.replace(' ', '');
      abn =
        abn.substring(0, 2) +
        ' ' +
        abn.substring(2, 5) +
        ' ' +
        abn.substring(5, 8) +
        ' ' +
        abn.substring(8, 11);
    }
    return abn;
  }

  /**
   * @description Check if the ACN is valid as per https://asic.gov.au/for-business/registering-a-company/steps-to-register-a-company/australian-company-numbers/australian-company-number-digit-check/
   * @name validateAcnString
   * @param acn the ACN to check
   * @return error message if ABN is invalid, null otherwise
   */
  private static String validateAcnString(String acn) {
    if (!Pattern.matches(REGEX_ACN, acn)) {
      return ACN_9_DIGIT_VALIDATION_ERROR;
    }
    Integer[] weight = new List<Integer>{ 8, 7, 6, 5, 4, 3, 2, 1 };
    // remove spaces and split into an array of digits
    Integer[] digits = new List<Integer>();
    acn = acn.replace(' ', '');
    for (Integer i = 0; i < 9; i++) {
      digits.add(Integer.valueOf(acn.substring(i, i + 1)));
    }
    //Multiply each of the 8 first digits in this new number by a "weighting factor" based on its position
    for (Integer i = 0; i < 8; i++) {
      digits[i] = digits[i] * weight[i];
    }
    //Sum the products
    Integer sum = 0;
    for (Integer i = 0; i < 8; i++) {
      sum += digits[i];
    }
    //Divide by 10 to obtain remainder, Complement the remainder to 10, If the complement equals 10, set it to 0.
    Integer check = 10 - Math.mod(sum, 10) == 10 ? 0 : 10 - Math.mod(sum, 10);
    //Based on these calculations, the calculated check digit equals the check (last) digit if valid
    return check == digits[8] ? null : (acn + ACN_NOT_VALID_ERROR);
  }

  /**
   * @description Properly format the ACN by adding space separators
   * @name formatACN
   * @param acn the ACN to format
   * @return the formatted ACN
   */
  private static String formatACN(String acn) {
    String error = validateAcnString(acn);
    if (error != null) {
      throw new AbnAcnArbnValidationException(error);
    }
    if (!Pattern.matches('^\\d{3} \\d{3} \\d{3}$', acn)) {
      acn = acn.replace(' ', '');
      acn =
        acn.substring(0, 3) +
        ' ' +
        acn.substring(3, 6) +
        ' ' +
        acn.substring(6, 9);
    }
    return acn;
  }

  /**
   * @description Properly format the ARBN by adding space separators
   * @name formatARBN
   * @param arbn the ARBN to format
   * @return the formatted ARBN
   */
  private static String formatARBN(String arbn) {
    if (!Pattern.matches(REGEX_ACN, arbn)) {
      throw new AbnAcnArbnValidationException(ARBN_9_DIGIT_VALIDATION_ERROR);
    }
    if (!Pattern.matches('^\\d{3} \\d{3} \\d{3}$', arbn)) {
      arbn = arbn.replace(' ', '');
      arbn =
        arbn.substring(0, 3) +
        ' ' +
        arbn.substring(3, 6) +
        ' ' +
        arbn.substring(6, 9);
    }
    return arbn;
  }

  private class AbnAcnArbnValidationException extends Exception {
  }
}
