import { LightningElement,api, wire, track } from 'lwc';
import getCustomerData from '@salesforce/apex/GetCustomerInformation.getCustomerData';
import { getRecord } from 'lightning/uiRecordApi';
import CAP_ID_FIELD from '@salesforce/schema/Case.IDR_Customer_Number__c';

export default class CustomerInformation extends LightningElement {
    @track loaded = false;
    @track customerInfo;
    @api recordId;
    @track error;
    @api showAsGrid;
    @api
    get customerId() {
        return this._customerId;
    }

    set customerId(customerId = '') {
        this._customerId = customerId;
    }

    connectedCallback() {
        if(this.customerId) {
            this.custData(this.customerId);
        }
    }


    @wire(getRecord, { recordId: '$recordId', fields: [CAP_ID_FIELD] })
    wiredProject({ error, data }) {
        if (data && this.record !== data) {
            this.record = data;
            this.custData(this.record.fields.IDR_Customer_Number__c.value);
        }
        else if (error) {
            this.loaded = true;
            this.error = error;
            this.record = undefined;
        }
    }

    custData(customerId) {
         // calling apex class method to make callout
         if (!this.loading){
         this.loading = true;    
         getCustomerData({ capId: customerId})
         .then(result => {
             let customerData = {
                 complainant_type: '',
                 first_name: '',
                 last_name: '',
                 middlename:'',
                 mobile: '',
                 businessname:'',
                 gender:'',
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
             customerData.complainant_type = responseData.complainantType;
             customerData.first_name = responseData.firstName;
             customerData.last_name = responseData.lastName;
             customerData.middlename = responseData.middleName;
             customerData.mobile = responseData.mobile; 
             customerData.businessname = responseData.businessName;
             customerData.age = responseData.age;
             customerData.country = responseData.country;
             customerData.email = responseData.email;
             customerData.gender = responseData.gender;
             customerData.postcode = responseData.postCode;
             customerData.state = responseData.state;
             customerData.street = responseData.street;
             customerData.suburb = responseData.suburb;
             // adding data object to show in UI
             this.loaded = true;
             this.loading = false; 
             this.customerInfo = customerData;
         }).catch(err => {
             this.loaded = true;
             this.loading = false; 
             this.error = err.body.message;
             this.record = undefined;
         })
        }
        
    }
}