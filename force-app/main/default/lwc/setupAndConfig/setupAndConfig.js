import { LightningElement, track } from 'lwc';

const UPDATEDCOUNT_NUM = 12;
export default class SetupAndConfig extends LightningElement {
    @track selectedItem = 'setup_config';
    @track currentContent = 'setup_config';
    @track updatedCount = UPDATEDCOUNT_NUM;

    handleSelect(event) {
        const selected = event.detail.name;

        if (selected === 'setup_config') {
            this.updatedCount = 0;
        }

        this.currentContent = selected;
    }
}