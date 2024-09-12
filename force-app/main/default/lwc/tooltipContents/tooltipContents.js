const totalFinancialPosition = `<span>
                    <p class="slds-text-title_bold" data-id="total-fin-pos-tooltip">
                    The amount shown is indicative of the amount a customer may be
                    able to use but may not be what should be available or is actually available.
                    </p>
                    <br />
                    The amount shown is indicative of the amount a customer may be
                    able to use in their
                    <strong>
                    ANZ Plus , ANZ Save and ANZ Plus Flex Saver accounts added together</strong
                    >. The amount shown may not be what should be available or is actually available.
                    <br />
                    <br />
                    This can be because, for example:
                    <ul
                    class="slds-list_dotted slds-m-top_medium slds-m-bottom_medium"
                    >
                    <li>
                        some transactions may not have updated the amount
                        shown (e.g. reversals)
                    </li>
                    <li>
                        some transactions may have updated the amount shown
                        but are not yet fully processed (e.g. pending transactions),
                    </li>
                    <li>
                        we may not process transactions at the time, on the
                        day or in the order that they are made, or
                    </li>
                    <li>
                        some transactions may have been processed and updated the amount
                        shown, but are later adjusted.
                    </li>
                    </ul>
                    If a customer proceeds with a transaction when there may be
                    insufficient funds, their account may go overdrawn or the
                    transaction may be declined.
                </span>`;

const totalSavedFinancialPosition = `<span>
                    <p class="slds-text-title_bold">
                    The amount shown is indicative of the amount you may be
                    able to use but may not be what is actually available.
                    </p>
                    <br />
                    The amount shown is indicative of the amount you may be
                    able to use in your ANZ Save account. This amount, when
                    shown at an ATM or on a receipt, may have a different
                    label such as 'Funds' or 'Balance'. Regardless, the amount
                    shown may not be what is actually available because:
                    <ul
                    class="slds-list_dotted slds-m-top_medium slds-m-bottom_medium"
                    >
                    <li>
                        some transactions may not have updated the amount
                        shown (e.g. reversals)
                    </li>
                    <li>
                        some transactions may have updated the amount shown
                        but are not yet fully processed (e.g. pending
                        transactions)
                    </li>
                    <li>
                        we may not process transactions at the time, on the
                        day or in the order that they are made, and/or
                    </li>
                    <li>
                        some transactions may have been processed and updated
                        the amount shown, but are later adjusted.
                    </li>
                    </ul>
                    If you proceed with a transaction when there may be
                    insufficient funds, your account may go overdrawn or the
                    transaction may be declined.
                </span>`;

const savings = `<span>
                    <p class="slds-text-title_bold">
                    The amount shown is indicative of the amount you may be able to
                    use but may not be what is actually available.
                    </p>
                    <br />
                    The amount shown is indicative of the amount you may be able to use
                    in your ANZ Save account. This amount, when shown at an ATM or
                    on a receipt, may have a different label such as 'Funds' or
                    'Balance'. Regardless, the amount shown may not be what is actually
                    available because:
                    <ul class="slds-list_dotted slds-m-top_medium slds-m-bottom_medium">
                    <li>
                        some transactions may not have updated the amount shown (e.g.
                        reversals)
                    </li>
                    <li>
                        some transactions may have updated the amount shown but are not
                        yet fully processed (e.g. pending transactions)
                    </li>
                    <li>
                        we may not process transactions at the time, on the day or in
                        the order that they are made, and/or
                    </li>
                    <li>
                        some transactions may have been processed and updated the amount
                        shown, but are later adjusted.
                    </li>
                    </ul>
                    If you proceed with a transaction when there may be insufficient
                    funds, your account may go overdrawn or the transaction may be
                    declined.
                </span>`;

const checking = `<span>
                <p class="slds-text-title_bold">
                The amount shown is indicative of the amount you may be able to
                use but may not be what is actually available.
                </p>
                <br />
                The amount shown is indicative of the amount you may be able to use
                in your ANZ Plus account. This amount, when shown at an ATM or
                on a receipt, may have a different label such as 'Funds' or
                'Balance'. Regardless, the amount shown may not be what is actually
                available because:
                <ul class="slds-list_dotted slds-m-top_medium slds-m-bottom_medium">
                <li>
                    some transactions may not have updated the amount shown (e.g.
                    reversals)
                </li>
                <li>
                    some transactions may have updated the amount shown but are not
                    yet fully processed (e.g. pending transactions)
                </li>
                <li>
                    we may not process transactions at the time, on the day or in
                    the order that they are made, and/or
                </li>
                <li>
                    some transactions may have been processed and updated the amount
                    shown, but are later adjusted.
                </li>
                </ul>
                If you proceed with a transaction when there may be insufficient
                funds, your account may go overdrawn or the transaction may be
                declined.
            </span>`;

const savingss2 = `<span>
                    <p class="slds-text-title_bold">
                    The amount shown is indicative of the amount a customer may be able to
                    use but may not be what should be avaialble or is actually available.
                    </p>
                    <br />
                    The amount shown is indicative of the amount a customer may be able to use
                    in their ANZ Plus Flex Saver account. This amount, when shown at an ATM or
                    on a receipt, may have a different label such as 'Funds' or
                    'Balance'. Regardless, the amount shown may not be what should be available or is actually
                    available.
                    <br/>
                    <br/>
                    This can be because, for example:
                    <ul class="slds-list_dotted slds-m-top_medium slds-m-bottom_medium">
                    <li>
                        some transactions may not have updated the amount shown (e.g.
                        reversals)
                    </li>
                    <li>
                        some transactions may have updated the amount shown but are not
                        yet fully processed (e.g. pending transactions)
                    </li>
                    <li>
                        we may not process transactions at the time, on the day or in
                        the order that they are made, or
                    </li>
                    <li>
                        some transactions may have been processed and updated the amount
                        shown, but are later adjusted.
                    </li>
                    </ul>
                    If a customer proceeds with a transaction when there may be insufficient
                    funds, their account may go overdrawn or the transaction may be
                    declined.
                </span>`;

// map to store key value pair of resourcename and tooltip content to display based on resourcename
const TOOLTIP_MAP = {
  totalFinancialPosition: totalFinancialPosition,
  totalSavedFinancialPosition: totalSavedFinancialPosition,
  savings: savings,
  checking: checking,
  savingss2: savingss2
};

//this method is use to fetch the tooltip content dynamically based on the resourcename
export function fetchTooltipContent(resourceName) {
  return resourceName ? TOOLTIP_MAP[resourceName] : "";
}
