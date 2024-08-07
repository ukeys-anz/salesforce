/**
 * @author Karen Valeriano
 * @since Jul 2024
 * @description Request Model for Stravinsky Updating Primary ID Document
 */
public with sharing class COBPrimaryIDDocUpdateRequestModel {
  static final String PASSPORT_TYPE = 'Passport';
  static final String LICENCE_TYPE = 'Licence';
  @TestVisible
  static final String PASSPORT_UPDATE_MASK =
    'primaryIdDocument.passport.firstName,' +
    'primaryIdDocument.passport.middleNames,' +
    'primaryIdDocument.passport.lastName,' +
    'primaryIdDocument.passport.countryOfIssue,' +
    'primaryIdDocument.passport.dateOfBirth.day,' +
    'primaryIdDocument.passport.dateOfBirth.month,' +
    'primaryIdDocument.passport.dateOfBirth.year,' +
    'primaryIdDocument.passport.expiryDate.day,' +
    'primaryIdDocument.passport.expiryDate.month,' +
    'primaryIdDocument.passport.expiryDate.year,' +
    'primaryIdDocument.passport.passportNumber';
  @TestVisible
  static final String AUSTRALIAN_DRIVER_LICENCE_UPDATE_MASK =
    'primaryIdDocument.australianDriverLicence.firstName,' +
    'primaryIdDocument.australianDriverLicence.middleNames,' +
    'primaryIdDocument.australianDriverLicence.lastName,' +
    'primaryIdDocument.australianDriverLicence.stateOfIssue,' +
    'primaryIdDocument.australianDriverLicence.dateOfBirth.day,' +
    'primaryIdDocument.australianDriverLicence.dateOfBirth.month,' +
    'primaryIdDocument.australianDriverLicence.dateOfBirth.year,' +
    'primaryIdDocument.australianDriverLicence.expiryDate.day,' +
    'primaryIdDocument.australianDriverLicence.expiryDate.month,' +
    'primaryIdDocument.australianDriverLicence.expiryDate.year,' +
    'primaryIdDocument.australianDriverLicence.licenceNumber,' +
    'primaryIdDocument.australianDriverLicence.licenceCardNumber';

  //use in api request
  public COBPrimaryIDDocumentModel primaryIdDocument;
  public String updateMask;
  public Id caseId;

  /**
   * @description constructor to build COBPrimaryIDDocUpdateRequestModel
   * @param idDocument the COBPrimaryIDDocument__c record
   * @param caseId ID Ops Assistance Case linked to the parent COB record
   */
  public COBPrimaryIDDocUpdateRequestModel(
    COBPrimaryIDDocument__c idDocument,
    Id caseId
  ) {
    if (idDocument.IdDocumentType__c == PASSPORT_TYPE) {
      this.updateMask = PASSPORT_UPDATE_MASK;
      this.primaryIdDocument = new COBPrimaryIDDocumentModel(
        new COBPrimaryIDDocumentModel.Passport(idDocument)
      );
    } else if (idDocument.IdDocumentType__c == LICENCE_TYPE) {
      this.updateMask = AUSTRALIAN_DRIVER_LICENCE_UPDATE_MASK;
      this.primaryIdDocument = new COBPrimaryIDDocumentModel(
        new COBPrimaryIDDocumentModel.AustralianDriverLicence(idDocument)
      );
    }
    this.caseId = caseId;
  }
}
