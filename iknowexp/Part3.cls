Include %IKInclude

Class iknowexp.Part3 Extends %ZEN.Component.page
{

/// Displayed name of this page.
Parameter PAGENAME = "iKnow Experience Step 3";

/// Default iKnow domain name 
Parameter IKPATENTDETAILDOMAINNAME = "PatentDetail";

/// Default iKnow domain name for event causes
Parameter IKpatentAbstractDomainNAME = "PatentAbstract";

/// Name of the dictionary generated as part of the matching-based similarity search
Parameter IKNOWDICTNAME [ Internal ] = "PatentUIDictionary";

/// Length of the summary to be displayed in the popup.
Property summaryLength As %ZEN.Datatype.string(ZENURL = "LENGTH");

/// The source ID of the report selected from the "similar reports" list (any tab).
Property selectedPatentsrcId As %ZEN.Datatype.integer;

/// The domain ID for the patent detail reports. Populated during <method>%OnAfterCreatePage</method>.
Property patentDetailDomain As %ZEN.Datatype.integer;

/// The domain ID for the event causes. Populated during <method>%OnAfterCreatePage</method>.
Property patentAbstractDomain As %ZEN.Datatype.integer;

/// The Source ID of the source containing the manual input from the text box. This is a Virtual
/// Source and hence the number will be negative.
Property inputSource As %ZEN.Datatype.integer;

/// A filter string to restrict the scope of the similarity search.
/// Either use an InitialExpression or add code to populate this property, similar to the
/// filterPane and associated methods in <class>%iKnow.UI.AbstractPortal</class>
Property filter As %ZEN.Datatype.string(ZENURL = "FILTER");

/// The ID of the dictionary created as part of <method>BuildSrcDictionary</method>
Property dictId As %ZEN.Datatype.integer;

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="iKnow Experience Lab: Part 3">
<modalGroup id="modSource" layout="vertical" containerStyle="padding:10px;">
<vgroup cellVAlign="top">
<html id="htmlTitle" OnDrawContent="DrawEventHeader" />
<spacer height="10" />
<tabGroup showTabBar="true" enclosingStyle="padding:5px;">
<tab caption="Patent Details" cellStyle="padding:5px;" width="100%">
<html id="htmlSource" OnDrawContent="DrawSource" containerStyle="overflow-y:scroll;" 
enclosingClass="textBox" seed="REPORT" />
<spacer height="10" />
<hgroup labelPosition="left" cellVAlign="top">
<text id="txtLength" value="all" hint="number of sentences to display" label="Summary length: " />
<spacer width="20" />
<button caption="summarize" onclick="zenPage.summarize();" />
</hgroup>
</tab>
<tab caption="Patent Abstract" cellStyle="padding:5px;" width="100%">
<html id="htmlAbstract" containerStyle="overflow-y:scroll" OnDrawContent="DrawSource" 
enclosingClass="textBox" seed="ABSTRACT" />
</tab>
</tabGroup>
</vgroup>
</modalGroup>
<form method="post" id="form" height="100%" width="100%">
<vgroup containerStyle="padding:10px;" height="100%" width="100%">
<!--
<hgroup id="bannerContainer" >
<label label="Part 3:  Use iKnow to Find Similar Aviation Events" labelClass="pageTitle" />
</hgroup>

<hgroup id="instructionContainer" >
<vgroup containerStyle="padding:10px;" height="100%" width="100%">
<label label="1.  Select any event from the combobox the press the Process button."  />
<label label="2.  After a few moments, a list of similar aviation event narratives will appear.  Click on the link for any similar narrative."  />
<label label="3.  In the popup that appears, notice the syntax coloring.  Select the Cause tab."  />
</vgroup>
</hgroup>
-->
<hgroup id="logoContainer" >
<vgroup containerStyle="padding:10px;" height="100%" width="100%">
<label label="Patent Numbers"  />
<dataListBox id="selPatentNum"
          width="150px"
           sql="select top 25 PatentNumber from patent.application where category='game'"
                onchange="zenPage.clrTblSimilar();zenPage.patentNumberSelectionClient();"
           >
</dataListBox>
</vgroup>
</hgroup>
<spacer height="10" />
<hgroup id="grpMain" valign="top">
<vgroup id="grpText" valign="top">
<textarea id="txtInput" rows="7" title="Select an patent number from the drop box or type your invention description here and press the 'process' button to look for similar patents." />
</vgroup>
<spacer width="20" />
<vgroup id="grpButtons" valign="top" labelPosition="left">
<button caption="process" onclick="zenPage.realTimeInputClient();" />
<spacer height="10" />
</vgroup>
</hgroup>
<spacer height="10" />
<tabGroup id="tgrResults" showTabBar="true" height="100px">
<tab id="tabSimilar" caption="Basic similarity" cellStyle="padding:10px;" title="Normal entity-based similarity" >
<tablePane id="tblSimilar" queryClass="%iKnow.Queries.SourceQAPI" queryName="GetSimilar"
 autoExecute="false" OnExecuteResultSet="ExecuteSimilarQuery" showRowSelector="false">
<parameter value="#(%page.patentDetailDomain)#" />
<parameter value="#(%page.inputSource)#" />
<parameter value="1" />
<parameter value="10" />
<parameter value="#(%page.filter)#" />
<parameter value="SIMPLE" />
<column colName="srcId" hidden="true" />
<column colName="extId" header="External ID"  link="javascript:zenPage.displaySourceClient(#(%query.srcId)#);" width="40" />
<column header="IssueDate" hidden="true" OnDrawCell="DrawMetadata" seed="IssueDate" width="15" />
<column header="Category" hidden="true" OnDrawCell="DrawMetadata" seed="Category" width="15" />
<column colName="percentageMatched" header="Percentage matched" OnDrawCell="DrawPercentage" width="15" />
<column colName="percentageNew" header="Percentage new" OnDrawCell="DrawPercentage" width="15" />
<column colName="nbOfEntsInRefSrc" hidden="true" />
<column colName="nbOfEntsInCommon" hidden="true" />
<column colName="nbOfEntsInSimSrc" hidden="true" />
<column colName="score" header="Score" hidden="true" />
</tablePane>
</tab>
</tabGroup>
</vgroup>
</form>
</page>
}

