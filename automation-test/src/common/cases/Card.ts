import RecordCreationForm from "pageObjects/recordCreationForm";
import Case from "./Case";
import * as faker from "faker";
import * as creationFormUtils from "utils/creationFormUtils";
import * as commonUtils from "utils/commonUtils";
import * as casePageUtils from "utils/casePageUtils";
import { FieldDefinition } from "types/field";
import CaseFields from "constants/case/caseFields";

export default class Card extends Case {
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Dispute_Reason,
        options: {
          firstFieldIndex: 14,
          picklistDOMIndex: 0,
          picklistOptionIndexRange: [2, 9]
        }
      },
      {
        label: CaseFields.Description_of_Issue
      },
      {
        label: CaseFields.Is_The_Card_Lost_Stolen,
        options: {
          picklistDOMIndex: 1,
          picklistOptionIndexRange: [2, 4]
        }
      },
      {
        label: CaseFields.Card_In_Possession_During_Transaction,
        options: {
          picklistDOMIndex: 2,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Has_The_Card_Been_Stopped,
        options: {
          picklistDOMIndex: 3,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Amount_Of_Authorised_Transaction
      },
      {
        label: CaseFields.Customer_Contacted_Merchant,
        options: {
          picklistDOMIndex: 4,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.What_Happened_with_Merchant
      },
      {
        label: CaseFields.Date_Of_Authorised_Transaction
      },
      {
        label: CaseFields.Amount_Of_Credit_Due
      },
      {
        label: CaseFields.Goods_Or_Services_Returned,
        options: {
          picklistDOMIndex: 5,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Good_Returned_Or_Service_Cancelled_Date
      },
      {
        label: CaseFields.Date_Of_Expected_Delivery_Service
      },
      {
        label: CaseFields.Regular_Payment_Cancellation_Date
      },
      {
        label: CaseFields.Refund_Request_Date
      },
      {
        label: CaseFields.Channel_Received,
        options: {
          picklistDOMIndex: 6,
          picklistOptionIndexRange: [2, 13]
        }
      },
      {
        label: CaseFields.External_System,
        options: {
          picklistDOMIndex: 7,
          picklistOptionIndexRange: [2, 4]
        }
      }
    ];

    Card.creationFormFieldIndexMap = await creationFormUtils.fillInFields(
      this.sobject,
      Card.creationFormFieldIndexMap,
      fieldsToFill
    );

    // click save button
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);
  }

  async update(): Promise<void> {
    console.log("Skip update | This scenario does not need it.");
  }

  async close(): Promise<void> {
    const baseRecordForm = (await casePageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // External Case ID
    const externalCaseIdField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [4, 7, 1]
    );
    const externalCaseId = `${faker.datatype.string(10)}`;
    await commonUtils.inputText(externalCaseIdField, externalCaseId);

    // Status
    // select Closed status
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [4, 1, 1], 5);
    await baseRecordForm.clickFooterButton("Save");
    await browser.pause(3000);
  }
}
