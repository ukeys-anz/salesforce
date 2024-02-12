/**
 * @author Hitesh
 * @since  02/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Map Product for Financial Accounts for Legacy(Existing) Data. CC-7395
 */
public class FinAccountSetProductLookupBatch implements Database.Batchable<sObject>, Database.Stateful {
  private Map<String, Product2> prodCatMap = new Map<String, Product2>(); // Stores Product.OCV_SubProductKey -> Product Map
  private integer runSize = 500000; // default runSize is 500k, can be updated by passing value
  private integer batchSize = 200; // default batchSize is 200, can be updated by passing value
  private integer chainLevel = 0; // default job chain level 0 (no chaining), can be updated by passing value
  private Map<string, integer> ignoreList = new Map<String, Integer>(); // Stores FA ProductSubCode/ProductType for which no Product Exist with the count
  private integer totalRecordsMapped = 0;
  private String pdtSubCodeNotFoundMsg = System.Label.MissingCodeMsgForClassicRecords;
  private String productsToMap = System.Label.FinAccountProductToMap;

  /**
   * @description default constructor to initialize values
   * @name FinAccountSetProductLookupBatch
   */
  public FinAccountSetProductLookupBatch() {
    initializeValues();
  }

  /**
   * @description default constructor to initialize values
   * @name FinAccountSetProductLookupBatch
   * @param givenRunSize passed runSize
   */
  public FinAccountSetProductLookupBatch(Integer givenRunSize) {
    initializeValues();
    runSize = givenRunSize;
  }

  /**
   * @description default constructor to initialize values
   * @name FinAccountSetProductLookupBatch
   * @param givenRunSize passed runSize
   * @param givenChainLimit passed chainLevel
   * @param givenBatchSize passed batchSize
   */
  public FinAccountSetProductLookupBatch(
    Integer givenRunSize,
    Integer givenChainLimit,
    Integer givenBatchSize
  ) {
    initializeValues();
    runSize = givenRunSize;
    batchSize = givenBatchSize;
    chainLevel = givenChainLimit;
  }

  /**
   * @description initialize values for the Batch
   * @name initializeValues
   */
  public void initializeValues() {
    Id crmProductId = MLCRMConstants.CRM_ANZ_PRODUCT_RT_ID;
    List<Product2> ls = [
      SELECT Id, OCV_Sub_Product_Key__c
      FROM Product2
      WHERE recordtypeId = :crmProductId AND OCV_Sub_Product_Key__c != NULL
    ];
    for (Product2 pdt : ls) {
      prodCatMap.put(pdt.OCV_Sub_Product_Key__c, pdt);
    }
  }

  /**
   * @description get finanical accounts with having empty ProductName
   * @name start
   * @param bc batachable context
   * @return Database.QueryLocator
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Id faBankingAcctRT = GetHelpConstants.BANK_ACCOUNT_RT_ID;
    String qry =
      'SELECT Id, Name, FinServ__ProductName__c, Product_SubCode__c, Product_Type__c from FinServ__FinancialAccount__c WHERE ' +
      'RecordTypeId = \'' +
      String.escapeSingleQuotes(faBankingAcctRT) +
      '\' AND FinServ__ProductName__c = null AND  ' +
      ' Product_Type__c IN (' +
      productsToMap +
      ') ' +
      ' ORDER BY Product_SubCode__c LIMIT ' +
      String.valueOf(runSize);
    return Database.getQueryLocator(qry);
  }

  /**
   * @description get finanical accounts with having empty ProductName
   * @name execute
   * @param bc batachable context
   * @param records chunks of Financial Account records
   */
  public void execute(
    Database.BatchableContext bc,
    List<FinServ__FinancialAccount__c> records
  ) {
    try {
      Set<Id> idsOfMappedRecords = new Set<Id>();
      Integer recordsUpdated = MLCRMFinancialAccountActions.populateANZProductForLegacyRecords(
        records,
        prodCatMap,
        ignoreList
      );
      for (FinServ__FinancialAccount__c fa : records) {
        if (fa.FinServ__ProductName__c != null) {
          idsOfMappedRecords.add(fa.Id);
        }
      }

      // Allow Partial update of Records and Log record with Error detatils.
      Database.SaveResult[] lstResult = database.update(records, false);
      for (Integer i = 0; i < lstResult.size(); i++) {
        if (!lstResult.get(i).isSuccess()) {
          Logger.error(
            'ERROR while updating - ' +
            lstResult.get(i).getId() +
            '. ErrorMessage - ' +
            lstResult.get(i).getErrors()
          );
          if (idsOfMappedRecords.contains(lstResult.get(i).getId())) {
            recordsUpdated -= 1; // as Error occoured while updating mapped record so reducing the count
          }
        }
      }
      totalRecordsMapped += recordsUpdated;
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
    }
  }

  /**
   * @description Create Log for total record mapped and failed FA's productCode -> Occurance map
   * @param bc batachable context
   * @name finish
   */
  public void finish(Database.BatchableContext bc) {
    // Log all the ProductCode/ProductType which do not match with Existing Products
    for (String pdtCode : ignoreList.keySet()) {
      Logger.error(
        pdtSubCodeNotFoundMsg +
        ' <' +
        pdtCode +
        '> = ' +
        ignoreList.get(pdtCode)
      );
    }
    // Log Total Records Mapped
    Logger.error('Total Records Mapped ' + String.valueOf(totalRecordsMapped));

    // spawn job chain if chain level is within bound
    if (chainLevel > 0) {
      chainLevel--;
      FinAccountSetProductLookupBatch setNextProdLookUp = new FinAccountSetProductLookupBatch(
        runSize,
        chainLevel,
        batchSize
      );
      ID batchprocessid = Database.executeBatch(setNextProdLookUp, batchSize);
      Logger.error(
        'Batch job Id ' +
        batchprocessid +
        ' sent to queue. Chain level: ' +
        String.valueOf(chainLevel) +
        '. Batch size: ' +
        String.valueOf(batchSize)
      );
    }
    Logger.saveLog();
  }
}
