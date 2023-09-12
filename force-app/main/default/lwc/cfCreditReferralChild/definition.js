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
        padding: [{ type: "around", size: "x-small", label: "around:x-small" }],
        margin: [{ type: "around", size: "none", label: "around:none" }],
        container: { class: "slds-card" },
        size: {
          isResponsive: false,
          default: "12",
          large: "12",
          medium: "8",
          small: "6"
        },
        sizeClass: "slds-size_12-of-12 ",
        class: "slds-card slds-p-around_x-small slds-m-around_none ",
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
                padding: [{ type: "around", size: "x-small" }],
                class: "slds-p-around_x-small",
                sizeClass: "slds-size_12-of-12"
              },
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
                  children: [
                    {
                      name: "Text",
                      element: "outputField",
                      size: {
                        isResponsive: true,
                        default: "12",
                        large: "3",
                        medium: "3",
                        small: "12"
                      },
                      stateIndex: 0,
                      class: "slds-col ",
                      property: {
                        record: "{record}",
                        mergeField:
                          "%3Cdiv%3E%3Cstrong%3EAssessment%20Outcome:%3C/strong%3E%20%7Boutcome%7D%3C/div%3E",
                        card: "{card}"
                      },
                      type: "text",
                      styleObject: {
                        sizeClass:
                          "slds-large-size_3-of-12  slds-medium-size_3-of-12  slds-small-size_12-of-12  slds-size_12-of-12 ",
                        size: {
                          isResponsive: true,
                          default: "12",
                          large: "3",
                          medium: "3",
                          small: "12"
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
                      elementLabel: "Assessment-Outcome_value",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            sizeClass:
                              "slds-large-size_3-of-12  slds-medium-size_3-of-12  slds-small-size_12-of-12  slds-size_12-of-12 ",
                            size: {
                              isResponsive: true,
                              default: "12",
                              large: "3",
                              medium: "3",
                              small: "12"
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
                      ],
                      key:
                        "element_element_element_block_0_0_block_0_0_outputField_0_0",
                      parentElementKey: "element_element_block_0_0_block_0_0",
                      userUpdatedElementLabel: true
                    },
                    {
                      key:
                        "element_element_element_block_0_0_block_0_0_outputField_1_0",
                      name: "Text",
                      element: "outputField",
                      size: { isResponsive: false, default: "3" },
                      stateIndex: 0,
                      class: "slds-col ",
                      property: {
                        record: "{record}",
                        mergeField:
                          "%3Cdiv%3E%3Cstrong%3EAssessed%20Time:%20%3C/strong%3E%7BassessedTime%7D%3C/div%3E",
                        card: "{card}"
                      },
                      type: "text",
                      styleObject: {
                        size: { isResponsive: false, default: "3" },
                        sizeClass: "slds-size_3-of-12 ",
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
                      parentElementKey: "element_element_block_0_0_block_0_0",
                      elementLabel: "Assessed-Time_value",
                      styleObjects: [
                        {
                          key: 0,
                          conditions: "default",
                          styleObject: {
                            size: { isResponsive: false, default: "3" },
                            sizeClass: "slds-size_3-of-12 ",
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
                      key:
                        "element_element_element_block_0_0_block_0_0_block_2_0",
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
                                type: "around",
                                size: "x-small",
                                label: "around:x-small"
                              }
                            ],
                            class: "slds-theme_default slds-p-around_x-small ",
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
                            inlineStyle: "font-weight: bold;",
                            style: "      \n         font-weight: bold;",
                            theme: "theme_default"
                          },
                          children: [
                            {
                              key:
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_outputField_0_0",
                              name: "Field",
                              element: "outputField",
                              size: { isResponsive: false, default: "1" },
                              stateIndex: 0,
                              class: "slds-col ",
                              property: {
                                placeholder: "",
                                record: "{record}",
                                type: "text",
                                card: "{card}",
                                label: "Reason Code",
                                styles: { label: { color: "#000000" } }
                              },
                              type: "element",
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
                                elementStyleProperties: {
                                  styles: { label: { color: "#000000" } }
                                },
                                text: { align: "", color: "" },
                                inlineStyle: "",
                                class: "",
                                style: "      \n         "
                              },
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              elementLabel: "Reason-Code_title",
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
                                    elementStyleProperties: {
                                      styles: { label: { color: "#000000" } }
                                    },
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
                              key:
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_outputField_1_0",
                              name: "Field",
                              element: "outputField",
                              size: { isResponsive: false, default: "1" },
                              stateIndex: 0,
                              class: "slds-col ",
                              property: {
                                placeholder: "",
                                record: "{record}",
                                type: "text",
                                card: "{card}",
                                label: "Category",
                                styles: { label: { color: "#000000" } }
                              },
                              type: "element",
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
                                elementStyleProperties: {
                                  styles: { label: { color: "#000000" } }
                                },
                                text: { align: "", color: "" },
                                inlineStyle: ""
                              },
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              elementLabel: "Category_title",
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
                                    elementStyleProperties: {
                                      styles: { label: { color: "#000000" } }
                                    },
                                    text: { align: "", color: "" },
                                    inlineStyle: ""
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
                              key:
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_outputField_2_0",
                              name: "Field",
                              element: "outputField",
                              size: { isResponsive: false, default: "3" },
                              stateIndex: 0,
                              class: "slds-col ",
                              property: {
                                placeholder: "",
                                record: "{record}",
                                type: "text",
                                card: "{card}",
                                label: "Description",
                                styles: { label: { color: "#000000" } }
                              },
                              type: "element",
                              styleObject: {
                                size: { isResponsive: false, default: "3" },
                                sizeClass: "slds-size_3-of-12 ",
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
                                  styles: { label: { color: "#000000" } }
                                },
                                text: { align: "", color: "" },
                                inlineStyle: ""
                              },
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              elementLabel: "Description_title",
                              styleObjects: [
                                {
                                  key: 0,
                                  conditions: "default",
                                  styleObject: {
                                    size: { isResponsive: false, default: "3" },
                                    sizeClass: "slds-size_3-of-12 ",
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
                                      styles: { label: { color: "#000000" } }
                                    },
                                    text: { align: "", color: "" },
                                    inlineStyle: ""
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
                              key:
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_outputField_3_0",
                              name: "Field",
                              element: "outputField",
                              size: { isResponsive: false, default: "1" },
                              stateIndex: 0,
                              class: "slds-col ",
                              property: {
                                placeholder: "",
                                record: "{record}",
                                type: "text",
                                card: "{card}",
                                label: "Authority Level",
                                styles: { label: { color: "#000000" } }
                              },
                              type: "element",
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
                                elementStyleProperties: {
                                  styles: { label: { color: "#000000" } }
                                },
                                text: { align: "", color: "" },
                                inlineStyle: ""
                              },
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              elementLabel: "Authority-Level_title",
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
                                    elementStyleProperties: {
                                      styles: { label: { color: "#000000" } }
                                    },
                                    text: { align: "", color: "" },
                                    inlineStyle: ""
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
                              key:
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_outputField_4_0",
                              name: "Field",
                              element: "outputField",
                              size: { isResponsive: false, default: "1" },
                              stateIndex: 0,
                              class: "slds-col ",
                              property: {
                                placeholder: "",
                                record: "{record}",
                                type: "text",
                                card: "{card}",
                                label: "Guidance",
                                styles: { label: { color: "#000000" } },
                                fieldLevelHelp: "This i"
                              },
                              type: "element",
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
                                elementStyleProperties: {
                                  styles: { label: { color: "#000000" } }
                                },
                                text: { align: "", color: "" },
                                inlineStyle: ""
                              },
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              elementLabel: "Guidance_title",
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
                                    elementStyleProperties: {
                                      styles: { label: { color: "#000000" } }
                                    },
                                    text: { align: "", color: "" },
                                    inlineStyle: ""
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
                              name: "Field",
                              element: "outputField",
                              size: { isResponsive: false, default: "3" },
                              stateIndex: 0,
                              class: "slds-col ",
                              property: {
                                placeholder: "",
                                record: "{record}",
                                type: "text",
                                card: "{card}",
                                label: "Referral Outcome",
                                styles: { label: { color: "#000000" } }
                              },
                              type: "element",
                              styleObject: {
                                size: { isResponsive: false, default: "3" },
                                sizeClass: "slds-size_3-of-12 ",
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
                                  styles: { label: { color: "#000000" } }
                                },
                                text: { align: "", color: "" },
                                inlineStyle: ""
                              },
                              elementLabel: "Referral-Outcome_title",
                              key:
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_outputField_5_0",
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              userUpdatedElementLabel: true,
                              styleObjects: [
                                {
                                  key: 0,
                                  conditions: "default",
                                  styleObject: {
                                    size: { isResponsive: false, default: "3" },
                                    sizeClass: "slds-size_3-of-12 ",
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
                                      styles: { label: { color: "#000000" } }
                                    },
                                    text: { align: "", color: "" },
                                    inlineStyle: ""
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
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_outputField_6_0",
                              name: "Field",
                              element: "outputField",
                              size: { isResponsive: false, default: "1" },
                              stateIndex: 0,
                              class: "slds-col ",
                              property: {
                                placeholder: "",
                                record: "{record}",
                                type: "text",
                                card: "{card}",
                                label: "Last Modified",
                                styles: { label: { color: "#000000" } }
                              },
                              type: "element",
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
                                elementStyleProperties: {
                                  styles: { label: { color: "#000000" } }
                                },
                                text: { align: "", color: "" },
                                inlineStyle: ""
                              },
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              elementLabel: "Last-Modified_title",
                              userUpdatedElementLabel: true,
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
                                    elementStyleProperties: {
                                      styles: { label: { color: "#000000" } }
                                    },
                                    text: { align: "", color: "" },
                                    inlineStyle: ""
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
                                padding: [],
                                class: "",
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
                                  key:
                                    "element_element_element_element_element_element_block_0_0_block_0_0_block_4_0_block_0_0_block_5_0_block_0_0",
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
                                    padding: [],
                                    class: "",
                                    sizeClass: "slds-size_12-of-12 ",
                                    margin: [],
                                    background: {
                                      color: "",
                                      image: "",
                                      size: "",
                                      repeat: "",
                                      position: ""
                                    },
                                    size: {
                                      isResponsive: false,
                                      default: "12"
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
                                      name: "FlexCard",
                                      element: "childCardPreview",
                                      size: {
                                        isResponsive: false,
                                        default: "12"
                                      },
                                      stateIndex: 0,
                                      class: "slds-col ",
                                      property: {
                                        cardName: "CreditReferralReasons",
                                        recordId: "{recordId}",
                                        selectedState: "Active",
                                        isChildCardTrackingEnabled: false,
                                        cardNode: "{record.reasons}"
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
                                        size: {
                                          isResponsive: false,
                                          default: "12"
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
                                        inlineStyle: "font-weight: normal;",
                                        class: "",
                                        style:
                                          "      \n         font-weight: normal;"
                                      },
                                      elementLabel:
                                        "Block-5-Block-5-Block-0-FlexCard-0",
                                      key:
                                        "element_element_element_element_element_element_element_block_0_0_block_0_0_block_4_0_block_0_0_block_5_0_block_0_0_childCardPreview_0_0",
                                      parentElementKey:
                                        "element_element_element_element_element_element_block_0_0_block_0_0_block_4_0_block_0_0_block_5_0_block_0_0",
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
                                            size: {
                                              isResponsive: false,
                                              default: "12"
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
                                            inlineStyle: "font-weight: normal;",
                                            class: "",
                                            style:
                                              "      \n         font-weight: normal;"
                                          },
                                          label: "Default",
                                          name: "Default",
                                          conditionString: "",
                                          draggable: false
                                        }
                                      ]
                                    }
                                  ],
                                  parentElementKey:
                                    "element_element_element_element_element_block_0_0_block_0_0_block_4_0_block_0_0_block_5_0",
                                  elementLabel:
                                    "Block-0-Block-4-Block-2-Block-6-Block-0",
                                  styleObjects: [
                                    {
                                      key: 0,
                                      conditions: "default",
                                      styleObject: {
                                        padding: [],
                                        class: "",
                                        sizeClass: "slds-size_12-of-12 ",
                                        margin: [],
                                        background: {
                                          color: "",
                                          image: "",
                                          size: "",
                                          repeat: "",
                                          position: ""
                                        },
                                        size: {
                                          isResponsive: false,
                                          default: "12"
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
                              ],
                              elementLabel: "Block-0-Block-7-Block-1-Block-7",
                              key:
                                "element_element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0_block_7_0",
                              parentElementKey:
                                "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                              styleObjects: [
                                {
                                  key: 0,
                                  conditions: "default",
                                  styleObject: {
                                    size: { isResponsive: false, default: 12 },
                                    padding: [],
                                    class: "",
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
                          ],
                          elementLabel: "Block-0-Block-7-Block-1",
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
                                  "slds-theme_default slds-p-around_x-small ",
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
                                inlineStyle: "font-weight: bold;",
                                style: "      \n         font-weight: bold;",
                                theme: "theme_default"
                              },
                              label: "Default",
                              name: "Default",
                              conditionString: "",
                              draggable: false
                            }
                          ],
                          key:
                            "element_element_element_element_block_0_0_block_0_0_block_2_0_block_0_0",
                          parentElementKey:
                            "element_element_element_block_0_0_block_0_0_block_2_0"
                        }
                      ],
                      parentElementKey: "element_element_block_0_0_block_0_0",
                      elementLabel: "Block-0-Block-7"
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
                  ],
                  key: "element_element_block_0_0_block_0_0",
                  parentElementKey: "element_block_0_0"
                }
              ],
              elementLabel: "Block-0"
            }
          ]
        }
      },
      childCards: ["CreditReferralReasons"],
      actions: [],
      omniscripts: [],
      documents: []
    }
  ],
  dataSource: { type: null, value: {}, orderBy: {}, contextVariables: [] },
  title: "CreditReferralChild",
  enableLwc: true,
  isFlex: true,
  theme: "slds",
  selectableMode: "Multi",
  lwc: {
    DeveloperName: "cfCreditReferralChild_1_ANZx",
    Id: "0RbBm0000003q0TKAQ",
    MasterLabel: "cfCreditReferralChild_1_ANZx",
    NamespacePrefix: "c",
    ManageableState: "unmanaged"
  },
  dynamicCanvasWidth: { type: "desktop" },
  Name: "CreditReferralChild",
  uniqueKey: "CreditReferralChild",
  Id: "0koBm0000000KbRIAU",
  OmniUiCardKey: "CreditReferralChild/ANZx/1.0",
  OmniUiCardType: "Child"
};
export default definition;
