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
              name: "Action",
              element: "action",
              size: { isResponsive: false, default: "1" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Current",
                iconName: "standard-default",
                record: "{record}",
                card: "{card}",
                stateObj: "{record}",
                actionList: [
                  {
                    stateAction: {
                      id: "flex-action-1684735224448",
                      type: "cardAction",
                      targetType: "Web Page",
                      openUrlIn: "Current Window",
                      "Web Page": { targetName: "/apex" },
                      eventName: "setValues",
                      fieldValues: [
                        {
                          fieldName: "Session.selectedTab",
                          fieldValue: "Current"
                        }
                      ]
                    },
                    key: "1684734948232-xytnyes9j",
                    label: "Current Tab Change",
                    draggable: false,
                    isOpen: true,
                    actionIndex: 0,
                    isTrackingDisabled: true
                  }
                ],
                showSpinner: "false",
                hideActionIcon: true,
                flyoutDetails: {},
                styles: { label: { fontSize: "20px" } }
              },
              type: "element",
              styleObject: {
                theme: "",
                background: {
                  color: "",
                  image: "",
                  size: "",
                  repeat: "",
                  position: ""
                },
                border: {
                  type: "",
                  width: "",
                  color: "",
                  radius: "",
                  style: ""
                },
                padding: [],
                margin: [],
                text: { align: "center", color: "" },
                height: "",
                minHeight: "",
                maxHeight: "",
                class: "slds-text-align_center ",
                sizeClass: "slds-size_1-of-12 ",
                container: { class: "" },
                size: { isResponsive: false, default: "1" },
                selectedStyles: "",
                customClass: "",
                elementStyleProperties: {
                  styles: { label: { fontSize: "20px" } }
                },
                inlineStyle: "",
                style: "      \n         "
              },
              elementLabel: "Action-0",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    theme: "",
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    padding: [],
                    margin: [],
                    text: { align: "center", color: "" },
                    height: "",
                    minHeight: "",
                    maxHeight: "",
                    class: "slds-text-align_center ",
                    sizeClass: "slds-size_1-of-12 ",
                    container: { class: "" },
                    size: { isResponsive: false, default: "1" },
                    selectedStyles: "",
                    customClass: "",
                    elementStyleProperties: {
                      styles: { label: { fontSize: "20px" } }
                    },
                    inlineStyle: "",
                    style: "      \n         "
                  },
                  label: "Default",
                  name: "Default",
                  conditionString: "",
                  draggable: false,
                  isSetForDesignTime: false,
                  isopen: true
                },
                {
                  key: 1,
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
                      type: "border_bottom",
                      width: "2",
                      color: "#0176d3",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {
                      styles: { label: { fontSize: "20px" } }
                    },
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center slds-border_bottom ",
                    style: "     border-bottom: #0176d3 2px solid; \n         ",
                    selectedStyles: "Selected Tab",
                    element: "action"
                  },
                  label: "Selected Tab",
                  name: "Selected Tab",
                  conditionString: "Session.selectedTab == Current",
                  isSetForDesignTime: false,
                  draggable: true,
                  isopen: true
                }
              ]
            },
            {
              name: "Action",
              element: "action",
              size: { isResponsive: false, default: "1" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "History",
                iconName: "standard-default",
                record: "{record}",
                card: "{card}",
                stateObj: "{record}",
                actionList: [
                  {
                    stateAction: {
                      id: "flex-action-1684735216065",
                      type: "cardAction",
                      targetType: "Web Page",
                      openUrlIn: "Current Window",
                      "Web Page": { targetName: "/apex" },
                      eventName: "setValues",
                      fieldValues: [
                        {
                          fieldName: "Session.selectedTab",
                          fieldValue: "History"
                        }
                      ]
                    },
                    key: "1684734948232-xytnyes9j",
                    label: "History Tab Change",
                    draggable: true,
                    isOpen: false,
                    actionIndex: 0,
                    isTrackingDisabled: true
                  }
                ],
                showSpinner: "false",
                hideActionIcon: true,
                flyoutDetails: {},
                styles: { label: { fontSize: "20px" } },
                flyoutChannel: "close_modal"
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
                  type: "border_bottom",
                  width: "2",
                  color: "#0176d3",
                  radius: "",
                  style: ""
                },
                elementStyleProperties: {
                  styles: { label: { fontSize: "20px" } }
                },
                text: { align: "center", color: "" },
                inlineStyle: "",
                class: "slds-text-align_center slds-border_bottom ",
                style: "     border-bottom: #0176d3 2px solid; \n         ",
                selectedStyles: "Selected Tab",
                element: "action"
              },
              elementLabel: "Action-1",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    theme: "",
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    padding: [],
                    margin: [],
                    text: { align: "center", color: "" },
                    height: "",
                    minHeight: "",
                    maxHeight: "",
                    class: "slds-text-align_center ",
                    sizeClass: "slds-size_1-of-12 ",
                    container: { class: "" },
                    size: { isResponsive: false, default: "1" },
                    selectedStyles: "",
                    customClass: "",
                    elementStyleProperties: {
                      styles: { label: { fontSize: "20px" } }
                    },
                    inlineStyle: "",
                    style: "      \n         "
                  },
                  label: "Default",
                  name: "Default",
                  conditionString: "",
                  draggable: false,
                  isSetForDesignTime: false,
                  isopen: true
                },
                {
                  key: 1,
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
                      type: "border_bottom",
                      width: "2",
                      color: "#0176d3",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {
                      styles: { label: { fontSize: "20px" } }
                    },
                    text: { align: "center", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_center slds-border_bottom ",
                    style: "     border-bottom: #0176d3 2px solid; \n         ",
                    selectedStyles: "Selected Tab",
                    element: "action"
                  },
                  label: "Selected Tab",
                  name: "Selected Tab",
                  conditionString: "Session.selectedTab == History",
                  isSetForDesignTime: true,
                  draggable: true,
                  isopen: true
                }
              ]
            },
            {
              name: "FlexCard",
              element: "childCardPreview",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                cardName: "CreditAssessmentChildContainer",
                recordId: "{recordId}",
                cardNode: "{record.current}",
                selectedState: "Active",
                isChildCardTrackingEnabled: false,
                "data-conditions": {
                  id: "state-condition-object",
                  isParent: true,
                  group: [
                    {
                      id: "state-new-condition-7",
                      field: "Session.selectedTab",
                      operator: "==",
                      value: "Current",
                      type: "custom",
                      hasMergeField: false
                    }
                  ]
                }
              },
              type: "element",
              styleObject: { sizeClass: "slds-size_12-of-12" },
              elementLabel: "FlexCard-2"
            },
            {
              name: "FlexCard",
              element: "childCardPreview",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                cardName: "CreditAssessmentChildContainer",
                recordId: "{recordId}",
                cardNode: "{record.history}",
                selectedState: "Active",
                isChildCardTrackingEnabled: false,
                "data-conditions": {
                  id: "state-condition-object",
                  isParent: true,
                  group: [
                    {
                      id: "state-new-condition-239",
                      field: "Session.selectedTab",
                      operator: "==",
                      value: "History",
                      type: "custom",
                      hasMergeField: false
                    },
                    {
                      id: "state-new-condition-252",
                      field: "record.history",
                      operator: "!=",
                      value: "null",
                      type: "custom",
                      hasMergeField: false,
                      logicalOperator: "&&"
                    }
                  ]
                },
                "data-preloadConditionalElement": false
              },
              type: "element",
              styleObject: { sizeClass: "slds-size_12-of-12" },
              elementLabel: "FlexCard-3"
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
                      id: "state-new-condition-288",
                      field: "Session.selectedTab",
                      operator: "==",
                      value: "History",
                      type: "custom",
                      hasMergeField: false
                    },
                    {
                      id: "state-new-condition-289",
                      field: "record.history.length",
                      operator: "==",
                      value: "0",
                      type: "custom",
                      hasMergeField: false,
                      logicalOperator: "&&"
                    }
                  ]
                },
                "data-preloadConditionalElement": false
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
              elementLabel: "Text-4",
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
      childCards: [
        "CreditAssessmentChildContainer",
        "CreditAssessmentChildContainer"
      ],
      actions: [],
      omniscripts: [],
      documents: []
    }
  ],
  dataSource: {
    type: "Custom",
    value: {
      dsDelay: "",
      body: '{\n  "current": {\n    "length": 1,\n    "assessments": [\n    {\n      "id": "9610b1d5-af42-d5a9-805d-9e5116ee6723",\n      "creditEnquiryId": "13561fa3-5db1-4996-b732-8510337b500d@1",\n      "collateralAssessmentId": "cc1811a3-1ce2-21f9-4c20-b031ae9bfa34",\n      "type": "ASSESSMENT_TYPE_PROVISIONAL",\n      "assessedTime": "2023-04-21T02:35:38.714743Z",\n      "outcome": "ASSESSMENT_OUTCOME_REFERRED",\n      "creditEnquiryServiceabilityId": "954b2232-8dfa-11ec-b909-0242ac120135",\n      "reasons": [\n        {\n          "reasonCode": "RE202",\n          "reasonDescription": "Review expense - Groceries",\n          "reasonOutcome": "ASSESSMENT_REASON_OUTCOME_APPROVED",\n          "applicantId": ""\n        },\n        {\n          "reasonCode": "RE106",\n          "reasonDescription": "Review expense justification - Health, Life & Other",\n          "reasonOutcome": "ASSESSMENT_REASON_OUTCOME_APPROVED",\n          "applicantId": ""\n        },\n        {\n          "reasonCode": "RE104",\n          "reasonDescription": "Review justification - Phone, Internet & Subscriptions",\n          "reasonOutcome": "ASSESSMENT_REASON_OUTCOME_UNSPECIFIED",\n          "applicantId": ""\n        }\n      ],\n      "lvr": { "maxAllowableLvr": 80, "actualLvr": 78.5 },\n      "debtToIncomeRatio": 2.5,\n      "createdBy": "adamboy",\n      "createTime": "2023-04-21T02:42:38.714743Z",\n      "expiryTime": "2023-07-20T02:42:38.714743Z"\n    }\n  ]\n},\n"history": {\n  "length": 0,\n    "assessments": [\n    {\n      "id": "9610b1d5-af42-d5a9-805d-9e5116ee6723",\n      "creditEnquiryId": "13561fa3-5db1-4996-b732-8510337b500d@1",\n      "collateralAssessmentId": "cc1811a3-1ce2-21f9-4c20-b031ae9bfa34",\n      "type": "ASSESSMENT_TYPE_PROVISIONAL",\n      "assessedTime": "2023-04-21T02:35:38.714743Z",\n      "outcome": "ASSESSMENT_OUTCOME_REFERRED",\n      "creditEnquiryServiceabilityId": "954b2232-8dfa-11ec-b909-0242ac120135",\n      "reasons": [\n        {\n          "reasonCode": "RE202",\n          "reasonDescription": "Review expense - Groceries",\n          "reasonOutcome": "ASSESSMENT_REASON_OUTCOME_APPROVED",\n          "applicantId": ""\n        },\n        {\n          "reasonCode": "RE106",\n          "reasonDescription": "Review expense justification - Health, Life & Other",\n          "reasonOutcome": "ASSESSMENT_REASON_OUTCOME_APPROVED",\n          "applicantId": ""\n        },\n        {\n          "reasonCode": "RE104",\n          "reasonDescription": "Review justification - Phone, Internet & Subscriptions",\n          "reasonOutcome": "ASSESSMENT_REASON_OUTCOME_UNSPECIFIED",\n          "applicantId": ""\n        }\n      ],\n      "lvr": { "maxAllowableLvr": 80, "actualLvr": 78.5 },\n      "debtToIncomeRatio": 2.5,\n      "createdBy": "adamboy",\n      "createTime": "2023-04-21T02:42:38.714743Z",\n      "expiryTime": "2023-07-20T02:42:38.714743Z"\n    }\n  ]\n}\n}\n',
      resultVar: ""
    },
    orderBy: { name: "", isReverse: "" },
    contextVariables: []
  },
  title: "CreditAssessmentParent",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfCreditAssessmentParent_1_ANZx",
    Id: "0RbBm0000005GaPKAU",
    MasterLabel: "cfCreditAssessmentParent_1_ANZx",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  sessionVars: [{ name: "selectedTab", val: "Current" }],
  Name: "CreditAssessmentParent",
  uniqueKey: "CreditAssessmentParent_1_ANZx",
  Id: "0koBm0000000Q0vIAE",
  OmniUiCardKey: "CreditAssessmentParent/ANZx/1.0",
  OmniUiCardType: "Child"
};
export default definition;
