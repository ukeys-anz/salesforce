/**
 * @author Naman Garg
 * @since  Nov 2024
 * @description This is the action class for CommercialOpportunityTriggerHandler
 */
public with sharing class CommercialOpportunityActions {
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of Opportunity records
   * @param oldMap Map of old Opportunity records
   */
  public static void restrictImagesInRichTextFields(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    try {
      List<SObjectField> fieldList = Schema.SObjectType.Opportunity.fields.getMap()
        .values();
      Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
        fieldList
      );
      CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
    } catch (Exception e) {
      Logger.error('Error while restrict images on Opportunity', e).save();
    }
  }
}
