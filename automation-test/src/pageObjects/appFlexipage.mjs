import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Component2 from "./../pageObjects/component2";

async function _utam_get_internal(driver, root) {
  let _element = root;
  const _locator = _By.css(`app_flexipage-lwc-app-flexipage-internal`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_adgRollup(driver, root) {
  let _element = await _utam_get_internal(driver, root);
  const _locator = _By.css(`.adg-rollup-wrapped`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_module(driver, root) {
  let _element = await _utam_get_adgRollup(driver, root);
  const _locator = _By.css(`.forcegenerated-flexipage-module`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_template(driver, root) {
  let _element = await _utam_get_module(driver, root);
  const _locator = _By.css(`.forcegenerated-flexipage-template`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_flexipageComponent2(driver, root) {
  let _element = await _utam_get_template(driver, root);
  const _locator = _By.css(`flexipage-component2`);
  return _element.findElement(_locator);
}

export default class AppFlexipage extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getInternal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_internal(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getAdgRollup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_adgRollup(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getModule() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_module(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTemplate() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_template(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getFlexipageComponent2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_flexipageComponent2(driver, root);
    element = new _Component2(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async waitForLoad() {
    await this.waitFor(async () => {
      const _statement0 = await this.__getModule();
      const _result0 = await _statement0.containsElement(
        _By.css(`.forcegenerated-flexipage-template`),
        true
      );
      return _result0;
    });
    return this;
  }
}
