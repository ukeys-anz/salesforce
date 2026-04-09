/**
 * @author Vikas AM
 * @since  Fev 2026
 * @description This is the action class for CommercialOpportunityTriggerHandler
 */
public with sharing class CommercialBrokerOpportunityActions {
  @TestVisible
  private static final String PS_NAME = System.Label.AMBIT_Integration_User_PS_Name;
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  /**
   * @author A M Vikash | Salesforce | 02-11-2025
   * @description : This is used to prevent user from changing the Broker Name and Customer Name Change
   * @param records list of opportunities
   * @param oldMap Old values of opportunities
   */
  public static void preventCustAndBrokerChange(
    List<Opportunity> records,
    Map<Id, Opportunity> oldMap
  ) {
    // Check if the permission set is assigned, if assigned don't do anything else.
    if (USER_INFO.checkPermission(PS_NAME)) {
      return;
    }

    // If permission set is not assigned then prevent change on Customer & Broker change
    CommercialBrokerOpportunityActionsHelper.preventCustAndBrokerChange(
      records,
      oldMap
    );
  }
}
