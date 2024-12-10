({
	doInit : function(component, event, helper) {
        debugger;        
		let searchParams = new URLSearchParams(window.location.search);
        console.log('fff =',searchParams);
       
        /*let accid = searchParams.get('accid');
        let oppid = searchParams.get('oppid');
        let t = searchParams.get('t');
        console.log(accid + oppid);
        if(accid === null || oppid === null || t === null){
            var randomNum = Math.random().toString(36).substring(7);
            let url = "/lightning/n/KTQB__Generate_Invoice#/?&t=" + randomNum;
            window.location.href = url;
        }*/
	}
})