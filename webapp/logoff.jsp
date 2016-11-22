<%@ page language="java" %>
<%@ page import="java.util.*, org.apache.log4j.Logger" %>

<%
	Logger logger = Logger.getLogger("com.procergs.logoff");
	String redirectURL = "login.jsp";
	
	logger.info("redirectURL...: " + redirectURL);
	
	session = request.getSession();
	session.invalidate();
 
  response.sendRedirect(redirectURL);
%>
