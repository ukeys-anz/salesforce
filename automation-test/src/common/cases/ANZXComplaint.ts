import RecordCreationForm from "pageObjects/recordCreationForm";
import { OwnerType } from "../../constants/enums";
import CaseType from "../../constants/case/caseType";
import CaseFields from "../../constants/case/caseFields";
import { FieldSectionIndex } from "../../types/layout";
import { FieldDefinition } from "../../types/field";
import Case from "./Case";
import * as commonUtils from "../../utils/commonUtils";
import * as creationFormUtils from "../../utils/creationFormUtils";
import * as casePageUtils from "../../utils/casePageUtils";
import IAssignNewOwner from "../../interfaces/IAssignNewOwner";

export default class ANZXComplaint extends Case implements IAssignNewOwner {
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(caseData: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);
    await recordCreationFormRoot.selectCaseRecordType(CaseType.ANZX_COMPLAINT);
    await browser.pause(2000);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Account_Name,
        options: {
          lookupText: caseData.accountName
        }
      },
      {
        label: CaseFields.Channel_Received,
        options: {
          picklistDOMIndex: 0,
          picklistOptionIndexRange: [2, 14]
        }
      },
      {
        label: CaseFields.Issue_Type,
        options: {
          picklistDOMIndex: 1,
          picklistOptionIndexRange: [2, 10]
        }
      },
      {
        label: CaseFields.Subsequent_Issue_Type,
        options: {
          picklistDOMIndex: 2,
          picklistOptionIndexRange: [2, 2]
        }
      },
      {
        label: CaseFields.Description_of_Issue
      },
      {
        label: CaseFields.Customer_Desired_Outcome
      },
      {
        label: CaseFields.Is_a_Written_Response_Requested,
        options: {
          picklistDOMIndex: 3,
          picklistOptionIndexRange: [2, 3]
        }
      },
      {
        label: CaseFields.Product_or_Service_Name,
        options: {
          lookupText: caseData.productName
        }
      }
    ];

    ANZXComplaint.creationFormFieldIndexMap =
      await creationFormUtils.fillInFields(
        this.sobject,
        ANZXComplaint.creationFormFieldIndexMap,
        fieldsToFill
      );

    // click save button
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);

    this.caseNumber = await casePageUtils.getCaseNumber();
  }

  async assignNewOwner(
    newOwnerType: OwnerType,
    newOwnerName: string
  ): Promise<void> {
    // Owner field index on layout
    const ownerFieldIndex: FieldSectionIndex = [2, 1, 1];

    await commonUtils.assignNewOwner(
      this.sobject,
      ownerFieldIndex,
      newOwnerType,
      newOwnerName
    );
  }

  async update(): Promise<void> {
    const baseRecordForm = await casePageUtils.getRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Priority
    await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      [2, 3, 2],
      [2, 5]
    );

    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  }

  async close(): Promise<void> {
    // Status
    // select Closed status
    const statusFieldIndex: FieldSectionIndex = [2, 2, 2];
    const closedOptionIndex = 7;
    await casePageUtils.closeCase(statusFieldIndex, closedOptionIndex);
  }
}
