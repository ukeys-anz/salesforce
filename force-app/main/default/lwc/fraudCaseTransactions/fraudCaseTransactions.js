import { LightningElement, wire, api } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import { SimpleToast, SimpleNav } from "c/utils";
import TransactionLink from "c/transactionLink";
import ACCOUNT_ID_FIELD from "@salesforce/schema/Case.AccountId";
import CASE_RECORDTYPE_FIELD from "@salesforce/schema/Case.RecordType.DeveloperName";
// Dispute fields
import DISPUTE_ID_D_FIELD from "@salesforce/schema/Dispute.Id";
import CASE_ID_FIELD from "@salesforce/schema/Dispute.CaseId";
import ACCOUNT_DETAILS_D_FIELD from "@salesforce/schema/Dispute.AccountDetails__c";
import RECEIVED_DATE_FIELD from "@salesforce/schema/Dispute.ReceivedDate";
// Dispute Item fields
import DISPUTE_ITEM_ID_FIELD from "@salesforce/schema/DisputeItem.Id";
import CASE_FIELD from "@salesforce/schema/DisputeItem.Case__c";
import TXN_DATE_FIELD from "@salesforce/schema/DisputeItem.TransactionDate";
import TXN_IDENTIFIER_FIELD from "@salesforce/schema/DisputeItem.TransactionIdentifier";
import TXN_AMOUNT_FIELD from "@salesforce/schema/DisputeItem.TransactionAmount";
import TXN_OFI_BSB_FIELD from "@salesforce/schema/DisputeItem.OtherFinancialInstituteBSB__c";
import TXN_OFI_ACCOUNT_NUMBER_FIELD from "@salesforce/schema/DisputeItem.OtherFinancialInstituteAccountNumber__c";
import TXN_MESSAGE_FIELD from "@salesforce/schema/DisputeItem.Message__c";
import TXN_TITLE_FIELD from "@salesforce/schema/DisputeItem.Title__c";
import TXN_ACCOUNT_DETAILS_FIELD from "@salesforce/schema/DisputeItem.AccountDetails__c";
import TXN_TYPE_FIELD from "@salesforce/schema/DisputeItem.TransactionType__c";
// Apex methods
import getDisputeItems from "@salesforce/apex/FraudCaseTransactionsController.getDisputeItemsByCaseId";
import saveDisputeWithItems from "@salesforce/apex/FraudCaseTransactionsController.saveDisputeWithItems";

