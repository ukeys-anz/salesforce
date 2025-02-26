/**
 * @author Ashwin Mohan
 * @since 10/2024
 * @description ContactPointEmailActionTest is the test class for ContactPointEmailActions Class.
 */
@IsTest
public class ContactPointEmailActionsTest {
  static Lib_MockProvider emailRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    emailRepoMock = Lib_MockProvider.forType(
      ContactPointObjectActionsRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testValidateUsageType() {
    setMocks();
    List<ContactPointEmail> emailList = new List<ContactPointEmail>{
      getEmailRecord('Security Email')
    };
    Test.startTest();
    ContactPointEmailActions.validateUsageType(emailList);
    Test.stopTest();

    Assert.areEqual(
      'You are not authorised to add/edit an email other than usage type of \'Email\'.',
      emailList[0].getErrors()[0].getMessage(),
      'validateUsageType is not restricting EmailRecords with usage type not having email'
    );
  }

  @isTest
  static void testPreventEdit() {
    setMocks();
    List<ContactPointEmail> emailRecords = new List<ContactPointEmail>{
      getEmailRecord('Security Email'),
      getEmailRecord('Email'),
      getEmailRecord('Email')
    };

    Map<Id, ContactPointEmail> emailRecordsMap = new Map<Id, ContactPointEmail>();
    emailRecordsMap.put(
      emailRecords[0].Id,
      new ContactPointEmail(
        Id = emailRecords[0].Id,
        Usagetype = 'Security Email'
      )
    );
    emailRecordsMap.put(
      emailRecords[1].Id,
      new ContactPointEmail(
        Id = emailRecords[1].Id,
        Usagetype = 'Business Email'
      )
    );
    emailRecordsMap.put(
      emailRecords[2].Id,
      new ContactPointEmail(Id = emailRecords[2].Id, Usagetype = 'Email')
    );

    Test.startTest();
    ContactPointEmailActions.preventEdit(emailRecords, emailRecordsMap);
    Test.stopTest();

    Assert.areEqual(
      'You are not authorised to add/edit an email other than usage type of \'Email\'.',
      emailRecords[0].getErrors()[0].getMessage(),
      'preventEdit method is allowing to edit Security Email'
    );
    Assert.areEqual(
      'You do not have the necessary privileges to update the usage type',
      emailRecords[1].getErrors()[0].getMessage(),
      'preventEdit method is allowing to edit usage type'
    );
    Assert.areEqual(
      0,
      emailRecords[2].getErrors().size(),
      'preventEdit method is throwing unexpeted error'
    );
  }

  @isTest
  static void testCheckExistingEmailRecords() {
    setMocks();
    List<ContactPointEmail> emailList = new List<ContactPointEmail>{
      getEmailRecord('Security Email')
    };
    emailRepoMock.mock('getExistingEmailRecords', emailList);
    Test.startTest();
    ContactPointEmailActions.checkExistingEmailRecords(
      new List<ContactPointEmail>{ emailList[0] }
    );
    Assert.areEqual(
      'An email record of this type is already available for this customer. Please edit the existing email record for the customer.',
      emailList[0].getErrors()[0].getMessage(),
      'checkExistingEmailRecords is not adding error correctly when same usage type email exists'
    );
    Test.stopTest();
  }

  @isTest
  static void testDeleteExpiredRecords() {
    registerMocks();
    List<ContactPointEmail> emailRecords = new List<ContactPointEmail>{
      new ContactPointEmail(
        Id = Lib_FakeIdGenerator.getMockId(ContactPointEmail.SObjectType),
        ActiveToDate = System.today().addDays(-2)
      )
    };
    Map<Id, ContactPointEmail> oldMap = new Map<Id, ContactPointEmail>{
      emailRecords[0].Id => new ContactPointEmail(
        Id = emailRecords[0].Id,
        ActiveToDate = null
      )
    };
    Test.startTest();
    ContactPointEmailActions.deleteExpiredRecords(emailRecords, oldMap);
    Test.stopTest();
    List<ContactPointEmail> deletedRecords = (List<ContactPointEmail>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      deletedRecords.size(),
      'The inactive email record is not deleted'
    );
  }

  private static void setMocks() {
    registerMocks();
    emailRepoMock.mock('isCurrentLoggedInMLUser', true);
    emailRepoMock.mock('isCustomValidationsSkipped', false);
  }

  private static ContactPointEmail getEmailRecord(String usageType) {
    return new ContactPointEmail(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointEmail.SObjectType),
      UsageType = usageType
    );
  }
}
