/**
 * @author Peter Charalambous
 * @since Wed Nov 01 2023
 * @description test class for settlement trigger handler
 */
@isTest
public with sharing class SettlementTriggerHandlerTest {
  @isTest
  static void testActionPlanCreated() {
    Faker faker = new Faker('AU');
    List<Settlement__c> settlementList = new List<Settlement__c>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      settlementList.add(
        new Settlement__c(
          Id = Lib_FakeIdGenerator.getMockId(Settlement__c.getSObjectType()),
          Type__c = faker.randomElement(
            new List<String>{ 'TYPE_REFINANCE_INTERNAL', 'TYPE_REFINANCE_OFI' }
          )
        )
      );
    }

    SettlementActions.actionPlansMap.put(
      'External Settlement Action Plan',
      new ActionPlanTemplateVersion(
        Id = Lib_FakeIdGenerator.getMockId(
          ActionPlanTemplateVersion.getSObjectType()
        )
      )
    );
    SettlementActions.actionPlansMap.put(
      'Internal Settlement Action Plan',
      new ActionPlanTemplateVersion(
        Id = Lib_FakeIdGenerator.getMockId(
          ActionPlanTemplateVersion.getSObjectType()
        )
      )
    );

    List<ActionPlan> actionPlans = SettlementActions.createActionPlansRecords(
      settlementList
    );

    Assert.areEqual(
      settlementList.size(),
      actionPlans.size(),
      'Each settlement record should have an action plan'
    );
  }
}
