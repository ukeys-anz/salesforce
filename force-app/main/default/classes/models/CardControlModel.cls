/**
 * @author Emma Bindi
 * @since June 2022
 * @description Model for Card Controls API
 * Suppressing PMD naming convention warning as api returns snake case formatting
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
public with sharing class CardControlModel extends CalloutModel {
  /**
   * @description the ListControlsResponse wrapper
   */
  @AuraEnabled
  public List<CardControlWrapper> card_controls;

  /**
   * @description the wrapper representing CardControlResponse / SetControlsRequest etc
   */
  public with sharing class CardControlWrapper {
    @AuraEnabled
    public List<CardControlCls> card_controls;
    @AuraEnabled
    public String tokenized_card_number;
  }

  /**
   * @description the Card Control wrapper
   */
  public class CardControlCls {
    @AuraEnabled
    public String control_type;
    @AuraEnabled
    public String impulse_delay_period;
    @AuraEnabled
    public String impulse_delay_start;

    /**
     * @description the Card Control Cls
     * @param controlType String representing the control type
     */
    public CardControlCls(String controlType) {
      this.control_type = controlType;
    }
  }

  /**
   * @param json input string to deserialize
   * @return `CardControlModel`  card controls representing ListControlsResponse
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static CardControlModel parseCardControlList(String json) {
    return (CardControlModel) deserialize(json, CardControlModel.class);
  }

  /**
   * @param json input string to deserialize
   * @return `CardControlModel.CardControlWrapper`  card controls wrapper
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static CardControlModel.CardControlWrapper parseCardControl(
    String json
  ) {
    return (CardControlModel.CardControlWrapper) deserialize(
      json,
      CardControlModel.CardControlWrapper.class
    );
  }
}
