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
          Name = 'Rejected1',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch1',
          Product_Type__c = 'invalidType1',
          Product_SubCode__c = productCode
        )
      );
      // ProductSubCode is not populated, ProductType is Populated. Product Exists with Matching OCV of ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Match1',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch2',
          Product_Type__c = productType
        )
      );
      // ProductSubCode is Populated, ProductType is not Populated. Product does not Exists with Matching OCV of ProductSubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Rejected2',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch3',
          Product_Type__c = 'invalidType2',
          Product_SubCode__c = productCode
        )
      );
      // ProductSubCode is Populated, ProductType is not Populated. Product does not exists Exists with Matching OCV of ProductSubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Rejected3',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch4',
          Product_Type__c = 'invalidType3',
          Product_SubCode__c = productCode
        )
      );
      // ProductSubCode is not populated, ProductType is Populated. Product does not Exists with Matching OCV of ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Match2',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch5',
          Product_Type__c = productType
        )
      );
      // ProductSubCode is not populated, ProductType is Populated. Product does not Exists with Matching OCV of ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Match3',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch6',
          Product_Type__c = productType
        )
      );
      // Both ProdcutSubCode and ProductType is Populated, Different Product Exists matching with ProductType but Product SubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Match4',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch7',
          Product_Type__c = productType,
          Product_SubCode__c = productCode
        )
      );
      // Both ProdcutSubCode and ProductType is Populated, No Product Exists matching with SubCode but Product Exists with ProductType
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'Match5',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch8',
          Product_Type__c = productType,
          Product_SubCode__c = productCode
        )
      );
      // Both ProdcutSubCode and ProductType is Populated, No Product Exists matching with ProductType but Product Exists with ProductSubCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'NoMatch1',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'FinAccountBatch9',
          Product_Type__c = productType,
          Product_SubCode__c = 'invalidSubCode1'
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
    Integer totalMapped = 0;
    Integer totalNotMapped = 0;
    String pdtSubCodeNotFoundMsg = System.Label.MissingCodeMsgForClassicRecords;

    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      Test.StartTest();
      FinAccountSetProductLookupBatch batch = new FinAccountSetProductLookupBatch();
      Database.executeBatch(batch, 10);
      Test.StopTest();

      List<FinServ__FinancialAccount__c> finAccounts = [
        SELECT
          Id,
          Name,
          FinServ__ProductName__c,
          Product_Type__c,
          Product_SubCode__c
        FROM FinServ__FinancialAccount__c
        WHERE Account_Key__c LIKE 'FinAccountBatch%'
      ];
      for (FinServ__FinancialAccount__c finAccount : finAccounts) {
        if (finAccount.FinServ__ProductName__c == null) {
          totalNotMapped++;
        } else {
          totalMapped++;
        }
      }
      system.assertEquals(
        5,
        totalMapped,
        'Total Mapped Account is not correct'
      );
      system.assertEquals(
        4,
        totalNotMapped,
        'Total Not Mapped Account is not correct'
      );
    }
  }

  /**
   * @description test functionality of FinAccountSetProductLookupBatch with specified run size
   */
  @isTest
  public static void testBatchWithRunSize() {
    Integer totalMapped = 0;
    Integer totalNotMapped = 0;
    Integer runSize = 10;
    String pdtSubCodeNotFoundMsg = System.Label.MissingCodeMsgForClassicRecords;

    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      Test.StartTest();
      FinAccountSetProductLookupBatch batch = new FinAccountSetProductLookupBatch(
        runSize
      );
      Database.executeBatch(batch, 10);
      Test.StopTest();

      List<FinServ__FinancialAccount__c> finAccounts = [
        SELECT
          Id,
          Name,
          FinServ__ProductName__c,
          Product_Type__c,
          Product_SubCode__c
        FROM FinServ__FinancialAccount__c
        WHERE Account_Key__c LIKE 'FinAccountBatch%'
      ];
      for (FinServ__FinancialAccount__c finAccount : finAccounts) {
        if (finAccount.FinServ__ProductName__c == null) {
          totalNotMapped++;
        } else {
          totalMapped++;
        }
      }
      system.assertEquals(
        5,
        totalMapped,
        'Total Mapped Account is not correct'
      );
      system.assertEquals(
        4,
        totalNotMapped,
        'Total Not Mapped Account is not correct'
      );
    }
  }

  /**
   * @description test functionality of FinAccountSetProductLookupBatch
   */
  @isTest
  public static void testBatchChained() {
    Integer totalMapped = 0;
    Integer totalNotMapped = 0;
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

      List<FinServ__FinancialAccount__c> finAccounts = [
        SELECT
          Id,
          Name,
          FinServ__ProductName__c,
          Product_Type__c,
          Product_SubCode__c
        FROM FinServ__FinancialAccount__c
        WHERE Account_Key__c LIKE 'FinAccountBatch%'
      ];
      for (FinServ__FinancialAccount__c finAccount : finAccounts) {
        if (finAccount.FinServ__ProductName__c == null) {
          totalNotMapped++;
        } else {
          totalMapped++;
        }
      }
      system.assertEquals(
        5,
        totalMapped,
        'Total Mapped Account is not correct'
      );
      system.assertEquals(
        4,
        totalNotMapped,
        'Total Not Mapped Account is not correct'
      );
    }
  }
}
