/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Common logic for Commercials
 **/

public with sharing class CommercialCommonUtil {
  public static final String RESTRICT_IMAGE_TEXT = 'Images cannot be attached.';

  /**
   * @description It will fetch the list of Rich Text fields
   * @name getRichTextFields
   * @param fieldList List of all Sobject
   * @return Set<SObjectField> Set of SObjectField containing the Rich Text fields
   */
  public static Set<SObjectField> getRichTextFields(
    List<SObjectField> fieldList
  ) {
    Set<SobjectField> richTextFieldSet = new Set<SobjectField>();
    for (SObjectField field : fieldList) {
      if (field.getDescribe().isHTMLformatted()) {
        richTextFieldSet.add(field);
      }
    }
    return richTextFieldSet;
  }

  /**
   * @description It will restrict user to attach image in Rich Text fields
   * @name restrictImages
   * @param recordsList list of Sobject records
   * @param oldMap map of Sobject records
   * @param richTextFieldSet Set of string containing the Rich Text fields
   */
  public static void restrictImages(
    List<Sobject> recordsList,
    Map<Id, Sobject> oldMap,
    Set<SObjectField> richTextFieldSet
  ) {
    if (richTextFieldSet.isEmpty()) {
      return;
    }
    for (Sobject newRec : recordsList) {
      Sobject oldRec = oldMap?.get(newRec.Id);
      for (SObjectField field : richTextFieldSet) {
        if (newRec.get(field) == oldRec?.get(field)) {
          continue;
        }
        if (
          newRec.get(field) != null &&
          String.valueOf(newRec.get(field)).contains('<img')
        ) {
          newRec.addError(field, RESTRICT_IMAGE_TEXT);
        }
      }
    }
  }
}
