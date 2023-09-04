/**
 * @author Hannah Sainumkheaw
 * @since  11/2022
 * @description Test class to cover validation rules for Interaction object
 */
@isTest
public with sharing class InteractionValidationTest {
  private static final String CALL_INTERACTIONTYPE = 'Call';
  private static final String INTERACTION_PURPOSE = 'Customer';
  private static final String AUTHENTICATION_METHOD = 'Manually Authenticated';
  private static final String CALL_DIRECTION = 'Inbound';
  private static final String INTERACTION_VR2_ERROR = 'This type of channel interaction requires a direction to be selected before you can save it.';

  //Test VR2_No_Blank_Direction_in_Call_Type with error
  @isTest
  static void testInteractionVR2WithError() {
    //GIVEN
    //A call interaction with missing direction
    Interaction testInteraction = createInteraction();

    Test.startTest();
    //WHEN
    //Inserting a callfor interaction with no direction provided
    try {
      insert testInteraction;
      System.assert(
        false,
        'Failed to prevent against user creating a call for interaction with missing direction (null call)'
      );
      //THEN
      //an error message should be thrown by VR2_No_Blank_Direction_in_Call_Type validation rule
    } catch (DmlException e) {
      System.assertEquals(
        true,
        e.getMessage().contains(INTERACTION_VR2_ERROR),
        'Error messgaes should match'
      );
    }
    Test.stopTest();
  }

  //Test VR2_No_Blank_Direction_in_Call_Type without error
  @isTest
  static void testInteractionVR2WithoutError() {
    //GIVEN
    //A call interaction with direction
    Interaction testInteraction = createInteraction();
    testInteraction.Direction__c = CALL_DIRECTION;

    Test.startTest();
    //WHEN
    //Inserting a call for interaction with direction selected
    try {
      insert testInteraction;
      //THEN
      //The call with provided direction should pass the validation rule
    } catch (DmlException e) {
      System.assertEquals(null, e, 'Error message should be null.');
    }
    Test.stopTest();
  }

  //Create Interaction with mandatory fields
  private static Interaction createInteraction() {
    Interaction newInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      InteractionType = CALL_INTERACTIONTYPE,
      Interaction_Purpose__c = INTERACTION_PURPOSE,
      Authentication_Method__c = AUTHENTICATION_METHOD
    );
    return newInteraction;
  }
}
