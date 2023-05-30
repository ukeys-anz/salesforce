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
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
              children: [
                {
                  key: "element_element_block_0_0_outputField_0_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "9" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22font-size:%2018pt;%22%3E%3Cstrong%3EFinances%3C/strong%3E%3C/span%3E%3C/div%3E%0A%3Cdiv%3E&nbsp;%3C/div%3E%0A%3Cdiv%3E%3Cspan%20style=%22font-size:%2010pt;%22%3ESome%20details%20are%20pre-filled%20from%20the%20customer's%20account%20and%20they%20will%20need%20to%20review%20and%20confirm%20each%20section.%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_9-of-12 ",
                    size: { isResponsive: false, default: "9" }
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Text-0"
                },
                {
                  key: "element_element_block_0_0_action_1_0",
                  name: "Action",
                  element: "action",
                  size: { isResponsive: false, default: "2" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    label: "Refresh all balances",
                    iconName: "standard-default",
                    record: "{record}",
                    card: "{card}",
                    stateObj: "{record}",
                    actionList: [
                      {
                        stateAction: {
                          id: "flex-action-1684285592124",
                          type: "cardAction",
                          targetType: "Web Page",
                          openUrlIn: "Current Window",
                          "Web Page": { targetName: "/apex" },
                          eventName: "reload"
                        },
                        key: "1684285539094-nz5ktqjrg",
                        label: "Action",
                        draggable: false,
                        isOpen: true,
                        actionIndex: 0
                      }
                    ],
                    showSpinner: "false",
                    flyoutDetails: {},
                    hideActionIcon: true,
                    displayAsButton: true,
                    buttonVariant: "neutral"
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_2-of-12 ",
                    size: { isResponsive: false, default: "2" }
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-0-Action-1"
                }
              ],
              elementLabel: "Block-0"
            },
            {
              name: "Block",
              element: "block",
              size: { isResponsive: false, default: "12" },
              stateIndex: 0,
              class: "slds-col ",
              property: {
                label: "Savings",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}",
                styles: { label: { textDecoration: "", color: "" } },
                action: {
                  label: "Action",
                  iconName: "standard-default",
                  eventType: "onclick",
                  actionList: [
                    {
                      key: "1684728769432-9g2em0hem",
                      label: "Action",
                      draggable: false,
                      isOpen: true,
                      card: "{card}",
                      stateAction: {
                        id: "flex-action-1684728846582",
                        type: "cardAction",
                        displayName: "Action",
                        vlocityIcon: "standard-default",
                        openUrlIn: "Current Window",
                        flyoutType: "childCard",
                        openFlyoutIn: "Modal",
                        channelName: "close_modal",
                        eventName: "reload"
                      },
                      actionIndex: 0
                    },
                    {
                      key: "1684728814096-387priuuo",
                      label: "Action",
                      draggable: true,
                      isOpen: false,
                      card: "{card}",
                      stateAction: {
                        id: "test-action",
                        type: "Custom",
                        displayName: "Action",
                        vlocityIcon: "standard-default",
                        targetType: "Web Page",
                        openUrlIn: "Current Window",
                        "Web Page": { targetName: "/apex" }
                      }
                    }
                  ],
                  showSpinner: "false"
                }
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class:
                  "slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small title_color",
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
                  type: [
                    "border_top",
                    "border_right",
                    "border_bottom",
                    "border_left"
                  ],
                  width: "",
                  color: "#cccccc",
                  radius: "",
                  style: ""
                },
                elementStyleProperties: {
                  styles: { label: { textDecoration: "", color: "" } }
                },
                text: { align: "", color: "" },
                inlineStyle: "",
                style:
                  "     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ",
                customClass: "title_color"
              },
              children: [
                {
                  key: "element_element_block_1_0_outputField_0_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}",
                    label: ""
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-0"
                },
                {
                  key: "element_element_block_1_0_outputField_1_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3EThis%20includes%20any%20cash%20and%20money%20in%20your%20account%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-1"
                },
                {
                  key: "element_element_block_1_0_outputField_2_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-2"
                },
                {
                  key: "element_element_block_1_0_outputField_3_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-3"
                },
                {
                  key: "element_element_block_1_0_outputField_4_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22color:%20#000000;%20font-family:%20'Salesforce%20Sans',%20Arial,%20sans-serif;%22%3E%3Cstrong%3EANZ%20Plus%3C/strong%3E%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
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
                    text: { align: "", color: "#000000" },
                    inlineStyle: "",
                    class: "slds-p-left_medium ",
                    style: "      \n        color:#000000; "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-4",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
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
                        text: { align: "", color: "#000000" },
                        inlineStyle: "",
                        class: "slds-p-left_medium ",
                        style: "      \n        color:#000000; "
                      },
                      label: "Default",
                      name: "Default",
                      conditionString: "",
                      draggable: false
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
                    cardName: "SOP_ANZPlus",
                    recordId: "{recordId}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false,
                    cardNode: "{records}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  elementLabel: "FlexCard-1",
                  key: "element_element_block_1_0_childCardPreview_5_0",
                  parentElementKey: "element_block_1_0",
                  userUpdatedElementLabel: true
                },
                {
                  key: "element_element_block_1_0_outputField_6_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-6"
                },
                {
                  key: "element_element_block_1_0_outputField_7_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cspan%20style=%22color:%20#000000;%22%3E%3Cstrong%3EANZ%3C/strong%3E%3C/span%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-left_medium ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-7",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
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
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-left_medium ",
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
                  key: "element_element_block_1_0_childCardPreview_8_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_ANZ3",
                    recordId: "{recordId}",
                    cardNode: "{records}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-FlexCard-8",
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
                  ]
                },
                {
                  key: "element_element_block_1_0_outputField_9_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-9"
                },
                {
                  key: "element_element_block_1_0_outputField_10_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3EOther%20Institutions%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-left_medium ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-10",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
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
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-left_medium ",
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
                  key: "element_element_block_1_0_childCardPreview_11_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Other_Banks",
                    recordId: "{recordId}",
                    cardNode: "{records}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [],
                    margin: [
                      { type: "left", size: "x-small", label: "left:x-small" },
                      { type: "right", size: "large", label: "right:large" }
                    ],
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
                    class: "slds-m-left_x-small slds-m-right_large ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-FlexCard-11",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [],
                        margin: [
                          {
                            type: "left",
                            size: "x-small",
                            label: "left:x-small"
                          },
                          { type: "right", size: "large", label: "right:large" }
                        ],
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
                        class: "slds-m-left_x-small slds-m-right_large ",
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
                  key: "element_element_block_1_0_outputField_12_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}"
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Field-12"
                },
                {
                  key: "element_element_block_1_0_outputField_13_0",
                  name: "Text",
                  element: "outputField",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    mergeField:
                      "%3Cdiv%3E%3Cstrong%3ECash%3C/strong%3E%3C/div%3E",
                    card: "{card}"
                  },
                  type: "text",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [
                      { type: "left", size: "medium", label: "left:medium" }
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
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    class: "slds-p-left_medium ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-Text-13",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [
                          { type: "left", size: "medium", label: "left:medium" }
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
                        text: { align: "", color: "" },
                        inlineStyle: "",
                        class: "slds-p-left_medium ",
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
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Other",
                    recordId: "{recordId}",
                    cardNode: "{records}",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_12-of-12 ",
                    padding: [],
                    margin: [
                      { type: "right", size: "large", label: "right:large" }
                    ],
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
                    class: "slds-m-right_large ",
                    style: "      \n         "
                  },
                  elementLabel: "Your Savings-FlexCard-14",
                  key: "element_element_block_1_0_childCardPreview_14_0",
                  parentElementKey: "element_block_1_0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_12-of-12 ",
                        padding: [],
                        margin: [
                          { type: "right", size: "large", label: "right:large" }
                        ],
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
                        class: "slds-m-right_large ",
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
                  key: "element_element_block_1_0_childCardPreview_15_0",
                  name: "FlexCard",
                  element: "childCardPreview",
                  size: { isResponsive: false, default: "12" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    cardName: "SOP_Message_Flex",
                    recordId: "{recordId}",
                    cardNode: "",
                    selectedState: "Active",
                    isChildCardTrackingEnabled: false
                  },
                  type: "element",
                  styleObject: { sizeClass: "slds-size_12-of-12" },
                  parentElementKey: "element_block_1_0",
                  elementLabel: "Your Savings-FlexCard-15"
                }
              ],
              elementLabel: "Your Savings",
              userUpdatedElementLabel: true,
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
                    class:
                      "slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small title_color",
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
                      type: [
                        "border_top",
                        "border_right",
                        "border_bottom",
                        "border_left"
                      ],
                      width: "",
                      color: "#cccccc",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {
                      styles: { label: { textDecoration: "", color: "" } }
                    },
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    style:
                      "     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         ",
                    customClass: "title_color"
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
                label: "Assets",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
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
                customClass: "title_color",
                style: "      \n         "
              },
              children: [],
              elementLabel: "Your Assets",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
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
                    customClass: "title_color",
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
                label: "Debts",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
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
                customClass: "title_color",
                style: "      \n         "
              },
              children: [],
              elementLabel: "Debts",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
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
                    customClass: "title_color",
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
                label: "Income",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
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
                customClass: "title_color",
                style: "      \n         "
              },
              children: [],
              elementLabel: "Income",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
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
                    customClass: "title_color",
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
                label: "Spending",
                collapsible: true,
                record: "{record}",
                collapsedByDefault: true,
                card: "{card}"
              },
              type: "block",
              styleObject: {
                padding: [
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class: "slds-p-around_x-small title_color",
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
                customClass: "title_color",
                style: "      \n         "
              },
              children: [],
              elementLabel: "Spending",
              userUpdatedElementLabel: true,
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
                    class: "slds-p-around_x-small title_color",
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
                    customClass: "title_color",
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
        "SOP_ANZPlus",
        "SOP_ANZ3",
        "SOP_Other_Banks",
        "SOP_Other",
        "SOP_Message_Flex"
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
      resultVar: '["object"]["assets"]',
      remoteClass: "ResidentialLoanApplicationController",
      remoteMethod: "getListAssets",
      vlocityAsync: false
    },
    orderBy: { name: "estimatedValue.value", isReverse: "true" },
    contextVariables: []
  },
  title: "SOP_Finances_Savings",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfSOP_Finances_Savings_1_ANZ",
    Id: "0Rb8r000000F1JxCAK",
    MasterLabel: "cfSOP_Finances_Savings_1_ANZ",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  isRepeatable: false,
  osSupport: true,
  globalCSS: true,
  Name: "SOP_Finances_Savings",
  uniqueKey: "SOP_Finances_Savings",
  Id: "0ko8r0000000I6bAAE",
  OmniUiCardKey: "SOP_Finances_Savings/ANZ/1.0",
  OmniUiCardType: "Parent"
};
export default definition;
