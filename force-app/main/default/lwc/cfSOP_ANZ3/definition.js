let definition = {
  states: [
    {
      fields: [],
      conditions: {
        id: "state-condition-object",
        isParent: true,
        group: [
          {
            id: "state-new-condition-0",
            field: "type",
            operator: "==",
            value: "ASSET_TYPE_BANK_ACCOUNT",
            type: "custom",
            hasMergeField: false
          },
          {
            id: "state-new-condition-7",
            field: "account.financialInstitution",
            operator: "==",
            value: "ANZ",
            type: "custom",
            hasMergeField: false,
            logicalOperator: "&&"
          }
        ]
      },
      definedActions: { actions: [] },
      name: "Active",
      isSmartAction: false,
      smartAction: {},
      styleObject: {
        padding: [{ type: "around", size: "x-small", label: "around:x-small" }],
        margin: [{ type: "left", size: "small", label: "left:small" }],
        container: { class: "slds-card" },
        size: { isResponsive: false, default: "6" },
        sizeClass: "slds-size_6-of-12 ",
        class:
          "slds-theme_default slds-card slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_x-small slds-m-left_small ",
        background: {
          color: "",
          image: "",
          size: "",
          repeat: "",
          position: ""
        },
        border: {
          type: ["border_top", "border_right", "border_bottom", "border_left"],
          width: "1",
          color: "#cccccc",
          radius: "5 px",
          style: ""
        },
        elementStyleProperties: {},
        text: { align: "", color: "" },
        inlineStyle: "",
        style:
          "     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n    border-radius:5 px;     ",
        theme: "theme_default"
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
                  { type: "left", size: "xxx-small", label: "left:xxx-small" },
                  { type: "around", size: "x-small", label: "around:x-small" }
                ],
                class:
                  "slds-theme_default  slds-p-left_xxx-small slds-p-around_x-small ",
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
                  type: [],
                  width: "",
                  color: "",
                  radius: "",
                  style: ""
                },
                elementStyleProperties: {},
                text: { align: "", color: "" },
                inlineStyle: "",
                style: "      \n         ",
                theme: "theme_default"
              },
              children: [
                {
                  key: "element_element_block_0_0_flexImg_0_0",
                  name: "Image",
                  element: "flexImg",
                  size: {
                    isResponsive: false,
                    default: "1",
                    large: "2",
                    medium: "2",
                    small: "1"
                  },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    record: "{record}",
                    card: "{card}",
                    size: "",
                    extraclass: "slds-align_absolute-right",
                    stateImg: {
                      imgsrc:
                        "/sfc/servlet.shepherd/version/download/0688r000001BxU1AAK",
                      alternativeText: "Image description",
                      document: {
                        label: "ANZ-Classic-lotus-circle-small (Version:1)",
                        value:
                          "/sfc/servlet.shepherd/version/download/0688r000001BxU1AAK",
                        title: "ANZ-Classic-lotus-circle-small",
                        Id: "0688r000001BxU1AAK",
                        attachmentType: "ContentVersion"
                      }
                    },
                    imgHeight: "60 px"
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_1-of-12 ",
                    size: {
                      isResponsive: false,
                      default: "1",
                      large: "2",
                      medium: "2",
                      small: "1"
                    },
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
                  elementLabel: "Block-1-Image-0",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_1-of-12 ",
                        size: {
                          isResponsive: false,
                          default: "1",
                          large: "2",
                          medium: "2",
                          small: "1"
                        },
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
                  ]
                },
                {
                  name: "Block",
                  element: "block",
                  size: { isResponsive: false, default: "7" },
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
                      { type: "left", size: "medium", label: "left:medium" },
                      {
                        type: "left",
                        size: "xxx-small",
                        label: "left:xxx-small"
                      }
                    ],
                    class: "slds-p-left_medium slds-p-left_xxx-small ",
                    sizeClass: "slds-size_7-of-12 ",
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "7" },
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
                      key:
                        "element_element_element_block_0_0_block_1_0_outputField_0_0",
                      name: "Text",
                      element: "outputField",
                      size: { isResponsive: false, default: "9" },
                      stateIndex: 0,
                      class: "slds-col ",
                      property: {
                        record: "{record}",
                        mergeField:
                          "%3Cdiv%3E%3Cstrong%3E%7Baccount.financialInstitution%7D%3C/strong%3E%3C/div%3E",
                        card: "{card}"
                      },
                      type: "text",
                      styleObject: {
                        sizeClass: "slds-size_9-of-12 ",
                        padding: [
                          {
                            type: "left",
                            size: "xx-small",
                            label: "left:xx-small"
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
                        size: { isResponsive: false, default: "9" },
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
                        class: "slds-p-left_xx-small ",
                        style: "      \n         "
                      },
                      parentElementKey: "element_element_block_0_0_block_1_0",
                      elementLabel: "Block-1-Block-13-Text-0",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            sizeClass: "slds-size_9-of-12 ",
                            padding: [
                              {
                                type: "left",
                                size: "xx-small",
                                label: "left:xx-small"
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
                            size: { isResponsive: false, default: "9" },
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
                            class: "slds-p-left_xx-small ",
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
                  elementLabel: "Block-1-Block-13",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        padding: [
                          {
                            type: "left",
                            size: "medium",
                            label: "left:medium"
                          },
                          {
                            type: "left",
                            size: "xxx-small",
                            label: "left:xxx-small"
                          }
                        ],
                        class: "slds-p-left_medium slds-p-left_xxx-small ",
                        sizeClass: "slds-size_7-of-12 ",
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "7" },
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
                  ],
                  key: "element_element_block_0_0_block_1_0",
                  parentElementKey: "element_block_0_0"
                },
                {
                  key: "element_element_block_0_0_block_2_0",
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
                      {
                        type: "left",
                        size: "xx-large",
                        label: "left:xx-large"
                      },
                      { type: "left", size: "x-large", label: "left:x-large" },
                      { type: "right", size: "large", label: "right:large" }
                    ],
                    class:
                      "slds-p-left_xx-large slds-p-left_x-large slds-p-right_large ",
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
                    style: "      \n         "
                  },
                  children: [
                    {
                      key:
                        "element_element_element_block_0_0_block_1_0_block_0_0",
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
                          {
                            type: "left",
                            size: "medium",
                            label: "left:medium"
                          },
                          { type: "left", size: "small", label: "left:small" },
                          {
                            type: "right",
                            size: "x-small",
                            label: "right:x-small"
                          }
                        ],
                        class:
                          "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                        style: "      \n         "
                      },
                      children: [
                        {
                          key:
                            "element_element_element_element_block_0_0_block_1_0_block_0_0_outputField_0_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField: "%3Cdiv%3EBelongs%20To%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            padding: [],
                            margin: [],
                            background: {
                              color: "",
                              image: "",
                              size: "",
                              repeat: "",
                              position: ""
                            },
                            size: { isResponsive: false, default: "6" },
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
                          parentElementKey:
                            "element_element_element_block_0_0_block_1_0_block_0_0",
                          elementLabel: "Block-0-Block-2-Block-0-Text-0",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                padding: [],
                                margin: [],
                                background: {
                                  color: "",
                                  image: "",
                                  size: "",
                                  repeat: "",
                                  position: ""
                                },
                                size: { isResponsive: false, default: "6" },
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
                          key:
                            "element_element_element_element_block_0_0_block_1_0_block_0_0_outputField_2_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField:
                              "%3Cdiv%3E%7Bownership%5B0%5D.ownerName%7D%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            size: { isResponsive: false, default: "6" },
                            padding: [
                              {
                                type: "right",
                                size: "xxx-small",
                                label: "right:xxx-small"
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
                            text: { align: "right", color: "" },
                            inlineStyle: "",
                            class:
                              "slds-text-align_right slds-p-right_xxx-small ",
                            style: "      \n         "
                          },
                          parentElementKey:
                            "element_element_element_block_0_0_block_1_0_block_0_0",
                          elementLabel: "Block-0-Block-2-Block-0-Text-1",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                size: { isResponsive: false, default: "6" },
                                padding: [
                                  {
                                    type: "right",
                                    size: "xxx-small",
                                    label: "right:xxx-small"
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
                                text: { align: "right", color: "" },
                                inlineStyle: "",
                                class:
                                  "slds-text-align_right slds-p-right_xxx-small ",
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
                      parentElementKey: "element_element_block_0_0_block_1_0",
                      elementLabel: "Block-0-Block-2-Block-0",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            padding: [
                              {
                                type: "left",
                                size: "medium",
                                label: "left:medium"
                              },
                              {
                                type: "left",
                                size: "small",
                                label: "left:small"
                              },
                              {
                                type: "right",
                                size: "x-small",
                                label: "right:x-small"
                              }
                            ],
                            class:
                              "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Block-1",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        padding: [
                          {
                            type: "left",
                            size: "xx-large",
                            label: "left:xx-large"
                          },
                          {
                            type: "left",
                            size: "x-large",
                            label: "left:x-large"
                          },
                          { type: "right", size: "large", label: "right:large" }
                        ],
                        class:
                          "slds-p-left_xx-large slds-p-left_x-large slds-p-right_large ",
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
                  key: "element_element_block_0_0_outputField_3_0",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Field-2"
                },
                {
                  key: "element_element_block_0_0_block_4_0",
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
                      {
                        type: "left",
                        size: "xx-large",
                        label: "left:xx-large"
                      },
                      { type: "left", size: "x-large", label: "left:x-large" },
                      { type: "right", size: "large", label: "right:large" }
                    ],
                    class:
                      "slds-text-align_left slds-p-left_xx-large slds-p-left_x-large slds-p-right_large ",
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
                    text: { align: "left", color: "" },
                    inlineStyle: "",
                    style: "      \n         "
                  },
                  children: [
                    {
                      key:
                        "element_element_element_block_0_0_block_4_0_block_0_0",
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
                          {
                            type: "left",
                            size: "medium",
                            label: "left:medium"
                          },
                          { type: "left", size: "small", label: "left:small" },
                          {
                            type: "right",
                            size: "x-small",
                            label: "right:x-small"
                          }
                        ],
                        class:
                          "slds-text-align_left slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                        text: { align: "left", color: "" },
                        inlineStyle: "",
                        style: "      \n         "
                      },
                      children: [
                        {
                          key:
                            "element_element_element_element_block_0_0_block_4_0_block_0_0_outputField_0_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField: "%3Cdiv%3EBalance%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            padding: [],
                            margin: [],
                            background: {
                              color: "",
                              image: "",
                              size: "",
                              repeat: "",
                              position: ""
                            },
                            size: { isResponsive: false, default: "6" },
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
                          parentElementKey:
                            "element_element_element_block_0_0_block_4_0_block_0_0",
                          elementLabel: "Block-0-Block-4-Block-0-Text-0",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                padding: [],
                                margin: [],
                                background: {
                                  color: "",
                                  image: "",
                                  size: "",
                                  repeat: "",
                                  position: ""
                                },
                                size: { isResponsive: false, default: "6" },
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
                          key:
                            "element_element_element_element_block_0_0_block_4_0_block_0_0_outputField_1_0",
                          name: "Field",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            placeholder: "",
                            record: "{record}",
                            type: "currency",
                            card: "{card}",
                            fieldName: "estimatedValue.value",
                            locale: "en-AU",
                            currency: "AUD"
                          },
                          type: "element",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            padding: [
                              {
                                type: "right",
                                size: "xxx-small",
                                label: "right:xxx-small"
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
                            size: { isResponsive: false, default: "6" },
                            container: { class: "" },
                            border: {
                              type: "",
                              width: "",
                              color: "",
                              radius: "",
                              style: ""
                            },
                            elementStyleProperties: {},
                            text: { align: "right", color: "" },
                            inlineStyle: "",
                            class:
                              "slds-text-align_right slds-p-right_xxx-small ",
                            style: "      \n         "
                          },
                          parentElementKey:
                            "element_element_element_block_0_0_block_4_0_block_0_0",
                          elementLabel: "Block-0-Block-4-Block-0-Field-1",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                padding: [
                                  {
                                    type: "right",
                                    size: "xxx-small",
                                    label: "right:xxx-small"
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
                                size: { isResponsive: false, default: "6" },
                                container: { class: "" },
                                border: {
                                  type: "",
                                  width: "",
                                  color: "",
                                  radius: "",
                                  style: ""
                                },
                                elementStyleProperties: {},
                                text: { align: "right", color: "" },
                                inlineStyle: "",
                                class:
                                  "slds-text-align_right slds-p-right_xxx-small ",
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
                      parentElementKey: "element_element_block_0_0_block_4_0",
                      elementLabel: "Block-0-Block-4-Block-0",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            padding: [
                              {
                                type: "left",
                                size: "medium",
                                label: "left:medium"
                              },
                              {
                                type: "left",
                                size: "small",
                                label: "left:small"
                              },
                              {
                                type: "right",
                                size: "x-small",
                                label: "right:x-small"
                              }
                            ],
                            class:
                              "slds-text-align_left slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                            text: { align: "left", color: "" },
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
                  ],
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Block-3",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        padding: [
                          {
                            type: "left",
                            size: "xx-large",
                            label: "left:xx-large"
                          },
                          {
                            type: "left",
                            size: "x-large",
                            label: "left:x-large"
                          },
                          { type: "right", size: "large", label: "right:large" }
                        ],
                        class:
                          "slds-text-align_left slds-p-left_xx-large slds-p-left_x-large slds-p-right_large ",
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
                        text: { align: "left", color: "" },
                        inlineStyle: "",
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
                  key: "element_element_block_0_0_outputField_5_0",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Field-4"
                },
                {
                  key: "element_element_block_0_0_block_6_0",
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
                      {
                        type: "left",
                        size: "xx-large",
                        label: "left:xx-large"
                      },
                      { type: "left", size: "x-small", label: "left:x-small" },
                      { type: "right", size: "large", label: "right:large" }
                    ],
                    class:
                      "slds-p-left_xx-large slds-p-left_x-small slds-p-right_large ",
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
                    style: "      \n         "
                  },
                  children: [
                    {
                      key:
                        "element_element_element_block_0_0_block_6_0_block_0_0",
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
                          {
                            type: "left",
                            size: "medium",
                            label: "left:medium"
                          },
                          { type: "left", size: "small", label: "left:small" },
                          {
                            type: "right",
                            size: "x-small",
                            label: "right:x-small"
                          }
                        ],
                        class:
                          "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                        style: "      \n         "
                      },
                      children: [
                        {
                          key:
                            "element_element_element_element_block_0_0_block_6_0_block_0_0_outputField_0_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField: "%3Cdiv%3ESavings%20Type%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            padding: [],
                            margin: [],
                            background: {
                              color: "",
                              image: "",
                              size: "",
                              repeat: "",
                              position: ""
                            },
                            size: { isResponsive: false, default: "6" },
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
                          parentElementKey:
                            "element_element_element_block_0_0_block_6_0_block_0_0",
                          elementLabel: "Block-0-Block-8-Block-0-Text-0",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                padding: [],
                                margin: [],
                                background: {
                                  color: "",
                                  image: "",
                                  size: "",
                                  repeat: "",
                                  position: ""
                                },
                                size: { isResponsive: false, default: "6" },
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
                          key:
                            "element_element_element_element_block_0_0_block_6_0_block_0_0_outputField_1_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField: "%3Cdiv%3EBank%20Balance%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            size: { isResponsive: false, default: "6" },
                            padding: [
                              {
                                type: "right",
                                size: "xxx-small",
                                label: "right:xxx-small"
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
                            text: { align: "right", color: "" },
                            inlineStyle: "",
                            class:
                              "slds-text-align_right slds-p-right_xxx-small ",
                            style: "      \n         "
                          },
                          parentElementKey:
                            "element_element_element_block_0_0_block_6_0_block_0_0",
                          elementLabel: "Block-0-Block-8-Block-0-Text-1",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                size: { isResponsive: false, default: "6" },
                                padding: [
                                  {
                                    type: "right",
                                    size: "xxx-small",
                                    label: "right:xxx-small"
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
                                text: { align: "right", color: "" },
                                inlineStyle: "",
                                class:
                                  "slds-text-align_right slds-p-right_xxx-small ",
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
                      parentElementKey: "element_element_block_0_0_block_6_0",
                      elementLabel: "Block-0-Block-8-Block-0",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            padding: [
                              {
                                type: "left",
                                size: "medium",
                                label: "left:medium"
                              },
                              {
                                type: "left",
                                size: "small",
                                label: "left:small"
                              },
                              {
                                type: "right",
                                size: "x-small",
                                label: "right:x-small"
                              }
                            ],
                            class:
                              "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Block-5",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        padding: [
                          {
                            type: "left",
                            size: "xx-large",
                            label: "left:xx-large"
                          },
                          {
                            type: "left",
                            size: "x-small",
                            label: "left:x-small"
                          },
                          { type: "right", size: "large", label: "right:large" }
                        ],
                        class:
                          "slds-p-left_xx-large slds-p-left_x-small slds-p-right_large ",
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
                  key: "element_element_block_0_0_outputField_7_0",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Field-6"
                },
                {
                  key: "element_element_block_0_0_block_8_0",
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
                      {
                        type: "left",
                        size: "xx-large",
                        label: "left:xx-large"
                      },
                      { type: "left", size: "x-small", label: "left:x-small" },
                      { type: "right", size: "large", label: "right:large" }
                    ],
                    class:
                      "slds-p-left_xx-large slds-p-left_x-small slds-p-right_large ",
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
                    style: "      \n         "
                  },
                  children: [
                    {
                      key:
                        "element_element_element_block_0_0_block_8_0_block_0_0",
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
                          {
                            type: "left",
                            size: "medium",
                            label: "left:medium"
                          },
                          { type: "left", size: "small", label: "left:small" },
                          {
                            type: "right",
                            size: "x-small",
                            label: "right:x-small"
                          }
                        ],
                        class:
                          "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                        style: "      \n         "
                      },
                      children: [
                        {
                          key:
                            "element_element_element_element_block_0_0_block_8_0_block_0_0_outputField_0_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField: "%3Cdiv%3EBSB%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            padding: [],
                            margin: [],
                            background: {
                              color: "",
                              image: "",
                              size: "",
                              repeat: "",
                              position: ""
                            },
                            size: { isResponsive: false, default: "6" },
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
                          parentElementKey:
                            "element_element_element_block_0_0_block_8_0_block_0_0",
                          elementLabel: "Block-0-Block-10-Block-0-Text-0",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                padding: [],
                                margin: [],
                                background: {
                                  color: "",
                                  image: "",
                                  size: "",
                                  repeat: "",
                                  position: ""
                                },
                                size: { isResponsive: false, default: "6" },
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
                          key:
                            "element_element_element_element_block_0_0_block_8_0_block_0_0_outputField_1_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField: "%3Cdiv%3E%7Baccount.bsb%7D%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            size: { isResponsive: false, default: "6" },
                            padding: [
                              {
                                type: "right",
                                size: "xxx-small",
                                label: "right:xxx-small"
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
                            text: { align: "right", color: "" },
                            inlineStyle: "",
                            class:
                              "slds-text-align_right slds-p-right_xxx-small ",
                            style: "      \n         "
                          },
                          parentElementKey:
                            "element_element_element_block_0_0_block_8_0_block_0_0",
                          elementLabel: "Block-0-Block-10-Block-0-Text-1",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                size: { isResponsive: false, default: "6" },
                                padding: [
                                  {
                                    type: "right",
                                    size: "xxx-small",
                                    label: "right:xxx-small"
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
                                text: { align: "right", color: "" },
                                inlineStyle: "",
                                class:
                                  "slds-text-align_right slds-p-right_xxx-small ",
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
                      parentElementKey: "element_element_block_0_0_block_8_0",
                      elementLabel: "Block-0-Block-10-Block-0",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            padding: [
                              {
                                type: "left",
                                size: "medium",
                                label: "left:medium"
                              },
                              {
                                type: "left",
                                size: "small",
                                label: "left:small"
                              },
                              {
                                type: "right",
                                size: "x-small",
                                label: "right:x-small"
                              }
                            ],
                            class:
                              "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Block-7",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        padding: [
                          {
                            type: "left",
                            size: "xx-large",
                            label: "left:xx-large"
                          },
                          {
                            type: "left",
                            size: "x-small",
                            label: "left:x-small"
                          },
                          { type: "right", size: "large", label: "right:large" }
                        ],
                        class:
                          "slds-p-left_xx-large slds-p-left_x-small slds-p-right_large ",
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
                  key: "element_element_block_0_0_outputField_9_0",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Field-8"
                },
                {
                  key: "element_element_block_0_0_block_10_0",
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
                      {
                        type: "left",
                        size: "xx-large",
                        label: "left:xx-large"
                      },
                      { type: "left", size: "x-small", label: "left:x-small" },
                      { type: "right", size: "large", label: "right:large" }
                    ],
                    class:
                      "slds-p-left_xx-large slds-p-left_x-small slds-p-right_large ",
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
                    style: "      \n         "
                  },
                  children: [
                    {
                      key:
                        "element_element_element_block_0_0_block_10_0_block_0_0",
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
                          {
                            type: "left",
                            size: "medium",
                            label: "left:medium"
                          },
                          { type: "left", size: "small", label: "left:small" },
                          {
                            type: "right",
                            size: "x-small",
                            label: "right:x-small"
                          }
                        ],
                        class:
                          "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                        style: "      \n         "
                      },
                      children: [
                        {
                          key:
                            "element_element_element_element_block_0_0_block_10_0_block_0_0_outputField_0_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField: "%3Cdiv%3EAccount%20Number%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            padding: [],
                            margin: [],
                            background: {
                              color: "",
                              image: "",
                              size: "",
                              repeat: "",
                              position: ""
                            },
                            size: { isResponsive: false, default: "6" },
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
                          parentElementKey:
                            "element_element_element_block_0_0_block_10_0_block_0_0",
                          elementLabel: "Block-0-Block-12-Block-0-Text-0",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                padding: [],
                                margin: [],
                                background: {
                                  color: "",
                                  image: "",
                                  size: "",
                                  repeat: "",
                                  position: ""
                                },
                                size: { isResponsive: false, default: "6" },
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
                          key:
                            "element_element_element_element_block_0_0_block_10_0_block_0_0_outputField_1_0",
                          name: "Text",
                          element: "outputField",
                          size: { isResponsive: false, default: "6" },
                          stateIndex: 0,
                          class: "slds-col ",
                          property: {
                            record: "{record}",
                            mergeField:
                              "%3Cdiv%3E%7Baccount.accountNumber%7D%3C/div%3E",
                            card: "{card}"
                          },
                          type: "text",
                          styleObject: {
                            sizeClass: "slds-size_6-of-12 ",
                            size: { isResponsive: false, default: "6" },
                            padding: [
                              {
                                type: "right",
                                size: "xxx-small",
                                label: "right:xxx-small"
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
                            text: { align: "right", color: "" },
                            inlineStyle: "",
                            class:
                              "slds-text-align_right slds-p-right_xxx-small ",
                            style: "      \n         "
                          },
                          parentElementKey:
                            "element_element_element_block_0_0_block_10_0_block_0_0",
                          elementLabel: "Block-0-Block-12-Block-0-Text-1",
                          styleObjects: [
                            {
                              key: 0,
                              conditions: "default",
                              styleObject: {
                                sizeClass: "slds-size_6-of-12 ",
                                size: { isResponsive: false, default: "6" },
                                padding: [
                                  {
                                    type: "right",
                                    size: "xxx-small",
                                    label: "right:xxx-small"
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
                                text: { align: "right", color: "" },
                                inlineStyle: "",
                                class:
                                  "slds-text-align_right slds-p-right_xxx-small ",
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
                      parentElementKey: "element_element_block_0_0_block_10_0",
                      elementLabel: "Block-0-Block-12-Block-0",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            padding: [
                              {
                                type: "left",
                                size: "medium",
                                label: "left:medium"
                              },
                              {
                                type: "left",
                                size: "small",
                                label: "left:small"
                              },
                              {
                                type: "right",
                                size: "x-small",
                                label: "right:x-small"
                              }
                            ],
                            class:
                              "slds-p-left_medium slds-p-left_small slds-p-right_x-small ",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Block-9",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        padding: [
                          {
                            type: "left",
                            size: "xx-large",
                            label: "left:xx-large"
                          },
                          {
                            type: "left",
                            size: "x-small",
                            label: "left:x-small"
                          },
                          { type: "right", size: "large", label: "right:large" }
                        ],
                        class:
                          "slds-p-left_xx-large slds-p-left_x-small slds-p-right_large ",
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
                  key: "element_element_block_0_0_outputField_11_0",
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
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Field-10"
                },
                {
                  key: "element_element_block_0_0_outputField_12_0",
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "8" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "text",
                    card: "{card}",
                    styles: { label: { color: "#868383" } },
                    label: "Last Modified"
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_8-of-12 ",
                    padding: [],
                    margin: [],
                    background: {
                      color: "",
                      image: "",
                      size: "",
                      repeat: "",
                      position: ""
                    },
                    size: { isResponsive: false, default: "8" },
                    container: { class: "" },
                    border: {
                      type: "",
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {
                      styles: { label: { color: "#868383" } }
                    },
                    text: { align: "right", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_right ",
                    style: "      \n         "
                  },
                  parentElementKey: "element_block_0_0",
                  elementLabel: "Block-1-Field-11",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_8-of-12 ",
                        padding: [],
                        margin: [],
                        background: {
                          color: "",
                          image: "",
                          size: "",
                          repeat: "",
                          position: ""
                        },
                        size: { isResponsive: false, default: "8" },
                        container: { class: "" },
                        border: {
                          type: "",
                          width: "",
                          color: "",
                          radius: "",
                          style: ""
                        },
                        elementStyleProperties: {
                          styles: { label: { color: "#868383" } }
                        },
                        text: { align: "right", color: "" },
                        inlineStyle: "",
                        class: "slds-text-align_right ",
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
                  name: "Field",
                  element: "outputField",
                  size: { isResponsive: false, default: "4" },
                  stateIndex: 0,
                  class: "slds-col ",
                  property: {
                    placeholder: "",
                    record: "{record}",
                    type: "datetime",
                    card: "{card}",
                    fieldName: "updateTime",
                    format: "D MMM YYYY | h:mm A",
                    styles: { value: { color: "#868383" } }
                  },
                  type: "element",
                  styleObject: {
                    sizeClass: "slds-size_4-of-12 ",
                    size: { isResponsive: false, default: "4" },
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
                      styles: { value: { color: "#868383" } }
                    },
                    text: { align: "left", color: "" },
                    inlineStyle: "",
                    class: "slds-text-align_left ",
                    style: "      \n         "
                  },
                  elementLabel: "Block-1-Field-12",
                  styleObjects: [
                    {
                      key: 0,
                      conditions: "default",
                      styleObject: {
                        sizeClass: "slds-size_4-of-12 ",
                        size: { isResponsive: false, default: "4" },
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
                          styles: { value: { color: "#868383" } }
                        },
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
                  key: "element_element_block_0_0_outputField_13_0",
                  parentElementKey: "element_block_0_0"
                }
              ],
              elementLabel: "Block-1",
              styleObjects: [
                {
                  key: 0,
                  conditions: "default",
                  styleObject: {
                    padding: [
                      {
                        type: "left",
                        size: "xxx-small",
                        label: "left:xxx-small"
                      },
                      {
                        type: "around",
                        size: "x-small",
                        label: "around:x-small"
                      }
                    ],
                    class:
                      "slds-theme_default  slds-p-left_xxx-small slds-p-around_x-small ",
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
                      type: [],
                      width: "",
                      color: "",
                      radius: "",
                      style: ""
                    },
                    elementStyleProperties: {},
                    text: { align: "", color: "" },
                    inlineStyle: "",
                    style: "      \n         ",
                    theme: "theme_default"
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
      documents: [
        {
          Id: "0688r000001BxU1AAK",
          developerName: "ANZ-Classic-lotus-circle-small",
          type: "ContentVersion"
        }
      ]
    }
  ],
  dataSource: { type: null, value: {}, orderBy: {}, contextVariables: [] },
  title: "SOP_ANZ3",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfSOP_ANZ3_1_ANZ",
    Id: "0Rb8r000000FIELCA4",
    MasterLabel: "cfSOP_ANZ3_1_ANZ",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  Name: "SOP_ANZ3",
  uniqueKey: "SOP_ANZ3",
  Id: "0ko8r0000000JNdAAM",
  OmniUiCardKey: "SOP_ANZ3/ANZ/1.0",
  OmniUiCardType: "Child"
};
export default definition;
