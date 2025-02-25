/**
 * @author cruzb
 * @since Oct 2024
 * @description SOP Expense View model
 */
public with sharing class SOPExpenseViewModel {
  @AuraEnabled
  public String name;

  @AuraEnabled
  public Decimal monthlySpend;

  @AuraEnabled
  public Datetime updateTime;

  @AuraEnabled
  public String reason;

  @AuraEnabled
  public String expenseParent;

  @AuraEnabled
  public String sopName;

  @AuraEnabled
  public String justificationCode;

  @AuraEnabled
  public String otherJustificationText;

  @AuraEnabled
  public String control;

  @AuraEnabled
  public String review;

  @AuraEnabled
  public String uid;

  @AuraEnabled
  public String categoryId;

  @AuraEnabled
  public String categoryName;

  @AuraEnabled
  public Boolean leafNode;

  @AuraEnabled
  public String etag;

  @AuraEnabled
  public String hemState;

  /**
   * @description constructor to map from sop expense api model to expenseSummary view model
   * @param sourceData expenseSummary api model
   * @param mapCodeToReason map of justification code to expense control
   */
  public SOPExpenseViewModel(
    SOPGetConsolidatedModel.MonthlyExpenses sourceData,
    Map<String, Expense_Control__c> mapCodeToReason
  ) {
    this.name = sourceData.categoryName;
    this.monthlySpend = SOPHelper.convertAmountToDecimal(
      sourceData.statedMonthlyAverageAmount
    );
    this.updateTime = sourceData.updateTime;
    this.expenseParent = sourceData.expenseParent;
    this.sopName = sourceData.name;
    this.control = sourceData.control;
    this.review = sourceData.review;
    this.justificationCode = sourceData.justificationCode;
    this.otherJustificationText = sourceData.otherJustificationText;

    this.reason = mapCodeToReason.get(this.justificationCode)
      ?.Justification_Description__c;

    this.uid = sourceData.uid;
    this.categoryId = sourceData.categoryId;
    this.categoryName = sourceData.categoryName;
    this.leafNode = sourceData.leafNode;
    this.etag = sourceData.etag;
    this.hemState = sourceData.hemState;
  }
}
