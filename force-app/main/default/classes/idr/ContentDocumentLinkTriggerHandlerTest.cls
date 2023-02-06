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
      Email = 'idruser@anz.com',
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
  /**
   * @description Test the link deletion.
   */
  @isTest
  static void testContentDocumentDelete() {
    List<User> usrlist = [SELECT id FROM User];

    System.runAs(usrlist[0]) {
      //Given a complaint case record
      Case testCase = [SELECT Id, SuppliedEmail, Origin, Description, IDR_NC_Country__c, IDR_Product_Category__c FROM Case LIMIT 1];

      Test.startTest();
      testCase.SuppliedEmail = System.Label.ANZ_com_Sender_Address;
      testCase.Origin = '8'; // anz.com
      testCase.Description = '[Issue Type :-: Service quality \\|-\\|  Subsequent Issue Type :-: Tone or manner of response \\|-\\| ';
      update testCase;
      
      List<Case> caseList = new List<Case>();
      caseList.add(testCase);
      IDREmailToCase.processEmail(caseList);
      
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
      delete cdl;

      Test.stopTest();

      //assert to validate document link with case
      List<ContentDocumentLink> cdList = [
        SELECT Id, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :testCase.Id
      ];
      System.assertEquals(0, cdList.size());
    }
  }
  
  @isTest
  static void testCreateCaseCloseNotification() {
    Case testCase = [
      SELECT Id, status, IDR_Description_of_Outcome__c, IDR_Complaint_Outcome__c
      FROM Case
    ];
    test.startTest();
    testCase.Status = 'Closed';
    testCase.IDR_Description_of_Outcome__c = 'Test';
    testCase.IDR_Complaint_Outcome__c = '1';
    testCase.IDR_Is_Common__c = 'No';
    update testCase;
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
    test.stopTest();

    CaseComment cc = [SELECT Id FROM CaseComment WHERE ParentId = :testCase.Id];
    System.assert(cc != null, 'casecomment not created');
  }
}
