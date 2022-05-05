"use strict";

var core = require("@utam/core");
var _Button = require("./../pageObjects/button");
var _LwcViewCardsDetails = require("./../pageObjects/lwcViewCardsDetails");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);
var _LwcViewCardsDetails__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcViewCardsDetails);

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-card`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_cardDetailsButton(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = core.By.css(`[data-test-id='get-card-details-button']`);
  return _element.findElement(_locator);
}

async function _utam_get_collapseExpandButton(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = core.By.css(`[data-test-id='collapse-expand-button']`);
  return _element.findElement(_locator);
}

async function _utam_get_cardss(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = core.By.css(`[data-test-id='card-details']`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElements(_locator);
}

async function _utam_get_loadMoreButton(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = core.By.css(`[data-test-id='load-more']`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

class LwcViewCards extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_lightningCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getCardDetailsButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_cardDetailsButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getCollapseExpandButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_collapseExpandButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getCards() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_cardss(driver, root);
    if (!elements) {
      return null;
    }
    elements = elements.map(function _createElement(element) {
      return new _LwcViewCardsDetails__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async __getLoadMoreButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_loadMoreButton(driver, root);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async showDetails() {
    const _statement0 = await this.__getCardDetailsButton();
    await _statement0.click();
  }

  async isInDetailsView() {
    const _statement0 = await this.__getCollapseExpandButton();
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async hasMoreCards() {
    const _statement0 = await this.__getLoadMoreButton();
    if (_statement0 === null) {
      return null;
    }
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async loadMore() {
    const _statement0 = await this.__getLoadMoreButton();
    if (_statement0 === null) {
      return null;
    }
    await _statement0.click();
  }
}

module.exports = LwcViewCards;
