/// This page is used as a popup to display aviation event narrative and cause texts
Class iknowexp.Part3popup Extends %ZEN.Component.page
{

/// Displayed name of this page.
Parameter PAGENAME = "Aviation Event Narrative and Cause";

/// Aviation eventID
Property aviationEventID As %ZEN.Datatype.string;

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="Aviation Event">
<vgroup cellVAlign="top">
<html id="htmlTitle" OnDrawContent="DrawEventHeader"/>
<spacer height="10" />
<tabGroup showTabBar="true" enclosingStyle="padding:5px;">
<tab caption="Event report" cellStyle="padding:5px;" width="100%">
<html id="htmlSource" OnDrawContent="DrawSource" containerStyle="overflow-y:scroll;" 
enclosingClass="textBox" seed="REPORT" />
</tab>
<tab caption="Cause" cellStyle="padding:5px;" width="100%">
<html id="htmlCause" containerStyle="overflow-y:scroll" OnDrawContent="DrawSource" 
enclosingClass="textBox" seed="CAUSE" />
</tab>
</tabGroup>
</vgroup>
</page>
}

/// <p>Draws a number of event properties as a header for the popup.</p>
Method DrawEventHeader(pSeed As %String) As %Status
{
	set tSC = $$$OK
	try {
		quit:'..aviationEventID
		
		#dim tEvent As Aviation.Event
		set tEvent = ##class(Aviation.Event).PKINDEXOpen(..aviationEventID)
		
		write "<table id=""title""><tr>"
		write "<td id=""titleLeft"">"_"Aviation Event: "_..aviationEventID_"</td>"
		write "<td id=""titleRight""></td>"
		write "</tr></table>"
		
		write "<table id=""metadata"">"
		write "<tr><td class=""left"">Date:</td><td>"_$e(tEvent.EventDate,1,10)_"</td></tr>"
		write "<tr><td class=""left"">NTSB ID:</td><td>"_tEvent.NTSBId_"</td></tr>"
		write "<tr><td class=""left"">Location:</td><td><a href=""http://maps.google.com/maps?q="_tEvent.LocationCoordsLatitude_",+"_tEvent.LocationCoordsLongitude_"+(Event location:+"_$zconvert(tEvent.LocationCity,"O","URL")_")&iwloc=A"" target=""_new"">"_$s(tEvent.LocationState'="":tEvent.LocationState_", ", 1:"")_tEvent.LocationCountry_"</a></td></tr>"
		write "<tr><td class=""left"">Aircraft:</td><td>"_tEvent.Aircraft.GetAt(1).AircraftManufacturer_" "_tEvent.Aircraft.GetAt(1).AircraftCategory_"</td></tr>"
	    write "<tr><td class=""left"">Damage:</td><td>"_tEvent.Aircraft.GetAt(1).Damage_"</td></tr>"
        write "</table>"
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

Method DrawSource(pSeed As %String) As %Status
{
	#dim tEvent As Aviation.Event
	set tSC = $$$OK
	try {
		quit:'..aviationEventID
		
		w "<p>"
		set tEvent = ##class(Aviation.Event).PKINDEXOpen(..aviationEventID)
		if (pSeed="REPORT") {
			w tEvent.NarrativeFull
		} else {
			w tEvent.NarrativeCause
		}
		w "</p>"
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Initializes some of the panes and session variables used by this page,
/// fetching the aviation Event ID from the %request 
Method %OnAfterCreatePage() As %Status
{
	Set ..aviationEventID = $G(%request.Data("eventID",1))	
	if (..aviationEventID="") {
		quit $$$ERROR($$$GeneralError, "No aviation event ID selected.")
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
