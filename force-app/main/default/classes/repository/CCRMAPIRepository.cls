/**
 * @author Boobalakrishnan Duraisamy
 * @since Mar 2022
 * @description CCRM API repository for all CCRM callouts
 * @group Repository
 */
public with sharing class CCRMAPIRepository extends RepositoryBase {
  /**
   * @param abn Australian Business Number to be validated
   * @return CCRMValidateAbnAcnModel result
   * @description calls the service class methods for integration/callout
   */
  public CCRMValidateAbnAcnModel validateAbn(String abn) {
    CCRMValidateAbnAcnModel result;
    Service s = ServiceProvider.getService(CCRMValidateAbnAcnService.class);
    HttpCalloutResponse response = s.getAbnAcnInformation(
      Label.MS_Get_Abr_Abn,
      abn
    );
    if (response.successful) {
      try {
        result = CCRMValidateAbnAcnModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }

  /**
   * @param acn Australian Company Number to be validated
   * @return CCRMValidateAbnAcnModel result
   * @description calls the service class methods for integration/callout
   */
  public CCRMValidateAbnAcnModel validateAcn(String acn) {
    CCRMValidateAbnAcnModel result;
    Service s = ServiceProvider.getService(CCRMValidateAbnAcnService.class);
    HttpCalloutResponse response = s.getAbnAcnInformation(
      Label.MS_Get_Abr_Acn,
      acn
    );
    if (response.successful) {
      try {
        result = CCRMValidateAbnAcnModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }

  /**
   * @param encodedAddressId from selected address record
   * @return CCRMGetSelectedAddressModel result
   * @description called from validateAddress lwc during address search
   */
  @AuraEnabled(cacheable=false)
  public static CCRMGetSelectedAddressModel getSelectedAddressLWC(
    String encodedAddressId
  ) {
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    try {
      return ccrmapi.getSelectedAddress(encodedAddressId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @param encodedAddressId from selected address record
   * @return CCRMGetSelectedAddressModel result
   * @description calls the service class methods for integration/callout
   */
  public CCRMGetSelectedAddressModel getSelectedAddress(
    String encodedAddressId
  ) {
    CCRMGetSelectedAddressModel result;
    Service s = ServiceProvider.getService(CCRMValidateAddressService.class);
    HttpCalloutResponse response = s.getSelectedAddressWithANZLayoutV3(
      encodedAddressId
    );
    if (response.successful) {
      try {
        result = CCRMGetSelectedAddressModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }

  /**
   * @param lookupString from address search bar
   * @return CCRMValidateAddressModelV3 result
   * @description called from validateAddress lwc during address search
   */
  @AuraEnabled(cacheable=true)
  public static CCRMValidateAddressModelV3 getAddressesLwcV3(
    String lookupString
  ) {
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    try {
      return ccrmapi.getAddressesV3(lookupString);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @param lookupString from address search bar
   * @return CCRMValidateAddressModelV3 result
   * @description calls the service class methods for integration/callout
   */
  public CCRMValidateAddressModelV3 getAddressesV3(String lookupString) {
    CCRMValidateAddressModelV3 result;
    Service s = ServiceProvider.getService(CCRMValidateAddressService.class);
    HttpCalloutResponse response = s.getAddressesV3(lookupString);
    if (response.successful) {
      try {
        result = CCRMValidateAddressModelV3.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }

  /**
   * @param globalAddressKey from selected address record
   * @return CCRMGetSelectedAddressModelV3 result
   * @description called from validateAddress lwc during address search
   */
  @AuraEnabled(cacheable=true)
  public static CCRMGetSelectedAddressModelV3 getSelectedAddressLwcV3(
    String globalAddressKey
  ) {
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    try {
      return ccrmapi.getSelectedAddressV3(globalAddressKey);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @param globalAddressKey from selected address record
   * @return CCRMGetSelectedAddressModelV3 result
   * @description calls the service class methods for integration/callout
   */
  public CCRMGetSelectedAddressModelV3 getSelectedAddressV3(
    String globalAddressKey
  ) {
    CCRMGetSelectedAddressModelV3 result;
    Service s = ServiceProvider.getService(CCRMValidateAddressService.class);
    HttpCalloutResponse response = s.getSelectedAddressV3(globalAddressKey);
    if (response.successful) {
      try {
        result = CCRMGetSelectedAddressModelV3.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }

  /**
   * @param record Lead record
   * @return CCRMSearchPartyModel result
   * @description calls the service class methods for integration/callout
   */
  public CCRMSearchPartyModel searchPartyInfo(Lead record) {
    CCRMSearchPartyModel result;
    Service s = ServiceProvider.getService(CCRMSearchPartyService.class);
    HttpCalloutResponse response = s.searchPartyInfo(record);
    if (response.successful) {
      try {
        result = CCRMSearchPartyModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }

  /**
   * @param record Lead record
   * @return CCRMCreatePartyModel result
   * @description calls the service class methods for integration/callout
   */
  public CCRMCreatePartyModel createParty(Lead record) {
    CCRMCreatePartyModel result;
    Service s = ServiceProvider.getService(CCRMCreatePartyService.class);
    HttpCalloutResponse response = s.createParty(record);
    if (response.successful) {
      try {
        result = CCRMCreatePartyModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }

  /**
   * @param record Lead record
   * @return DCRMMaintainPartyModel result
   * @description calls the service class methods for integration/callout
   */
  public DCRMMaintainPartyModel maintainParty(OCVRequestPayloadWrapper record) {
    DCRMMaintainPartyModel result;
    Service s = ServiceProvider.getService(DCRMMaintainPartyService.class);
    HttpCalloutResponse response = s.maintainParty(record);
    if (response.successful) {
      try {
        result = DCRMMaintainPartyModel.parse(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CCRMAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CCRMAPIRepository.class);
    }
    return result;
  }
}