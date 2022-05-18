import { PicklistOptionIndexRange } from "./layout";

export type FieldOptions = {
  firstFieldIndex?: number;
  textContent?: string;
  picklistDOMIndex?: number;
  picklistOptionIndexRange?: PicklistOptionIndexRange;
  lookupText?: string;
};

export type FieldDefinition = {
  label: string;
  type?: FieldType;
  options?: FieldOptions;
};

export type FieldType =
  | "readonly"
  | "text"
  | "textarea"
  | "number"
  | "picklist"
  | "lookup"
  | "date"
  | "iframe";
