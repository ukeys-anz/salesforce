/**
 * @author Olivier Saier
 * @since 10/2021
 * @group CCRM (Commercial CRM)
 * @description AbnAcnUtil is the utilitary class to check ABN and ACN are correctly formatted
 */
public with sharing class AbnAcnUtil {
  private static final String ABN_11_DIGIT_VALIDATION_ERROR = 'ABN should be 11 digits, optionally with spaces as separators.';
  private static final String ABN_NOT_VALID_ERROR = ' is not a valid ABN.';
  /**
   * @description Check if the lead's ABN is valid and if so, format it to the recommended pattern
   * @name validateABN
   * @param records leads to check
   * @param oldMap contains the map which holds the previous values of lead record
   */
  public static void validateABN(Lead[] records, Map<Id, Lead> oldMap) {
    for (Lead record : records) {
      Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
      if (isABNValueEntered(record, oldRec)) {
        if (!Pattern.matches('^(\\d *){11}$', record.ABN__c)) {
          record.addError(ABN_11_DIGIT_VALIDATION_ERROR);
        } else if (!isABNValid(record.ABN__c)) {
          record.addError(record.ABN__c + ABN_NOT_VALID_ERROR);
        } else {
          record.ABN__c = formatABN(record.ABN__c);
        }
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
      Lead oldRec = oldMap != null ? oldMap.get(record.id) : new Lead();
      if (isACNValueEntered(record, oldRec)) {
        if (!Pattern.matches('^(\\d *){9}$', record.ACN__c)) {
          record.addError(
            'ACN should be 9 digits, optionally with spaces as separators.'
          );
        } else if (!isACNValid(record.ACN__c)) {
          record.addError(record.ACN__c + ' is not a valid ACN.');
        } else {
          record.ACN__c = formatACN(record.ACN__c);
        }
      }
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
   * The check on 11 digits with or without spaces should be made before calling this method.
   * @name isABNValid
   * @param abn the ABN to check
   * @return true is valid, false otherwise
   */
  private static Boolean isABNValid(String abn) {
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
    return math.mod(sum, 89) == 0;
  }

  /**
   * @description Properly format the ABN
   * @name formatABN
   * @param abn the ABN to format
   * @return the formatted ABN
   */
  private static String formatABN(String abn) {
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
   * The check on 9 digits with or without spaces should be made before calling this method.
   * @name isACNValid
   * @param acn the ACN to check
   * @return true is valid, false otherwise
   */
  private static Boolean isACNValid(String acn) {
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
    return check == digits[8];
  }

  /**
   * @description Properly format the ACN by adding space separators
   * @name formatACN
   * @param acn the ACN to format
   * @return the formatted ACN
   */
  private static String formatACN(String acn) {
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
}
