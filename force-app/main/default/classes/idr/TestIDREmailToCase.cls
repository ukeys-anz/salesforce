@isTest
public with sharing class TestIDREmailToCase {
  @isTest
  static void testANZComCaseParsing() {
    Schema.DescribeFieldResult productWorkbasketList = Product_Family__c.IDR_Workbasket__c.getDescribe();
    List<Schema.PicklistEntry> workbasketPicklistValues = productWorkbasketList.getPicklistValues();

    Product_Family__c pf = new Product_Family__c(
      Name = 'Product Family1',
      IDR_Workbasket__c = workbasketPicklistValues[0].getValue(),
      IDR_ANZ_com_Product_Category__c = 'Credit Card'
    );

    insert pf;

    Test.startTest();
    List<Case> caseList = new List<Case>();
    for (Integer i = 0; i <= Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case c = new Case();
      c.recordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID;
      c.SuppliedEmail = System.Label.ANZ_com_Sender_Address;
      c.Description = 'Product Category :-: Credit Card|-|  \n\nIssue Type :-: Account set-up & maintenance|-|  \n\nDescription of Issue :-: test|-|  \n\nCustomer Desired Outcome :-: test|-|  \n\nExisting ANZ Customer :-: yes|-|  \n\nCustomer Desired Outcome :-: test|-|  \n\nContact preference:-: Phone|-| Date :-: |-|  \n\nFirst Name:-: MARY|-|  \n\nLast Name:-: JOHN|-|  \n\nPhone:-: 043456732|-|  \n\nEmail:-: TEST2@yahoo.com.au|-|  \n\nStreet Address:-: 5 COUNTRY ROAD|-|  \n\nSuburb:-: BALGOWLAH HEIGHTS|-|  \n\nPostcode:-: 2093|-|  \n\nCountry:-: Australia]';
      caseList.add(c);
    }

    IDREmailToCase.processEmail(caseList);

    insert caseList;
    Test.stopTest();
    Case queriedCase = [
      SELECT
        Id,
        Type,
        IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c,
        IDR_Product_category__c
      FROM Case
      LIMIT 1
    ];
    System.assertEquals('18', queriedCase.Type, 'Case Type is not correct');
    system.assertEquals(
      queriedCase.IDR_Product_category__c,
      queriedCase.IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c,
      'Product family assignment is incorrect'
    );
  }
}
