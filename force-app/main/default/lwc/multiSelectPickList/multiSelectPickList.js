import { LightningElement, api, track} from 'lwc';
const ONE = 1,
      TWO = 2,
      ZERO = 0;
 
export default class MultiSelectPickList extends LightningElement {
    @api placeholderData;
    @api options;
    @api selectedValue;
    @api selectedValues = [];
    @api label;
    @api disabled = false;
    @api multiSelect = false;
    @track value;
    @track values = [];
    @track optionData;
    @track searchString;
    @track noResultMessage;
    @track showDropdown = false;
    @api
    initializeComponent(){
         this.searchString='';
         this.value='';
    }
    connectedCallback() {
        this.showDropdown = false;
        let optionData = '',
            value = '',
            values = '';
        if(this.options){
            optionData = (JSON.parse(JSON.stringify(this.options)));
        }else{
             optionData = null;
        }
        if(this.selectedValue){
            value = (JSON.parse(JSON.stringify(this.selectedValue)));
        }else{
             value = null;
        }
        if(this.selectedValues){
            values = (JSON.parse(JSON.stringify(this.selectedValues)));
        }else{
             values = null;
        }
        if(value || values) {
            let count = ZERO,
                index = ZERO,
                searchStr = '';
            for(index = ZERO; index < optionData.length; index+=ONE) {
                if(this.multiSelect) {
                    if(values.includes(optionData[index].value)) {
                        optionData[index].selected = true;
                        count+=ONE;
                    }  
                } else if(optionData[index].value === value) {
                        searchStr = optionData[index].label;
                    }
            }
            if(this.multiSelect)
                {this.searchString = `${count  } Option(s) Selected`;}
            else
                {this.searchString = searchStr;}
        }
        this.value = value;
        this.values = values;
        this.optionData = optionData;
    }
    filterOptions(event) {
        this.searchString = event.target.value;
        if( this.searchString && this.searchString.length > ZERO ) {
            this.noResultMessage = '';
            if(this.searchString.length >= TWO) {
                let flag = true;
                for(let index = ZERO; index < this.optionData.length; index+=ONE) {
                    if(this.optionData[index].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        this.optionData[index].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[index].isVisible = false;
                    }
                }
                if(flag) {
                    this.noResultMessage = `No results found for '${  this.searchString  }'`;
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
    }
    selectItem(event) {
        const selectedVal = event.currentTarget.dataset.id;
        if(selectedVal) {
            let count = ZERO;
            const options = JSON.parse(JSON.stringify(this.optionData));
            for(let index = ZERO; index < options.length; index+=ONE) {
                if(options[index].value === selectedVal) {
                    if(this.multiSelect) {
                        if(this.values.includes(options[index].value)) {
                            this.values.splice(this.values.indexOf(options[index].value), ONE);
                        } else {
                            this.values.push(options[index].value);
                        }
                        if(options[index].selected){
                            options[index].selected = false;
                        }else{
                            options[index].selected = true;
                        }   
                    } else {
                        this.value = options[index].value;
                        this.searchString = options[index].label;
                    }
                }
                if(options[index].selected) {
                    count+=ONE;
                }
            }
            this.optionData = options;
            if(this.multiSelect){
                this.searchString = `${count  } Option(s) Selected`;
                const ev = new CustomEvent('selectoption', {detail:this.values});
                this.dispatchEvent(ev);
            }
                
            if(!this.multiSelect){
                const ev = new CustomEvent('selectoption', {detail:this.value});
                this.dispatchEvent(ev);
            }
            if(this.multiSelect){
                event.preventDefault();
            }
            else{
              this.showDropdown = false;
            }
        }else{
            this.value = null;
            this.searchString = 'None';
            const ev = new CustomEvent('selectoptionnew', { detail: '' });
            this.dispatchEvent(ev);
        }
    }
    showOptions() {
        if(this.disabled === false && this.options) {
            this.noResultMessage = '';
            this.searchString = '';
            const options = JSON.parse(JSON.stringify(this.optionData));
            for(let index = ZERO; index < options.length; index+=ONE) {
                options[index].isVisible = true;
            }
            if(options.length > ZERO) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }
    @api clearAll() {
        this.values = [];
        let optionData = '';
        if(this.options){
            optionData = (JSON.parse(JSON.stringify(this.options)));
        }else{
            optionData = null;
        }
        for (let index = ZERO; index < optionData.length; index+=ONE) {
            if (this.multiSelect) {
                optionData[index].selected = false;
            }
        }
        this.searchString = `${ZERO  } Option(s) Selected`;
        //this.selectedValues = [];
        this.optionData = optionData;
    }
    closePill(event) {
        let count = ZERO;
        const options = JSON.parse(JSON.stringify(this.optionData)),
              value = event.currentTarget.name;
        for(let index = ZERO; index < options.length; index+=ONE) {
            if(options[index].value === value) {
                options[index].selected = false;
                this.values.splice(this.values.indexOf(options[index].value), ONE);
            }
            if(options[index].selected) {
                count+=ONE;
            }
        }
        this.optionData = options;
        if(this.multiSelect){
            this.searchString = `${count  } Option(s) Selected`;
            
            const ev = new CustomEvent('selectoption', {detail:this.values});
            this.dispatchEvent(ev);
        }
    }
    handleBlur() {
        let count = ZERO,
            previousLabel = '';
        for(let index = ZERO; index < this.optionData.length; index+=ONE) {
            if(this.optionData[index].value === this.value) {
                previousLabel = this.optionData[index].label;
            }
            if(this.optionData[index].selected) {
                count+=ONE;
            }
        }

        if(this.multiSelect){
            this.searchString = `${count  } Option(s) Selected`;
        }else{
            this.searchString = previousLabel;
        }
        this.showDropdown = false;
    }
}