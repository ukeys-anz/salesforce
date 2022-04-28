/**
 * @author Adnan
 * @since  April 2022
 * @description This is a test class for Product Family Trigger and Handler.
 */
@isTest
public with sharing class ProductFamilyTriggerHandlerTest {
  @isTest
  static void createProductFamilyRecordsTest() {
    //Retrieve all ANZ.com product category picklist values
    List<String> anzComProductCategoryList = new List<String>();
    for (
      Schema.PicklistEntry f : (Product_Family__c.IDR_ANZ_com_Product_Category__c.getDescribe())
        .getPicklistValues()
    ) {
      anzComProductCategoryList.add(f.getValue());
    }
    List<String> idrWorkBasketList = new List<String>();

    for (
      Schema.PicklistEntry f : (Product_Family__c.IDR_Workbasket__c.getDescribe())
        .getPicklistValues()
    ) {
      idrWorkBasketList.add(f.getValue());
    }
    List<Product_Family__c> productFamilyList = new List<Product_Family__c>();
    for (String anzComProductCategory : anzComProductCategoryList) {
      Product_Family__c pf = new Product_Family__c();
      pf.Name = 'Testpf ' + anzComProductCategory;
      pf.IDR_ANZ_com_Product_Category__c = anzComProductCategory;
      pf.IDR_Workbasket__c = idrWorkBasketList[0];
      productFamilyList.add(pf);
    }
    Test.startTest();
    insert productFamilyList;
    Test.stopTest();
    System.assertEquals(
      [SELECT id, Name FROM Product_Family__c].size() > 0,
      true,
      'Incorrect or no product family records were retrieved'
    );
  }
}
