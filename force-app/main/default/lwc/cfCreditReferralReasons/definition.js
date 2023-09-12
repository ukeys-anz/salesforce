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
        padding: [],
        margin: [],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "12" },
        sizeClass: "slds-size_12-of-12 ",
        class: "slds-card ",
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
              size: { isResponsive: false, default: 12 },
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
                size: { isResponsive: false, default: 12 },
                padding: [
                  { type: "bottom", size: "large", label: "bottom:large" }
                ],
                class: "slds-p-bottom_large ",
                sizeClass: "slds-size_12-of-12 ",
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
                text: { align: "", color: "" },
                inlineStyle: "",
                style: "      \n         "
              },
              children: [
                {
                  key: "element_element_block_0_0_outputField_0_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "1" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cp%20class=%22slds-text-body_regular%22%3E%7BreasonCode%7D%3C/p%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "1" },
                    sizeClass: "slds-size_1-of-12 ",
                    padding: [
                      { type: "right", size: "medium", label: "right:medium" }
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
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-right_medium ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Reason-Code_value",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "1" },
                        sizeClass: "slds-size_1-of-12 ",
                        padding: [
                          {
                            type: "right",
                            size: "medium",
                            label: "right:medium"
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
                        elementStyleProperties: {},
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-right_medium ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  userUpdatedElementLabel: true
                },
                {
                  key: "element_element_block_0_0_outputField_1_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "1" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cp%20class=%22slds-text-body_regular%22%3E%7BassessmentCategory%7D%3C/p%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "1" },
                    sizeClass: "slds-size_1-of-12 ",
                    padding: [
                      { type: "right", size: "x-large", label: "right:x-large" }
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
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-right_x-large ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Assessment-Category_value",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "1" },
                        sizeClass: "slds-size_1-of-12 ",
                        padding: [
                          {
                            type: "right",
                            size: "x-large",
                            label: "right:x-large"
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
                        elementStyleProperties: {},
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-right_x-large ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  userUpdatedElementLabel: true
                },
                {
                  key: "element_element_block_0_0_outputField_2_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "3" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cp%3E%7BreasonDescription%7D%3C/p%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "3" },
                    sizeClass: "slds-size_3-of-12 ",
                    padding: [
                      { type: "right", size: "x-large", label: "right:x-large" }
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
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-right_x-large ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Reason-Description_value",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "3" },
                        sizeClass: "slds-size_3-of-12 ",
                        padding: [
                          {
                            type: "right",
                            size: "x-large",
                            label: "right:x-large"
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
                        elementStyleProperties: {},
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-right_x-large ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  userUpdatedElementLabel: true
                },
                {
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "1" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cp%20class=%22slds-text-body_regular%22%3E%7BauthorityLevel%7D%3C/p%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "1" },
                    sizeClass: "slds-size_1-of-12 ",
                    padding: [
                      { type: "right", size: "x-large", label: "right:x-large" }
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
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-right_x-large ",
                    style: "      \n         "
                  },
                  elementLabel: "Authority-Level_value",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "1" },
                        sizeClass: "slds-size_1-of-12 ",
                        padding: [
                          {
                            type: "right",
                            size: "x-large",
                            label: "right:x-large"
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
                        elementStyleProperties: {},
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-right_x-large ",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  key: "element_element_block_0_0_outputField_3_0",
                  parentElementKey: "element_block_0_0",
                  userUpdatedElementLabel: true
                },
                {
                  key: "element_element_block_0_0_outputField_4_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "1" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cp%20class=%22slds-text-body_regular%22%3E%7BguidanceCode%7D%3C/p%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "1" },
                    sizeClass: "slds-size_1-of-12 ",
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Guidance-Code_value",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "1" },
                        sizeClass: "slds-size_1-of-12 ",
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
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  userUpdatedElementLabel: true
                },
                {
                  name: "Action",
                  element: "action",
                  size: { isResponsive: false, default: "3" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    label: "Test sample",
                    iconName: "utility:edit",
                    record: "{record}",
                    card: "{card}",
                    stateObj: "{record}",
                    actionList: [
                      {
                        stateAction: {
                          id: "flex-action-1686628146415",
                          type: "Flyout",
                          openUrlIn: "Current Window",
                          flyoutType: "childCard",
                          openFlyoutIn: "Modal",
                          channelName: "close_modal",
                          flyoutCustomLwcData: {
                            attributes: {
                              type: "LightningComponentBundle",
                              url:
                                "/services/data/v46.0/tooling/sobjects/LightningComponentBundle/0RbBm0000003gAEKAY"
                            },
                            MasterLabel: "modal",
                            IsExposed: true,
                            Id: "0RbBm0000003gAEKAY",
                            NamespacePrefix: "omnistudio",
                            ManageableState: "installed",
                            DeveloperName: "modal"
                          },
                          flyoutLwc: "CreditAssessmentModal",
                          cardName: "CreditAssessmentModal",
                          cardNode: "{record}"
                        },
                        key: "1686112953672-5wgj5r1wg",
                        label: "Action",
                        draggable: true,
                        isOpen: true,
                        actionIndex: 0
                      }
                    ],
                    showSpinner: "false",
                    iconOnly: false,
                    flyoutChannel: "close_modal",
                    flyoutDetails: { openFlyoutIn: "Modal" },
                    iconSize: "x-small",
                    displayAsButton: false,
                    hideActionIcon: false
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_3-of-12 ",
                    size: { isResponsive: false, default: "3" },
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
                    elementStyleProperties: { iconSize: "x-small" },
                    text: { align: "", color: "" },
                    inlineStyle: "position: relative; right: 20px;",
                    class: "",
                    style: "      \n         position: relative; right: 20px;",
                    customClass: ""
                  },
                  elementLabel: "Referral-Outcome_value",
                  key: "element_element_block_0_0_action_5_0",
                  parentElementKey: "element_block_0_0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_3-of-12 ",
                        size: { isResponsive: false, default: "3" },
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
                        elementStyleProperties: { iconSize: "x-small" },
                        text: { align: "", color: "" },
                        inlineStyle: "position: relative; right: 20px;",
                        class: "",
                        style:
                          "      \n         position: relative; right: 20px;",
                        customClass: ""
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  userUpdatedElementLabel: true
                },
                {
                  key: "element_element_block_0_0_outputField_6_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "2" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3EPeter%20Charalambous,%2008/06/2023%209:23am%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    size: { isResponsive: false, default: "2" },
                    sizeClass: "slds-size_2-of-12 ",
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Last-Modified_value",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: "2" },
                        sizeClass: "slds-size_2-of-12 ",
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
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "",
                        style: "      \n         "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ],
                  userUpdatedElementLabel: true
                }
              ],
              elementLabel: "Block-0",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    size: { isResponsive: false, default: 12 },
                    padding: [
                      { type: "bottom", size: "large", label: "bottom:large" }
                    ],
                    class: "slds-p-bottom_large ",
                    sizeClass: "slds-size_12-of-12 ",
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
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
      childCards: [],
      actions: [],
      omniscripts: [],
      documents: []
    }
  ],
  dataSource: { type: null, value: {}, orderBy: {}, contextVariables: [] },
  title: "CreditReferralReasons",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfCreditReferralReasons_1_ANZx",
    Id: "0RbBm0000003yJ2KAI",
    MasterLabel: "cfCreditReferralReasons_1_ANZx",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  globalCSS: false,
  Name: "CreditReferralReasons",
  uniqueKey: "CreditReferralReasons",
  Id: "0koBm0000000MBpIAM",
  OmniUiCardKey: "CreditReferralReasons/ANZx/1.0",
  OmniUiCardType: "Child"
};
export default definition;
