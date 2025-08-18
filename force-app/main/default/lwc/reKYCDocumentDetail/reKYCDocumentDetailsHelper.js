const TRUSTME_CUSTOMER_ATTRIBUTE = {
  TrustMe_First_Name__c: "TrustMe First Name",
  TrustMe_Last_Name__c: "TrustMe Last Name",
  TrustMe_Middle_Name__c: "TrustMe Middle Name"
};
const TRUSTME_DOCUMENT_VERIFICATION = {
  Evaluation_Date__c: "Evaluation Date",
  Evaluation_Outcome__c: "Evaluation Outcome",
  eIDV_Verification_Outcome__c: "eIDV Verification Outcome",
  Selfie_Verification_Outcome__c: "Selfie Verification Outcome",
  Manual_Verification_Outcome__c: "Manual Verification Outcome",
  TrustMe_Primary_Document_ID__c: "TrustMe Primary Document ID"
};
const TRUSTME_ADDITIONAL_CUSTOMER_CONTEXT = {
  Customer_UUID__c: "PersonID",
  Date_Of_Birth__c: "Date Of Birth",
  QAS__c: "QAS",
  Daon_Selfie_Match_ID__c: "Daon Selfie Match ID",
  Daon_Evaluation_Outcome__c: "Daon Evaluation Outcome",
  Existing_Selfie__c: "Existing Selfie",
  TrustMe_Secondary_Document_ID__c: "TrustMe Secondary Document ID"
};

export const DOCUMENTYPE = {
  DOCUMENT_TYPE_PASSPORT: "DOCUMENT_TYPE_AUSTRALIAN_PASSPORT",
  DOCUMENT_TYPE_DRIVERS_LICENCE: "DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE",
  DOCUMENT_TYPE_PROOF_OF_AGE: "DOCUMENT_TYPE_AUSTRALIAN_PROOF_OF_AGE",
  DOCUMENT_TYPE_MEDICARE: "DOCUMENT_TYPE_AUSTRALIAN_MEDICARE",
  DOCUMENT_TYPE_BIRTH_CERTIFICATE: "DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE",
  TYPE_UNSPECIFIED: "DOCUMENT_TYPE_UNSPECIFIED"
};

export const FILES_BY_DOCUMENTTYPE = {
  DOCUMENT_TYPE_DRIVERS_LICENCE: [
    {
      fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Drivers License Front"
    },
    {
      fileType: "DAON_FILE_TYPE_BACK_PROCESSED",
      title: "Processed Drivers License Back"
    },
    {
      fileType: "DAON_FILE_TYPE_SELFIE_ANZX_REKYC_FACE",
      title: "Selfie"
    },
    {
      fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Drivers License Front"
    },
    {
      fileType: "DAON_FILE_TYPE_BACK_UNPROCESSED",
      title: "Unprocessed Drivers License Back"
    }
  ],
  DOCUMENT_TYPE_PASSPORT: [
    {
      fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Passport Front"
    },
    {
      fileType: "DAON_FILE_TYPE_SELFIE_ANZX_REKYC_FACE",
      title: "Selfie"
    },
    {
      fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Passport Front"
    }
  ],
  DOCUMENT_TYPE_PROOF_OF_AGE: [
    {
      fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Proof of Age Front"
    },
    {
      fileType: "DAON_FILE_TYPE_BACK_PROCESSED",
      title: "Processed Proof of Age Back"
    },
    {
      fileType: "DAON_FILE_TYPE_SELFIE_ANZX_REKYC_FACE",
      title: "Selfie"
    },
    {
      fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Proof of Age Front "
    },
    {
      fileType: "DAON_FILE_TYPE_BACK_UNPROCESSED",
      title: "Unprocessed Proof of Age Back"
    }
  ],
  DOCUMENT_TYPE_MEDICARE: [
    {
      fileType: "DAON_FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Medicare Card Front"
    },
    {
      fileType: "DAON_FILE_TYPE_SELFIE_ENROLLED",
      title: "Enrolled Selfie on file"
    },
    {
      fileType: "DAON_FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Medicare Card Front"
    }
  ]
};
export function buildTrustMeCustAttribute(data) {
  return transformResponse(TRUSTME_CUSTOMER_ATTRIBUTE, data);
}

export function buildTrustMeSelfieAndPrimDoc(data) {
  return transformResponse(TRUSTME_DOCUMENT_VERIFICATION, data);
}

export function buildTrustMeAdditionalContext(data) {
  return transformResponse(TRUSTME_ADDITIONAL_CUSTOMER_CONTEXT, data);
}

export function transformResponseForAddress(recordDetails) {
  if (
    !recordDetails.Residential_Address__c &&
    !recordDetails.TrustMe_Residential_Address__c
  ) {
    return null;
  }
  const results = [];
  if (
    recordDetails.Residential_Address__c &&
    recordDetails.Residential_Address_Geolocation__Latitude__s &&
    recordDetails.Residential_Address_Geolocation__Longitude__s
  ) {
    results.push({
      type: "Residential",
      addressValue: recordDetails.Residential_Address__c,
      latitude: recordDetails.Residential_Address_Geolocation__Latitude__s,
      longitude: recordDetails.Residential_Address_Geolocation__Longitude__s
    });
  }
  if (
    recordDetails.TrustMe_Residential_Address__c &&
    recordDetails.TrustMe_Residential_Address_Geolocation__Latitude__s &&
    recordDetails.TrustMe_Residential_Address_Geolocation__Longitude__s
  ) {
    results.push({
      type: "TrustMe Residential",
      addressValue: recordDetails.TrustMe_Residential_Address__c,
      latitude:
        recordDetails.TrustMe_Residential_Address_Geolocation__Latitude__s,
      longitude:
        recordDetails.TrustMe_Residential_Address_Geolocation__Longitude__s
    });
  }
  return results;
}

export function transformResponse(section, recordDetails) {
  if (!recordDetails) {
    return null;
  }
  return Object.entries(section).map(([key, value]) => ({
    label: value,
    fieldName: recordDetails[key]
  }));
}
