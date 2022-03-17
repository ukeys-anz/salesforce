import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionsRibbon from "./../pageObjects/actionsRibbon";

async function _utam_get_primaryFieldContent(driver, root) {
  let _element = root;
  const _locator = _By.css(`[slot='primaryField']`);
  return _element.findElement(_locator);
}

async function _utam_get_iconContent(driver, root) {
  let _element = root;
  const _locator = _By.css(`[slot='icon']`);
  return _element.findElement(_locator);
}

async function _utam_get_secondaryFieldss(driver, root) {
  let _element = root;
  const _locator = _By.css(`[slot='secondaryFields']`);
  return _element.findElements(_locator);
}

async function _utam_get_secondaryTextField(driver, root, fieldIndexStarting1) {
  let _element = root;
  const _locator = _By.css(
    `[slot='secondaryFields']:nth-of-type(${fieldIndexStarting1})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_secondaryFieldContent(driver, root) {
  let _element = root;
  const _locator = _By.css(`slot[name='secondaryFields']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_actionsRibbon(driver, root) {
  let _element = root;
  const _locator = _By.css(`runtime_platform_actions-actions-ribbon`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_actionsContent(driver, root) {
  let _element = root;
  const _locator = _By.css(`.actionsContainer > * :first-child`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class Highlights2 extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
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
    const BaseUtamElement = _createUtamMixinCtor();
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
    element = new _ActionsRibbon(driver, element);
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
