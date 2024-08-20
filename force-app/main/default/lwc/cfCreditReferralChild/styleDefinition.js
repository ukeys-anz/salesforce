let styleDefinition = {
  state0element0block_element0: [
    {
      conditions: "default",
      styleObject: {
        class:
          "slds-col   slds-theme_shade slds-border_top slds-border_right slds-border_left slds-p-top_medium  slds-size_12-of-12  ",
        style:
          "background-color:#EBF3FF;     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-left: #cccccc 1px solid; \n    border-radius:5px;     ",
        styleProperties: {}
      }
    },
    {
      conditions: {
        id: "state-condition-object",
        isParent: true,
        group: [
          {
            id: "state-new-condition-0",
            field: "Parent.selectedTab",
            operator: "==",
            value: "History",
            type: "custom",
            hasMergeField: false
          }
        ]
      },
      styleObject: {
        class:
          "slds-col   slds-theme_shade slds-border_top slds-border_right slds-border_left slds-p-top_medium  slds-size_12-of-12  ",
        style:
          "     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-left: #cccccc 1px solid; \n    border-radius:5px;     background-color: #DDDBDA",
        styleProperties: {}
      }
    }
  ],
  state0element0block_element0block_element0block_element1block_element2block_element3block_element4block_element0:
    [
      {
        conditions: "default",
        styleObject: {
          class:
            "slds-col   slds-theme_default slds-p-top_medium slds-m-top_medium  slds-size_12-of-12  ",
          style: "background-color:#F5FBFF;      \n         font-weight: bold;",
          styleProperties: {}
        }
      },
      {
        conditions: {
          id: "state-condition-object",
          isParent: true,
          group: [
            {
              id: "state-new-condition-9",
              field: "Parent.selectedTab",
              operator: "==",
              value: "History",
              type: "custom",
              hasMergeField: false
            }
          ]
        },
        styleObject: {
          class:
            "slds-col   slds-theme_default slds-p-top_medium slds-m-top_medium  slds-size_12-of-12  ",
          style:
            "      \n         font-weight: bold;\nbackground-color:#F3F3F3",
          styleProperties: {}
        }
      }
    ]
};
export default styleDefinition;
