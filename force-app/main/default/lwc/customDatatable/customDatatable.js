import LightningDatatable from "lightning/datatable";
import customUrlDatatypeTemplate from "./customUrlDatatypeTemplate.html";

export default class CustomDatatable extends LightningDatatable {
  static customTypes = {
    customUrl: {
      template: customUrlDatatypeTemplate,
      standardCellLayout: false,
      typeAttributes: ["label", "value", "tooltip", "rowdata"]
    }
  };
}
