import { createElement } from "lwc";
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import CustomerInfoComponent from "c/customerInformation";
import { getRecord } from 'lightning/uiRecordApi';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getCustomerData from "@salesforce/apex/GetCustomerInformation.getCustomerData";

import { ShowToastEventName } from "lightning/platformShowToastEvent";
const mockGetCustomerData = require('./data/getRecord.json');
const getRecordWireAdapter = registerLdsTestWireAdapter(getRecord);
const mockOCVCustomerDataResponse = require('./data/getCustomerData.json');
const getCustomerDataAdapter = registerApexTestWireAdapter(getCustomerData);


/*describe("c-customer-information", () => {
    afterEach(() => {
      // The jsdom instance is shared across test cases in a single file so reset the DOM
      while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
      }
      //jest.restoreAllMocks();
      jest.clearAllMocks();
    });

    describe('getCustomerData @wire data', () => {
      it('renders six records', () => {
        const element = createElement("c-customer-information", {
          is: CustomerInfoComponent
        });

        document.body.appendChild(element);
        getCustomerDataAdapter.emit(mockGetCustomerData);
        element.showAsGrid = false;
        customerId( '4021733054');
        return Promise.resolve().then(() => {
          // Select elements for validation
          const accountElements = element.shadowRoot.querySelectorAll('li');
          expect(accountElements).not.toBeNull();
          expect(accountElements.length).toBe(3);
         // expect(accountElements[0].textContent).toBe(mockGetAccountList[0].Name);
        });
      });
    });
  
    /*function flushPromises() {
      // eslint-disable-next-line no-undef
      return new Promise((resolve) => setImmediate(resolve));
    }*/



   /* it("display all sections in the form", () => {
        const element = createElement("c-customer-information", {
          is: CustomerInfoComponent
        });
        /*element.showAsGrid = true;
        element.showMore = true;
        document.body.appendChild(element);
    
        const accordionSections = element.shadowRoot.querySelectorAll(
          "lightning-accordion-section"
        );
        expect(accordionSections.length).toBe(2);
      
      getRecordWireAdapter.emit(mockGetRecord);
      element.customerInfo = mockGetRecord.fields;
      element.showAsGrid = false;
      
      return Promise.resolve().then(() => {
        const content = element.shadowRoot.querySelector("li");
        const nameField = mockGetRecord.fields.first_name.value;
        expect(content).not.toBeNull();
        expect(element.customerInfo).toBe('${nameField}')

    });
    });

    

});*/

describe('c-customer-information', () => {
  // Disconnect the component to reset the adapter. It is also
  // a best practice to clean up after each test.
  afterEach(() => {
      while (document.body.firstChild) {
          document.body.removeChild(document.body.firstChild);
      }
  });

  it('Display stored customer data', () => {
      const element = createElement('c-customer-information', { is: CustomerInfoComponent });
      document.body.appendChild(element);
      getRecordWireAdapter.emit(mockGetCustomerData);

  // Resolve a promise to wait for a rerender of the new content.
      return Promise.resolve().then(() => {
          //const content = element.querySelector('li');
          const customerdataElements = element.shadowRoot.querySelectorAll('li');
          expect(customerdataElements).not.toBeNull();
          expect(customerdataElements.length).toBe(5);
          const firstName = mockGetCustomerData.fields.IDR_NC_First_Name__c.value;
          const middleName = mockGetCustomerData.fields.IDR_NC_Middle_Names__c.value;
          const lastName = mockGetCustomerData.fields.IDR_NC_Last_Name__c.value;
          const rmComplaint = (mockGetCustomerData.fields.Relationship_Managed_Complaint__c.value == true?'YES':'NO');

          expect(customerdataElements[1].textContent).toBe('First Name : '+firstName);
          expect(customerdataElements[2].textContent).toBe('Middle Names : '+middleName);
          expect(customerdataElements[3].textContent).toBe('Last Name : '+lastName);
          expect(customerdataElements[4].textContent).toBe('RM Complaint : '+rmComplaint);

          const showMoreButton = element.shadowRoot.querySelectorAll('button');
        expect(showMoreButton).not.toBeNull();
        });
  });

  describe('Test Show More Data', () => {

    it('Show More Data', () => {
      const element = createElement("c-customer-information", {
        is: CustomerInfoComponent
      });
      
      document.body.appendChild(element);
        
      // Emit data from @wire
      getCustomerDataAdapter.emit(mockOCVCustomerDataResponse);
      //element.showAsGrid = false;
      element.customerId = jest.fn();
      element.customerId = '4021733054';
     
      
          return Promise.resolve().then(() => {
            // Compare if public function has been called
            const customerdataElements = element.shadowRoot.querySelectorAll('div');
            expect(customerdataElements).not.toBeNull();  
            expect(customerdataElements.length).toBe(1);
            expect(customerdataElements[1].textContext).toBe('ddd');
          });
    });
  });
});