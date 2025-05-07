/**
 * @author Raman Gupta
 * @date Nov 2024
 * @description Test class for {@link SOPUpdateSOPandPartyHelper}
 */
@isTest
public with sharing class SOPUpdateSOPandPartyHelperTest {
  @isTest
  static void testTransformToRelationshipState() {
    String relationshipState = 'In a relationship';
    String relationshipStateSingle = 'Single';
    Test.startTest();
    String transformedRelationshipState = SOPUpdateSOPandPartyHelper.transformToRelationshipState(
      relationshipState
    );

    String transformedRelationshipStateSingle = SOPUpdateSOPandPartyHelper.transformToRelationshipState(
      relationshipStateSingle
    );
    Test.stopTest();
    Assert.areEqual(
      transformedRelationshipState,
      'RELATIONSHIP_STATE_IN_RELATIONSHIP',
      'Relationship state is In a relationship'
    );
    Assert.areEqual(
      transformedRelationshipStateSingle,
      'RELATIONSHIP_STATE_SINGLE',
      'Relationship state is Single'
    );
  }

  @isTest
  static void testTransformSpouceEarnIncome() {
    Test.startTest();
    Boolean result = SOPUpdateSOPandPartyHelper.transformSpouceEarnIncome(
      'Yes'
    );
    Test.stopTest();
    // Assert the result
    Assert.isFalse(result, 'success');
  }

  @isTest
  static void testTransformPartiesList() {
    Test.startTest();
    List<SOPViewModel.Parties> result = SOPUpdateSOPandPartyHelper.transformPartiesList(
      getSOPViewModel
    );
    Test.stopTest();
    // Assert the result
    Assert.isNotNull(result, 'Parties should not be null');
    Assert.areEqual(
      result[0]?.partyDependantsCount,
      2,
      'party dependants counts should be expected'
    );
  }

  /**
   * @description Static method to return SOPViewModel Record
   */
  static SOPViewModel getSOPViewModel {
    get {
      SOPViewModel sopViewModel = new SOPViewModel();
      sopViewModel.name = 'e6782045-b850-46a6-8b13-ffb8839633c9';
      sopViewModel.parties = new List<SOPViewModel.Parties>();
      SOPViewModel.Parties party = new SOPViewModel.Parties();
      party.id = 'e6782045-b850-46a6-8b13-ffb8839633c9';
      party.ocvId = '123456';
      party.spouseEarnsIncome = false;
      party.soleIncomeEarner = 'Yes';
      party.partyDependantsCount = 2;
      party.relationshipState = 'Single';
      sopViewModel.parties.add(party);
      sopViewModel.dependantsCount = 2;
      sopViewModel.isSOPDataUpdated = true;
      sopViewModel.isPartyDataUpdated = true;
      sopViewModel.etag = '13243356664';
      return sopViewModel;
    }
  }
}
