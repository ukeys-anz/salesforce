/**
 *
 * @author Afreen
 * @since 01/2021
 * @description Process IDR case orginated from emails
 */
public with sharing class IDREmailToCase {
  /**
   * @description entry method for any email cases to be processed
   * @param records List of cases in current context
   */
  public static void processEmail(List<Case> records) {
    for (Case caseRecord : records) {
      if (caseRecord.SuppliedEmail == IDRConstants.ANZ_COM_SUPPLIED_EMAIL) {
        parseWebFormEmail(caseRecord);
      }
    }
  }

  /**
   * @description Parses the cases generated from Anz.com complaint/feedback webform
   * @param c Single Case record
   */
  private static void parseWebFormEmail(Case c) {
    String emailBody = c.Description.trim();
    emailBody = emailBody.removeStart('[');
    emailBody = emailBody.removeEnd(']');
    List<String> fieldList = emailBody.split(',  \n\n');

    for (String field : fieldList) {
      List<String> fieldValueList = field.split(':', 2);
      String fieldName = fieldValueList[0];
      String fieldValue = fieldValueList[1].trim(); //replacing the trailing spaces
      fieldValue = fieldValue.replaceFirst('^[ \t]+', ''); //replacing the leading spaces

      if (IDRConstants.ANZ_COM_FIELD_MAPPING.containsKey(fieldName)) {
        if (
          fieldValueList[0] == 'Feedback Topic' &&
          IDRConstants.ANZ_COM_ISSUE_TYPE_MAPPING.containsKey(fieldValue)
        ) {
          c.put(
            IDRConstants.ANZ_COM_FIELD_MAPPING.get(fieldName),
            IDRConstants.ANZ_COM_ISSUE_TYPE_MAPPING.get(fieldValue)
          );
        } else {
          c.put(IDRConstants.ANZ_COM_FIELD_MAPPING.get(fieldName), fieldValue);
        }
      }
    }
  }
}
