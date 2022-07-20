/**
 * @author Emma Bindi
 * @since July 2022
 * @description Model for disputes API
 * Suppressing PMD naming convention warnings as api returns snake case formatting
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
public with sharing class DisputesModel extends CalloutModel {
  /**
   * @description the search tokenized card number response wrapper
   */
  public with sharing class SearchTokenizedCardResponseCls {
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String tokenized_card_number;
  }

  /**
   * @param json input string to deserialize
   * @return `DisputesModel.SearchTokenizedCardResponseCls`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static DisputesModel.SearchTokenizedCardResponseCls parseTokenizedCardResponse(
    String json
  ) {
    return (DisputesModel.SearchTokenizedCardResponseCls) deserialize(
      json,
      DisputesModel.SearchTokenizedCardResponseCls.class
    );
  }
}
