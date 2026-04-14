/**
 * @author A M VIKASH
 * @since  02/11//2025
 * @group CCRM (Commercial CRM)
 * @description CommercialBrokerOpportunityActionsHelper is class to handle all the operations on opp stage changes
 */
public class CommercialBrokerOpportunityActionsHelper {
  @TestVisible
  private static final String PREVENT_BROKER_CHANGE_ERROR_MSG = System.Label.Broker_Name_change_Error_on_Opportunity;
  @TestVisible
  private static final String PREVENT_CUSTOMER_CHANGE_ERROR_MSG = System.Label.Customer_Name_change_Error_on_Opportunity;
  private static final CommercialOpportunityRepository OPP_REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );
  private static final CommercialAppFormProductActionsRepo AFP_REPOSITORY = (CommercialAppFormProductActionsRepo) Lib_InstanceProvider.forType(
    CommercialAppFormProductActionsRepo.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
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
    string errorLocation;
    List<Opportunity> filteredBrokerOppList = ListUtil.filter(records, oldMap)
      .equals(Opportunity.RecordTypeId, RTOpportunity.commercialOpportunity)
      .changed(Opportunity.Broker_Name__c)
      .toList();
    List<Opportunity> filteredCustomerOppList = ListUtil.filter(records, oldMap)
      .equals(Opportunity.RecordTypeId, RTOpportunity.commercialOpportunity)
      .changed(Opportunity.AccountId)
      .toList();
    if (!filteredBrokerOppList.isEmpty()) {
      errorLocation = 'Broker';
      validateApfAndApfprod(
        filteredBrokerOppList,
        PREVENT_BROKER_CHANGE_ERROR_MSG,
        errorLocation
      );
    }
    if (!filteredCustomerOppList.isEmpty()) {
      errorLocation = 'Customer';
      validateApfAndApfprod(
        filteredCustomerOppList,
        PREVENT_CUSTOMER_CHANGE_ERROR_MSG,
        errorLocation
      );
    }
  }
  /**
   * @author A M Vikash | Salesforce | 02-11-2025
   * @description : This is used to validate the ApplicationForm And ApplicationFormProduct associated to the Opportunity
   * @param filteredOpty opportunityb records where
   * @param errormsg to show message
   * @param errorLocation to specify the location
   */
  public static void validateApfAndApfprod(
    List<Opportunity> filteredOpty,
    String errormsg,
    String errorLocation
  ) {
    Set<Id> validOppIds = getValidOpportunityIds(filteredOpty);
    addOpportunityErrors(filteredOpty, validOppIds, errormsg, errorLocation);
  }
  /**
   * @author A M Vikash | Salesforce | 02-11-2025
   * @description : This is used to extract applicationform and form product with the help of OpportunityIds
   * @param opportunities all updated
   * @return set of validopportunities
   */
  private static Set<Id> getValidOpportunityIds(
    List<Opportunity> opportunities
  ) {
    Set<Id> validOppIds = new Set<Id>();
    List<ApplicationForm> appForms = OPP_REPOSITORY.getApplicationFormsAndProducts(
      ListUtil.getIds(opportunities, Opportunity.Id)
    );

    for (ApplicationForm af : appForms) {
      if (
        af.ApplicationFormProducts != null &&
        !af.ApplicationFormProducts.isEmpty()
      ) {
        validOppIds.add(af.OpportunityId);
      }
    }
    return validOppIds;
  }
  /**
   * @author A M Vikash | Salesforce | 02-11-2025
   * @description : This is used to display errors
   * @param opportunities List of Opportunity records to process.
   * @param validOppIds Set of Opportunity IDs that are considered valid for error checking.
   * @param errorMsg The error message to add to the specified field.
   * @param errorLocation The field where the error should be added.
   */
  private static void addOpportunityErrors(
    List<Opportunity> opportunities,
    Set<Id> validOppIds,
    String errorMsg,
    String errorLocation
  ) {
    for (Opportunity opp : opportunities) {
      if (!validOppIds.contains(opp.Id)) {
        continue;
      }

      if (errorLocation == 'Broker') {
        opp.Broker_Name__c.addError(errorMsg);
      } else if (errorLocation == 'Customer') {
        opp.AccountId.addError(errorMsg);
      }
    }
  }
}
