/**
 * @author Amisha Gyani
 * @since February, 2026
 * @group CCRMAgent
 * @description CCRMAgentCreateOpportunity is an invocable Apex class that creates
 *              Opportunity records and returns their details
 */
public with sharing class CCRMAgentCreateOpportunity {
  /**
   * Repository for all query operations (injectable for tests).
   * Using an interface-driven provider enables dependency injection and unit test isolation.
   */
  private static final CCRMAgentforceActionRepository REPO = (CCRMAgentforceActionRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceActionRepository.class
  );

  /**
   * Repository for Agent Action History.
   */
  private static final AgentActionHistoryController AGENT_ACTION_REPO = (AgentActionHistoryController) Lib_InstanceProvider.forType(
    AgentActionHistoryController.class
  );

  /**
   * Repository wrapper for DML operations to centralize error handling and user-mode execution.
   */
  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Wrapper class for input details for opportunity creation
   */
  public class OpportunityInput {
    @InvocableVariable(required=true)
    public String opportunityName;

    @InvocableVariable(required=true)
    public Id accountId;

    @InvocableVariable(required=false)
    public String description;

    @InvocableVariable(required=true)
    public Date closeDate;
  }

  /**
   * @description Wrapper class for output details of created opportunity
   */
  public class OpportunityOutput {
    @InvocableVariable
    public Id opportunityId;

    @InvocableVariable
    public String opportunityJson;
  }

  /**
   * @description Factory method that constructs an Opportunity SObject from the provided input.
   * @param input Wrapper containing required and optional Opportunity fields
   * @param standardPbId Standard pricebook entry
   * @param closeDate Close date for opportunity
   * @param ownerId Owner Id for the opportunity record
   * @return Opportunity instance ready for insert
   */
  private static Opportunity buildOpportunity(
    OpportunityInput input,
    Id standardPbId,
    Date closeDate,
    Id ownerId
  ) {
    return new Opportunity(
      Name = input.opportunityName,
      AccountId = input.accountId,
      StageName = 'New',
      CloseDate = closeDate,
      Description = input.description,
      Pricebook2Id = standardPbId,
      OwnerId = ownerId
    );
  }

  /**
   * @description Invocable entry point that creates Opportunity records.
   * @param inputs List of OpportunityInput records provided by Flow
   * @return List of OpportunityOutput containing Ids and JSON details of created Opportunities
   */
  @InvocableMethod(
    label='Agent Action to Create Opportunity'
    description='Creates Opportunity records and returns their details.'
  )
  public static List<OpportunityOutput> createOpportunity(
    List<OpportunityInput> inputs
  ) {
    try {
      List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
      List<OpportunityOutput> outputs = new List<OpportunityOutput>();
      if (!inputs.isEmpty()) {
        Id standardPbId = REPO.getStandardPricebookId();
        Date closeDate = inputs[0].closeDate;
        Id ownerId = new UserInfoRepository().getUser().Id;
        opportunitiesToInsert.add(
          buildOpportunity(inputs[0], standardPbId, closeDate, ownerId)
        );
      }
      DML_REPO.doInsert(opportunitiesToInsert);

      if (!opportunitiesToInsert.isEmpty()) {
        Opportunity opp = opportunitiesToInsert[0];
        OpportunityOutput output = new OpportunityOutput();
        output.opportunityId = opp.Id;
        output.opportunityJson = JSON.serializePretty(opp);
        outputs.add(output);

        AGENT_ACTION_REPO.createAgentActionHistory(
          'Opportunity',
          'CRM AI Agent',
          'Created',
          new List<String>{ opp.Id }
        );
      }

      Logger.debug(
        'Successfully created Opportunities. Output count: ' + outputs.size()
      );
      Logger.saveLog();
      return outputs;
    } catch (Exception e) {
      Logger.error('Error creating opportunity: ' + e.getMessage());
      Logger.saveLog();
      throw e;
    }
  }
}
