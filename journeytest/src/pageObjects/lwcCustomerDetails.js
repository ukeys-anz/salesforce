"use strict";

var core = require("@utam/core");

async function _utam_get_searchBox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[title='Search...']`);
  return _element.findElement(_locator);
}

async function _utam_get_navigationShow(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Show Navigation Menu']`);
  return _element.findElement(_locator);
}

async function _utam_get_menuSelect(driver, root, menuItem) {
  let _element = root;
  const _locator = core.By.css(`li a[data-label='${menuItem}']`);
  return _element.findElement(_locator);
}

async function _utam_get_homeSearchBox(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `div[class='forceSearchAssistantDialog'] input[type='search']`
  );
  return _element.findElement(_locator);
}

async function _utam_get_searchBoxBtn(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[aria-label='Search']`);
  return _element.findElement(_locator);
}

async function _utam_get_searchMoreBox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[title='Search Accounts and more...']`);
  return _element.findElement(_locator);
}

async function _utam_get_connectClose(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button[data-id='close-button']`);
  return _element.findElement(_locator);
}

async function _utam_get_cases(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a span[title='Cases']`);
  return _element.findElement(_locator);
}

async function _utam_get_searchItem(driver, root, customerNumber) {
  let _element = root;
  const _locator = core.By.css(`div span[title='${customerNumber}']`);
  return _element.findElement(_locator);
}

async function _utam_get_appLauncher(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div[role='navigation'] button`);
  return _element.findElement(_locator);
}

async function _utam_get_searchAccount(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a[title='Accounts']`);
  return _element.findElement(_locator);
}

async function _utam_get_customerNameLink(driver, root, titleString) {
  let _element = await _utam_get_searchAccount(driver, root);
  const _locator = core.By.css(`a[title='${titleString}']`);
  return _element.findElement(_locator);
}

async function _utam_get_closeCustomer(driver, root, customerName) {
  let _element = root;
  const _locator = core.By.css(`button[title='Close ${customerName}']`);
  return _element.findElement(_locator);
}

async function _utam_get_accountDetailss(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `section[role='tabpanel'] section article[class='everydayAccount slds-card']`
  );
  return _element.findElements(_locator);
}

async function _utam_get_cardDetailButtons(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `lightning-button[data-id='get-cards-button'] button`
  );
  return _element.findElements(_locator);
}

async function _utam_get_cardDetailsSections(driver, root) {
  let _element = root;
  const _locator = core.By.css(`article[class='card-container'] p`);
  return _element.findElements(_locator);
}

async function _utam_get_tabHeaders(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `flexipage-component2[data-component-id='accountsAndGoalsRefresh']`
  );
  return _element.findElements(_locator);
}

async function _utam_get_accountSections(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a[class='tabHeader']`);
  return _element.findElements(_locator);
}

class LwcCustomerDetails extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }
  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getSearchBox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_searchBox(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getNavigationShow() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_navigationShow(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getMenuSelect(menuItem) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_menuSelect(driver, root, menuItem);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getHomeSearchBox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_homeSearchBox(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getSearchBoxBtn() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_searchBoxBtn(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getSearchMoreBox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_searchMoreBox(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getConnectClose() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_connectClose(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getCases() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_cases(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getSearchItem(customerNumber) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_searchItem(driver, root, customerNumber);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getAppLauncher() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_appLauncher(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getSearchAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_searchAccount(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getCustomerNameLink(titleString) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_customerNameLink(driver, root, titleString);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getCloseCustomer(customerName) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_closeCustomer(driver, root, customerName);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getAccountDetails() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_accountDetailss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }

  async getCardDetailButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_cardDetailButtons(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }

  async getCardDetailsSection() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ActionableUtamElement = core.createUtamMixinCtor(
      core.ActionableUtamElement
    );
    let elements = await _utam_get_cardDetailsSections(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ActionableUtamElement(driver, element);
    });
    return elements;
  }

  async getTabHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ActionableUtamElement = core.createUtamMixinCtor(
      core.ActionableUtamElement
    );
    let elements = await _utam_get_tabHeaders(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ActionableUtamElement(driver, element);
    });
    return elements;
  }

  async getAccountSection() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_accountSections(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }
}

module.exports = LwcCustomerDetails;
