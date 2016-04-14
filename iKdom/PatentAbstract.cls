Class iKdom.PatentAbstract Extends %iKnow.DomainDefinition [ ProcedureBlock ]
{

XData Domain [ XMLNamespace = "http://www.intersystems.com/iknow" ]
{
<domain name="PatentAbstract" disabled="false" allowCustomUpdates="true">
<parameter name="DefaultConfig" value="PatentAbstract.Configuration" isList="false" />
<data dropBeforeBuild="true">
<table listname="Table_1" batchMode="true" disabled="false" listerClass="%iKnow.Source.SQL.Lister" tableName="Patent.Application" idField="PatentNumber" groupField="Category" dataFields="Abstract" metadataColumns="Category" metadataFields="Category" />
</data>
<metadata>
<field name="Category" operators="=" dataType="STRING" storage="0" caseSensitive="false" disabled="false" />
</metadata>
<configuration name="PatentAbstract.Configuration" detectLanguage="false" languages="en" summarize="true" maxConceptLength="0" />
</domain>
}

}
