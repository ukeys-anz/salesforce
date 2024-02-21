/**
 * @author Hinduja Upadhyay
 * @since DEC 2023
 * @description util class for Aegis migration squad
 * @group Utils
 */
public with sharing class TFMCheckADGroupAccessUtil {
  /**
   * @param func Enum for specifying which type of fuction user wants to perform
   * @param token ocv id or persona Id or Mobile
   * @return Boolean validating the user
   * @description sets Authorization required for a callout
   */
  public static String checkADGroupWithfunctionality(
    String func,
    String token
  ) {
    String validUser = 'false';
    //strip jwt header
    List<String> tokenParts = token.split('\\.');
    //decode claims to json map, the first part is header, second part is claims
    String decodedString = EncodingUtil.base64Decode(
        CommonUtil.base64URLToBase64(tokenParts[1])
      )
      .toString();
    Map<String, Object> tokenMap = (Map<String, Object>) (JSON.deserializeUntyped(
      decodedString
    ));
    Object rolesObj = tokenMap.get('scopes');
    List<String> rolesAsStrings = (List<String>) JSON.deserialize(
      JSON.serialize(rolesObj),
      List<String>.class
    );
    // get Custom mdt
    TFMGroupsWithFunctionality__mdt groupWithFuncMdt = TFMGroupsWithFunctionality__mdt.getInstance(
      func
    );

    List<String> adGroupsValueList = groupWithFuncMdt.AssociatedGroups__c.split(
      ','
    );
    for (String adGroup : adGroupsValueList) {
      for (String role : rolesAsStrings) {
        if (adGroup.equals(role)) {
          validUser = 'true';
          return validUser;
        }
      }
    }
    return validUser;
  }
}
