/**
 * @author Batya Aisman Sufrin
 * @since 03/2025
 * @description FraudXCaseActions class is to handle all the Fraud Cases (Fraud, Identity, Recipient/Mule and Scam) Actions
 */
public with sharing class FraudXCaseActions {
  /**
   * @description This method populates subject on Fraud cases based on Record Type and Type
   * @param records Case record from trigger
   * @param oldMap old trigger values
   */
  public static void populateFraudXCaseSubject(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    Set<SObjectField> fieldsToTrack = new Set<SObjectField>{
      Case.Type,
      Case.RecordTypeId
    };
    List<Case> filteredCases = ListUtil.filter(records, oldMap)
      .anyChanged(fieldsToTrack)
      .isNotNull(Case.Type)
      .toList();

    if (filteredCases.isEmpty()) {
      return;
    }

    Map<String, String> caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
      Case.Type
    );

    for (Case record : filteredCases) {
      String rtName = RTCase.get(record.RecordTypeId).Name;
      String label = caseTypeLabelByValue.get(record.Type);
      record.Subject = rtName + ' - ' + label;
    }
  }
}