/// <p>ZenMethod to process manual user input <var>pText</var> by the iKnow engine and store the
/// ID of the generated Virtual Source in <property>inputSource</property>.</p>
Method ProcessInput(pText As %String(MAXLEN=32767), pLanguage As %String) As %String [ ZenMethod ]
{
	set tSC = $$$OK, tOldStatus = 0
	try {
		set tDomainId = ..patentDetailDomain
		set tDomainName = $system.iKnow.GetDomainName(tDomainId)
		
		// drop the previous virtual source created
		do:..inputSource ##class(%iKnow.Source.Loader).DeleteVirtualSource(tDomainId, $zabs(..inputSource))
		
		// create a simple configuration object for pLanguage, if none exists yet
		set tConfigName = "PatentInvestigatorConfig"_pLanguage
		if '##class(%iKnow.Configuration).NameIndexExists(tConfigName) {
			set tLanguages = $s(pLanguage="AUTO":$$$IKLANGUAGES, 1:$lb(pLanguage))
			set tConfig = ##class(%iKnow.Configuration).%New(tConfigName, (pLanguage="AUTO"), tLanguages)
			set tSC = tConfig.%Save()
			quit:$$$ISERR(tSC)
		}
		
		// process pText, loading it as a virtual source
		set tFullRef = "PatentInvestigatorInput "_$zdt($h)
		set tSC = $system.iKnow.IndexString(tDomainName, tFullRef, pText, tConfigName, 1, .vSrcId)
		quit:$$$ISERR(tSC)
		
		// store the generated (virtual) source ID
		set ..inputSource = vSrcId
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit $s($$$ISOK(tSC):"OK", 1:$system.Status.GetErrorText(tSC))
}

