/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : This is the action class for CommercialLeadTriggerHandler
 **/
public with sharing class CommercialLeadActions {
  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @description : It will restrict the user to upload images in rich text fields
   * @name : restrictImagesInRichTextFields
   * @param records List of Lead records
   * @param oldMap Map of old Lead records
   */
  public static void restrictImagesInRichTextFields(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    try {
      List<SObjectField> fieldList = Schema.SObjectType.Lead.fields.getMap()
        .values();
      Set<SObjectField> richTextFieldSet = CommercialCommonUtil.getRichTextFields(
        fieldList
      );
      CommercialCommonUtil.restrictImages(records, oldMap, richTextFieldSet);
    } catch (Exception e) {
      Logger.error('Error while restrict images on Lead', e).save();
    }
  }
}
