/**
 * @author       : Naman Garg
 * @since        : Feb 2025
 * @description  : CommercialCOIActions is the actions class for CommercialCOIActions.
 **/

public with sharing class CommercialCOIActions {
  /**
   * @description : It will populate the Name field on COI
   * @name : populateCOINameOnInsert
   * @param records List of COI records
   */
  public static void populateCOINameOnInsert(
    List<Circle_Of_Influence__c> records
  ) {
    for (Circle_Of_Influence__c coiRecord : records) {
      if (String.isBlank(coiRecord.First_Name__c)) {
        coiRecord.Name = coiRecord.Last_Name__c;
        continue;
      }
      coiRecord.Name = coiRecord.First_Name__c + ' ' + coiRecord.Last_Name__c;
    }
  }

  /**
   * @description : It will populate the Name field on COI
   * @name : populateCOINameOnUpdate
   * @param records List of COI records
   * @param oldMap Map of old COI records
   */
  public static void populateCOINameOnUpdate(
    List<Circle_Of_Influence__c> records,
    Map<Id, Circle_Of_Influence__c> oldMap
  ) {
    List<Circle_Of_Influence__c> filteredCOIRecords = ListUtil.filter(records)
      .changed(Circle_Of_Influence__c.Name__c)
      .toList();

    for (Circle_Of_Influence__c coiRecord : filteredCOIRecords) {
      coiRecord.Name = coiRecord.Name__c;
    }
  }
}
