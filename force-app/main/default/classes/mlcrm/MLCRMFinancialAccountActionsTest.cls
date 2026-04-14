/**
 * @author Hitesh
 * @since  02/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Test Class for MLCRMFinancialAccountActions. CC-7395
 */
@isTest
public class MLCRMFinancialAccountActionsTest {
  private static Lib_MockProvider finAccActionsRepoMock;

  static void registerMocks() {
    finAccActionsRepoMock = Lib_MockProvider.forType(
      FinancialAccountActionsRepository.class
    );
  }

  private static Map<Id, Product2> getProductData() {
    Map<String, Product2> ocvSubProductKeyToProductIdMap = new Map<String, Product2>();

    Id productId1 = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id productId2 = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id productId3 = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id productId4 = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    return new Map<Id, Product2>{
      productId1 => new Product2(
        Id = productId1,
        OCV_Sub_Product_Key__c = 'CAP-CIS:ILSTVB1',
        Is_Portfolio__c = 'Yes',
        RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
        Name = 'Product isPortfolio Yes'
      ),
      productId2 => new Product2(
        Id = productId2,
        OCV_Sub_Product_Key__c = 'CAP-CIS:ILSTVB2',
        Is_Portfolio__c = 'No',
        RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
        Name = 'Product isPortfolio No'
      ),
      productId3 => new Product2(
        Id = productId3,
        OCV_Sub_Product_Key__c = 'CAP-CIS:ILSTVB3',
        Is_Portfolio__c = 'Yes',
        RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
        Name = 'Product isPortfolio Yes 2'
      ),
      productId4 => new Product2(
        Id = productId4,
        OCV_Sub_Product_Key__c = 'CAP-CIS:ILSTVB3',
        RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
        Name = 'Product isPortfolio Null'
      )
    };
  }

  private static List<FinServ__FinancialAccount__c> getFinAccountData() {
    return new List<FinServ__FinancialAccount__c>{
      new FinServ__FinancialAccount__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.SObjectType
        ),
        Product_SubCode__c = 'CAP-CIS:ILSTVB1',
        Portfolio_Indicator__c = 'P',
        RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
        Name = 'Financial Account w/ PortIndi'
      ),
      new FinServ__FinancialAccount__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.SObjectType
        ),
        Product_Type__c = 'CAP-CIS:ILSTVB2',
        RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
        Name = 'Financial Account w/o PortIndi'
      ),
      new FinServ__FinancialAccount__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__FinancialAccount__c.SObjectType
        ),
        Product_SubCode__c = 'CAP-CIS:ILSTVB3',
        RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
        Name = 'Financial Account w/o PortIndi 2'
      )
    };
  }
  /**
   * @description test functionality of PopulateANZProduct on Insert
   */
  @isTest
  public static void testPopulateANZProductOnInsert() {
    registerMocks();

    // GIVEN List of Financial Accounts
    Map<Id, Product2> products = getProductData();
    List<FinServ__FinancialAccount__c> finAccounts = getFinAccountData();

    finAccActionsRepoMock.mock('getByOcvSubProductKey', products.values());

    // WHEN Calling MLCRMFinancialAccountActions.populateANZProduct
    Test.StartTest();
    MLCRMFinancialAccountActions.populateANZProduct(finAccounts, null);
    Test.StopTest();

    // THEN proper product should be populated
    Map<String, String> acceptableProductMapping = new Map<String, String>{
      finAccounts[0].Id => products.values()[0].Id,
      finAccounts[1].Id => products.values()[1].Id,
      finAccounts[2].Id => products.values()[3].Id
    };
    Assert.areEqual(
      finAccounts[0].FinServ__ProductName__c,
      acceptableProductMapping.get(finAccounts[0].Id),
      'Wrong Product Propulated.'
    );
    Assert.areEqual(
      finAccounts[1].FinServ__ProductName__c,
      acceptableProductMapping.get(finAccounts[1].Id),
      'Wrong Product Propulated.'
    );
    Assert.areEqual(
      finAccounts[2].FinServ__ProductName__c,
      acceptableProductMapping.get(finAccounts[2].Id),
      'Wrong Product Propulated.'
    );
  }

  /**
   * @description test functionality of PopulateANZProduct on Update
   */
  @isTest
  public static void testPopulateANZProductOnUpdate() {
    registerMocks();

    // GIVEN List & oldMap of Financial Accounts
    Map<Id, Product2> products = getProductData();

    finAccActionsRepoMock.mock('getByOcvSubProductKey', products.values());

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
      Id = Lib_FakeIdGenerator.getMockId(
        FinServ__FinancialAccount__c.SObjectType
      ),
      Product_SubCode__c = 'CAP-CIS:ILSTVB1',
      Portfolio_Indicator__c = 'P',
      RecordTypeId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID,
      Name = 'Financial Account w/ PortIndi'
    );
    List<FinServ__FinancialAccount__c> newFinAccounts = new List<FinServ__FinancialAccount__c>{
      finAccount
    };

    FinServ__FinancialAccount__c oldFinAccount = new FinServ__FinancialAccount__c();
    oldFinAccount.Product_SubCode__c = 'CAP-CIS:ILSTVB1';
    oldFinAccount.Id = finAccount.Id;

    Map<Id, FinServ__FinancialAccount__c> oldFinAccountMap = new Map<Id, FinServ__FinancialAccount__c>{
      oldFinAccount.Id => oldFinAccount
    };

    // WHEN Calling MLCRMFinancialAccountActions.populateANZProduct
    Test.StartTest();
    oldFinAccount.Portfolio_Indicator__c = null;
    MLCRMFinancialAccountActions.populateANZProduct(
      newFinAccounts,
      oldFinAccountMap
    );
    Test.StopTest();

    // THEN proper product should be populated
    Assert.areEqual(
      newFinAccounts[0].FinServ__ProductName__c,
      products.values()[0].Id,
      'Proper product should be populated.'
    );
  }
}
