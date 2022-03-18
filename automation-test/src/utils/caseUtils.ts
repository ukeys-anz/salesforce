import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import { fieldSectionIndex, picklistItemIndexRange } from "types/layout";
import * as faker from "faker";

export const selectPicklistOnCreationForm = async (
  caseCreationFormRoot: CaseCreationForm,
  fieldSectionIndex: fieldSectionIndex,
  picklistItemIndexRange: picklistItemIndexRange,
  picklistDOMIndex: number
): Promise<void> => {
  // get field from layout
  await caseCreationFormRoot.selectPicklist(
    fieldSectionIndex[0],
    fieldSectionIndex[1],
    fieldSectionIndex[2]
  );

  let itemIndex: picklistItemIndexRange;

  if (typeof picklistItemIndexRange === "number") {
    // use the specific item index
    itemIndex = picklistItemIndexRange;
  } else {
    // get a random picklist item index, usually min starts from 2, as 1 is index of --None--
    itemIndex = faker.datatype.number({
      min: picklistItemIndexRange[0],
      max: picklistItemIndexRange[1]
    });
  }

  // get picklist dropdown
  const picklist = (await caseCreationFormRoot.getPicklistItemsLists())[
    picklistDOMIndex
  ];

  // select an item from picklist
  await picklist.selectPicklistItem(itemIndex);
};
