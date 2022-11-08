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
   * @param lookupString from address search bar
   * @return CCRMValidateAddressModel result
   * @description called from validateAddress lwc during address search
   */
  @AuraEnabled(cacheable=false)
  public static CCRMValidateAddressModel getAddressesLWC(String lookupString) {
    CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
    try {
      return ccrmapi.getAddresses(lookupString);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @param lookupString from address search bar
   * @return CCRMValidateAddressModel result
   * @description calls the service class methods for integration/callout
   */
  public CCRMValidateAddressModel getAddresses(String lookupString) {
    CCRMValidateAddressModel result;
    Service s = ServiceProvider.getService(CCRMValidateAddressService.class);
    HttpCalloutResponse response = s.getAddresses(lookupString);
    if (response.successful) {
      try {
        result = CCRMValidateAddressModel.parse(response.body);
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
   * @return CCRMValidateAddressModel result
   * @description calls the service class methods for integration/callout
   */
  public CCRMGetSelectedAddressModel getSelectedAddress(
    String encodedAddressId
  ) {
    CCRMGetSelectedAddressModel result;
    Service s = ServiceProvider.getService(CCRMValidateAddressService.class);
    HttpCalloutResponse response = s.getSelectedAddress(encodedAddressId);
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
}
