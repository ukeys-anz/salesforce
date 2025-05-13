/**
 * @author Naman Garg
 * @since April'25
 * @description CommercialCppActionsTest is test class for CommercialCppActions
 */
@isTest
public with sharing class CommercialCppActionsTest {
  static Lib_MockProvider phoneRepoMock;
  static Lib_MockProvider userRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    phoneRepoMock = Lib_MockProvider.forType(
      ContactPointObjectActionsRepository.class
    );
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static ContactPointPhone getPhoneRecord(Id parentId, String usageType) {
    return new ContactPointPhone(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType),
      UsageType = usageType,
      Customer_Name__c = parentId,
      ParentId = parentId
    );
  }

  @isTest
  static void testValidateUsageType() {
    registerMocks();

    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<ContactPointPhone> phoneRecords = new List<ContactPointPhone>{
      getPhoneRecord(accountId, 'Security Mobile')
    };

    Test.startTest();
    CommercialCppActions.validateUsageType(phoneRecords);
    Test.stopTest();

    Assert.areEqual(
      CommercialCppActions.NOT_ALLOWED_USAGE_TYPE_ERROR,
      phoneRecords[0].getErrors()[0].getMessage(),
      'User is able to add security Mobile on Contact Point Phone records.'
    );
  }

  @isTest
  static void testPreventEdit() {
    registerMocks();

    Id cppId = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType);
    List<ContactPointPhone> cppList = new List<ContactPointPhone>{
      new ContactPointPhone(Id = cppId, Usagetype = 'Business Phone')
    };

    Map<Id, ContactPointPhone> oldCppMap = new Map<Id, ContactPointPhone>{
      cppId => new ContactPointPhone(Id = cppId, Usagetype = 'Mobile Telephone')
    };

    Test.startTest();
    CommercialCppActions.preventEdit(cppList, oldCppMap);
    Test.stopTest();

    Assert.areEqual(
      CommercialCppActions.USAGE_TYPE_CHANGE_ERROR,
      cppList[0].getErrors()[0].getMessage(),
      'User is able to update Usage Type on Contact Point Phone records.'
    );
  }
}
