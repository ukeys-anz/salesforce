import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import OPPORTUNITYID_FIELD from "@salesforce/schema/ApplicationFormProduct.ApplicationForm.OpportunityId";
import getProducts from "@salesforce/apex/ModifyProductController.getProducts";
import { showToast, handleErrorShowToast } from "c/utils";
import { CloseActionScreenEvent } from "lightning/actions";
import ID_FIELD from "@salesforce/schema/ApplicationFormProduct.Id";
import PRODUCTID_FIELD from "@salesforce/schema/ApplicationFormProduct.ProductId";
import OPPPRODUCT_FIELD from "@salesforce/schema/ApplicationFormProduct.Opportunity_Product__c";
import { updateRecord } from "lightning/uiRecordApi";

export default class ModifyProduct extends LightningElement {
  @api recordId;

  selectedProductId = "";
  products = [];
  opportunityId;
  CONSTANT = {
    HEADER_TEXT: "Modify Product",
    CANCEL: "Cancel",
    SAVE: "Save"
  };
  disableSave = true;
  isLoading;
  oppLineItemId;
  selectedOppLineItemId;
  missingProductText =
    "Note-Please add product in opportunity product if you want to add new product which is not existing in this opportunity.";

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [OPPORTUNITYID_FIELD, OPPPRODUCT_FIELD]
  })
  getOppId({ data, error }) {
    if (data) {
      this.opportunityId =
        data.fields.ApplicationForm.value.fields.OpportunityId.value;
      this.oppLineItemId = data.fields.Opportunity_Product__c.value;
    }

    if (error && error?.body) {
      handleErrorShowToast(
        this,
        "Error",
        error,
        "Error in getting Opportunity Id.",
        "dismissable"
      );
    }
  }

  @wire(getProducts, { recordId: "$opportunityId" })
  getProductsRelatedToOpp({ data, error }) {
    if (data) {
      this.products = data;
    }
    if (error && error?.body) {
      handleErrorShowToast(
        this,
        "Error",
        error,
        "Error in populating products from opportunity.",
        "dismissable"
      );
    }
  }

  get productOptions() {
    return (
      this.products?.map((product) => ({
        label: product.Product2.Name,
        value: product.Id
      })) || []
    );
  }

  getProductId() {
    const result = this.products.filter(
      (product) => product.Id === this.selectedOppLineItemId
    );
    return result.length > 0 ? result[0].Product2Id : null;
  }
  handleChange(event) {
    this.selectedOppLineItemId = event.detail.value;
    this.disableSave = !(this.oppLineItemId !== this.selectedOppLineItemId);
  }
  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  handleSave() {
    this.isLoading = true;
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[PRODUCTID_FIELD.fieldApiName] = this.getProductId();
    fields[OPPPRODUCT_FIELD.fieldApiName] = this.selectedOppLineItemId;
    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        showToast(
          this,
          "Success",
          "Product updated successfully",
          "",
          "success",
          "dismissable"
        );
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Error",
          error,
          "Some error occurred while changing record type.",
          "dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }
}
