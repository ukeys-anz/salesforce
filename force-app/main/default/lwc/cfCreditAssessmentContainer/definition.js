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
        margin: [{ type: "bottom", size: "x-small" }],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "12" },
        sizeClass: "slds-size_12-of-12",
        class: "slds-card slds-p-around_x-small slds-m-bottom_x-small"
      },
      components: {
        "layer-0": {
          children: [
            {
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Block",
                collapsible: false,
                record: "{record}",
                collapsedByDefault: false,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-theme_shade slds-p-around_x-small ",
                sizeClass: "slds-size_12-of-12 ",
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
                text: { align: "", color: "" },
                inlineStyle: "",
                theme: "theme_shade",
                style: "      \n         "
              },
              children: [
                {
                  name: "Icon",
                  element: "flexIcon",
                  size: { isResponsive: false, default: "1" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    card: "{card}",
                    iconType: "Salesforce SVG",
                    iconName: "standard:service_report",
                    size: "large",
                    extraclass:
                      "slds-icon_container slds-icon-standard-service-report ",
                    variant: "inverse",
                    imgsrc: ""
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_1-of-12 ",
                    size: { isResponsive: false, default: "1" },
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "left", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_left ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-2-Icon-0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_1-of-12 ",
                        size: { isResponsive: false, default: "1" },
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {},
                        text: { align: "left", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_left ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_flexIcon_0_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_outputField_1_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "10" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}",
                    label: "Credit Assessment",
                    styles: { label: { fontSize: "24px" } }
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_10-of-12 ",
                    size: { isResponsive: false, default: "10" },
                    padding: [
                      { type: "top", size: "x-small", label: "top:x-small" }
                    ],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {
                      styles: { label: { fontSize: "24px" } }
                    },
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-top_x-small ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-2-Field-1",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_10-of-12 ",
                        size: { isResponsive: false, default: "10" },
                        padding: [
                          { type: "top", size: "x-small", label: "top:x-small" }
                        ],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {
                          styles: { label: { fontSize: "24px" } }
                        },
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-top_x-small ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ]
                }
              ],
              elementLabel: "Block-0",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    padding: [
                      {
                        type: "around",
                        size: "x-small",
                        label: "around:x-small"
                      }
                    ],
                    class: "slds-theme_shade slds-p-around_x-small ",
                    sizeClass: "slds-size_12-of-12 ",
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    theme: "theme_shade",
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
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Credit Assessment",
                collapsible: false,
                record: "{record}",
                collapsedByDefault: false,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
              children: [
                {
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "CreditAssessmentParent",
                    recordId: "{recordId}",
                    cardNode: "",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: true,
                    parentAttribute: { creditId: "{Credit_Id__c}" }
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "FlexCard-1",
                  key: "element_element_block_0_0_childCardPreview_0_0"
                }
              ],
              elementLabel: "Block-1"
            }
          ]
        }
      },
      childCards: ["CreditAssessmentParent"],
      actions: [],
      omniscripts: [],
      documents: []
    }
  ],
  dataSource: {
    type: "Query",
    value: {
      dsDelay: "",
      query: "SELECT Id, Credit_Id__c FROM Case WHERE Id = '{recordId}'",
      jsonMap: '{"recordId":"{recordId}"}',
      resultVar: ""
    },
    orderBy: { name: "", isReverse: "" },
    contextVariables: []
  },
  title: "CreditAssessmentContainer",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfCreditAssessmentContainer_1_ANZx",
    Id: "0RbBm0000005Gk5KAE",
    MasterLabel: "cfCreditAssessmentContainer_1_ANZx",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  Name: "CreditAssessmentContainer",
  uniqueKey: "CreditAssessmentContainer",
  Id: "0koBm0000000Q2XIAU",
  OmniUiCardKey: "CreditAssessmentContainer/ANZx/1.0",
  OmniUiCardType: "Parent"
};
export default definition;
