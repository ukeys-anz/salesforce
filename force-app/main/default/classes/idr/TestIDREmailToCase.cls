@isTest
public with sharing class TestIDREmailToCase {
  @isTest
  static void testANZComCaseParsing() {
    Test.startTest();
    List<Case> caseList = new List<Case>();
    for (Integer i = 0; i <= Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case c = new Case();
      c.recordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID;
      c.SuppliedEmail = System.Label.ANZ_com_Sender_Address;
      c.Description = 'This feedback is a:-: Complaint|-|  \n\nPreviously raised?:-: Yes|-|  \n\nWhich product:-: Credit card|-|  \n\nFeedback topic:-: Credit card/Loan assessment|-|  \n\nFeedback summary:-: Test Description|-|  \n\nDetails and outcome:-: I want my excellent credit rating back as this has caused great personal problems and do not want this affecting my credit in years to come.|-|  \n\nContact preference:-: Phone|-|  \n\nANZ Customer?:-: Yes|-|  \n\nFirst name:-: MARY|-|  \n\nLast name:-: JOHN|-|  \n\nContact number:-: 043456732|-|  \n\nEmail address:-: TEST2@yahoo.com.au|-|  \n\nStreet address:-: 5 COUNTRY ROAD|-|  \n\nSuburb:-: BALGOWLAH HEIGHTS|-|  \n\nPostcode:-: 2093|-|  \n\nCountry:-: Australia]';

      caseList.add(c);
    }
      
    IDREmailToCase.processEmail(caseList);  

    insert caseList;

    Case queriedCase = [SELECT Id, Type FROM Case LIMIT 1];
    System.assertEquals('Credit assessment', queriedCase.Type, 'Case Type is not correct');
    Test.stopTest();

  }
}