/// <p>ZenMethod to process Patent Number selection 
Method ProcessPatentNumberSelection(pPatNum As %String) As %String [ ZenMethod ]
{
	try {
        &sql(SELECT ABSTRACT INTO :strDetailedDescr FROM Patent.Application WHERE PatentNumber=:pPatNum)
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit $s((SQLCODE=0):strDetailedDescr, 1:"ERROR RETRIEVING DESCRIPTION")
}

ClientMethod openAssistance(cspPageName) [ Language = javascript ]
{
   	var urlAssist="/csp/iknowexp/"+cspPageName;
	window.open(urlAssist, 'Assist', 'width=560,height=585', 'scrollbars=no');
}

/// Client-side method coordinating the processing of user input by invoking <method>ProcessInput</method>
/// and then refreshing the appropriate sections of the interface. 
ClientMethod realTimeInputClient() [ Language = javascript ]
{
	var msg = zenPage.ProcessInput(zen('txtInput').getValue(), 'en');
	if (msg != 'OK') {
		alert(msg);
	}
	zen('tblSimilar').refreshContents();
	//zenPage.refreshDictionaryAsync();
	//zen('tblDominance').refreshContents();
}

/// Client-side method coordinating the processing of patent number selection 
/// by invoking <method>ProcessEventSelection</method>
/// and then refreshing the text area.
ClientMethod patentNumberSelectionClient() [ Language = javascript ]
{
	var msg = zenPage.ProcessPatentNumberSelection(zen('selPatentNum').getValue());
	if (msg == 'ERROR RETRIEVING NARRATIVE') {
		alert(msg);
	}
	zen('txtInput').setValue(msg);
}

/// Builds/replaces a dictionary based on the contents of the (virtual) source represented by
/// <property>inputSource</property> and stores it into both the reports and the causes domains.
/// The ID of this dictionary (in the reports domain) is stored into <property>dictId</property>.
Method BuildSrcDictionary() As %Status [ ZenMethod ]
{
	set tSC = $$$OK
	try {
		set tSrcId = +..inputSource
		set tDomainId = ..patentDetailDomain
		set tDomainIdAbstract = ..patentAbstractDomain
		
		// first kill existing dictionary
		set tDictId = ##class(%iKnow.Matching.DictionaryAPI).GetDictionaryId(tDomainId, ..#IKNOWDICTNAME)
		set:tDictId>0 tSC = ##class(%iKnow.Matching.DictionaryAPI).DropDictionary(tDomainId, tDictId)
		quit:$$$ISERR(tSC)
		set tDictIdCause = ##class(%iKnow.Matching.DictionaryAPI).GetDictionaryId(tDomainIdAbstract, ..#IKNOWDICTNAME)
		set:tDictIdCause>0 tSC = ##class(%iKnow.Matching.DictionaryAPI).DropDictionary(tDomainIdAbstract, tDictIdCause)
		quit:$$$ISERR(tSC)
		
		// now create a new one, containing all entities and CRCs of the current source
		// NOTE: this is a very crude approach. refining this to all entities that are dominant
		// in the input text and/or not too common in the overall domain (such as "pilot" etc),
		// could improve the results.
		set ..dictId = ##class(%iKnow.Matching.DictionaryAPI).CreateDictionary(tDomainId, ..#IKNOWDICTNAME)
		set tDictIdCause = ##class(%iKnow.Matching.DictionaryAPI).CreateDictionary(tDomainIdAbstract, ..#IKNOWDICTNAME)
		
		set tSC = ##class(%iKnow.Queries.EntityAPI).GetBySource(.tEntities, tDomainId, tSrcId, 0, 0)
		quit:$$$ISERR(tSC)
		set i=""
		for {
			set i = $order(tEntities(i),1,tData)
			quit:i=""
			
			set tSC = ##class(%iKnow.Matching.DictionaryAPI).CreateDictionaryItemAndTerm(tDomainId, ..dictId, $li(tData,2), ":entity:"_$li(tData,1)_":"_$li(tData,2))
			quit:$$$ISERR(tSC)
			set tSC = ##class(%iKnow.Matching.DictionaryAPI).CreateDictionaryItemAndTerm(tDomainIdAbstract, tDictIdCause, $li(tData,2), ":entity:"_$li(tData,1)_":"_$li(tData,2))
			quit:$$$ISERR(tSC)
		}
		quit:$$$ISERR(tSC)
		
		set tSC = ##class(%iKnow.Queries.CrcAPI).GetBySource(.tCrcs, tDomainId, tSrcId, 0, 0)
		quit:$$$ISERR(tSC)
		set i=""
		for {
			set i = $order(tCrcs(i),1,tData)
			quit:i=""
			
			set tSC = ##class(%iKnow.Matching.DictionaryAPI).CreateDictionaryItemAndTerm(tDomainId, ..dictId, $lts($li(tData,2,4)," "), ":crc:"_$lts($li(tData,1,4),":"))
			quit:$$$ISERR(tSC)
			set tSC = ##class(%iKnow.Matching.DictionaryAPI).CreateDictionaryItemAndTerm(tDomainIdAbstract, tDictIdCause, $lts($li(tData,2,4)," "), ":crc:"_$lts($li(tData,1,4),":"))
			quit:$$$ISERR(tSC)
		}
		quit:$$$ISERR(tSC)
		
		// now match all sources in the reports domain against this new dictionary
		set tSC = ##class(%iKnow.Matching.MatchingAPI).MatchSources(tDomainId, ..filter, $lb(..dictId))
		quit:$$$ISERR(tSC)
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Client-side method called asynchroneously from <method>realTimeInputClient</method> to
/// perform the matching-based similarity search in the background and avoid "freezing" the UI
/// while it runs.
ClientMethod refreshDictionaryAsync() [ Language = javascript ]
{
	var sc = zenPage.BuildSrcDictionary();
	zen('tblDictionary').refreshContents();
	
	// also refresh source view panes, should they already be open before the matching process
	// finished at the end of BuildSrcDictionary();
	zen('htmlSource').refreshContents();
	zen('htmlAbstract').refreshContents();
}

/// This client event, if present, is fired when the page 
/// is first loaded or whenever it is resized.<br/>
/// If this is called at load time, then <var>load</var> will
/// be true.
ClientMethod onlayoutHandler(load) [ Language = javascript ]
{
	zenPage.resizeGroups(load);
}

/// Utility method to properly position and align the main page components.
ClientMethod resizeGroups(load) [ Language = javascript ]
{
	var logo = zen('logoContainer').getEnclosingDiv().clientHeight;
	var txtInput = zen('grpText').getEnclosingDiv().clientHeight;
	var available = 100; //zenGetWindowHeight()-logo-txtInput-100; ???
	zen('tgrResults').getEnclosingDiv().style.height = available;
	zen('tabSimilar').getEnclosingDiv().style.height = available-20;
	//zen('tabSrcDictionary').getEnclosingDiv().style.height = available-20;
	
	var fullWidth = zenGetWindowWidth()-40;
	zen('grpMain').getEnclosingDiv().style.width = fullWidth;
	zen('tgrResults').getEnclosingDiv().style.width = fullWidth;
	zen('tblSimilar').getEnclosingDiv().style.width = fullWidth-40;
	zen('grpText').getEnclosingDiv().style.width = parseInt(fullWidth*0.7);
	zen('txtInput').setProperty('cols', parseInt(fullWidth*0.07));
	zen('grpButtons').getEnclosingDiv().style.width = parseInt(fullWidth*0.3);
}

/// Ensures required parameters are present when calling a GetSimilar() query from the main
/// tables, to avoid noisy errors when the page opens before typing/selecting anything.
Method ExecuteSimilarQuery(pRS As %Library.ResultSet, ByRef tSC As %Status, pInfo As %ZEN.Auxiliary.QueryInfo) As %Boolean
{
	merge p = pInfo.parms
	quit:'+p(1) 1  // quit if no domain is specified
	quit:'+p(2) 1  // quit if no source is specified
	
	set p = $o(p(""),-1)
	set tSC = pRS.Execute(p...)
	
	quit 1
}

/// Client-side utility method to refresh appropriate sections when <property>filter</property>
/// changes.
ClientMethod onUpdateFilterClient() [ Language = javascript ]
{
	zen('tblSimilar').refreshContents();
	//zen('tblDictionary').refreshContents();
}

/// Draws a &lt;tablePane&gt; column's contents as a percentage
Method DrawPercentage(pTable As %ZEN.Component.tablePane, pName As %String, pSeed As %String) As %Status
{
	write $g(%query(pName))*100, "%"
	quit $$$OK
}

/// Utility method to draw source metadata in a &lt;tablePane&gt; column for a given source.
/// <var>pSeed</var> is expected to be the name of the metadata field to display.
Method DrawMetadata(pTable As %ZEN.Component.tablePane, pName As %String, pSeed As %String) As %Status
{
	set tExtId = $g(%query("extId"),$g(%query("externalId")))
	set tValue = ##class(%iKnow.Queries.MetadataAPI).GetValue(..patentDetailDomain, pSeed, tExtId, .tSC)
	set:pSeed="EventDate" tValue = $zd(tValue)
	write tValue
	quit tSC
}

/// Client-side method to clear the tablePane of results
ClientMethod clrTblSimilar() [ Language = javascript ]
{
	
var tablePane = zen('tblSimilar');
// Don't actually execute the query the next time the table is rendered.
tablePane.setProperty('initialExecute',false);

// Re-execute the query (this also clears the snapshot if snapshots are in use)
tablePane.executeQuery();
}

/// Client-side method refreshing appropriate sections of the popup window using the
/// <var>srcId</var> passed in.
ClientMethod displaySourceClient(srcId) [ Language = javascript ]
{
	zen('modSource').show();
	var sc = zenPage.setProperty('selectedPatentsrcId',srcId);
	zen('htmlTitle').refreshContents();
	zen('htmlSource').refreshContents();
	zen('htmlAbstract').refreshContents();
	//zen('tabTopEnts').refreshContents();
}

/// Client-side method triggered when the user presses the "summarize" button.
ClientMethod summarize() [ Language = javascript ]
{
	var sc = zenPage.setProperty('summaryLength', zen('txtLength').getValue());
	zen('htmlSource').refreshContents();
}

/// <p>Draws a number of event properties as a header for the popup.</p>
Method DrawEventHeader(pSeed As %String) As %Status
{
	set tSC = $$$OK
	try {
		quit:..selectedPatentsrcId=""
			
		set patExtSrcId=##class(%iKnow.Queries.SourceAPI).GetExternalId(..patentDetailDomain,..selectedPatentsrcId)
		
		set patNum=$p(patExtSrcId,":",4)
		
		&sql(select Title,IssueDate,Status,Category,InventorName into :title,:issuedate,:status,:category,:inventor from patent.application where PatentNumber = :patNum)
				
		write "<table id=""title""><tr>"
		write "<td id=""titleLeft"">"_"Patent Number: "_patNum_"</td>"
		write "<td id=""titleRight""></td>"
		write "</tr>"
	    write "<td id=""titleLeft"">"_"Title: "_title_"</td>"
		write "<td id=""titleRight""></td>"
		write "</tr></table>"
		write "<table id=""metadata"">"
		write "<tr><td class=""left"">Category:</td><td>"_##class(Patent.Application).CategoryLogicalToDisplay(category)_"</td></tr>"
		write "<tr><td class=""left"">Inventor:</td><td>"_$p(inventor,";",2)_" "_$p(inventor,";",1)_"</td></tr>"
		write "<tr><td class=""left"">Status:</td><td>"_status_"</td></tr>"
		write "<tr><td class=""left"">Issue Date:</td><td>"_$zdt(issuedate,5)_"</td></tr>"
        write "</table>"
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// <p>Draws the contents of a source (report or cause, based on <var>pSeed</var>) as identified by
/// the value of <property>selectedPatentsrcId</property>. The source is summarized if
/// <property>summaryLength</property> is non-zero (interpreted as the number of sentences) and
/// any matches against the dictionary created by <method>BuildSrcDictionary</method> is
/// highlighted.</p>
Method DrawSource(pSeed As %String) As %Status
{
	set tSC = $$$OK
	try {
		quit:'..selectedPatentsrcId
		
		if (pSeed="REPORT") {
			set tDomainId = ..patentDetailDomain
			set tSrcId = ..selectedPatentsrcId
			set tLength = ..summaryLength
		} else {
			set tDomainId = ..patentAbstractDomain
			set tExtId = ##class(%iKnow.Queries.SourceAPI).GetExternalId(..patentDetailDomain, ..selectedPatentsrcId)
			set tSrcId = ##class(%iKnow.Queries.SourceAPI).GetSourceId(tDomainId, tExtId)
			set tLength = 0
		}
		
		set tMatchFilter = ##class(%iKnow.Matching.MatchFilter).%New()
		set tDictId = ##class(%iKnow.Matching.DictionaryAPI).GetDictionaryId(tDomainId, ..#IKNOWDICTNAME)
		
		s ^aaa=tDictId
		
		//set tHighlight("MATCH", tDictId) = "<span class=""matchF"" title=""$$$TERM"">"
		//set tHighlight("MATCH", tDictId, "PARTIAL") = "<span class=""matchP"" title=""$$$TERM"">"
		
		// Cause domain is not matched yet!
		//set:pSeed="ABSTRACT" tSC = ##class(%iKnow.Matching.MatchingAPI).MatchSource(tDomainId, tSrcId, $lb(tDictId))
		//quit:$$$ISERR(tSC)
		
		w "<p>"
		
		set srcObj = ##class(%iKnow.Objects.Source).PKINDEXOpen(tDomainId, tSrcId)
		set sentBase = srcObj.FirstSentenceId-1
			
		if (tLength>0) {
			set tSC = ##class(%iKnow.Queries.SourceAPI).GetSummary(.res, tDomainId, tSrcId, tLength)
			quit:$$$ISERR(tSC)
		} else {
			kill res
			for i=1:1:srcObj.SentenceCount { set res(i) = $lb(sentBase+i) }
		}
		
		set i = "", prevPos=0
		for {
			set i = $o(res(i),1,d)
			quit:i=""
			
			set tSentId = $li(d,1), sentPos = tSentId-sentBase
			w:(sentPos>(prevPos+1)) " ... "
			
			write ##class(%iKnow.Queries.SentenceAPI).GetHighlighted(tDomainId, tSentId, .tHighlight,,,.tSC)," "
			quit:$$$ISERR(tSC)
			
			set prevPos = sentPos
		}
		w:(prevPos=(sentBase+srcObj.SentenceCount)) " ..."
		
		w "</p>"
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Initializes some of the panes and session variables used by this page, fetching domain, 
/// source and term variables from the request (if present).
/// This method also verifies if the appropriate domains are present.
Method %OnAfterCreatePage() As %Status
{
	set ..patentDetailDomain = $system.iKnow.GetDomainId(..#IKPATENTDETAILDOMAINNAME)
	set ..patentAbstractDomain = $system.iKnow.GetDomainId(..#IKpatentAbstractDomainNAME)
	
	if (..patentDetailDomain="") || (..patentAbstractDomain="") {
		quit $$$ERROR($$$GeneralError, "Patent domains must be setup before proceeding.")
	}
	
	quit ##super()
}

ClientMethod onunloadHandler() [ Language = javascript ]
{
	zenPage.OnUnload();
	return true;
}

Method OnUnload() As %Status [ Internal, ZenMethod ]
{
	try {
		// clean up any leftover sources
		do:..patentDetailDomain&&..inputSource ##class(%iKnow.Source.Loader).DeleteVirtualSource(..patentDetailDomain, $zabs(..inputSource))
	} catch {}
	quit $$$OK
}

}
