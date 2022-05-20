import { FieldDefinition } from "types/field";
import LeadFields from "./leadFields";

export default new Map<string, FieldDefinition>([
  [LeadFields.First_Name, { label: LeadFields.First_Name, type: "text" }],
  [LeadFields.Last_Name, { label: LeadFields.Last_Name, type: "text" }],
  [LeadFields.Mobile, { label: LeadFields.Mobile, type: "number" }],
  [LeadFields.Email, { label: LeadFields.Email, type: "text" }],
  [
    LeadFields.Marketing_Consent,
    { label: LeadFields.Marketing_Consent, type: "picklist" }
  ],
  [
    LeadFields.Privacy_Consent,
    { label: LeadFields.Privacy_Consent, type: "readonly" }
  ],
  [LeadFields.Lead_Source, { label: LeadFields.Lead_Source, type: "picklist" }],
  [LeadFields.Status, { label: LeadFields.Status, type: "picklist" }]
]);
