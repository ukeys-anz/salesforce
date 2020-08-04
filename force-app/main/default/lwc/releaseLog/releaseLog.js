import { LightningElement, track } from "lwc";

import getReleases from "@salesforce/apex/ReleaseLogServerController.getReleases";
import countTotalRecords from "@salesforce/apex/ReleaseLogServerController.countTotalRecords";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Declare default records per page
const RECORDS_PER_PAGE = 2;

export default class ReleaseLog extends LightningElement {
  @track releases;
  @track currentPage = 1;
  @track totalPages = null;
  @track loadMore = true;

  connectedCallback() {
    //Determine the current records to display using the current page
    //and the initial records per page
    let recordCount = RECORDS_PER_PAGE * this.currentPage;
    getReleases({ recordLimit: recordCount })
      .then((result) => {
        if (result) {
          for (let i = 0; i < result.length; i++) {
            //Split the text area fields into an array by new lines
            //and filter out any null elements from the array that we created
            //in case someone enters two new lines back to back
            if (result[i].Changes__c) {
              result[i].Changes__c = result[i].Changes__c.split("\n").filter(
                (el) => {
                  return el !== false;
                }
              );
            }

            if (result[i].Additions__c) {
              result[i].Additions__c = result[i].Additions__c.split(
                "\n"
              ).filter((el) => {
                return el !== false;
              });
            }

            if (result[i].Fixes__c) {
              result[i].Fixes__c = result[i].Fixes__c.split("\n").filter(
                (el) => {
                  return el !== false;
                }
              );
            }
          }
        }
        this.releases = result;
      })
      .catch((error) => {
        let errorMessage = "Failed to load release log";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Release Log Load Failed", errorMessage, error);
      });

    //Retrieve count of total records to determine the total pages
    //available. Only needs to be done once
    if (!this.totalPages) {
      countTotalRecords().then((total) => {
        if (total <= 2) {
          this.loadMore = false;
        }
        this.totalPages = Math.round(total / RECORDS_PER_PAGE);
      });
    }

    //Hide the view more button if we've run out of pages to load
    if (this.currentPage === this.totalPages) {
      this.loadMore = false;
    }
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

  //Load more records
  loadRecords() {
    if (this.currentPage !== this.totalPages) {
      this.currentPage++;
      this.connectedCallback();
    }
  }
}
