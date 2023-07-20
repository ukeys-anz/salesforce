import LightningDatatable from "lightning/datatable";
import datatableColumnClickHandler from "./datatableColumnClickHandler.html";

export default class DatatableWithColumnClick extends LightningDatatable {
  static customTypes = {
    datatableColumnClickHandler: {
      template: datatableColumnClickHandler,
      typeAttributes: ["recordId", "cellValue"]
    }
  };
}
