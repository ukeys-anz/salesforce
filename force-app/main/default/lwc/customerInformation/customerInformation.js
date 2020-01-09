import { LightningElement,api, wire, track } from 'lwc';
import getCustomerData from '@salesforce/apex/GetCustomerInformation.getCustomerData';
import { getRecord } from 'lightning/uiRecordApi';
import CAP_ID_FIELD from '@salesforce/schema/Case.IDR_Customer_Number__c';

export default class CustomerInformation extends LightningElement {
    @track customerInfo;
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [CAP_ID_FIELD] })
    wiredProject({ error, data }) {
        if (data) {
            this.record = data;

            // calling apex class method to make callout
            getCustomerData({ capId: this.record.fields.IDR_Customer_Number__c.value })
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
                    this.customerInfo = customerData;
                }).catch(err => {
                    this.error = err;
                    this.record = undefined;
                })
        }
        else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
}