/**
 * @author Greg Shaw (shawg2)
 * @since 11/2023
 * @description Test class for LogEntryTriggerHandler
 * @group IDR(Internal Dispute Resolution)
 */

@IsTest
private class LogEntryTriggerHandlerTest {
  @TestSetup
  static void setup() {
    // Create custom setting at user level
    Profile engineerProfile = CommonUtil.getProfileByName(
      'Minimum Access - Salesforce'
    );
    UserRole engineerRole = CommonUtil.getUserRoleByDevName('Engineer');

    // Create global approver user
    User engineerUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'Engineer_Test',
        'ProfileId' => engineerProfile.Id,
        'UserRoleId' => engineerRole.Id
      }
    );
    insert engineerUser;
    // enable the engineer to create Cases
    TestUtil.assignPermissionSetGroups(
      new List<String>{ 'IDR_Level_1' },
      new List<User>{ engineerUser }
    );
    // enable the engineer to create Logs
    TestUtil.assignPermissionSets(
      new List<String>{ 'API_ACCESS_SAF' },
      new List<User>{ engineerUser }
    );

    System.runAs(engineerUser) {
      LoggingSettings__c userCustomSetting = new LoggingSettings__c(
        DefaultSaveMethod__c = 'IMMEDIATE',
        DefaultLoggingLevel__c = 'DEBUG',
        SecureLogEnabled__c = true,
        SetupOwnerId = engineerUser.Id
      );
      insert userCustomSetting;
    }
  }

  private static User getEngineer() {
    return [SELECT Id FROM User WHERE FirstName = 'Engineer_Test' LIMIT 1];
  }

  /**
   * @description delete ContentDocumentLink -> LogEntry__c -> delete ContentDocument
   */
  @IsTest
  static void deleteContentDocuments() {
    ContentDocument cd;
    Case oCase = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      Status = IDRConstants.OPEN_STATUS,
      IsEscalated = false
    );
    System.runAs(getEngineer()) {
      insert oCase;

      ContentVersion cv = new ContentVersion();
      cv.Title = 'Test File Delete';
      cv.PathOnClient = 'Test File Delete' + '.txt';
      cv.VersionData = Blob.valueOf('Test File Delete functionality');

      insert cv;

      // retrieve file to create an association with case
      cd = [SELECT Id FROM ContentDocument LIMIT 1];

      // insert Content document link
      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.ContentDocumentId = cd.Id;
      cdl.LinkedEntityId = oCase.Id;
      cdl.ShareType = 'V';
      cdl.Visibility = 'AllUsers';
      insert cdl;

      delete cdl;

      List<LogEntry__c> lstLogEntries = [
        SELECT
          Id,
          Name,
          CreatedDate,
          ApexClassName__c,
          ApexMethodName__c,
          ExceptionMessage__c,
          LogMessage__c,
          RecordId__c
        FROM LogEntry__c
        WHERE
          ApexClassName__c = 'ContentDocumentLinkTriggerHandler'
          AND ApexMethodName__c = 'logFileDelete'
          AND LogMessage__c LIKE 'Doc Deleted%'
      ];

      System.assertNotEquals(
        null,
        lstLogEntries,
        'There should be at least one LogEntry for the deletion'
      );
      System.assertEquals(
        1,
        lstLogEntries.size(),
        'There should be only one LogEntry for the deletion'
      );

      delete lstLogEntries;

      List<ContentDocument> lstContentDocument = [
        SELECT Id
        FROM ContentDocument
        LIMIT 1
      ];

      System.debug('ContentDocument: ' + lstContentDocument);
      System.assertEquals(
        0,
        lstContentDocument.size(),
        'ContentDocument should be deleted.'
      );
    }
  }
}
