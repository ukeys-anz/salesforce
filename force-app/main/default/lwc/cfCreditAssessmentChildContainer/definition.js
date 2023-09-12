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
      },
      components: {
        "layer-0": {
          children: [
            {
              name: "FlexCard",
              element: "childCardPreview",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                cardName: "CreditReferralChild",
                recordId: "{recordId}",
                cardNode: "{record.assessments}",
                selectedState: "Active",
                isChildCardTrackingEnabled: false,
                "data-conditions": {
                  id: "state-condition-object",
                  isParent: true,
                  group: [
                    {
                      id: "state-new-condition-417",
                      field: "length",
                      operator: ">",
                      value: "0",
                      type: "custom",
                      hasMergeField: false
                    }
                  ]
                }
              },
              type: "element",
              styleObject: { sizeClass: "slds-size_12-of-12" },
              elementLabel: "FlexCard-0"
            },
            {
              name: "Text",
              element: "outputField",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                record: "{record}",
                mergeField:
                  "%3Ch2%3ENo%20historical%20credit%20assessments%20completed%3C/h2%3E",
                card: "{card}",
                "data-conditions": {
                  id: "state-condition-object",
                  isParent: true,
                  group: [
                    {
                      id: "state-new-condition-396",
                      field: "Parent.selectedTab",
                      operator: "==",
                      value: "History",
                      type: "custom",
                      hasMergeField: false
                    },
                    {
                      id: "state-new-condition-428",
                      field: "length",
                      operator: "==",
                      value: "0",
                      type: "custom",
                      hasMergeField: false,
                      logicalOperator: "&&"
                    }
                  ]
                }
              },
              type: "text",
              styleObject: {
                sizeClass: "slds-size_12-of-12 ",
                padding: [],
                margin: [],
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                size: { isResponsive: false, default: "12" },
                container: { class: "" },
                border: {
                  type: "",
                  width: "",
                  color: "",
                  radius: "",
                  style: ""
                },
                elementStyleProperties: {},
                text: { align: "center", color: "" },
                inlineStyle: "",
                class: "slds-text-align_center ",
                style: "      \n         "
              },
              elementLabel: "Text-1",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "12" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center ",
                    style: "      \n         "
                  },
                  label: "Default",
                  name: "Default",
                  conditionString: "",
                  draggable: false
                }
              ]
            }
          ]
        }
      },
      childCards: ["CreditReferralChild"],
      actions: [],
      omniscripts: [],
      documents: []
    }
  ],
  dataSource: { type: null, value: {}, orderBy: {}, contextVariables: [] },
  title: "Credit Assessment Child Container",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfCreditAssessmentChildContainer_1_ANZx",
    Id: "0RbBm0000005GNVKA2",
    MasterLabel: "cfCreditAssessmentChildContainer_1_ANZx",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  Name: "CreditAssessmentChildContainer",
  uniqueKey: "CreditAssessmentChildContainer",
  Id: "0koBm0000000PxhIAE",
  OmniUiCardKey: "CreditAssessmentChildContainer/ANZx/1.0",
  OmniUiCardType: "Child"
};
export default definition;