export default class FraudCaseTransactions extends NavigationMixin(
  LightningElement
) {
  toast = new SimpleToast(this);
  nav = new SimpleNav(this);
  @api recordId;

  disputeItems = [];
  originalTxnAccs = [];
  originalTxnIds = [];
  modalOpen = false;
  caseRecordType;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [ACCOUNT_ID_FIELD, CASE_RECORDTYPE_FIELD]
  })
  async wiredCaseFields({ error, data }) {
    if (error) {
      this.toast.error("Error loading case record.");
      this.handler.close();
      return;
    }

    if (!data) return;
    if (this.modalOpen) return;
    this.modalOpen = true;
    this.caseRecordType = getFieldValue(data, CASE_RECORDTYPE_FIELD);

    let accId = getFieldValue(data, ACCOUNT_ID_FIELD);
    if (!accId) {
      this.toast.error("Error fetching Customer Id.");
      this.handler.close();
      return;
    }

    const originals = await this.service.getOriginalDisputeItems();
    if (!originals) {
      this.handler.close();
      return;
    }

    await TransactionLink.open({
      accId,
      originalTxnAccs: originals.originalTxnAccs,
      originalTxnIds: originals.originalTxnIds,
      onsubmit: (event) => {
        this.handler.submit(event);
      },
      onerror: (event) => {
        this.handler.error(event);
      }
    });
    this.handler.close();
  }

  handler = {
    submit: async (event) => {
      const modal = event.target;
      event.stopPropagation();
      modal.showSpinner();
      try {
        await this.handler.save(event.detail);
        modal.close();
        this.nav.toRecord(this.recordId);
      } catch (e) {
        modal.hideSpinner();
      }
    },
    save: async (link) => {
      const dispute = this.mapper.dispute(link.account);
      const itemsToAdd = this.mapper.disputeItemsToAdd(link.transactions.added);
      const itemsToRemove = this.mapper.disputeItemsToRemove(
        link.transactions.removed
      );
      await this.service.saveDisputes(dispute, itemsToAdd, itemsToRemove);
    },
    error: (event) => {
      const modal = event.target;
      event.stopPropagation();
      this.toast.error(event.detail);
      modal.close();
    },
    close: () => {
      this.dispatchEvent(new CloseActionScreenEvent());
    }
  };

  service = {
    getOriginalDisputeItems: async () => {
      try {
        this.disputeItems = await getDisputeItems({ caseId: this.recordId });

        // Build distinct account numbers from disputeItems account details
        const accDetails = this.disputeItems.map(
          (item) => item.AccountDetails__c
        );
        const uniqueAccDetails = [...new Set(accDetails)];
        const originalTxnAccs = uniqueAccDetails.map((acc) =>
          acc.split(" ").pop()
        );

        // Build transaction Identifiers from disputeItems
        const originalTxnIds = this.disputeItems.map(
          (disputeItem) => disputeItem.TransactionIdentifier
        );

        return {
          originalTxnAccs,
          originalTxnIds
        };
      } catch (error) {
        this.toast.error("Error fetching dispute items.");
        return null;
      }
    },
    saveDisputes: async (disputeAccount, itemsToAdd, itemsToRemove) => {
      if (!itemsToAdd.length && !itemsToRemove.length) {
        return;
      }

      try {
        await saveDisputeWithItems({
          disputeAccount,
          itemsToAdd,
          itemsToRemove
        });
        this.toast.success("Dispute and items saved successfully!");
      } catch (error) {
        this.toast.error("Error saving dispute and items.");
        throw error;
      }
    }
  };

  mapper = {
    dispute: (dispute) => {
      // Build lookup map from disputeItems to hold Account with DisputeId.
      let originalTxnDisputeRecId = Object.fromEntries(
        this.disputeItems.map((disputeItem) => [
          disputeItem.AccountDetails__c,
          disputeItem.DisputeId
        ])
      );

      const accountDetails =
        dispute.Product_Name_Display__c + " " + dispute.Account_Number__c;
      return {
        [DISPUTE_ID_D_FIELD.fieldApiName]:
          originalTxnDisputeRecId[accountDetails],
        [CASE_ID_FIELD.fieldApiName]: this.recordId,
        [ACCOUNT_DETAILS_D_FIELD.fieldApiName]: accountDetails,
        [RECEIVED_DATE_FIELD.fieldApiName]: new Date().toISOString()
      };
    },
    disputeItemsToAdd: (disputeItemsToAdd) => {
      return disputeItemsToAdd.map((txn) => ({
        [CASE_FIELD.fieldApiName]: this.recordId,
        [TXN_DATE_FIELD.fieldApiName]: new Date(
          txn.TransactionDate
        ).toLocaleDateString("en-CA"),
        [TXN_IDENTIFIER_FIELD.fieldApiName]: txn.TransactionId,
        [TXN_AMOUNT_FIELD.fieldApiName]:
          this.caseRecordType === "Recipient_Mule"
            ? txn.Amount
            : txn.Amount * -1,
        [TXN_OFI_BSB_FIELD.fieldApiName]: txn.PayerBSB,
        [TXN_OFI_ACCOUNT_NUMBER_FIELD.fieldApiName]: txn.PayerAccount,
        // substring first 6 characters from Message to fit field size
        [TXN_MESSAGE_FIELD.fieldApiName]: txn.Message?.substring(0, 6),
        [TXN_TITLE_FIELD.fieldApiName]: txn.Title,
        [TXN_ACCOUNT_DETAILS_FIELD.fieldApiName]: txn.AccountDetails,
        [TXN_TYPE_FIELD.fieldApiName]: txn.Type
      }));
    },
    disputeItemsToRemove: (disputeItemsToRemove) => {
      // Build lookup maps from disputeItems to hold TransactionIdentifier with transaction Id
      let originalTxnsRecIds = Object.fromEntries(
        this.disputeItems.map((disputeItem) => [
          disputeItem.TransactionIdentifier,
          disputeItem.Id
        ])
      );
      return disputeItemsToRemove.map((txnId) => ({
        [DISPUTE_ITEM_ID_FIELD.fieldApiName]: originalTxnsRecIds[txnId]
      }));
    }
  };
}
