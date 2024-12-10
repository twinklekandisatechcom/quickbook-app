import {LightningElement, api, track} from "lwc";
const ONE = 1,
    POINT5 = 0.5,
    TWO = 2,
    ZERO = 0;

export default class CircularProgressIndicator extends LightningElement {

    @api percent;

    @api content;

    @track fillpercent;

    @track isLong = ONE;

    @track arcX = ZERO;

    @track arcY = ZERO;

    @track svgURL = "";

    connectedCallback () {

        this.calculateProgress();

    }

    calculateProgress () {

        this.fillpercent = Number(this.percent);
        // Previous - this.fillpercent = eval(this.percent);

        if (this.fillpercent > POINT5) {

            this.isLong = ONE;

        } else {

            this.isLong = ZERO;

        }
        this.arcX = Math.cos(TWO * Math.PI * this.fillpercent);
        this.arcY = Math.sin(TWO * Math.PI * this.fillpercent);
        this.svgURL =
        `M 1 0 A 1 1 0 ${this.isLong} 1 ${this.arcX} ${this.arcY} L 0 0`;

    }

}