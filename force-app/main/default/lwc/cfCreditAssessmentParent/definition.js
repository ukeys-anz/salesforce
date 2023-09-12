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
                },
                parentAttribute: { selectedTab: "Current" }
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
                    }
                  ]
                },
                "data-preloadConditionalElement": false,
                parentAttribute: { selectedTab: "History" }
              },
              type: "element",
              styleObject: { sizeClass: "slds-size_12-of-12" },
              elementLabel: "FlexCard-3"
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
    type: "ApexRemote",
    value: {
      dsDelay: "",
      resultVar: '["object"]',
      remoteClass: "CreditAssessmentController",
      remoteMethod: "getCreditAssessments",
      vlocityAsync: false,
      inputMap: { creditId: "Parent.creditId" },
      jsonMap: '{"Parent.creditId":"{Parent.creditId}"}'
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
  uniqueKey: "CreditAssessmentParent",
  Id: "0koBm0000000Q0vIAE",
  OmniUiCardKey: "CreditAssessmentParent/ANZx/1.0",
  OmniUiCardType: "Child"
};
export default definition;
