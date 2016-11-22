<%@ page language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<html ng-app="app">
	<head>
		<meta http-equiv="cache-control" content="max-age=0" />
		<meta http-equiv="cache-control" content="no-cache" />
		<meta http-equiv="expires" content="0" />
		<meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT" />
		<meta http-equiv="pragma" content="no-cache" />	
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		
		<!--[if lte IE 7]>
			<style type="text/css"> body { font-size: 85%; } </style>
		<![endif]-->
	
		<!-- 1.3.15 -->
		<script src="include/angular.js"></script>
		<script src="include/angular-touch.js"></script>
		<script src="include/angular-animate.js"></script>
		<script src="include/applogin.js"></script>
		<script src="include/jquery-1.11.3.js"></script>
		<script src="include/jquery.layout.js"></script>
		<script src="include/spin.js"></script>
		<script src="include/angular-spinner.js"></script>
		<link rel="stylesheet" href="include/font-awesome.min.css">
		
		<script src="include/ui-bootstrap-tpls-0.13.0.min.js"></script>
		<script src="include/bootstrap.js"></script>
		
		<link rel="stylesheet" href="include/animate.min.css">		
		<link rel="styleSheet" href="include/styles.css" />
		<link rel="stylesheet" href="include/bootstrap.css">
		
		<script type="text/javascript">
		function showPassword() {
			console.log("Inside showPassword...");
			var type = $("#password").attr("type");
			if (type == "password") { 
				$("#password").attr("type", "text"); 
				$("#eye_icon").removeClass('fa fa-eye').addClass('fa fa-eye-slash');
			}
		}
		
		function hidePassword() {
			console.log("Inside hidePassword...");
			var type = $("#password").attr("type");
			if (type == "text") { 
				$("#password").attr("type", "password");
				$("#eye_icon").removeClass('fa fa-eye-slash').addClass('fa fa-eye');
			}
		}
		
		function submitForm() {
			console.log("Inside submitForm...");
			
			var username = $("#username").val();
			var user_len =  $("#username").val().length;
			
			var plainText = $("#password").val();
			var pw_len =  $("#password").val().length;
			
			if (user_len == 0) {
				$( "#error" ).html("Username is required, please try again...");
				return;
			}
			
			if (pw_len == 0) {
				$( "#error" ).html("Password is required, please try again");
				return;
			}
			var base64Text = window.btoa(unescape(encodeURIComponent(plainText)));
			$("#encoded_pw").val(base64Text);
			
			document.myform.submit();
		};
		
		function clearErrors() {
			console.log("Inside clearErrors...");
			$( "#error" ).html("");
		};
		
		$( document ).ready(function() {
			console.log("Document Ready Now...");
			
			$("#username").keypress(function(event) {
					console.log("keypress event..." + event);
			    if (event.which == 13) {
			        event.preventDefault();
			        submitForm();
			    }
			});
			
			$("#password").keypress(function(event) {
				console.log("keypress event..." + event);
		    if (event.which == 13) {
		        event.preventDefault();
		        submitForm();
		    }
			});
		});
		</script>
	</head>
	
	<%
	boolean isDebug = false;
	String debugParam = request.getParameter("debug");
	if (debugParam != null && (debugParam.toLowerCase().equals("true") || 
															debugParam.toLowerCase().equals("yes") || 
															debugParam.equals("1"))) {
		isDebug = true;
	}
	
	session = request.getSession();
	String error_msg = (String)session.getAttribute("error");
	
	
	%>

	<body class="login-background" ng-controller="MainCtrl">
		<script type="text/ng-template" id="myModalContent.html">
	<div class="modal-header-error">
		<h4 class="modal-title-error"><span class="glyphicon glyphicon-alert" aria-hidden="true"></span>  {{modal.title}}</h4>
	</div>
	<div class="modal-body">
		<b>{{modal.message}}</b>
	</div>
	<div class="modal-footer">
		<button class="btn btn-danger" ng-click="ok()">OK</button>
	</div>
	</script>

		<div class="login-panel">
			<div class="animated bounceIn shadow">
				<div class="panel panel-info">
			  	<div class="panel-heading"><i class="fa fa-lock fa-2x"></i><font class="loginTitle"> Login Security via JWT, JWS and JWE</font></div>
			  	<div class="panel-body">
			    	<form id="myform" name="myform" method="POST" action="processLogin.jsp">
			    		<div class="form-fields">
			    			<span us-spinner spinner-key="spinner-1"></span>
				    		<div class="col-lg-10">
				    			<input id="encoded_pw" name="encoded_pw" type="hidden" ng-model="login.encoded_pw"/>
				    			
				    			<div class="form-group has-feedback" ng-class="{'has-error': myform.username.$invalid, 'has-success': myform.username.$valid}">
					    			<div class="input-group margin-bottom-sm" >
											<span class="input-group-addon"><i class="fa fa-user fa-fw"></i></span>
											<input type="text" class="form-control" id="username" name="username" required ng-model="login.username"  placeholder="Username"  focus-on="setFocus"/>
				     				</div>
				     			</div>
				     			
				     			<div><br/></div>
				     			<div class="form-group has-feedback" ng-class="{'has-error': myform.password.$invalid, 'has-success': myform.password.$valid}">
				     				<div class="input-group margin-bottom-sm" >
											<span class="input-group-addon"><i class="fa fa-key fa-fw"></i></span>
											<input type="password" class="form-control" id="password" name="password" required ng-model="login.password"  placeholder="Password" />
											<span class="input-group-addon"><a href=""  onmousedown="showPassword();" onmouseup="hidePassword();" onmouseout="hidePassword();"><i id="eye_icon" class="fa fa-eye revealIcon"></i></a></span>
				     				</div>
				     			</div>
				     			
				     			<div id="failure-message" class="login-message">
				     				<p id="error" name="error">
				     			<% if (error_msg != null) {
				     				out.print(error_msg);
				     			} %>
				     			</p>
				     			</div>
				     			
				     			<div style="float: right;"><br/>
				     				<button id="clear" type="button" class="btn btn-primary" style="width: 80px;" ng-click="clearLogin()" onclick="clearErrors()">
				     				<i class="fa fa-times"></i> Clear</button>
				     				
				     				<button id="login" type="button" class="btn btn-primary" style="width: 100px;" onclick="submitForm();">
				     				<i class="fa fa-chevron-circle-left"></i>&nbsp; Login</button>
				     				
				     				<!-- <button id="login" type="submit" class="btn btn-primary" style="width: 100px;" ng-click="processLogin()">
				     				<i class="fa fa-chevron-circle-left"></i>&nbsp; Login</button> -->
	  							</div>
			     			</div>
		     			</div>
			    	</form>
			 	 	</div>
			 	 <!-- 	<div class="panel-footer">Help!  I forgot my password?</div> -->
				</div>
			</div>
			<div ng-element-ready="setDefaults('<%=isDebug %>')"></div>
			<div ng-element-ready="init()"></div>
		</div>
	</body>
</html>