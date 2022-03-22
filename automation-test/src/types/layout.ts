/**
 * @description the position index of a field on the page layout
 * @param sectionsIndex index of the section on the layout, start from 1
 * @param sectionRowIndex index of the row on the section, start from 1
 * @param sectionRowItem index of the item on the row, start from 1
 */
export type fieldSectionIndex = [
  sectionsIndex: number,
  sectionRowIndex: number,
  sectionRowItemIndex: number
];

/**
 * @description the index range of a selectable item in the picklist
 * @param number specific index of a selectable item
 * @param min min index of the selectable picklist item
 * @param max max index of the selectable picklist item
 */
export type picklistItemIndexRange =
  | number
  | [minIndex: number, maxIndex: number];
