let definition = {
  states: [
    {
      fields: [],
      conditions: { id: "state-condition-object", isParent: true, group: [] },
      definedActions: { actions: [] },
      name: "Active",
      isSmartAction: false,
      smartAction: {},
      styleObject: {
        padding: [{ type: "around", size: "x-small" }],
        margin: [{ type: "around", size: "none" }],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "12" },
        sizeClass: "slds-size_12-of-12",
        class: "slds-card slds-p-around_x-small slds-m-bottom_x-small"
      }
    }
  ],
  dataSource: {
    type: "ApexRemote",
    value: {
      dsDelay: "",
      remoteClass: "ResidentialLoanApplicationController",
      remoteMethod: "getListAssets",
      vlocityAsync: false,
      resultVar: "assetsJSON"
    },
    orderBy: { name: "", isReverse: "" },
    contextVariables: []
  },
  title: "SOP_Other",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  Name: "SOP_Other",
  uniqueKey: "SOP_Other_1_ANZ",
  Id: "0ko8r0000000JFZAA2",
  OmniUiCardKey: "SOP_Other/ANZ/1.0",
  OmniUiCardType: "Child"
};
export default definition;
