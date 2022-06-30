/**
 * @author Boobalakrishnan Duraisamy
 * @since 12/2020
 * @description  To test ContentDocumentLinkTriggerHandler
 */
@isTest
public class ContentDocumentLinkTriggerHandlerTest {
  /**
   * @description Test data setup required for this test class
   */
  @testSetup
  static void setup() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];
    User idrUser = new User(
      Alias = 'idruse',
      Email = 'idruser@anztest.com',
      LastName = 'Testing',
      ProfileId = p.Id,
      UserName = 'idruser@anztest.com',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      Division = 'IDR Test Office',
      isActive = true
    );
    insert idrUser;
    //Create Case
    Case testCase = new Case();

    testCase.IDR_Account_Card_Policy_Number__c = '000001234';
    testCase.Description = 'Test decription';
    testCase.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    testCase.IDR_Customer_Number__c = '1234567890';
    testCase.Status = IDRConstants.OPEN_STATUS;
    testCase.OwnerId = idrUser.Id;
    insert testCase;

    //Create user
    User usr = (User) FakerFactory.make(new FakerUserFactory());
    usr.ProfileId = p.Id;
    usr.Business_Function__c = 'CMOS';
    usr.Business_Role__c = 'Customer Resolution';
    insert usr;
  }
  /**
   * @description Test whether the case flag is updated when another user adds a file in case record
   */
  @isTest
  static void testContentDocumentNotification() {
    List<User> usrlist = [SELECT id FROM User];

    System.runAs(usrlist[0]) {
      //Given a complaint case record
      Case testCase = [SELECT Id FROM Case LIMIT 1];

      Test.startTest();
      //When another user adds a file attachment
      //Create a file
      ContentVersion cv = new ContentVersion();
      cv.Title = 'Test File Delete';
      cv.PathOnClient = 'Test File Delete' + '.txt';
      cv.VersionData = Blob.valueOf('Test File Delete functionality');

      insert cv;

      // retrieve file to create an association with case
      ContentDocument cd = [SELECT id FROM ContentDocument LIMIT 1];

      // insert Content document link
      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.ContentDocumentId = cd.Id;
      cdl.LinkedEntityId = testCase.Id;
      cdl.ShareType = 'V';
      cdl.Visibility = 'AllUsers';
      insert cdl;

      Test.stopTest();

      //assert to validate document link with case
      List<ContentDocumentLink> cdList = [
        SELECT Id, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :testCase.Id
      ];
      System.assertEquals(
        testCase.Id,
        cdList[0].LinkedEntityId,
        'The content document link Id should be as expected.'
      );
    }
  }
}
