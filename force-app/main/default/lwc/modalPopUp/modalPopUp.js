import { LightningElement,api } from 'lwc';

export default class ModalPopUp extends LightningElement {
    @api showPositive;

    @api showNegative;

    @api positiveButtonLabel;

    @api negativeButtonLabel;

    @api showModal;

    handlePositive () {

        this.dispatchEvent(new CustomEvent("positive"));

    }

    handleNegative () {

        this.dispatchEvent(new CustomEvent("negative"));

    }

    handleClose () {

        this.dispatchEvent(new CustomEvent("close"));

    }
}