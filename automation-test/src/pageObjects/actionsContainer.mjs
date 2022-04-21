import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionButton from "./../pageObjects/actionButton";
import _ActionLink from "./../pageObjects/actionLink";

async function _utam_filter_actionButton(element, text) {
  const result = await element.getLabel();
  return result === text;
}

async function _utam_filter_actionLink(element, text) {
  const result = await element.getLabel();
  return result === text;
}

async function _utam_get_actionButtons(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceActionButton`);
  return _element.findElements(_locator);
}

async function _utam_get_actionLinks(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceActionLink`);
  return _element.findElements(_locator);
}

export default class ActionsContainer extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getActionButton(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_actionButtons(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _ActionButton(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_actionButton(el, text))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }

  async getActionLink(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_actionLinks(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _ActionLink(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_actionLink(el, text))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }
}
