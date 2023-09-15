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
                  { type: "top", size: "small", label: "top:small" },
                  { type: "bottom", size: "x-small", label: "bottom:x-small" }
                ],
                class:
                  "slds-border_right slds-border_bottom slds-border_left slds-border_top slds-p-top_small slds-p-bottom_x-small ",
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
                  type: [
                    "border_right",
                    "border_bottom",
                    "border_left",
                    "border_top"
                  ],
                  width: "1",
                  color: "#cccccc",
                  radius: "",
                  style: "solid"
                },
                elementStyleProperties: {},
                text: { align: "", color: "" },
                inlineStyle: "",
                style:
                  "     border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid; \n         "
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
                    margin: [
                      { type: "left", size: "small", label: "left:small" }
                    ],
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
                    class: "slds-p-right_medium slds-m-left_small ",
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
                        margin: [
                          { type: "left", size: "small", label: "left:small" }
                        ],
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
                        class: "slds-p-right_medium slds-m-left_small ",
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
                  userUpdatedElementLabel: true,
                  key: "element_element_block_0_0_outputField_4_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_outputField_5_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "2" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%7BreferralOutcomeDescription%7D%3C/div%3E",
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
                  elementLabel: "Referral-outcome_value",
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
                      "%3Cdiv%3E%7BcreatedBy%7D,%20%7BcreateTime%7D%3C/div%3E",
                    card: "{card}",
                    "data-conditions": {
                      id: "state-condition-object",
                      isParent: true,
                      group: [
                        {
                          id: "state-new-condition-3",
                          field: "createdBy",
                          operator: "!=",
                          value: "",
                          type: "custom",
                          hasMergeField: false
                        },
                        {
                          id: "state-new-condition-0",
                          field: "createTime",
                          operator: "!=",
                          value: "",
                          type: "custom",
                          hasMergeField: false,
                          logicalOperator: "&&"
                        }
                      ]
                    }
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
                    inlineStyle: "margin-right: -50px",
                    class: "",
                    style: "      \n         margin-right: -50px"
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-7-clone-0",
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
                        inlineStyle: "margin-right: -50px",
                        class: "",
                        style: "      \n         margin-right: -50px"
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
                  key: "element_element_block_0_0_outputField_7_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "2" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField: "%3Cdiv%3E%7BcreateTime%7D%3C/div%3E",
                    card: "{card}",
                    "data-conditions": {
                      id: "state-condition-object",
                      isParent: true,
                      group: [
                        {
                          id: "state-new-condition-3",
                          field: "createdBy",
                          operator: "==",
                          value: "",
                          type: "custom",
                          hasMergeField: false
                        },
                        {
                          id: "state-new-condition-7",
                          field: "createTime",
                          operator: "!=",
                          value: "",
                          type: "custom",
                          hasMergeField: false,
                          logicalOperator: "&&"
                        }
                      ]
                    }
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
                    inlineStyle: "margin-right: -50px",
                    class: "",
                    style: "      \n         margin-right: -50px"
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Text-6-clone-0",
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
                        inlineStyle: "margin-right: -50px",
                        class: "",
                        style: "      \n         margin-right: -50px"
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
                  size: { isResponsive: false, default: "1" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    label: "Edit",
                    iconName: "utility:edit",
                    record: "{record}",
                    card: "{card}",
                    stateObj: "{record}",
                    actionList: [
                      {
                        stateAction: {
                          id: "flex-action-1694580022797",
                          type: "Flyout",
                          openUrlIn: "Current Window",
                          flyoutType: "customLwc",
                          openFlyoutIn: "Modal",
                          channelName: "close_modal",
                          flyoutLwc: "creditAssessmentModal",
                          cardName: "CreditAssessmentModal",
                          cardNode: "{record}",
                          flyoutContainerClass: "",
                          hasExtraParams: true,
                          flyoutParams: {
                            reasonCode: "{reasonCode}",
                            assessmentCategory: "{assessmentCategory}",
                            reasonDescription: "{reasonDescription}",
                            guidanceCode: "{guidanceCode}",
                            createdBy: "{createdBy}",
                            createTime: "{createTime}",
                            referralOutcomeCode: "{referralOutcomeCode}",
                            reasonCodeId: "{reasonCodeId}",
                            recordId: "{Parent.recordId}",
                            creditId: "{Parent.creditId}",
                            applicantId: "{applicantId}"
                          }
                        },
                        key: "1686112953672-5wgj5r1wg",
                        label: "Open Modal",
                        draggable: true,
                        isOpen: true,
                        actionIndex: 0,
                        preloadFlyout: false,
                        reRenderFlyout: false
                      }
                    ],
                    showSpinner: "false",
                    iconOnly: true,
                    flyoutChannel: "close_modal",
                    flyoutDetails: { openFlyoutIn: "Modal" },
                    iconSize: "small",
                    displayAsButton: false,
                    hideActionIcon: false,
                    buttonVariant: "neutral",
                    disabled: "",
                    "data-conditions": {
                      id: "state-condition-object",
                      isParent: true,
                      group: [
                        {
                          id: "state-new-condition-10",
                          field: "Parent.selectedTab",
                          operator: "==",
                          value: "Current",
                          type: "custom",
                          hasMergeField: false
                        },
                        {
                          id: "state-new-condition-0",
                          field: "editable",
                          operator: "==",
                          value: "true",
                          type: "custom",
                          hasMergeField: false,
                          logicalOperator: "&&"
                        }
                      ]
                    },
                    iconColor: "#0070D2",
                    preloadFlyout: false,
                    reRenderFlyout: false
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
                    elementStyleProperties: {
                      iconSize: "small",
                      iconColor: "#0070D2"
                    },
                    text: { align: "", color: "" },
                    inlineStyle: "position:relative; left: 80px",
                    class: "",
                    style: "      \n         position:relative; left: 80px",
                    customClass: ""
                  },
                  elementLabel: "Last-Modified_value2",
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
                        elementStyleProperties: {
                          iconSize: "small",
                          iconColor: "#0070D2"
                        },
                        text: { align: "", color: "" },
                        inlineStyle: "position:relative; left: 80px",
                        class: "",
                        style: "      \n         position:relative; left: 80px",
                        customClass: ""
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false,
                      isSetForDesignTime: false,
                      isopen: true
                    }
                  ],
                  userUpdatedElementLabel: true,
                  key: "element_element_block_0_0_action_8_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_flexIcon_9_0",
                  name: "Icon",
                  element: "flexIcon",
                  size: { isResponsive: false, default: 1 },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    card: "{card}",
                    iconType: "Salesforce SVG",
                    iconName: "utility:edit",
                    size: "small",
                    extraclass: "",
                    variant: "default",
                    imgsrc: "",
                    "data-conditions": {
                      id: "state-condition-object",
                      isParent: true,
                      group: [
                        {
                          id: "state-new-condition-0",
                          field: "Parent.selectedTab",
                          operator: "==",
                          value: "Current",
                          type: "custom",
                          hasMergeField: false
                        },
                        {
                          id: "state-new-condition-7",
                          field: "editable",
                          operator: "!=",
                          value: "true",
                          type: "custom",
                          hasMergeField: false,
                          logicalOperator: "&&"
                        }
                      ]
                    }
                  },
                  type: "element",
                  styleObject: {
                    size: { isResponsive: false, default: 1 },
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
                    inlineStyle: "position:relative; left: 80px",
                    class: "",
                    style: "      \n         position:relative; left: 80px"
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Icon-8",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        size: { isResponsive: false, default: 1 },
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
                        inlineStyle: "position:relative; left: 80px",
                        class: "",
                        style: "      \n         position:relative; left: 80px"
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
                    }
                  ]
                }
              ],
              elementLabel: "Block-1",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    size: { isResponsive: false, default: 12 },
                    padding: [
                      { type: "top", size: "small", label: "top:small" },
                      {
                        type: "bottom",
                        size: "x-small",
                        label: "bottom:x-small"
                      }
                    ],
                    class:
                      "slds-border_right slds-border_bottom slds-border_left slds-border_top slds-p-top_small slds-p-bottom_x-small ",
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
                      type: [
                        "border_right",
                        "border_bottom",
                        "border_left",
                        "border_top"
                      ],
                      width: "1",
                      color: "#cccccc",
                      radius: "",
                      style: "solid"
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    style:
                      "     border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid;border-top: #cccccc 1px solid; \n         "
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
    DeveloperName: "cfCreditReferralReasons_2_ANZx",
    Id: "0RbAD000000KSOL0A4",
    MasterLabel: "cfCreditReferralReasons_2_ANZx",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  globalCSS: false,
  events: [
    {
      eventname: "closeFlyout",
      channelname: "CreditReferralReasons",
      element: "action",
      eventtype: "pubsub",
      recordIndex: "0",
      actionList: [
        {
          key: "1689725972331-93vk8ppnw",
          label: "Action",
          draggable: false,
          isOpen: true,
          card: "{card}",
          stateAction: {
            message: "closemodal",
            id: "flex-action-1689742547511",
            type: "cardAction",
            subType: "Custom",
            eventName: "reload",
            bubbles: true,
            composed: true
          },
          actionIndex: 0,
          isTrackingDisabled: true
        }
      ],
      showSpinner: "false",
      key: "event-0",
      displayLabel: "CreditReferralReasons:closeFlyout",
      eventLabel: "pubsub"
    }
  ],
  selectedCardsLabel: "",
  sessionVars: [],
  Name: "CreditReferralReasons",
  uniqueKey: "CreditReferralReasons",
  Id: "0ko9r0000000kcMAAQ",
  OmniUiCardKey: "CreditReferralReasons/ANZx/2.0",
  OmniUiCardType: "Child"
};
export default definition;
