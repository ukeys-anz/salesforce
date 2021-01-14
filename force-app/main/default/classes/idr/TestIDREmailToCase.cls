@isTest
public with sharing class TestIDREmailToCase {
  @isTest
  static void testANZComCaseParsing() {
    Case c = new Case();
    c.recordTypeId = IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID;
    c.SuppliedEmail = IDRConstants.ANZ_COM_SUPPLIED_EMAIL;
    c.Description = 'This feedback is a: Complaint,  \n\nPreviously raised?: Yes,  \n\nWhich product: Credit card,  \n\nFeedback topic: Credit card/Loan assessment,  \n\nFeedback summary: I have been making inquiries into my credit rating.I discovered that there were missed payments back from Jan 2019 to Jul  2019.I have been told that although ANZ tried to unsuccessfully contact me and that my rating cannot be returned.However, I have looked further through my records and have discovered that I was actually paying into a recently 2019 closed account as per the periodic statements.This is documented on my other bank statements and thus I would have assumed my debits were in order.I had scheduled to pay 34.00 a day and thus over the 3 months that would have equated to 3 000.I would like this again to be looked into as clearly there was some problem as the amount of money in the account as to where I was paying this was in a healthy situation to pay.Please contact me asap,  \n\nDetails and outcome: I want my excellent credit rating back as this has caused great personal problems and do not want this affecting my credit in years to come.,  \n\nContact preference: Phone,  \n\nANZ Customer?: Yes,  \n\nFirst name: ********,\n\nLast name: ********,  \n\nContact number: 04*******9,  \n\nEmail address: *******2@yahoo.com.au,  \n\nStreet address:**, ********** ave,  \n\nSuburb: BALGOWLAH HEIGHTS,  \n\nPostcode: 2093,  \n\nCountry: Australia]';
    insert c;

    Case queriedCase = [SELECT Id, Type FROM Case LIMIT 1];
    System.assertEquals('Credit assessment', queriedCase.Type);
  }
}
