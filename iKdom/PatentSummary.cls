Class iKdom.PatentSummary Extends %iKnow.DomainDefinition [ ProcedureBlock ]
{

XData Domain [ XMLNamespace = "http://www.intersystems.com/iknow" ]
{
<domain name="PatentSummary" disabled="false" allowCustomUpdates="true">
<parameter name="DefaultConfig" value="PatentSummary.Configuration" isList="false" />
<data dropBeforeBuild="true">
<table listname="Table_1" batchMode="true" disabled="false" listerClass="%iKnow.Source.SQL.Lister" tableName="Patent.Application" idField="PatentNumber" groupField="Category" dataFields="SummaryDescription" metadataColumns="Category" metadataFields="Category" />
</data>
<metadata>
<field name="Category" operators="=" dataType="STRING" storage="0" caseSensitive="false" disabled="false" />
</metadata>
<configuration name="PatentSummary.Configuration" detectLanguage="false" languages="en" summarize="true" maxConceptLength="0" />
</domain>
}

}
