/**
 * @author Amisha Gyani
 * @since 2025
 * @description  Test class for CCRMAgentCustomerSummaryPrompt invocable Apex class.
 */
@IsTest
private class CCRMAgentCustomerSummaryPromptTest {
  static Lib_MockProvider repoMock;
  static Lib_MockProvider userRepoMock;
  static void registerMocks() {
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
    repoMock = Lib_MockProvider.forType(CCRMAgentforceRepository.class);
  }
  @IsTest
  /**
   * @description Positive test: Validate prompt JSON contains key sections.
   */
  static void testGetPromptSuccess() {
    registerMocks();
    // Common Non-CLG path mocks
    repoMock.mock('fetchInteractionCount', 3);

    List<Interaction> interactions = new List<Interaction>{
      new Interaction(
        Id = Lib_FakeIdGenerator.getMockId(Interaction.SobjectType),
        Name = 'Call Follow-Up',
        Optional_Notes__c = 'Notes',
        Interaction_Type__c = 'Phone',
        StartTime = Datetime.now().addDays(-5)
      )
    };
    repoMock.mock('fetchLatestInteractions', interactions);
    // CLG path mocks (these will not be used in this test since RecordType is businessAccount,
    // but are provided to ensure method presence is covered and stubbable)
    repoMock.mock('fetchInteractionCountForCLG', 5);
    repoMock.mock('fetchLatestInteractionsForCLG', interactions);

    User oppOwner = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType)
    );
    List<Opportunity> opps = new List<Opportunity>{
      new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Opportunity.SobjectType),
        Name = 'Opportunity 1',
        Owner = oppOwner
      )
    };
    repoMock.mock('fetchOpportunities', opps);
    // CLG variant stubbed for coverage
    repoMock.mock('fetchOpportunitiesForCLG', opps);

    // Application Form Products replacing OLI path in main class
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
      Stage = 'Submitted',
      Product = new Product2(Name = 'Product X'),
      Opportunity_Product__c = Lib_FakeIdGenerator.getMockId(
        OpportunityLineItem.SObjectType
      ),
      Opportunity_Product__r = (OpportunityLineItem) new OpportunityLineItem(
        OpportunityId = opps[0].Id
      )
    );
    List<ApplicationFormProduct> afps = new List<ApplicationFormProduct>{ afp };
    repoMock.mock('fetchApplicationFormProductsByOppIds', afps);
    List<Lead> leads = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Status = 'Open',
        SubStatus__c = 'New',
        Referral_Status__c = 'Pending'
      )
    };
    repoMock.mock('fetchLeads', leads);
    // CLG variant stubbed for coverage
    repoMock.mock('fetchLeadsForCLG', leads);
    List<A_Z_Review__c> reviews = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SobjectType),
        Name = 'Review A',
        CreatedDate = Date.today().addDays(-3),
        Business_Details__c = 'Good business details',
        Borrowing_OFI_Relationship__c = 'Strong',
        Personal_Banking__c = 'High Value'
      )
    };
    repoMock.mock('fetchAZReviews', reviews);
    // CLG variant stubbed for coverage
    repoMock.mock('fetchAZReviewsForCLG', reviews);
    List<qualtrics__Survey_Response__c> surveys = new List<qualtrics__Survey_Response__c>{
      new qualtrics__Survey_Response__c(
        Id = Lib_FakeIdGenerator.getMockId(
          qualtrics__Survey_Response__c.SObjectType
        ),
        Name = 'Survey 1',
        A_Z_Review__c = reviews[0].Id,
        Customer_Feedback__c = 'Great service',
        qualtrics__Date_Responded__c = Date.today(),
        qualtrics__Net_Promoter_Score__c = 10
      )
    };
    repoMock.mock('fetchSurveyResponses', surveys);
    List<Customer_Relationship__c> rels = new List<Customer_Relationship__c>{
      new Customer_Relationship__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Customer_Relationship__c.SObjectType
        ),
        Status__c = 'Active'
      )
    };
    repoMock.mock('fetchCustomerRelationships', rels);
    List<Task> tasks = new List<Task>{
      new Task(
        Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
        Subject = 'Follow up',
        ActivityDate = Date.today()
      )
    };
    repoMock.mock('fetchOpenTasks', tasks);

    User pbUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Commercial_Segment__c = 'PB'
    );
    userRepoMock.mock('getUser', pbUser);
    userRepoMock.mock('checkCustomPermission', true);

    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account',
      RecordTypeId = RTAccount.businessAccount,
      ExtraCareTimePeriod__c = 'Active',
      ExtraCareReason__c = 'Financial Hardship'
    );

    repoMock.mock('fetchAccountAccountRelationsForExtraCare', 1);

    CCRMAgentCustomerSummaryPrompt.Request req = new CCRMAgentCustomerSummaryPrompt.Request();
    req.accountObj = acc;
    Test.startTest();
    List<CCRMAgentCustomerSummaryPrompt.Response> result = CCRMAgentCustomerSummaryPrompt.getPrompt(
      new List<CCRMAgentCustomerSummaryPrompt.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(1, result.size(), 'Should return 1 result');
    Assert.isNotNull(result[0].prompt, 'Prompt should not be null');

    String json = result[0].prompt;
    Assert.isTrue(
      json.contains('Account'),
      'Prompt should contain Account section'
    );
    Assert.isTrue(
      json.contains('Interactions'),
      'Prompt should contain Interactions section'
    );
    Assert.isTrue(
      json.contains('Opportunities'),
      'Prompt should contain Opportunities section'
    );
    Assert.isTrue(
      json.contains('A_Z_Reviews'),
      'Prompt should contain A_Z_Reviews section'
    );
    Assert.isTrue(
      json.contains('ExtraCare'),
      'Prompt should contain ExtraCare section'
    );
    Assert.isTrue(
      json.contains('SuggestedTasks'),
      'Prompt should contain SuggestedTasks section'
    );
  }

  @IsTest
  /**
   * @description Negative test: Validates Extra Care alert is shown when no direct Extra Care flags exist on the Account
   */
  static void testExtraCareFromRelatedAccounts() {
    registerMocks();
    userRepoMock.mock('checkCustomPermission', true);

    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      ExtraCareTimePeriod__c = 'Not Required',
      ExtraCareReason__c = null
    );

    repoMock.mock('fetchAccountAccountRelationsForExtraCare', 1);

    Test.startTest();
    Map<String, Object> result = CCRMAgentCustomerSummaryPrompt.buildExtraCare(
      acc
    );
    Test.stopTest();

    Assert.isTrue(
      (Boolean) result.get('ShowExtraCareAlert'),
      'Extra care alert should be shown when related accounts exist'
    );

    Assert.isTrue(
      ((String) result.get('ExtraCareMessage'))
        .contains('related Extra Care customer'),
      'Message should indicate related Extra Care customer'
    );
  }

  @IsTest
  /**
   * @description Negative test: Request with null Account should return error.
   */
  static void testNullAccountInRequest() {
    CCRMAgentCustomerSummaryPrompt.Request req = new CCRMAgentCustomerSummaryPrompt.Request();
    List<CCRMAgentCustomerSummaryPrompt.Response> r = CCRMAgentCustomerSummaryPrompt.getPrompt(
      new List<CCRMAgentCustomerSummaryPrompt.Request>{ req }
    );
    Assert.areEqual(
      'No account data provided.',
      r[0].prompt,
      'Should return error message for null account in request'
    );
  }
  @IsTest
  /**
   * @description Utility test: Verifies suggested task filter logic produces expected items.
   */
  static void testFilterSuggestedTasks() {
    Interaction i = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      Name = 'Interaction A',
      StartTime = Datetime.now().addDays(-5),
      Optional_Notes__c = 'Test notes'
    );
    A_Z_Review__c r = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
      Name = 'Review A',
      CreatedDate = Date.today().addDays(-5),
      Business_Details__c = 'Details'
    );
    Date cutoff = Date.today().addMonths(-6);
    List<Map<String, Object>> result = CCRMAgentCustomerSummaryPrompt.filterSuggestedTasks(
      new List<Interaction>{ i },
      new List<A_Z_Review__c>{ r },
      cutoff
    );
    Assert.areEqual(
      2,
      result.size(),
      'filterSuggestedTasks should return 2 items'
    );
  }
  @IsTest
  /**
   * @description Mapper test: Validates Account map keys/values.
   */
  static void testBuildAccountMap() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account',
      RecordTypeId = RTAccount.businessAccount
    );
    Map<String, Object> result = CCRMAgentCustomerSummaryPrompt.buildAccountMap(
      acc
    );
    Assert.areEqual(acc.Id, result.get('AccountId'), 'AccountId should match');
  }
  @IsTest
  /**
   * @description Mapper test: Validates Interaction map structure.
   */
  static void testBuildInteractionMap() {
    Interaction i = new Interaction(
      Id = Lib_FakeIdGenerator.getMockId(Interaction.SObjectType),
      Name = 'Call Follow-up',
      Optional_Notes__c = 'Discussed features',
      Interaction_Type__c = 'Call',
      StartTime = Datetime.now()
    );
    List<Map<String, Object>> result = CCRMAgentCustomerSummaryPrompt.buildInteractionMap(
      new List<Interaction>{ i }
    );
    Assert.areEqual(1, result.size(), 'Should return 1 interaction map');
    Map<String, Object> interactionMap = result[0];
    Assert.areEqual(
      i.Id,
      interactionMap.get('InteractionId'),
      'InteractionId should match'
    );
    Assert.areEqual(
      i.Name,
      interactionMap.get('InteractionName'),
      'InteractionName should match'
    );
  }
  @IsTest
  /**
   * @description Mapper test: Validates Opportunity map structure.
   */
  static void testBuildOpportunityMap() {
    Opportunity opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      Name = 'Opportunity 1',
      StageName = 'Prospecting',
      Amount = 1000,
      Approved_Amount__c = 900,
      CloseDate = Date.today(),
      Lost_Reason__c = 'Price',
      Owner = new User(Id = Lib_FakeIdGenerator.getMockId(User.SObjectType))
    );
    // Updated to align with AFP-based mapping
    ApplicationFormProduct afp1 = new ApplicationFormProduct(
      Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
      Stage = 'Submitted',
      Product = new Product2(Name = 'Product A'),
      Opportunity_Product__c = Lib_FakeIdGenerator.getMockId(
        OpportunityLineItem.SObjectType
      ),
      Opportunity_Product__r = (OpportunityLineItem) new OpportunityLineItem(
        OpportunityId = opp.Id
      )
    );
    List<Map<String, Object>> result = CCRMAgentCustomerSummaryPrompt.buildOpportunityMap(
      new List<Opportunity>{ opp },
      new List<ApplicationFormProduct>{ afp1 }
    );
    Assert.areEqual(1, result.size(), 'Should return 1 opportunity map');
    Map<String, Object> oppMap = result[0];
    Assert.areEqual(
      opp.Id,
      oppMap.get('OpportunityId'),
      'OpportunityId should match'
    );
  }
  @IsTest
  /**
   * @description Grouper test: Validates OLIs grouping by Opportunity Id.
   */
  static void testGroupAFPsByOpportunity() {
    Opportunity opp = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType)
    );
    ApplicationFormProduct afp1 = new ApplicationFormProduct(
      Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
      Stage = 'Submitted',
      Product = new Product2(Name = 'Product A'),
      Opportunity_Product__c = Lib_FakeIdGenerator.getMockId(
        OpportunityLineItem.SObjectType
      ),
      Opportunity_Product__r = (OpportunityLineItem) new OpportunityLineItem(
        OpportunityId = opp.Id
      )
    );
    ApplicationFormProduct afp2 = new ApplicationFormProduct(
      Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
      Stage = 'Approved',
      Product = new Product2(Name = 'Product B'),
      Opportunity_Product__c = Lib_FakeIdGenerator.getMockId(
        OpportunityLineItem.SObjectType
      ),
      Opportunity_Product__r = (OpportunityLineItem) new OpportunityLineItem(
        OpportunityId = opp.Id
      )
    );
    Map<Id, List<Map<String, Object>>> result = CCRMAgentCustomerSummaryPrompt.groupAFPsByOpportunity(
      new List<ApplicationFormProduct>{ afp1, afp2 }
    );
    Assert.areEqual(
      2,
      result.get(opp.Id).size(),
      'Should group 2 AFPs by opportunity'
    );
  }
  @IsTest
  /**
   * @description Mapper test: Validates Lead map structure.
   */
  static void testBuildLeadMap() {
    Lead l = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      Status = 'Open',
      SubStatus__c = 'New',
      Referral_Status__c = 'Pending'
    );
    List<Map<String, Object>> result = CCRMAgentCustomerSummaryPrompt.buildLeadMap(
      new List<Lead>{ l }
    );
    Assert.areEqual(1, result.size(), 'Should return 1 lead map');
    Map<String, Object> leadMap = result[0];
    Assert.areEqual(l.Id, leadMap.get('LeadId'), 'LeadId should match');
  }
  @IsTest
  /**
   * @description Mapper test: Validates AZ Review + Survey mapper structure.
   */
  static void testBuildAZReviewsMap() {
    A_Z_Review__c r = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
      Name = 'Review A',
      Business_Details__c = 'Good business details',
      Borrowing_OFI_Relationship__c = 'Strong',
      Personal_Banking__c = 'High Value',
      CreatedDate = Date.today()
    );
    qualtrics__Survey_Response__c survey = new qualtrics__Survey_Response__c(
      Id = Lib_FakeIdGenerator.getMockId(
        qualtrics__Survey_Response__c.SObjectType
      ),
      Name = 'Survey 1',
      A_Z_Review__c = r.Id,
      Customer_Feedback__c = 'Great service',
      qualtrics__Date_Responded__c = Date.today(),
      qualtrics__Net_Promoter_Score__c = 10
    );
    List<Map<String, Object>> result = CCRMAgentCustomerSummaryPrompt.buildAZReviewsMap(
      new List<A_Z_Review__c>{ r },
      new List<qualtrics__Survey_Response__c>{ survey }
    );
    Assert.areEqual(1, result.size(), 'Should return 1 review map');
    Map<String, Object> reviewMap = result[0];
    Assert.areEqual(r.Id, reviewMap.get('Id'), 'Id should match');
  }
  @IsTest
  /**
   * @description Grouper test: Verifies survey responses are grouped by related review Id.
   */
  static void testGroupSurveyResponsesByReview() {
    A_Z_Review__c r = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType)
    );
    qualtrics__Survey_Response__c survey = new qualtrics__Survey_Response__c(
      Id = Lib_FakeIdGenerator.getMockId(
        qualtrics__Survey_Response__c.SObjectType
      ),
      Name = 'Survey 1',
      A_Z_Review__c = r.Id,
      Customer_Feedback__c = 'Great service',
      qualtrics__Date_Responded__c = Date.today(),
      qualtrics__Net_Promoter_Score__c = 10
    );
    Map<Id, List<Map<String, Object>>> result = CCRMAgentCustomerSummaryPrompt.groupSurveyResponsesByReview(
      new List<qualtrics__Survey_Response__c>{ survey }
    );
    Assert.areEqual(
      1,
      result.get(r.Id).size(),
      'Should group 1 survey response by review'
    );
  }
  @IsTest
  /**
   * @description Mapper test: Validates Task map structure.
   */
  static void testBuildTaskMap() {
    Task t = new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Subject = 'Follow up',
      ActivityDate = Date.today()
    );
    List<Map<String, Object>> result = CCRMAgentCustomerSummaryPrompt.buildTaskMap(
      new List<Task>{ t }
    );
    Assert.areEqual(1, result.size(), 'Should return 1 task map');
    Map<String, Object> taskMap = result[0];
    Assert.areEqual(t.Id, taskMap.get('TaskId'), 'TaskId should match');
  }
  @IsTest
  /**
   * @description Mapper test: Validates ExtraCare structure presence.
   */
  static void testBuildExtraCare() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      ExtraCareTimePeriod__c = 'Active',
      ExtraCareReason__c = 'Financial Hardship'
    );
    Map<String, Object> result = CCRMAgentCustomerSummaryPrompt.buildExtraCare(
      acc
    );
    Assert.isNotNull(result, 'Result should not be null');
  }

  /**
   * @description Mapper test: Validates PB Notes mapping.
   */
  @IsTest
  static void testBuildPBNotes() {
    registerMocks();
    // Create PB user
    User pbUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Commercial_Segment__c = 'PB'
    );
    userRepoMock.mock('getUser', pbUser);
    Customer_Relationship__c cr = new Customer_Relationship__c(
      Id = Lib_FakeIdGenerator.getMockId(Customer_Relationship__c.SObjectType),
      Private_Banker_Advisor__c = pbUser.Id,
      Customer_Areas_of_Interest__c = 'Investments',
      Priorities_and_Objectives__c = 'Growth',
      Other_Account_Plan_Information__c = 'Plan Details',
      ANZ_Opportunities__c = 'Cross-sell',
      Competitive_Landscape_and_ANZ_Relative__c = 'Strong',
      Notes__c = 'Important notes',
      Personal_Background__c = 'Background info',
      Financial_Wealth_Background__c = 'Wealth info',
      Business_Investment_Background__c = 'Investment info',
      Additional_Details__c = 'Extra info',
      Status__c = 'Active'
    );
    Test.startTest();
    List<Map<String, Object>> result = CCRMAgentCustomerSummaryPrompt.buildPBNotes(
      Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      new List<Customer_Relationship__c>{ cr }
    );
    Test.stopTest();
    Assert.areEqual(1, result.size(), 'Should return 1 PB note map');
    Map<String, Object> pbNoteMap = result[0];
    Assert.areEqual(cr.Id, pbNoteMap.get('Id'), 'Id should match');
  }
}
