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
    Id crmProductId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID;
    String productType = 'ExistingProductType';
    String productCode = 'ExistingProductCode';
    User mlUser = MLCRMTestDataFactory.getMLCRMBaseUser();
    TestUtil.assignPermissionSets(
      new List<String>{
        'FinancialServicesCloudExtension',
        'FinancialServicesCloudStandard'
      },
      new List<User>{ mlUser }
    );

    User ocvIntegrationUser = CCRMTestDataFactory.createOCVIntegrationUser();
    System.runAs(ocvIntegrationuser) {
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
          Name = 'MatchingPdtTypeOnly',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'MatchingPdtTypeOnly',
          Product_Type__c = productType
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
      // Both ProdcutSubCode and ProductType is Populated, No Product Exists matching with ProductType and ProductCode
      finAccounts.add(
        new FinServ__FinancialAccount__c(
          Name = 'BothNonMatching',
          FinServ__Status__c = 'Active',
          RecordTypeId = GetHelpConstants.BANK_ACCOUNT_RT_ID,
          FinServ__PrimaryOwner__c = accnt.Id,
          Account_Key__c = 'CorrectPdtCode',
          Product_Type__c = 'wrongPdtType',
          Product_SubCode__c = 'wrongPdtCode'
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
   * @description test functionality of PopulateANZProduct
   */
  @isTest
  public static void testPopulateANZProduct() {
    Map<String, Product2> ocvSubProductKeyToProductIdMap = new Map<String, Product2>();
    List<Product2> products = [SELECT Id, OCV_Sub_Product_Key__c FROM Product2];
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
        FinServ__ProductName__c = NULL
        AND (Product_SubCode__c != NULL
        OR Product_Type__c != NULL)
    ];

    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      Test.StartTest();
      MLCRMFinancialAccountActions.populateANZProduct(finAccounts, null);
      Test.StopTest();

      for (FinServ__FinancialAccount__c fa : finAccounts) {
        if (fa.Name == 'BothNonMatchingPdtCodeAndPdtType') {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            null,
            'FinAcc not mapped correctly when no matching Product Found'
          );
        } else if (fa.Name == 'MatchingBoth') {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            ocvSubProductKeyToProductIdMap.get(fa.Product_SubCode__c).Id,
            'FinAcc not mapped correctly when matching ProductSubCode exists'
          );
        } else if (fa.Name == 'MatchingPdtTypeOnly') {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            ocvSubProductKeyToProductIdMap.get(fa.Product_Type__c).Id,
            'FinAcc not mapped correctly when matching ProductSubType exists'
          );
        } else if (fa.Name == 'MatchingPdtCodeOnly') {
          system.assertEquals(
            fa.FinServ__ProductName__c,
            ocvSubProductKeyToProductIdMap.get(fa.Product_SubCode__c).Id,
            'FinAcc not mapped correctly when matching ProductSubCode exists'
          );
        }
      }
    }
  }
}
