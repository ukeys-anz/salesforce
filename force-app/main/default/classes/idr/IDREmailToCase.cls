/**
 *
 * @author Afreen
 * @since 01/2021
 * @description Process IDR case orginated from emails
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDREmailToCase {
  /**
   * @description entry method for any email cases to be processed
   * @param records List of cases in current context
   */
  public static void processEmail(List<Case> records) {
    for (Case caseRecord : records) {
      if (caseRecord.SuppliedEmail == System.Label.ANZ_com_Sender_Address) {
        parseWebFormEmail(caseRecord);
      }
    }
  }

  /**
   * @description Parses the cases generated from Anz.com complaint/feedback webform
   * @param c Single Case record
   */
  public static void parseWebFormEmail(Case c) {
    c.Origin = '8'; // anz.com
    String emailBody = c.Description.trim();
    emailBody = emailBody.removeStart('[');
    emailBody = emailBody.replaceAll(
      'This e-mail and any attachments to it \\(the "Communication"\\) is, unless otherwise stated, confidential, may contain copyright material and is for the use only of the intended.+',
      ''
    );
    emailBody = emailBody.trim();
    emailBody = emailBody.removeEnd(']');

    List<String> fieldList = emailBody.split('\\|-\\|');
    if (fieldList.isEmpty()) {
      Logger.error('Anz.com email parsing error');
      Logger.saveLog();
    } else {
      for (String field : fieldList) {
        List<String> fieldValueList = field.split(':-:', 2);
        String fieldName = fieldValueList[0].trim();
        String fieldValue = (fieldValueList.size() > 1
          ? fieldValueList[1].trim()
          : ''); //replacing the trailing spaces
        fieldValue = fieldValue.replaceFirst('^[ \t]+', ''); //replacing the leading spaces

        if (IDRConstants.anzComFieldMapping.containsKey(fieldName)) {
          if (
            fieldName == 'Issue Type' &&
            IDRConstants.anzComIssueTypeMapping.containsKey(fieldValue)
          ) {
            c.put(
              IDRConstants.anzComFieldMapping.get(fieldName),
              IDRConstants.anzComIssueTypeMapping.get(fieldValue)
            );
            c.Priority = IDRConstants.ANZ_COM_PRIORITY_ISSUES.contains(
                fieldValue
              )
              ? ''
              : IDRConstants.CASE_PRIORITY_STANDARD;
          } else if (fieldName == 'Email') {
            List<String> emailValues = fieldValue.split('<', 2);
            c.put(
              IDRConstants.anzComFieldMapping.get(fieldName),
              emailValues[0]
            );
          } else {
            c.put(IDRConstants.anzComFieldMapping.get(fieldName), fieldValue);
          }
        }
      }
      String countryValue = String.valueOf(c.get('IDR_NC_Country__c'));
      List<String> countryAcceptableValues = getPickListValuesIntoList();
      if (
        countryValue == 'Please select' ||
        (countryAcceptableValues != null &&
        countryAcceptableValues.size() > 0 &&
        !countryAcceptableValues.contains(countryValue))
      ) {
        c.put('IDR_NC_Country__c', 'Australia');
      }
      String productCategoryValue = String.valueOf(
        c.get('IDR_Product_Category__c')
      );
      if (productCategoryValue == 'Please select') {
        c.put('IDR_Product_Category__c', 'Not product related');
      }
    }
  }

  /**
   * @description To get the picklist values for the Country field of Case object.
   * @return pickListValuesList
   */
  public static List<String> getPickListValuesIntoList() {
    List<String> pickListValuesList = new List<String>();
    Schema.DescribeFieldResult fieldResult = Case.IDR_NC_Country__c.getDescribe();
    List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : pickListEntry) {
      if (pickListVal.isActive()) {
        pickListValuesList.add(pickListVal.getValue());
      }
    }
    return pickListValuesList;
  }
}
