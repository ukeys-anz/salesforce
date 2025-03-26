/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description Mock implementation of mule api service for SOP service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class BOHServiceMock extends Service {
  /**
   * @description constructor which sets default code as successful
   */

  public BOHServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  private static final string SOP_RESPONSE = getStaticResource('mock_sop');

  @TestVisible
  private static final string CREDIT_ASSESSMENT_LIST_RESPONSE = getStaticResource(
    'mock_CRListAssessment'
  );

  private static final string CREDIT_ASSESSMENT_DELETE_RESPONSE = getStaticResource(
    'mock_CRDeleteReferralOutcome'
  );

  private static final string SOP_LIST_ASSETS_RESPONSE = getStaticResource(
    'mock_getConsolidateSOP'
  );
  private static final string UMI_LIST_ASSEEEMENTS_RESPONSE = getStaticResource(
    'mock_UMIListAssessments'
  );

  private static final string VERIFY_INSURANCE = getStaticResource(
    'mock_verifyInsurance'
  );

  private static final string CANCEL_LOAN_APP = getStaticResource(
    'mock_cancelHomeLoanApplication'
  );

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer savings and asset
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for sop api
   */

  public override HttpCalloutResponse getListAssets(
    String ocvId,
    String sopId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param verification whether the income is verified
   * @param ocvId ocv id of the customer account
   * @param incomeBody post data of income information
   * @return `HttpCalloutResponse` the api response
   * @description create income
   */
  public override HttpCalloutResponse createIncome(
    String verification,
    String ocvId,
    String incomeBody
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param verification whether the income is verified
   * @param ocvId ocv id of the customer account
   * @param incomeBody post data of income information
   * @param incomeVerifiedChanged checks if the income verified value has changed
   * @return `HttpCalloutResponse` the api response
   * @description update income
   */
  public override HttpCalloutResponse updateIncome(
    String verification,
    String ocvId,
    String incomeBody,
    Boolean incomeVerifiedChanged
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param expenseBody post data of expense information
   * @return `HttpCalloutResponse` the api response
   * @description edit Expense
   */
  public override HttpCalloutResponse editExpense(
    String ocvId,
    String expenseBody
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }
  /**
   * @param creditId to receive credit assessment list
   * @param ocvId customer ocv id
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for gearbox
   */
  public override HttpCalloutResponse getCreditAssessments(
    String creditId,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param sopId sop id of the customer account
   * @param ocvId ocv id of the customer account
   * @param incomeBody name and tag of income to be deleted
   * @return `HttpCalloutResponse` the api response
   * @description delete income
   */
  public override HttpCalloutResponse deleteIncome(
    String sopId,
    String ocvId,
    String incomeBody
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }
  /**
   * @param payload payload containing credit id and uuid from credit assessment
   * @param ocvId customer ocv id
   * @return `HttpCalloutResponse` the api response
   * @description submits credit assessment for reassessment
   */
  public override HttpCalloutResponse creditReassessment(
    String payload,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param creditId credit id from credit assessment
   * @param assessmentId id of assessment submitted for finalisation
   * @param ocvId customer ocv id
   * @return `HttpCalloutResponse` the api response
   * @description submits credit assessment for reassessment
   */
  public override HttpCalloutResponse finaliseAssessment(
    String creditId,
    String assessmentId,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param payload payload containing credit id, referralOutcome and uuid from credit assessment
   * @param ocvId customer ocv id
   * @return HttpCalloutResponse api response
   * @description submits referral outcome update
   */
  public override HttpCalloutResponse createCreditEnquiryAssessment(
    String payload,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param sopIds sop id
   * @param creditId credit id
   * @param ocvId ocv id of the primary loan application
   * @param termMonths Loan term in months
   * @param loanAmount Loan amount
   * @return `HttpCalloutResponse` the api response
   * @description fetches UMI assessments from sop and gearbox api through mule
   */
  public override HttpCalloutResponse getUMIAssessments(
    List<String> sopIds,
    String creditId,
    String ocvId,
    Integer termMonths,
    Decimal loanAmount
  ) {
    if (!preset) {
      response.body = BOHServiceMock.UMI_LIST_ASSEEEMENTS_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for sop api
   */
  public override HttpCalloutResponse getSOP(String ocvId, String sopId) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_RESPONSE;
    }
    return response;
  }

  /**
   * @param creditId to receive credit assessment list
   * @param ocvId ocv id of the customer account
   * @param assessmentId id of assessment submitted for finalisation
   * @param outcomeCode referral code to delete
   * @return `HttpCalloutResponse` the api response
   * @description delete income
   */
  public override HttpCalloutResponse deleteReferralOutcome(
    String creditId,
    String ocvId,
    String assessmentId,
    String outcomeCode
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_DELETE_RESPONSE;
    }
    return response;
  }
  /**
   * @param requestBody body of request to send
   * @param ocvId ocv id
   * @return `HttpCalloutResponse` the api response
   * @description delete income from sop
   */
  public override HttpCalloutResponse verifyInsurance(
    String requestBody,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.VERIFY_INSURANCE;
    }
    return response;
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param debtBody post data of debt information
   * @return `HttpCalloutResponse` the api response
   * @description create debt
   */
  public override HttpCalloutResponse createDebt(
    String ocvId,
    String debtBody
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param debtBody post data of debt information
   * @return `HttpCalloutResponse` the api response
   * @description edit debt
   */
  public override HttpCalloutResponse editDebt(String ocvId, String debtBody) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param sopId sop id of the customer account
   * @param ocvId ocv id of the customer account
   * @param debtBody name and tag of debt to be deleted
   * @return `HttpCalloutResponse` the api response
   * @description delete debt
   */
  public override HttpCalloutResponse deleteDebt(
    String sopId,
    String ocvId,
    String debtBody
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param loanAppNumber Loan application Number
   * @param ocvId required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description cancel home loan application through mule
   */
  public override HttpCalloutResponse cancelResidentialLoanApp(
    String loanAppNumber,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CANCEL_LOAN_APP;
    }

    return response;
  }
}
