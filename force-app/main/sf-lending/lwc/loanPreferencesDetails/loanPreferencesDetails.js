import { LightningElement, api, wire } from "lwc";
import SOP_IMAGE from "@salesforce/resourceUrl/SOP_Images";
import PROPERTY_IMG from "@salesforce/resourceUrl/Property";
//import getLoanPreferenceDetails from "@salesforce/apex/LoanApplicationController.getLoanPreferenceDetails";
import RLA_STATUS_APINAME from "@salesforce/schema/ResidentialLoanApplication.Status";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

export default class LoanPreferencesDetails extends LightningElement {
  @api recordId;
  componentSpinner = false;
  showBlankScreen = false;
  showViewScreen = true;
  logoImage = `${SOP_IMAGE}/additionalFunds/UpdateLoanAddFunds.png`;
  propertyImage = PROPERTY_IMG;
  loanLoanPreferenceData = [
    {
      address: "4/70 Gadd St, Northcote, VIC 3071",
      propertyStatus: "Live In",
      productName: "ANZ Plus Variable Home loan",
      currentLoanBalance: 2627289,
      interestRate: 5.73,
      interestType: "Variable",
      loanTerm: "25 year, 8 months",
      requestedLoanAmount: 650000,
      propertyUse: "Investment",
      taxDeductible: "No",
      loanMargin: "Investment",
      offset: "No",
      loanRepaymentType: "Interest Only",
      InterestOnlyPeriod: "3 years",
      InterestOnlyPurpose: "Anicipated large expense Item",
      loanRepaymentFrequency: "Monthly",
      estimatedRepaymentAmount: 2300.06,
      borrowAdditionalFunds: "No",
      lastModified: "13 August 2022 | 3:05 PM"
    },
    {
      address: "4/70 Gadd St, Northcote, VIC 3071 Addle Col",
      propertyStatus: "Owner Occupied",
      productName: "ANZ Plus Variable Investment Home loan",
      currentLoanBalance: 2627289,
      interestRate: 4.83,
      interestType: "Fixed",
      loanTerm: "25 year, 8 months",
      requestedLoanAmount: 650000,
      propertyUse: "Investment",
      taxDeductible: "No",
      loanMargin: "Investment",
      offset: "No",
      loanRepaymentType: "No Interest",
      loanRepaymentFrequency: "Monthly",
      estimatedRepaymentAmount: 2300.06,
      borrowAdditionalFunds: "No",
      lastModified: "13 August 2022 | 3:05 PM"
    }
  ];
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [RLA_STATUS_APINAME]
  })
  wiredAccount({ data }) {
    if (data) {
      this.applicationStatus = getFieldValue(data, RLA_STATUS_APINAME); // Storing the loan status field value
      this.loadLoanPreferenceData();
    }
  }
  //To:Do Add logic to fetch and transform Loan Preference Details
  async loadLoanPreferenceData() {
    try {
      // Callout to get the Loan Preference details
      //this.loanPreferenceData1 = await getLoanPreferenceDetails();
      //TO:DO include the logic to receive model from controller
    } catch (error) {
      //capture error
    } finally {
      this.componentSpinner = false;
    }
  }
}
