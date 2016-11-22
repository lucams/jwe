<%@ page language="java" %>
<%@ page import="org.apache.log4j.Logger" %>

<!doctype html>
<html ng-app="app">
  <head>
    <script src="include/angular.js"></script>
    <script src="include/angular-touch.js"></script>
    <script src="include/angular-animate.js"></script>
    <script src="include/csv.js"></script>
    <script src="include/vfs_fonts.js"></script>
    <script src="include/pdfmake.js"></script>
    <script src="include/jquery-1.11.3.js"></script>
		<script src="include/jquery.layout.js"></script>
    <script src="include/ui-grid.js"></script>
    <script src="include/angular-spinner.js"></script>
    <script src="include/spin.js"></script>
    <script src="include/app.js"></script>
		
		<script src="include/ui-bootstrap-tpls-0.13.0.min.js"></script>
		<script src="include/bootstrap.js"></script>
		
    <link rel="stylesheet" href="http://ui-grid.info/release/ui-grid.css">
		<link rel="stylesheet" href="include/font-awesome.min.css">
		<link rel="styleSheet" href="include/styles.css" />
		<link rel="stylesheet" href="include/bootstrap.css">
  </head>
  
  <%! static Logger logger = Logger.getLogger("com.procergs.InventoryApp"); %>
  
  <%
	String fullProtocol = request.getProtocol().toLowerCase();
	String protocol[] = fullProtocol.split("/");
	String baseUrl = protocol[0] + "://" + request.getHeader("Host");
	
	session = request.getSession();
	String username = (String) session.getAttribute("username");
	String token = (String) session.getAttribute("token");
	
	logger.info("username..: " + username);
	logger.info("token.....: " + token);
	
	if (token == null) {
		String loginURL = "login.jsp";
		response.sendRedirect(loginURL);
	}
	%>

  <body>
    <div ng-controller="MainCtrl">
    	<div class="page-header">
    		<h2><strong>JWT/JWS/JWE Sample Application<br><small>Using JSON Web Tokens, JSON Web Signature and JSON Web Encryption</small></strong></h2>
     		<span ng-show="userRoles.indexOf('admin') > 0">
    			<button id="login" type="button" onClick="alert('Show Admin Window...')" class="btn btn-primary" style="width: 100px;">
					<i class="fa fa-user fa-fw"></i>&nbsp; Admin</button>
				</span>
				<a href="logoff.jsp"><button id="login" type="button" class="btn btn-primary" style="width: 100px;" >
				<i class="fa fa-power-off"></i>&nbsp; Logout</button></a>
				<span class="right_justified">
    			<button class="btn btn-info" style="width: 200px;">Welcome {{username}}</button>
				</span>
    	</div>
      <div class="row">
        <div class="span4">
        	<span us-spinner spinner-key="spinner-0"></span>
          <div id="grid1" ui-grid="gridOptions" class="grid"></div>
        </div>
      </div>
	    <div ng-element-ready="setDefaults('<%=baseUrl%>', '<%=username %>', '<%=token %>')"></div>
	    <div ng-element-ready="loadAllRoles()"></div>    
	    <div ng-element-ready="loadAllItems()"></div>    
    </div>
  </body>
</html>