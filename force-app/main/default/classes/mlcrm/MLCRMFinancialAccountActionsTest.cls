/**
 * @author Hitesh
 * @since  02/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Test Class for MLCRMFinancialAccountActions. CC-7395
 */
@isTest
public class MLCRMFinancialAccountActionsTest {
  /**
   * @description testsetup method
   */
  @testSetup
  static void setup() {
    User adminUser = MLCRMTestDataFactory.createAdminUser();
    Id crmProductId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID;
    // Take two products from Label and consider one as ProductSubcode, and the another one as ProductType
    List<String> validPdtSubCodeAndType = getValidProductTypeAndSubcode();
    String productType = validPdtSubCodeAndType[0];
    String productCode = validPdtSubCodeAndType[1];
    TestUtil.assignPermissionSets(
      new List<String>{
        'FinancialServicesCloudExtension',
        'FinancialServicesCloudStandard'
      },
      new List<User>{ adminUser }
    );
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
   * @description test functionality of PopulateANZProductForLegacyRecords
   */
  @isTest
  public static void testPopulateANZProductForLegacyRecords() {
    Integer totalRecordsFailed = 0;
    Integer runSize = 5;
    Integer totalRecordsMapped = 0;
    Map<String, Product2> ocvSubProductKeyToProductIdMap = new Map<String, Product2>();
    Map<string, integer> ignoreList = new Map<String, Integer>();
    Id faBankingAcctRT = GetHelpConstants.BANK_ACCOUNT_RT_ID;

    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      List<String> validPdtSubCodeAndType = getValidProductTypeAndSubcode();
      String productType = validPdtSubCodeAndType[0];
      String productCode = validPdtSubCodeAndType[1];

      String pdtQry =
        'SELECT Id, OCV_Sub_Product_Key__c FROM Product2 WHERE OCV_Sub_Product_Key__c IN (\'' +
        productType +
        '\',\'' +
        productCode +
        '\')';
      List<Product2> products = Database.query(pdtQry);
      for (Product2 pdt : products) {
        ocvSubProductKeyToProductIdMap.put(pdt.OCV_Sub_Product_Key__c, pdt);
      }
      List<FinServ__FinancialAccount__c> finAccounts = [
        SELECT
          Id,
          Name,
          FinServ__ProductName__c,
          Product_SubCode__c,
          Product_Type__c
        FROM FinServ__FinancialAccount__c
        WHERE
          RecordTypeId = :faBankingAcctRT
          AND FinServ__ProductName__c = NULL
          AND (Product_SubCode__c != NULL
          OR Product_Type__c != NULL)
      ];

      Test.StartTest();
      totalRecordsMapped = MLCRMFinancialAccountActions.populateANZProductForLegacyRecords(
        finAccounts,
        ocvSubProductKeyToProductIdMap,
        ignoreList
      );
      Test.StopTest();

      for (FinServ__FinancialAccount__c fa : finAccounts) {
        if (fa.Product_SubCode__c != null && fa.Product_Type__c != null) {
          if (
            ocvSubProductKeyToProductIdMap.containsKey(fa.Product_SubCode__c)
          ) {
            system.assertEquals(
              fa.FinServ__ProductName__c,
              ocvSubProductKeyToProductIdMap.get(fa.Product_SubCode__c).Id,
              'Scenario: Both ProductSubCode, ProductType is Populated and Product Exists with Matching OCV Code. Result: FA not mapped using SubProduct Value'
            );
          } else {
            system.assertEquals(
              fa.FinServ__ProductName__c,
              null,
              'Scenario: Both ProductSubCode, ProductType is Populated and Product not Exists with Matching OCV sub Code. Result: FA mapped to wrong Product'
            );
          }
        } else if (
          fa.Product_SubCode__c != null &&
          fa.Product_Type__c == null &&
          ocvSubProductKeyToProductIdMap.containsKey(fa.Product_SubCode__c)
        ) {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            ocvSubProductKeyToProductIdMap.get(fa.Product_SubCode__c).Id,
            'Scenario: ProductSubCode is populated, ProductType is not Populated and Product Exists with Matching OCV Code. Result: FA not mapped using ProductSubCode value'
          );
        } else if (
          fa.Product_SubCode__c != null &&
          fa.Product_Type__c == null &&
          !ocvSubProductKeyToProductIdMap.containsKey(fa.Product_SubCode__c)
        ) {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            null,
            'Scenario: ProductSubCode is populated, ProductType is not Populated and Product not Exists with Matching OCV Code. Result: FA mapped with wrong Product'
          );
        } else if (
          fa.Product_SubCode__c == null &&
          fa.Product_Type__c != null &&
          ocvSubProductKeyToProductIdMap.containsKey(fa.Product_Type__c)
        ) {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            ocvSubProductKeyToProductIdMap.get(fa.Product_Type__c).Id,
            'Scenario: ProductSubCode is not populated, ProductType is Populated and Product Exists with Matching OCV Code. Result: FA not mapped using ProductType value'
          );
        } else if (
          fa.Product_SubCode__c == null &&
          fa.Product_Type__c != null &&
          !ocvSubProductKeyToProductIdMap.containsKey(fa.Product_Type__c)
        ) {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            null,
            'Scenario: ProductSubCode is not populated, ProductType is Populated and Product not Exists with Matching OCV Code. Result: FA mapped to wrong Product'
          );
        }
      }
      for (Integer pdtFailCount : ignoreList.values()) {
        totalRecordsFailed += pdtFailCount;
      }
      system.assertEquals(
        4,
        totalRecordsMapped,
        'Total Mapped Records count is not correct'
      );
      system.assertEquals(
        5,
        totalRecordsFailed,
        'Total non-mapped/faild records count is not correct'
      );
    }
  }

  /**
   * @description returns List of Two Products from Label FinAccountProductToMap. Will be used to create dummy FinAcc and Products
   * @name getValidProductTypeAndSubcode
   * @return list of validProducts used in FinAccountSetProductLookupBatch as mentioned in FinAccountProductToMap Label
   */
  public static List<String> getValidProductTypeAndSubcode() {
    List<String> pdtsToSplitArr = System.Label.FinAccountProductToMap.split(
      ','
    );
    List<String> validPdtSubCodeAndType = new List<String>();
    // if there are more than 1 pdt then use first two Products, else use first one for both productSubCode and ProductType
    if (pdtsToSplitArr.size() > 1) {
      validPdtSubCodeAndType.add(pdtsToSplitArr[0].replaceAll('\'', ''));
      validPdtSubCodeAndType.add(pdtsToSplitArr[1].replaceAll('\'', ''));
    } else {
      validPdtSubCodeAndType.add(pdtsToSplitArr[0].replaceAll('\'', ''));
      validPdtSubCodeAndType.add(pdtsToSplitArr[0].replaceAll('\'', ''));
    }
    return validPdtSubCodeAndType;
  }
}
