/// This page is used as a popup to display patent description
Class iknowexp.Part0popup Extends %ZEN.Component.page
{

/// Displayed name of this page.
Parameter PAGENAME = "Patent Description";

/// Patent Name
Property PatentNumber As %ZEN.Datatype.string;

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Patent Description">
<vgroup cellVAlign="top">
<html id="htmlTitle" OnDrawContent="DrawPatentHeader"/>
<spacer height="10" />
<tabGroup showTabBar="true" enclosingStyle="padding:5px;">
<tab caption="Patent Description" cellStyle="padding:5px;" width="100%">
<html id="htmlSource" OnDrawContent="DrawSource" containerStyle="overflow-y:scroll;" 
enclosingClass="textBox" seed="REPORT" />
</tab>
<tab caption="Abstract" cellStyle="padding:5px;" width="100%">
<html id="htmlAbstract" containerStyle="overflow-y:scroll" OnDrawContent="DrawSource" 
enclosingClass="textBox" seed="ABSTRACT" />
</tab>
</tabGroup>
</vgroup>
</page>
}

/// <p>Draws a number of patent properties as a header for the popup.</p>
Method DrawPatentHeader(pSeed As %String) As %Status
{
	set tSC = $$$OK
	try {
		quit:..PatentNumber=""
		
		set patNum=..PatentNumber
		&sql(select Title,IssueDate,Status,Category,InventorName into :title,:issuedate,:status,:category,:inventor from patent.application where PatentNumber = :patNum)
				
		write "<table id=""title""><tr>"
		write "<td id=""titleLeft"">"_"Patent Number: "_..PatentNumber_"</td>"
		write "<td id=""titleRight""></td>"
		write "</tr></table>"
		
		write "<table id=""metadata"">"
		write "<tr><td class=""left"">Issue Date:</td><td>"_$zdt(issuedate,5)_"</td></tr>"
		write "<tr><td class=""left"">Status:</td><td>"_status_"</td></tr>"
		write "<tr><td class=""left"">Category:</td><td>"_##class(Patent.Application).CategoryLogicalToDisplay(category)_"</td></tr>"
		write "<tr><td class=""left"">Inventor:</td><td>"_$p(inventor,";",2)_" "_$p(inventor,";",1)_"</td></tr>"
        write "</table>"
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

Method DrawSource(pSeed As %String) As %Status
{
	set tSC = $$$OK
	try {
		quit:..PatentNumber=""
		set patNum=..PatentNumber
		&sql(select DetailedDescription,abstract into :description,:abstract from patent.application where patentnumber = :patNum)
		w "<p>"
		if (pSeed="REPORT") {
			w $g(description)
		} else {
			w $g(abstract)
		}
		w "</p>"
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Initializes some of the panes and session variables used by this page,
/// fetching the Patent Number from the %request 
Method %OnAfterCreatePage() As %Status
{
	Set ..PatentNumber = $G(%request.Data("PatentNumber",1))	
	if (..PatentNumber="") {
		quit $$$ERROR($$$GeneralError, "No Patent Number selected.")
	}
	quit ##super()
}

XData Style
{
<style type="text/css">

body {
	font-family: Verdana, Arial;
	font-size: 12px;
	line-height: 17px;
}

a {
	color: #a00000;
}

.match,.matchF {
	background-color: #9999ff;
	border: solid #9999ff 2px;
}
.matchP {
	border: solid #9999ff 2px;
	background-color: none;
}

table#title {
	border-bottom: solid black 1px;
	width: 100%;
}
td#titleLeft {
	font-weight: bold;
	font-size: 20px;
}
td#titleRight {
	vertical-alignment: bottom;
	text-align: right
}

table#metadata {
	margin-left: 20px;
	margin-top: 10px;
}
table#metadata td.left {
	padding-right: 10px;
	text-align: right;
}

.pageTitle {
	vertical-alignment: bottom;
	font-weight: bold;
	font-size: 25px;
}

.textBox {
	overflow-y: scroll;
	width: 500px;
	height: 400px;
	background-color: white;
	padding: 5px;
}

</style>
}

}
