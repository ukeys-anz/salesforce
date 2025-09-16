/**
 * @author       : Naman Garg
 * @since        : July 2025
 * @description  : This is actions class for CommercialCRTriggerHandler
 **/
public with sharing class CommercialCRActions {
  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of customer relationship records
   * @param oldMap Map of old customer relationship records
   */
  public static void restrictImagesInRichTextFields(
    List<Customer_Relationship__c> records,
    Map<Id, Customer_Relationship__c> oldMap
  ) {
    List<SObjectField> fieldList = Schema.SObjectType.Customer_Relationship__c.fields.getMap()
      .values();
    Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
      fieldList
    );
    CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
  }

  /**
   * @description : It will used to auto create Interaction
   * @name autoCreateInteraction
   * @param records List of customer relationship records
   * @param oldMap Map of old customer relationship records
   */
  public static void autoCreateInteraction(
    List<Customer_Relationship__c> records,
    Map<Id, Customer_Relationship__c> oldMap
  ) {
    List<Customer_Relationship__c> filteredCRRecords = ListUtil.filter(
        records,
        oldMap
      )
      .changedTo(Customer_Relationship__c.Status__c, 'Inactive')
      .toList();

    List<Interaction> interactionToInsert = formInteractionList(
      filteredCRRecords
    );

    DML_REPO.doInsert(interactionToInsert);
  }

  /**
   * @description : It will used to form Interaction List
   * @name formInteractionList
   * @param filteredCRRecords List of filtered customer relationship records
   * @return List<Interaction> List of interactions records
   */
  @TestVisible
  private static List<Interaction> formInteractionList(
    List<Customer_Relationship__c> filteredCRRecords
  ) {
    List<Interaction> interactionList = new List<Interaction>();
    for (Customer_Relationship__c crRecord : filteredCRRecords) {
      Interaction interactionRec = new Interaction();
      interactionRec.Name = 'Customer Relationship';
      interactionRec.Category__c = 'General';
      interactionRec.Interaction_Type__c = 'Existing Relationship Building';
      interactionRec.InteractionType = 'Annual Review';
      interactionRec.StartTime = System.Now();
      interactionRec.RecordTypeId = RTInteraction.commercialInteraction;
      interactionRec.Customer_Relationship__c = crRecord.Id;
      interactionList.add(interactionRec);
    }
    return interactionList;
  }
}
