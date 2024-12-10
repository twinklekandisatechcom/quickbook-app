import { LightningElement, api } from 'lwc';
const EIGHT = 8,
      FIVE = 5,
      FOUR = 4,
      NINE = 9,
      ONE = 1,
      SEVEN = 7,
      SIX = 6,
      TEN = 10,
      THREE = 3,
      TWO = 2,
      ZERO = 0;

export default class PaginationCmp extends LightningElement {
    @api pageSize ;
    @api totalrecordscount;
    totalreccount;
    pageList =[] ;
    startforShift= EIGHT;
    index = ZERO;
    clickedPage = ONE;
    allowedshiftno=[];
    totalpages=ZERO;

    connectedCallback(){
        this.totalreccount = this.totalrecordscount;
        if(this.totalreccount && this.pageSize){
            this.totalpages = Math.ceil(Number(this.totalreccount)/Number(this.pageSize));
            const DEFAULTLIST=[];
            let   pglDefault = '';
            if(this.totalpages<=TEN){
                for(let ind=ONE; ind<=this.totalpages; ind+=ONE){
                    DEFAULTLIST.push(ind);
                }
            }
            if(this.totalpages > EIGHT){
                pglDefault = [ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,'...',this.totalpages];
            }else{
                pglDefault = DEFAULTLIST;
            }
            this.pageList = pglDefault;
        }
    }
    renderedCallback(){
        this.changeColorOnClick();
    }
    changeColorOnClick(){
        this.template.querySelectorAll('.pagenum').forEach(ele=>{
            if(Number(ele.dataset.id) === this.clickedPage){
                ele.classList.add('pagenumcolour');
                ele.blur();
            }else{
                ele.classList.remove('pagenumcolour');
            }
        });
    }
    @api get totalrecords(){
        return this.totalreccount;
    }
    set totalrecords(value){
        this.totalreccount = value;
        this.connectedCallback();
    }
    get startrange(){
        return (((this.clickedPage-ONE)*this.pageSize)+ONE);
    }
    get endrange(){
        return ((this.pageSize*this.clickedPage));
    }
    get disableleftarrow(){
        return (this.clickedPage === ONE)
    }
    get disablerightarrow(){
        return (this.clickedPage === this.totalpages);
    }
    get rightshift(){
        return Number(this.index)===TWO;
    }
    get leftshift(){
        return (Number(this.index)===SEVEN || Number(this.index)===EIGHT);
    }
    get isStartNoClicked(){
        return (this.clickedPage - ONE === FOUR || this.clickedPage<EIGHT );
    }
    get isLastNoClcked (){  
        return (this.totalpages - this.clickedPage >=FOUR &&  this.totalpages - this.clickedPage <EIGHT);
    }
    get isLastPageClicked(){
        const LAST8ARRAY = [];
        for(let ind=this.totalpages-SIX;ind<=this.totalpages;ind+=ONE){
            LAST8ARRAY.push(ind);
        }
        return (LAST8ARRAY.includes(this.clickedPage));
    }
    getallowedshiftno(){
        if(this.allowedshiftno){
            if(!this.allowedshiftno.includes(EIGHT)){
                this.allowedshiftno.push(EIGHT);
            }
            if(!this.allowedshiftno.includes(this.totalpages)){
                this.allowedshiftno.push(this.totalpages);
            }
        }
    }
    handlePrevious(){
        this.clickedPage-=ONE;
        this.dispatchPaginationevent();
        this.getallowedshiftno();
        if(this.clickedPage !== '...' && this.totalpages >TEN){
            this.displayePages(this.clickedPage);
        }
    }
    handleNext(){
        this.clickedPage+=ONE;
        this.dispatchPaginationevent();
        this.getallowedshiftno();
        if(this.clickedPage !== '...' && this.totalpages >TEN){
            this.displayePages(this.clickedPage);
        }
    }
    handleClick(event){
        this.index = event.currentTarget.dataset.index;
        this.clickedPage = Number(event.currentTarget.dataset.id);
        this.getallowedshiftno();
        if(event.target.label !== '...'){
            this.dispatchPaginationevent();
        }
        if(event.target.label !== '...' && this.totalpages >TEN){
            this.displayePages(this.clickedPage);
        }
    }
    displayePages(clickedPage){
        if(clickedPage === this.startforShift){
            this.pageList[ONE] = '...';
        }
        if(this.allowedshiftno && !this.isStartNoClicked && !this.isLastPageClicked && (this.allowedshiftno.includes(clickedPage) || this.isLastNoClcked)){
            this.pageList[TWO] = clickedPage-THREE;
            this.pageList[THREE] = clickedPage-TWO;
            this.pageList[FOUR] = clickedPage-ONE;
            this.pageList[FIVE] = clickedPage;
            this.pageList[SIX] = clickedPage+ONE;
            this.pageList[SEVEN] = clickedPage+TWO;
            this.pageList[EIGHT] = clickedPage+THREE;
            if(this.isLastNoClcked){
                if(this.pageList[NINE] === '...'){
                    this.pageList[NINE] = this.totalpages;
                }else{
                    this.pageList[NINE] = '...';
                }
                if(this.pageList[NINE] && this.pageList[NINE] === this.totalpages){
                    this.pageList.pop();
                }
            }
            this.allowedshiftno = [];
            this.allowedshiftno.push(this.pageList[TWO],this.pageList[EIGHT]);
        }
        if((!this.isLastNoClcked || this.rightshift) && !this.isLastPageClicked && !this.isStartNoClicked){
            this.pageList[NINE] = '...';
            this.pageList[TEN] = this.totalpages;
        }
        if((this.isStartNoClicked && this.allowedshiftno.includes(this.clickedPage)) || this.clickedPage === ONE){
            if(this.totalpages <= EIGHT){
                this.pageList = [ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,EIGHT];
            }else{
                this.pageList = [ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,EIGHT,'...',this.totalpages];
            }
        }
        if(this.isLastPageClicked && this.allowedshiftno.includes(this.clickedPage)){
            this.pageList[ONE] = '...';
            this.pageList[TWO] = this.totalpages-SEVEN;
            this.pageList[THREE] = this.totalpages-SIX;
            this.pageList[FOUR] = this.totalpages-FIVE;
            this.pageList[FIVE] = this.totalpages-FOUR;
            this.pageList[SIX] = this.totalpages-THREE;
            this.pageList[SEVEN] = this.totalpages-TWO;
            this.pageList[EIGHT] = this.totalpages-ONE;
            this.pageList[NINE] = this.totalpages;
            if(this.pageList[TEN]){
                this.pageList.pop();
            }
            this.allowedshiftno = [];
            this.allowedshiftno.push(this.pageList[TWO]);
        }
        this.pageList = [...this.pageList];
    }
    dispatchPaginationevent(){
        this.dispatchEvent(new CustomEvent('pagination', {
                bubbles: true,
                composed: true,
                "detail": this.clickedPage
            }));
    }
}