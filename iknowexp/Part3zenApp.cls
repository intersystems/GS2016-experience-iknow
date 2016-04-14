/// iknowexp.Part3zenApp
Class iknowexp.Part3zenApp Extends %ZEN.application
{

Parameter JSINCLUDES = "jQuery/2.2.2/jquery-2.2.2.min.js,angularjs/1.5.0/angular.min.js,angularjs/1.5.0/angular-touch.min.js,angularjs/1.5.0/angular-animate.min.js,angular-ui-grid/3.1.1/ui-grid.min.js,angular-ui-grid/3.1.1/vfs_fonts.js,bootstrap/3.3.6/js/bootstrap.min.js";

/// This is the name of this application.
Parameter APPLICATIONNAME = "Part3";

/// This is the URL of the main starting page of this application.
Parameter HOMEPAGE = "/csp/iknowexp/iknowexp.Part3.cls";

Parameter CSSINCLUDES = "angular-ui-grid/3.1.1/ui-grid.min.css,bootstrap/3.3.6/css/bootstrap.min.css,main.css";

/// This Style block contains application-wide CSS style definitions.
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
	height: 300px;
	background-color: white;
	padding: 5px;
}

</style>
}

}
