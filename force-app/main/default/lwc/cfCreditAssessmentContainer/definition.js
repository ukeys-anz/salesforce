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
          { type: "top", size: "small", label: "top:small" },
          { type: "right", size: "small", label: "right:small" },
          { type: "left", size: "small", label: "left:small" }
        ],
        margin: [],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "12" },
        sizeClass: "slds-size_12-of-12 ",
        class:
          "slds-card slds-p-top_small slds-p-right_small slds-p-left_small ",
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
                  { type: "around", size: "small", label: "around:small" }
                ],
                class: "slds-theme_shade slds-p-around_small ",
                sizeClass: "slds-size_12-of-12 ",
                margin: [],
                background: {
                  color: "#F3F3F3",
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
                  color: "#cccccc",
                  radius: "3px",
                  style: ""
                },
                elementStyleProperties: {},
                text: { align: "", color: "" },
                inlineStyle: "",
                theme: "theme_shade",
                style:
                  "background-color:#F3F3F3;      \n    border-radius:3px;     "
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
                    iconName: "utility:edit_form",
                    size: "small",
                    extraclass: "",
                    variant: "default",
                    imgsrc: "",
                    color: "#0070D2"
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_1-of-12 ",
                    size: { isResponsive: false, default: "1" },
                    padding: [
                      { type: "left", size: "x-small", label: "left:x-small" },
                      { type: "top", size: "xx-small", label: "top:xx-small" }
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
                    elementStyleProperties: { color: "#0070D2" },
                    text: { align: "left", color: "" },
                    inlineStyle: "",
                    class:
                      "slds-text-align_left slds-p-left_x-small slds-p-top_xx-small ",
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
                        padding: [
                          {
                            type: "left",
                            size: "x-small",
                            label: "left:x-small"
                          },
                          {
                            type: "top",
                            size: "xx-small",
                            label: "top:xx-small"
                          }
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
                        elementStyleProperties: { color: "#0070D2" },
                        text: { align: "left", color: "" },
                        inlineStyle: "",
                        class:
                          "slds-text-align_left slds-p-left_x-small slds-p-top_xx-small ",
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
                    styles: { label: { fontSize: "17px" } }
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
                      styles: { label: { fontSize: "17px" } }
                    },
                    text: { align: "", color: "" },
                    inlineStyle: "margin-left: -60px;\nmargin-top: -5px",
                    class: "slds-p-top_x-small ",
                    style:
                      "      \n         margin-left: -60px;\nmargin-top: -5px"
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
                          styles: { label: { fontSize: "17px" } }
                        },
                        text: { align: "", color: "" },
                        inlineStyle: "margin-left: -60px;\nmargin-top: -5px",
                        class: "slds-p-top_x-small ",
                        style:
                          "      \n         margin-left: -60px;\nmargin-top: -5px"
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
                      { type: "around", size: "small", label: "around:small" }
                    ],
                    class: "slds-theme_shade slds-p-around_small ",
                    sizeClass: "slds-size_12-of-12 ",
                    margin: [],
                    background: {
                      color: "#F3F3F3",
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
                      color: "#cccccc",
                      radius: "3px",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    theme: "theme_shade",
                    style:
                      "background-color:#F3F3F3;      \n    border-radius:3px;     "
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
                    parentAttribute: {
                      creditId: "{Credit_Id__c}",
                      recordId: "{recordId}",
                      outcomeStatus: "{Assessment_Outcome__c}"
                    }
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "Block-1-FlexCard-0",
                  key: "element_element_block_1_0_childCardPreview_0_0",
                  parentElementKey: "element_block_1_0"
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
      query:
        "SELECT Id, Credit_Id__c, Assessment_Outcome__c FROM Case WHERE Id = '{recordId}'",
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
  events: [
    {
      eventname: "",
      channelname: "CreditAssessmentContainer",
      element: "action",
      eventtype: "recordChange",
      recordIndex: "0",
      actionList: [
        {
          key: "1687150489792-3hywldqve",
          label: "Action",
          draggable: false,
          isOpen: true,
          card: "{card}",
          stateAction: {
            id: "flex-action-1687150489847",
            type: "cardAction",
            displayName: "Action",
            vlocityIcon: "standard-default",
            targetType: "Web Page",
            openUrlIn: "Current Window",
            "Web Page": { targetName: "/apex" },
            eventName: "reload"
          },
          actionIndex: 0,
          isTrackingDisabled: false
        }
      ],
      showSpinner: "false",
      key: "event-0",
      displayLabel: "",
      eventLabel: "record change",
      _isAdvanceMode: false,
      sobject: "Case",
      selectedFields:
        '["OwnerId","Assessment_Outcome__c","Case_Authority_Level__c"]',
      optionalFields:
        "Case.OwnerId,Case.Assessment_Outcome__c,Case.Case_Authority_Level__c",
      recordId: "{recordId}"
    }
  ],
  Name: "CreditAssessmentContainer",
  uniqueKey: "CreditAssessmentContainer",
  Id: "0ko9r0000000aBbAAI",
  OmniUiCardKey: "CreditAssessmentContainer/ANZx/1.0",
  OmniUiCardType: "Parent"
};
export default definition;
