let styleDefinition = {
  state0element0: [
    {
      conditions: "default",
      styleObject: {
        class: "slds-col   slds-text-align_center  slds-size_1-of-12  ",
        style: "      \n         ",
        styleProperties: { styles: { label: { fontSize: "20px" } } }
      }
    },
    {
      conditions: {
        id: "state-condition-object",
        isParent: true,
        group: [
          {
            id: "state-new-condition-0",
            field: "Session.selectedTab",
            operator: "==",
            value: "Current",
            type: "custom",
            hasMergeField: false
          }
        ]
      },
      styleObject: {
        class:
          "slds-col   slds-text-align_center slds-border_bottom  slds-size_1-of-12  ",
        style: "     border-bottom: #0176d3 2px solid; \n         ",
        styleProperties: { styles: { label: { fontSize: "20px" } } }
      }
    }
  ],
  state0element1: [
    {
      conditions: "default",
      styleObject: {
        class: "slds-col   slds-text-align_center  slds-size_1-of-12  ",
        style: "      \n         ",
        styleProperties: { styles: { label: { fontSize: "20px" } } }
      }
    },
    {
      conditions: {
        id: "state-condition-object",
        isParent: true,
        group: [
          {
            id: "state-new-condition-0",
            field: "Session.selectedTab",
            operator: "==",
            value: "History",
            type: "custom",
            hasMergeField: false
          }
        ]
      },
      styleObject: {
        class:
          "slds-col   slds-text-align_center slds-border_bottom  slds-size_1-of-12  ",
        style: "     border-bottom: #0176d3 2px solid; \n         ",
        styleProperties: { styles: { label: { fontSize: "20px" } } }
      }
    }
  ],
  state0element2: [
    {
      conditions: "default",
      styleObject: {
        class: "slds-col  condition-element  slds-size_12-of-12 ",
        style: "",
        styleProperties: ""
      }
    }
  ],
  state0element3: [
    {
      conditions: "default",
      styleObject: {
        class: "slds-col  condition-element  slds-size_12-of-12 ",
        style: "",
        styleProperties: ""
      }
    }
  ]
};
export default styleDefinition;
