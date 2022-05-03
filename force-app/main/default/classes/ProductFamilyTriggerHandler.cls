/**
 * @author Adnan
 * @since 04/2022
 * @description  ProductFamilyTriggerHandler is the handler class for Product Family Trigger which extends Lib_TriggerHandler the trigger framework used.
 * We are checking recursion in after update so that update doesnt get called repeatedly for the same transaction.
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 */
public with sharing class ProductFamilyTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public ProductFamilyTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    updateUniqueProductIndicator();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @param mpOldProductFamilies old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> mpOldProductFamilies) {
    updateUniqueProductIndicator();
  }

  private void updateUniqueProductIndicator() {
    for (Product_Family__c pf : (List<Product_Family__c>) records) {
      pf.IDR_ANZ_com_Unique_Product_Indicator__c = pf.IDR_ANZ_com_Product_Category__c;
    }
  }
}
