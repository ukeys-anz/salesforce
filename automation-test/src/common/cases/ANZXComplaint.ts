import RecordCreationForm from "pageObjects/recordCreationForm";
import RecordLayout from "pageObjects/lwcRecordLayout";
import { UserRole, OwnerType } from "constants/enums";
import CaseType from "constants/case/caseType";
import CaseFields from "constants/case/caseFields";
import { FieldSectionIndex } from "types/layout";
import { FieldDefinition } from "types/field";
import Case from "./Case";
import * as commonUtils from "utils/commonUtils";
import * as creationFormUtils from "utils/creationFormUtils";
import * as casePageUtils from "utils/casePageUtils";
import IAssignNewOwner from "interfaces/IAssignNewOwner";

export default class ANZXComplaint extends Case implements IAssignNewOwner {
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(caseData: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);
    await recordCreationFormRoot.selectCaseRecordType(CaseType.ANZX_COMPLAINT);
    await browser.pause(2000);

    const fieldsToFill = this.initFieldsToFill(caseData);
    ANZXComplaint.creationFormFieldIndexMap =
      await creationFormUtils.fillInFields(
        this.sobject,
        ANZXComplaint.creationFormFieldIndexMap,
        fieldsToFill
      );

    // click save button
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);
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
    const baseRecordForm = (await casePageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    if (this.userRole === UserRole.COACH) {
      await this.updatePriority(recordLayout, [2, 3, 2]);
      await baseRecordForm.clickFooterButton("Save");
    } else if (this.userRole === UserRole.FRAUDX_AGENT) {
      await this.updatePriority(recordLayout, [2, 2, 2]);
      await baseRecordForm.clickFooterButton("Save");
    }

    await browser.pause(3000);
  }

  async close(): Promise<void> {
    const baseRecordForm = (await casePageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Status
    // select Closed status
    if (this.userRole === UserRole.COACH) {
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 2, 2],
        7
      );
      await baseRecordForm.clickFooterButton("Save");
    } else if (this.userRole === UserRole.FRAUDX_AGENT) {
      await commonUtils.selectPicklistOnRecordLayout(
        recordLayout,
        [2, 1, 2],
        7
      );
      await baseRecordForm.clickFooterButton("Save");
    }

    await browser.pause(6000);
  }

  initFieldsToFill(caseData: any): FieldDefinition[] {
    // default fields to fill in
    let fieldsToFill: FieldDefinition[] = [
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
      }
    ];

    if (
      this.userRole === UserRole.COACH ||
      this.userRole === UserRole.FRAUDX_AGENT
    ) {
      fieldsToFill = [
        ...fieldsToFill,
        {
          label: CaseFields.Product_or_Service_Name,
          options: {
            lookupText: caseData.productName
          }
        }
      ];
    }

    return fieldsToFill;
  }

  // Priority (used on Record Page, not on Creation Form)
  async updatePriority(
    recordLayout: RecordLayout,
    FieldSectionIndex: FieldSectionIndex
  ) {
    await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      FieldSectionIndex,
      [2, 5]
    );
  }
}
