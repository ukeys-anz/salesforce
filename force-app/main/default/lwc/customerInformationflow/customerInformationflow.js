import { LightningElement, api, track } from "lwc";
import getCustomerData from "@salesforce/apex/GetCustomerInformation.getCustomerData";

export default class CustomerInformationFlow extends LightningElement {
  @track loaded = false;
  @track customerInfo;
  @track error;
  @api capId;
  connectedCallback() {
      // calling apex class method to make callout
      getCustomerData({ capId: "123" })
      .then(result => {
          let customerData = {
              complainant_type: '',
              first_name: '',
              last_name: '',
              middlename:'',
              phone: '',
              mobile: '',
              businessname:'',
              gender:'',
              aboriginal:'',
              email:'',
              age:'',
              suburb:'',
              street:'',
              state:'',
              postcode:'',
              country:''
          };
          // retrieving the response data
          let responseData = result.profile;
          // adding data object by reading from JSON
          customerData.complainant_type = responseData.complainant_type;
          customerData.first_name = responseData.firstname;
          customerData.last_name = responseData.lastname;
          customerData.middlename = responseData.middlename;
          customerData.phone = responseData.phone;
          customerData.mobile = responseData.mobile; 
          customerData.businessname = responseData.businessname;
          customerData.aboriginal = responseData.aboriginal;
          customerData.age = responseData.age;
          customerData.country = responseData.country;
          customerData.email = responseData.email;
          customerData.gender = responseData.gender;
          customerData.postcode = responseData.postcode;
          customerData.state = responseData.state;
          customerData.street = responseData.street;
          customerData.suburb = responseData.suburb;
          // adding data object to show in UI
          this.loaded = true;
          this.customerInfo = customerData;
      }).catch(error => {
        this.loaded = true;
        this.error = error.body.message;
        this.record = undefined;
      })
  }
}
