/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 08-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@SuppressWarnings('PMD.CyclomaticComplexity')
@IsTest
public with sharing class AUFControllerTest {
  static Faker faker = new Faker('AU');
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
  static Lib_MockProvider aufQueryMock;
  static Lib_MockProvider aufAPIRepoMock;
  static Lib_MockProvider finAccRepoMock;
  static Lib_MockProvider userMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider finAccAPIRepoMock;

  static void registerMocks() {
    aufQueryMock = Lib_MockProvider.forType(IDOpsQueryRepository.class);
    aufAPIRepoMock = Lib_MockProvider.forType(AUFAPIRepository.class);
    finAccRepoMock = Lib_MockProvider.forType(FinancialAccountRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', true);
    finAccAPIRepoMock = Lib_MockProvider.forType(
      FinancialAccountAPIRepository.class
    );
  }

  static List<Id> personDigitalIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(PersonDigitalIdentity__x.SObjectType)
  };

  static List<PersonDigitalIdentity__x> personDigitalIdentityRecords {
    get {
      List<PersonDigitalIdentity__x> personDigitalIdRecList = new List<PersonDigitalIdentity__x>();
      PersonDigitalIdentity__x digitalIdentityRecord = new PersonDigitalIdentity__x(
        credentialsResId__c = TFMConstants.CREDENTIALSRESID,
        Internal_User_ID__c = TFMConstants.INTERNAL_USER_ID,
        UUID__c = TFMConstants.UUID_VALUE,
        OCV_ID__c = '32212110',
        pinrefid__c = '137532',
        persona_id__c = '222332322',
        Status__c = 'Active',
        PIN_Status__c = 'Active',
        IAL_Identity_Assurance_Level__c = 4,
        Id = personDigitalIds[0]
      );
      personDigitalIdRecList.add(digitalIdentityRecord);

      PersonDigitalIdentity__x digitalIdentityRecord1 = new PersonDigitalIdentity__x(
        credentialsResId__c = TFMConstants.CREDENTIALSRESID,
        Internal_User_ID__c = TFMConstants.INTERNAL_USER_ID,
        UUID__c = TFMConstants.UUID_VALUE,
        OCV_ID__c = '32212110',
        pinrefid__c = '137532',
        persona_id__c = '222332322',
        Status__c = 'Active',
        PIN_Status__c = 'Active',
        IAL_Identity_Assurance_Level__c = 2,
        Id = personDigitalIds[0]
      );
      personDigitalIdRecList.add(digitalIdentityRecord1);

      PersonDigitalIdentity__x digitalIdentityRecord2 = new PersonDigitalIdentity__x(
        credentialsResId__c = TFMConstants.CREDENTIALSRESID,
        Internal_User_ID__c = TFMConstants.INTERNAL_USER_ID,
        UUID__c = TFMConstants.UUID_VALUE,
        OCV_ID__c = '32212110',
        pinrefid__c = '137532',
        persona_id__c = '222332322',
        Status__c = 'Suspended',
        PIN_Status__c = 'Active',
        IAL_Identity_Assurance_Level__c = 4,
        Mobile_Number__c = '0061043211111',
        Id = personDigitalIds[0]
      );
      personDigitalIdRecList.add(digitalIdentityRecord2);

      return personDigitalIdRecList;
    }
  }

  private static List<FinServ__FinancialAccount__c> createMockFinancialAccount() {
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Product2 product = new Product2(
      Id = productId,
      Name = 'Test Product',
      ANZ_Product_Code__c = 'SAVING01'
    );
    Account testAccount = TestDataFactory.createPersonAccount('1111', false);
    testAccount.Id = FAKER_ACCOUNT_ID;
    List<FinServ__FinancialAccount__c> financialAccountsList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount1 = TestDataFactory.createFinancialAccountRecord(
      GetHelpConstants.SAVINGS_ACCOUNT_RT_ID,
      FAKER_ACCOUNT_ID,
      false
    );
    FinServ__FinancialAccount__c finAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      finAccount1,
      new Map<String, Object>{
        'Ownership__c' => 'Single',
        'Linked_Product_Code__c' => 'SAVING01'
      }
    );
    finAccount.FinServ__ProductName__r = product;
    finAccount.FinServ__FinancialAccountNumber__c = '111111111';
    financialAccountsList.add(finAccount);
    return financialAccountsList;
  }

  @isTest
  static void testupdatePinStatus() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    try {
      Test.startTest();
      AUFController.updatePinStatus(
        personDigitalIdentityRecords[0].Id,
        'Locked'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testUpdatePinStatusErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updatePinStatus',
      new AUFAPIRepository.ServerErrorException('Server Error')
    );
    try {
      Test.startTest();
      AUFController.updatePinStatus(
        personDigitalIdentityRecords[0].Id,
        'Locked'
      );
      Test.stopTest();
      Assert.fail('Exception should be thrown.');
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof AuraHandledException,
        'No server error occurred'
      );
    }
  }

  @isTest
  static void testUpdatePinStatusGenericExcResp() {
    registerMocks();
    aufQueryMock.mockException('getPersonDigitalIdentityRec');
    try {
      Test.startTest();
      AUFController.updatePinStatus(
        personDigitalIdentityRecords[0].Id,
        'Locked'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Query failed to return records'
      );
    }
  }

  @isTest
  static void testUpdatePinStatusInsufficientErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updatePinStatus',
      new AUFAPIRepository.InsufficientAccessException(
        'InsufficientAccessException'
      )
    );
    try {
      Test.startTest();
      AUFController.updatePinStatus(
        personDigitalIdentityRecords[0].Id,
        'Locked'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Insufficient access error expected'
      );
    }
  }

  @isTest
  static void testUpdateStatus() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    try {
      Test.startTest();
      AUFController.updateStatus(
        personDigitalIdentityRecords[0].Id,
        'Suspended'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testUpdateStatusGenericExceptionResp() {
    registerMocks();
    aufQueryMock.mockException('getPersonDigitalIdentityRec');
    try {
      Test.startTest();
      AUFController.updateStatus(
        personDigitalIdentityRecords[0].Id,
        'Suspended'
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Query returned no results'
      );
    }
  }

  @isTest
  static void testUpdateStatusErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updateStatus',
      new AUFAPIRepository.ServerErrorException('ServerErrorException')
    );
    try {
      Test.startTest();
      AUFController.updateStatus(
        personDigitalIdentityRecords[0].Id,
        'Suspended'
      );
      Test.stopTest();
      Assert.fail('ServerErrorException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Server error expected.'
      );
    }
  }

  @isTest
  static void testUpdateStatusInsufficientErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updateStatus',
      new AUFAPIRepository.InsufficientAccessException(
        'InsufficientAccessException'
      )
    );
    try {
      Test.startTest();
      AUFController.updateStatus(
        personDigitalIdentityRecords[0].Id,
        'Suspended'
      );
      Test.stopTest();
      Assert.fail('InsufficientAccessException expected');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Insufficient Server error expected.'
      );
    }
  }

  @isTest
  static void testResetPin() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    try {
      Test.startTest();
      AUFController.resetPin(personDigitalIdentityRecords[0].Id, '894432');
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testResetPinErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'resetPin',
      new AUFAPIRepository.ServerErrorException('ServerErrorException')
    );
    try {
      Test.startTest();
      AUFController.resetPin(personDigitalIdentityRecords[0].Id, '894432');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Server error expected.'
      );
    }
  }

  @isTest
  static void testResetPinGenericExceptionResp() {
    registerMocks();
    aufQueryMock.mockException('getPersonDigitalIdentityRec');
    try {
      Test.startTest();
      AUFController.resetPin(personDigitalIdentityRecords[0].Id, '894432');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Query returned no result'
      );
    }
  }

  @isTest
  static void testResetPinInsufficientErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'resetPin',
      new AUFAPIRepository.InsufficientAccessException(
        'InsufficientAccessException'
      )
    );
    try {
      Test.startTest();
      AUFController.resetPin(personDigitalIdentityRecords[0].Id, '894432');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'InsufficientAccessException error expected.'
      );
    }
  }

  @isTest
  static void testResetPinBadErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'resetPin',
      new AUFAPIRepository.ResetPinBadException('ResetPinBadException')
    );
    try {
      Test.startTest();
      AUFController.resetPin(personDigitalIdentityRecords[0].Id, '894432');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'ResetPinBadException error expected.'
      );
    }
  }

  @isTest
  static void testUpdateMobileNumber() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    try {
      Test.startTest();
      AUFController.updateMobileNumber(
        personDigitalIdentityRecords[0].Id,
        '61470896073',
        false
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testUpdateMobileNumberErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updateMobileNumber',
      new AUFAPIRepository.ServerErrorException('ServerErrorException')
    );
    try {
      Test.startTest();
      AUFController.updateMobileNumber(
        personDigitalIdentityRecords[0].Id,
        '61470896073',
        false
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Server error expected.'
      );
    }
  }

  @isTest
  static void testUpdateMobileNumberGenericExceptionResp() {
    registerMocks();
    aufQueryMock.mockException('getPersonDigitalIdentityRec');
    try {
      Test.startTest();
      AUFController.updateMobileNumber(
        personDigitalIdentityRecords[0].Id,
        '61470896073',
        false
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Query returned no result'
      );
    }
  }

  @isTest
  static void testUpdateMobileNumberInsufficientErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updateMobileNumber',
      new AUFAPIRepository.InsufficientAccessException(
        'InsufficientAccessException'
      )
    );
    try {
      Test.startTest();
      AUFController.updateMobileNumber(
        personDigitalIdentityRecords[0].Id,
        '61470896073',
        false
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'InsufficientAccessException error expected.'
      );
    }
  }

  @isTest
  static void testUpdateMobileNumberDuplicateErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updateMobileNumber',
      new AUFAPIRepository.DuplicateMobileNumberException(
        'DuplicateMobileNumberException'
      )
    );
    try {
      Test.startTest();
      AUFController.updateMobileNumber(
        personDigitalIdentityRecords[0].Id,
        '61470896073',
        true
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'DuplicateMobileNumberException error expected.'
      );
    }
  }

  @isTest
  static void testUpdateOcvid() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    try {
      Test.startTest();
      AUFController.updateOcvid(personDigitalIdentityRecords[0].Id, '3228392');
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testUpdateOcvidErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updateOcvid',
      new AUFAPIRepository.ServerErrorException('ServerErrorException')
    );
    try {
      Test.startTest();
      AUFController.updateOcvid(personDigitalIdentityRecords[0].Id, '3228392');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Server error expected.'
      );
    }
  }

  @isTest
  static void testUpdateOcvidGenericExceptionResp() {
    registerMocks();
    aufQueryMock.mockException('getPersonDigitalIdentityRec');
    try {
      Test.startTest();
      AUFController.updateOcvid(personDigitalIdentityRecords[0].Id, '3228392');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Query returned no results'
      );
    }
  }

  @isTest
  static void testUpdateOcvidInsufficientErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'updateOcvid',
      new AUFAPIRepository.InsufficientAccessException(
        'InsufficientAccessException'
      )
    );

    try {
      Test.startTest();
      AUFController.updateOcvid(personDigitalIdentityRecords[0].Id, '3228392');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'InsufficientAccessException error expected.'
      );
    }
  }

  @isTest
  static void testCheckAccountsOpen() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[1]
    );
    try {
      Test.startTest();
      AUFController.checkAccountsOpen(personDigitalIdentityRecords[1].Id);
      test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testCheckAccountsOpenError() {
    try {
      Test.startTest();
      AUFController.checkAccountsOpen(personDigitalIdentityRecords[0].Id);
      test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(e, AuraHandledException.class, 'Error expected');
    }
  }
  @isTest
  static void testArchiveUser() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    try {
      Test.startTest();
      AUFController.archiveUser(personDigitalIdentityRecords[0].Id, 'archived');
      test.stopTest();
    } catch (Exception e) {
      Assert.areEqual('', e.getMessage(), 'Exception occurred');
    }
  }

  @isTest
  static void testArchiveUserErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'archiveUser',
      new AUFAPIRepository.ServerErrorException('ServerErrorException')
    );
    try {
      Test.startTest();
      AUFController.archiveUser(personDigitalIdentityRecords[0].Id, 'archived');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Server error expected'
      );
    }
  }

  @isTest
  static void testArchiveUserGenericErrorResp() {
    registerMocks();
    aufQueryMock.mockException('getPersonDigitalIdentityRec');
    try {
      Test.startTest();
      AUFController.archiveUser(personDigitalIdentityRecords[0].Id, 'archived');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Query returned no result'
      );
    }
  }

  @isTest
  static void testArchiveUserInsufficientErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'archiveUser',
      new AUFAPIRepository.InsufficientAccessException(
        'InsufficientAccessException'
      )
    );

    try {
      Test.startTest();
      AUFController.archiveUser(personDigitalIdentityRecords[0].Id, 'archived');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'InsufficientAccessException error expected.'
      );
    }
  }

  @isTest
  static void testArchiveUserArchiveErrorResp() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    aufAPIRepoMock.mockException(
      'archiveUser',
      new AUFAPIRepository.ArchiveFailException('ArchiveFailException')
    );

    try {
      Test.startTest();
      AUFController.archiveUser(personDigitalIdentityRecords[0].Id, 'archived');
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'ArchiveFailException error expected.'
      );
    }
  }

  @isTest
  static void testDisputedChecks() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[2]
    );

    Test.startTest();
    Boolean disputed = AUFController.disputedChecks(
      personDigitalIdentityRecords[2].Id
    );
    Test.stopTest();
    Assert.isTrue(disputed, 'PDI can be disputed');
  }

  @isTest
  static void testDisputedChecks1() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );

    Test.startTest();
    Boolean disputed = AUFController.disputedChecks(
      personDigitalIdentityRecords[0].Id
    );
    Test.stopTest();
    Assert.isFalse(disputed, 'PDI cannot be disputed');
  }

  @isTest
  static void testDisputedChecksGenericErrorResp() {
    registerMocks();
    aufQueryMock.mockException('getPersonDigitalIdentityRec');
    try {
      Test.startTest();
      AUFController.disputedChecks(personDigitalIdentityRecords[0].Id);
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Query returned no result'
      );
    }
  }

  @isTest
  public static void testGetFinancialAccountFabricPositive() {
    registerMocks();
    finAccRepoMock.mock('getFinAccountList', createMockFinancialAccount());
    finAccRepoMock.mock(
      'getDigitallyConnectedFinAccounts',
      createMockFinancialAccount()
    );
    Test.startTest();
    List<UnifiedFinancialAccountModel> processedfinancialAccounts = FinancialAccountController.getFinancialAccountFabric(
      '12345',
      null
    );
    AUFController.isAnyAccountOpen(processedfinancialAccounts[0].accounts);
    Test.stopTest();

    Assert.isTrue(
      processedfinancialAccounts.size() > 0,
      'Fabric financial accounts should be grouped'
    );
  }

  @isTest
  public static void testCheckAccountsOpenFabric() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    finAccRepoMock.mock('getFinAccountList', createMockFinancialAccount());
    finAccRepoMock.mock(
      'getDigitallyConnectedFinAccounts',
      createMockFinancialAccount()
    );

    Test.startTest();
    List<UnifiedFinancialAccountModel> processedfinancialAccounts = FinancialAccountController.getFinancialAccountFabric(
      '12345',
      null
    );
    processedfinancialAccounts[0].accounts = null;
    finAccAPIRepoMock.mock('getAccounts', processedfinancialAccounts[0]);
    AUFController.checkAccountsOpen(personDigitalIdentityRecords[0].Id);
    Test.stopTest();

    Assert.isTrue(
      processedfinancialAccounts.size() > 0,
      'Fabric financial accounts should be grouped'
    );
  }

  @isTest
  static void testPermissionException() {
    registerMocks();
    aufQueryMock.mock(
      'getPersonDigitalIdentityRec',
      personDigitalIdentityRecords[0]
    );
    finAccRepoMock.mock('getFinAccountList', createMockFinancialAccount());
    userMock = Lib_MockProvider.forType(UserInfoRepository.class)
      .mock('checkCustomPermission', false);
    finAccAPIRepoMock.mockException(
      'getAccounts',
      new FinancialAccountAPIRepository.PermissionException(
        'PermissionException'
      )
    );
    try {
      Test.startTest();
      AUFController.checkAccountsOpen(personDigitalIdentityRecords[0].Id);
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'PermissionException Error'
      );
    }
  }
}
