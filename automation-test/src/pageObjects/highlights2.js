"use strict";

var core = require("@utam/core");
var _ActionsRibbon = require("./../pageObjects/actionsRibbon");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ActionsRibbon__default =
  /*#__PURE__*/ _interopDefaultLegacy(_ActionsRibbon);

async function _utam_get_primaryFieldContent(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[slot='primaryField']`);
  return _element.findElement(_locator);
}

async function _utam_get_iconContent(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[slot='icon']`);
  return _element.findElement(_locator);
}

async function _utam_get_secondaryFieldss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[slot='secondaryFields']`);
  return _element.findElements(_locator);
}

async function _utam_get_secondaryTextField(driver, root, fieldIndexStarting1) {
  let _element = root;
  const _locator = core.By.css(
    `[slot='secondaryFields']:nth-of-type(${fieldIndexStarting1})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_secondaryFieldContent(driver, root) {
  let _element = root;
  const _locator = core.By.css(`slot[name='secondaryFields']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_actionsRibbon(driver, root) {
  let _element = root;
  const _locator = core.By.css(`runtime_platform_actions-actions-ribbon`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_actionsContent(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.actionsContainer > * :first-child`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Highlights2 extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getPrimaryFieldContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_primaryFieldContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getIconContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_iconContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getSecondaryFields(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_secondaryFieldss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ContainerCtor(driver, element);
    });
    return elements;
  }

  async __getSecondaryTextField(fieldIndexStarting1) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_secondaryTextField(
      driver,
      root,
      fieldIndexStarting1
    );
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getSecondaryFieldContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_secondaryFieldContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getActionsRibbon() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actionsRibbon(driver, root);
    element = new _ActionsRibbon__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getActionsContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actionsContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getSecondaryFieldText(fieldIndexStarting1) {
    const _statement0 = await this.__getSecondaryTextField(fieldIndexStarting1);
    const _result0 = await _statement0.getText();
    return _result0;
  }
}

module.exports = Highlights2;
