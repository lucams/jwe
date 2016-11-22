<%@ page language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.*, org.apache.log4j.Logger, 
								com.procergs.util.ApacheConnection,
								org.json.simple.parser.*, org.json.simple.*" %>

<%! static Logger logger = Logger.getLogger("com.procergs.processLogin"); %>

<%
	//Logger logger = Logger.getLogger("com.procergs.processLogin");
	int MaxInactiveInterval = 30*60;   // 30 minutes
	String fullProtocol = request.getProtocol().toLowerCase();
	String protocol[] = fullProtocol.split("/");
	String baseUrl = protocol[0]+"://" + request.getHeader("Host");
	String url = baseUrl + "/JweSecurity/rest/security/authenticate";
	
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	String loginURL = "login.jsp";
	String targetURL = loginURL; 

	if (username != null && username.equals("")) {
		username = null;
	}
	
	if (password != null && password.equals("")) {
		password = null;
	}
	logger.info("URL...........: [" + url + "]");
	logger.info("USERNAME......: [" + username + "]");
	logger.info("PASSWORD......: [" + password + "]");
	
	// add checks for username / password 
	if (username != null && password != null) {
		String redirectURL = baseUrl + "/JweSecurity/InventoryApp.jsp";
		
		ApacheConnection httpConnection = new ApacheConnection();
		
		Map<String,String> header = new HashMap<String,String>();
		header.put("username", username);
		header.put("password", password);

		String authenticationJSON = httpConnection.executePost(url, header, null);
	
		logger.info("Authentication JSON...: " + authenticationJSON);
		
		JSONParser authParser=new JSONParser();
		JSONObject jsonAuthObj = (JSONObject) authParser.parse(authenticationJSON);
		
		Long authStatusCode = (Long) jsonAuthObj.get("status_code");
		String authMessage = (String) jsonAuthObj.get("message");
		
		logger.info("JSONObject....: " + jsonAuthObj);
		logger.info("status_code...: " + authStatusCode);
		logger.info("message.......: " + authMessage);
		
		session = request.getSession();
		
		if (authStatusCode != null  && authStatusCode.intValue() != 200) {
			if (authStatusCode.intValue() == 403) {
				session.setAttribute("error", "Username/Password are incorrect, please try again...");
			}			
			if (authStatusCode.intValue() == 412) {
				session.setAttribute("error", "Username/Password is required, please try again...");
			}			
			targetURL = loginURL;
		} else {
			session.setAttribute("username", username);	
			session.setAttribute("token", authMessage);
			targetURL = redirectURL;
		}
	  session.setMaxInactiveInterval(MaxInactiveInterval);
	  
	} else {
		logger.error("Username or Password is NULL...");
	}
	
  response.sendRedirect(targetURL);
%>
