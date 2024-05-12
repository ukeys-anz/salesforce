/**
 * @description       :
 * @author            : Transformers Squad - Anuj
 * @group             :
 * @last modified on  : 04-17-2024
 * @last modified by  : Transformers Squad - Shivraj
 **/
public with sharing class TFMCommonFunctionUtility {
  /**
   * @param idValue value for staffModel.idValue
   * @return `StaffTokenRequestModel`
   * @description set StaffTokenRequestModel class instance
   */
  public static StaffTokenRequestModel setStaffModel(String idValue) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = idValue;
    staffModel.anzTokenType = TFMConstants.ANZTOKENTYPE;
    return staffModel;
  }
}
