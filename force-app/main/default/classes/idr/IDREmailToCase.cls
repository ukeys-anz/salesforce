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
      '"This e-mail and any attachments to it \\(the "Communication"\\) is, unless otherwise stated, confidential, may contain copyright material and is for the use only of the intended.+',
      ''
    );
    emailBody = emailBody.trim();
    emailBody = emailBody.removeEnd(']');

    List<String> fieldList = emailBody.split('\\|-\\|');
    if (fieldList.isEmpty()) {
      Lib_SystemLog.createSingleLog(
        IDREmailToCase.class.getName(),
        'parseWebFormEmail',
        '',
        'Anz.com email parsing error',
        Lib_SystemLog.Severity.Fatal
      );
    } else {
      for (String field : fieldList) {
        List<String> fieldValueList = field.split(':-:', 2);
        String fieldName = fieldValueList[0].trim();
        String fieldValue = (fieldValueList.size() > 1
          ? fieldValueList[1].trim()
          : ''); //replacing the trailing spaces
        fieldValue = fieldValue.replaceFirst('^[ \t]+', ''); //replacing the leading spaces

        if (IDRConstants.anzComFieldMapping.containsKey(fieldName)) {
          if (fieldName == 'Email') {
            List<String> emailValues = fieldValue.split('<', 2);
            c.put(
              IDRConstants.anzComFieldMapping.get(fieldName),
              emailValues[0]
            );
          } else if(fieldName == 'Date'){
            if(fieldValue != '' && fieldValue != null){
              c.put(IDRConstants.anzComFieldMapping.get(fieldName), DateTime.parse(fieldValue));
            }      
          } else {
            c.put(IDRConstants.anzComFieldMapping.get(fieldName), fieldValue);
          }
        }
      }
    }
  }
}
