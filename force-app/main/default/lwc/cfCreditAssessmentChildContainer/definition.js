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
        padding: [
          { type: "right", size: "small", label: "right:small" },
          { type: "left", size: "small", label: "left:small" },
          { type: "bottom", size: "small", label: "bottom:small" }
        ],
        margin: [{ type: "around", size: "none", label: "around:none" }],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "12" },
        sizeClass: "slds-size_12-of-12 ",
        class:
          "slds-card slds-p-right_small slds-p-left_small slds-p-bottom_small slds-m-around_none ",
        background: {
          color: "",
          image: "",
          size: "",
          repeat: "",
          position: ""
        },
        border: { type: "", width: "", color: "", radius: "", style: "" },
        elementStyleProperties: {},
        text: { align: "", color: "" },
        inlineStyle: "",
        style: "      \n         "
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
                      id: "state-new-group-484",
                      group: [
                        {
                          id: "state-new-condition-483",
                          field: "Parent.selectedTab",
                          operator: "==",
                          value: "Current",
                          type: "custom",
                          hasMergeField: false
                        },
                        {
                          id: "state-new-condition-522",
                          field: "Parent.outcomeStatus",
                          operator: "!=",
                          value: "Processing",
                          type: "custom",
                          hasMergeField: false,
                          logicalOperator: "&&"
                        },
                        {
                          id: "state-new-condition-10",
                          field: "length",
                          operator: ">",
                          value: "0",
                          type: "custom",
                          hasMergeField: false,
                          logicalOperator: "&&"
                        }
                      ]
                    },
                    {
                      id: "state-new-group-1",
                      group: [
                        {
                          id: "state-new-condition-0",
                          field: "Parent.selectedTab",
                          operator: "==",
                          value: "History",
                          type: "custom",
                          hasMergeField: false
                        },
                        {
                          id: "state-new-condition-107",
                          field: "length",
                          operator: ">",
                          value: "0",
                          type: "custom",
                          hasMergeField: false,
                          logicalOperator: "&&"
                        }
                      ],
                      logicalOperator: "||"
                    }
                  ]
                },
                parentAttribute: {
                  selectedTab: "{Parent.selectedTab}",
                  recordId: "{Parent.recordId}",
                  creditId: "{Parent.creditId}"
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
                padding: [{ type: "top", size: "large", label: "top:large" }],
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
                class: "slds-text-align_center slds-p-top_large ",
                style: "      \n         "
              },
              elementLabel: "Text-1",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "top", size: "large", label: "top:large" }
                    ],
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
                    class: "slds-text-align_center slds-p-top_large ",
                    style: "      \n         "
                  },
                  label: "Default",
                  name: "Default",
                  conditionString: "",
                  draggable: false
                }
              ]
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
                  "%3Ch2%3E%3Cspan%20class=%22ui-provider%20gl%20b%20c%20d%20e%20f%20g%20h%20i%20j%20k%20l%20m%20n%20o%20p%20q%20r%20s%20t%20u%20v%20w%20x%20y%20z%20ab%20ac%20ae%20af%20ag%20ah%20ai%20aj%20ak%22%3ELoan%20Assessment%20in%20progress.%20Waiting%20on%20an%20outcome....%3C/span%3E%3C/h2%3E",
                card: "{card}",
                "data-conditions": {
                  id: "state-condition-object",
                  isParent: true,
                  group: [
                    {
                      id: "state-new-condition-396",
                      field: "Parent.selectedTab",
                      operator: "==",
                      value: "Current",
                      type: "custom",
                      hasMergeField: false
                    },
                    {
                      id: "state-new-condition-428",
                      field: "Parent.outcomeStatus",
                      operator: "==",
                      value: "Processing",
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
                padding: [{ type: "top", size: "large", label: "top:large" }],
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
                class: "slds-text-align_center slds-p-top_large ",
                style: "      \n         "
              },
              elementLabel: "Text-1-clone-0",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "top", size: "large", label: "top:large" }
                    ],
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
                    class: "slds-text-align_center slds-p-top_large ",
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
  Id: "0ko9r0000000aBaAAI",
  OmniUiCardKey: "CreditAssessmentChildContainer/ANZx/1.0",
  OmniUiCardType: "Child"
};
export default definition;
