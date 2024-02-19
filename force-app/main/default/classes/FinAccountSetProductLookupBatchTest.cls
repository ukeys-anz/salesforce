/**
 * @author Hitesh
 * @since  02/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Test Class for FinAccountSetProductLookupBatch. CC-7395
 */
@isTest
public class FinAccountSetProductLookupBatchTest {
  /**
   * @description testsetup method
   */
  @testSetup
  static void setup() {
    User adminUser = MLCRMTestDataFactory.createAdminUser();
    String productsToMap = System.Label.FinAccountProductToMap;
    String productCode;
    String productType;

    List<String> pdtsToSplitArr = productsToMap.split(',');
    // If there are more than one product in the label then will use one as ProductSubCode and another as ProductSubType
    if (pdtsToSplitArr.size() > 1) {
      productType = pdtsToSplitArr[1];
      productCode = pdtsToSplitArr[0];
    } else {
      productType = pdtsToSplitArr[0];
      productCode = pdtsToSplitArr[0];
    }
    productType = productType.replaceAll('\'', '');
    productCode = productCode.replaceAll('\'', '');

    TestUtil.assignPermissionSets(
      new List<String>{
        'FinancialServicesCloudExtension',
        'FinancialServicesCloudStandard'
      },
      new List<User>{ adminUser }
    );

    Id crmProductId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID;
    System.runAs(adminUser) {
      Account accnt = new Account();
      accnt.Name = 'TestAccount';
      accnt.Display_Name__c = 'TestAccount';
      accnt.OCV_ID__c = 'OCV11';
      accnt.ANZx_Customer__c = true;
      accnt.External_Id__c = 'Test123';
      insert accnt;

      List<FinServ__FinancialAccount__c> finAccounts = new List<FinServ__FinancialAccount__c>();
      // ProductSubCode is Populated, ProductType is not Populated. Product Exists with Matching OCV of ProductSubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'MatchingPdtCodeOnly',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'MatchingPdtCodeOnly',
          Product_SubCode__c = productCode
        )
      );
      // ProductSubCode is not populated, ProductType is Populated. Product Exists with Matching OCV of ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'MatcingPdtTypeOnly',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'MatcingPdtTypeOnly',
          Product_Type__c = productType
        )
      );
      // ProductSubCode is Populated, ProductType is not Populated. Product does not Exists with Matching OCV of ProductSubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'NonMatchingPdtCode1',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'NonMatchingPdtCode1',
          Product_SubCode__c = 'zwrongPdtCode'
        )
      );
      // ProductSubCode is Populated, ProductType is not Populated. Product does not exists Exists with Matching OCV of ProductSubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'NonMatchingPdtCode2',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'NonMatchingPdtCode2',
          Product_SubCode__c = 'zwrongPdtCode'
        )
      );
      // ProductSubCode is not populated, ProductType is Populated. Product does not Exists with Matching OCV of ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'NonMatchingPdtType1',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'NonMatchingPdtType1',
          Product_Type__c = 'zwrongPdtType'
        )
      );
      // ProductSubCode is not populated, ProductType is Populated. Product does not Exists with Matching OCV of ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'NonMatchingPdtType2',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'NonMatchingPdtType2',
          Product_Type__c = 'zwrongPdtType'
        )
      );
      // Both ProdcutSubCode and ProductType is Populated, Different Product Exists matching with ProductType but Product SubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'MatchingBoth',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'MatchingBoth',
          Product_Type__c = productType,
          Product_SubCode__c = productCode
        )
      );
      // Both ProdcutSubCode and ProductType is Populated, No Product Exists matching with SubCode but Product Exists with ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'CorrectPdtType',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'CorrectPdtType',
          Product_Type__c = productType,
          Product_SubCode__c = 'zwrongPdtCode'
        )
      );
      // Both ProdcutSubCode and ProductType is Populated, No Product Exists matching with ProductType but Product Exists with ProductSubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'CorrectPdtCode',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'CorrectPdtCode',
          Product_Type__c = 'zwrongPdtType',
          Product_SubCode__c = productCode
        )
      );
      insert finAccounts;

      List<Product2> pdts = new List<Product2>();
      pdts.add(
        new Product2(
          recordtypeId = crmProductId,
          name = 'testProduct1',
          IDR_Product_or_Service_Line__c = '1',
          OCV_Sub_Product_Key__c = productCode
        )
      );
      pdts.add(
        new Product2(
          recordtypeId = crmProductId,
          name = 'testProduct2',
          IDR_Product_or_Service_Line__c = '1',
          OCV_Sub_Product_Key__c = productType
        )
      );
      insert pdts;
    }
  }

  /**
   * @description test functionality of FinAccountSetProductLookupBatch
   */
  @isTest
  public static void testBatch() {
    Integer totalRecordsFailed = 0;
    Integer totalRecordsMapped = 0;
    String pdtSubCodeNotFoundMsg = System.Label.MissingCodeMsgForClassicRecords;

    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      Test.StartTest();
      FinAccountSetProductLookupBatch batch = new FinAccountSetProductLookupBatch();
      Database.executeBatch(batch, 10);
      Test.StopTest();

      List<LogEntry__c> logEntries = [
        SELECT Id, name, ApexClassName__c, LogMessage__c
        FROM LogEntry__c
      ];
      for (LogEntry__c le : logEntries) {
        if (le.LogMessage__c.contains(pdtSubCodeNotFoundMsg)) {
          totalRecordsFailed += Integer.valueof(le.LogMessage__c.right(1));
        } else if (le.LogMessage__c.contains('Total Records Mapped')) {
          totalRecordsMapped = Integer.valueof(le.LogMessage__c.right(1));
        }
      }
      system.assertEquals(
        2,
        totalRecordsMapped,
        'Total Mapped Records count is not correct'
      );
      system.assertEquals(
        1,
        totalRecordsFailed,
        'Total non-mapped/failed records count is not correct. Correct Calculation: Total Rec =9, Failed = 1, Skipped = 4, Mapped = 4'
      );
    }
  }

  /**
   * @description test functionality of FinAccountSetProductLookupBatch with specified run size
   */
  @isTest
  public static void testBatchWithRunSize() {
    Integer totalRecordsFailed = 0;
    Integer totalRecordsMapped = 0;
    Integer runSize = 5;
    String pdtSubCodeNotFoundMsg = System.Label.MissingCodeMsgForClassicRecords;

    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      Test.StartTest();
      FinAccountSetProductLookupBatch batch = new FinAccountSetProductLookupBatch(
        runSize
      );
      Database.executeBatch(batch, 10);
      Test.StopTest();

      List<LogEntry__c> logEntries = [
        SELECT Id, name, ApexClassName__c, LogMessage__c
        FROM LogEntry__c
      ];
      for (LogEntry__c le : logEntries) {
        if (le.LogMessage__c.contains(pdtSubCodeNotFoundMsg)) {
          totalRecordsFailed += Integer.valueof(le.LogMessage__c.right(1));
        } else if (le.LogMessage__c.contains('Total Records Mapped')) {
          totalRecordsMapped = Integer.valueof(le.LogMessage__c.right(1));
        }
      }
      system.assertEquals(
        3,
        totalRecordsMapped + totalRecordsFailed,
        'Total Records processed is not Correct. Calculation: Total Rec 9, Mapped 2, Failed 1, skipped 6'
      );
    }
  }

  /**
   * @description test functionality of FinAccountSetProductLookupBatch
   */
  @isTest
  public static void testBatchChained() {
    String pdtSubCodeNotFoundMsg = System.Label.MissingCodeMsgForClassicRecords;
    Integer totalRecordsFailed = 0;
    Integer totalRecordsMapped = 0;
    Id crmProductId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID;
    Integer runSize = 5;
    Integer chainLevel = 1;
    Integer batchSize = 5;

    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      Test.StartTest();
      FinAccountSetProductLookupBatch batch = new FinAccountSetProductLookupBatch(
        runSize,
        chainLevel,
        batchSize
      );
      Database.executeBatch(batch, batchSize);
      Test.StopTest();

      List<LogEntry__c> logEntries = [
        SELECT Id, name, ApexClassName__c, LogMessage__c
        FROM LogEntry__c
      ];
      for (LogEntry__c le : logEntries) {
        if (le.LogMessage__c.contains(pdtSubCodeNotFoundMsg)) {
          totalRecordsFailed += Integer.valueof(le.LogMessage__c.right(1));
        } else if (le.LogMessage__c.contains('Total Records Mapped')) {
          totalRecordsMapped += Integer.valueof(le.LogMessage__c.right(1));
        }
      }
      system.assertEquals(
        4,
        totalRecordsMapped + totalRecordsFailed,
        'Total processed count is not correct'
      );
    }
  }
}
