Include %IKInclude

Class REST.IKEXP.DocServer Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/Patents" Method="GET" Call="GetPatents"/>
<Route Url="/updatePatentStatus/:patentNumber/:newStatus" Method="POST" Call="UpdatePatentStatus"/>
<Route Url="/getD3relAndsim/:domainName/:concept" Method="GET" Call="GetRelatedAndSimOfRel"/>
<Route Url="/getD3relAndsim/:domainName/:concept/:metadataFilter/:metadataFilterValue" Method="GET" Call="GetRelatedAndSimOfRel"/>
<Route Url="/dominance/:domainName" Method="GET" Call="GetDominantForDomain"/>
</Routes>
}

ClassMethod GetPatents() As %Status
{
 #dim tSC As %Status = $$$OK
 try {
     set tQuery="SELECT "_
     "PatentNumber," _
     "Title," _
     "InventorName," _
     "Abstract," _
     "Status," _
     "Category" _
     " FROM Patent.Application"   
     set jsonSQLprovider=##class(%ZEN.Auxiliary.altJSONSQLProvider).%New() 
     set jsonSQLprovider.sql=tQuery 
     set jsonStr=jsonSQLprovider.%WriteJSONFromSQL(,"",,1000,,jsonSQLprovider) 
 }
 catch (ex) {
     set tSC = ex.AsStatus()
 }
 quit tSC
}

ClassMethod UpdatePatentStatus(pPatentNumber As %String, pNewStatus As %String) As %Status
{
   #dim tSC As %Status=$$$OK
   try {
      if $g(pPatentNumber)'="" {
         set newStatus=$zstrip(pNewStatus,"*C")
         &sql(UPDATE Patent.Application (Status) VALUES (:newStatus) WHERE PatentNumber=:pPatentNumber)
      }
      else {
	      set tSC=$$$ERROR($$$GeneralError,"Database update failed.")
      }
   }
   catch (ex) {
	   set tSC = ex.AsStatus()
   }
   quit tSC
}

ClassMethod GetRelatedAndSimOfRel(pDomainName As %String, pConcept As %String, pFilterCategory As %String, pFilterValue) As %Status
{
	try{
		 set domain=##class(%iKnow.Domain).Open(pDomainName),domainId=domain.Id
		 if (($g(pFilterCategory)'="")&&($g(pFilterValue)'=""))  {
		     set filter=##class(%iKnow.Filters.SimpleMetadataFilter).%New(domainId,pFilterCategory,"=",pFilterValue)
             set status=##class(%iKnow.Queries.EntityAPI).GetRelated(.resRelated,domainId,$lb(pConcept),1,10,filter)
		 }
		 else {
			 set status=##class(%iKnow.Queries.EntityAPI).GetRelated(.resRelated,domainId,$lb(pConcept))
		 }
         if $$$ISERR(status) { do $system.OBJ.DisplayError(status) }
         set key=$o(resRelated(""))
         set d3JSON={"name":pConcept}
         set relConcepts=[] 
	     while key'=""{
	        set jsonRelConcept={}
	        set relConcept=$lg(resRelated(key),2)
		    do jsonRelConcept.$set("name",relConcept)
		    // for each concept related to pConcept, get its similar concepts
			// TODO try stemming parrameter
			set status=##class(%iKnow.Queries.EntityAPI).GetSimilar(.resSimChildOfRel,domainId,relConcept)
			if $$$ISERR(status) { do $system.OBJ.DisplayError(status) }
            set keySimChild=$o(resSimChildOfRel(""))
            set SimChildConcepts=[]             
            while keySimChild'=""{
	            set jsonSimConcept={}
	            set simConcept=$lg(resSimChildOfRel(keySimChild),2)
	            //skip if concept and similar concept are identical
	            if simConcept'=relConcept {
		          do jsonSimConcept.$set("name",simConcept)
			      do jsonSimConcept.$set("size",$lg(resSimChildOfRel(keySimChild),3))
			      do SimChildConcepts.$push(jsonSimConcept)
	            }
	            set keySimChild=$o(resSimChildOfRel(keySimChild))
            }
            do jsonRelConcept.$set("children",SimChildConcepts)
            do relConcepts.$push(jsonRelConcept)
			set key=$o(resRelated(key))
         }
         //Output the JSON
         do d3JSON.$set("children",relConcepts)
         w d3JSON.$toJSON()
   }
   catch (ex) {
     set tSC = ex.AsStatus()
   }

  quit $$$OK
}

ClassMethod GetDominantForDomain(pDomainName As %String) As %Status
{
	try{
		 set domainId=$system.iKnow.GetDomainId(pDomainName)
         set status=##class(%iKnow.Semantics.DominanceAPI).GetTop(.res,domainId,1,50)
         if $$$ISERR(status) { do $system.OBJ.DisplayError(status) }
         set key=$o(res(""))
         set d3JSON={"name":"TopConcepts"}
         set jsonConcepts=[]           
	     while key'=""{
	        set jsonConcept={}
		    do jsonConcept.$set("name",$lg(res(key),2))
			do jsonConcept.$set("size",$lg(res(key),3))
			do jsonConcepts.$push(jsonConcept)
			set key=$o(res(key))
         }
   }
   catch (ex) {
     set tSC = ex.AsStatus()
   }
    #; Output the JSON
    do d3JSON.$set("children",jsonConcepts)
    w d3JSON.$toJSON()
  quit $$$OK
}

}
