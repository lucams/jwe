package com.procergs.service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.ws.rs.GET;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import org.apache.log4j.Logger;
import org.bson.Document;
import org.bson.json.JsonParseException;
import org.codehaus.jackson.JsonGenerationException;
import org.codehaus.jackson.map.JsonMappingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.jose4j.jwe.ContentEncryptionAlgorithmIdentifiers;
import org.jose4j.jwe.JsonWebEncryption;
import org.jose4j.jwe.KeyManagementAlgorithmIdentifiers;
import org.jose4j.jwk.JsonWebKey;
import org.jose4j.jwk.JsonWebKey.Factory;
import org.jose4j.jws.AlgorithmIdentifiers;
import org.jose4j.jws.JsonWebSignature;
import org.jose4j.jwt.JwtClaims;
import org.jose4j.jwt.MalformedClaimException;
import org.jose4j.jwt.consumer.InvalidJwtException;
import org.jose4j.jwt.consumer.JwtConsumer;
import org.jose4j.jwt.consumer.JwtConsumerBuilder;
import org.jose4j.lang.JoseException;

import com.mongodb.client.MongoDatabase;
import com.procergs.model.Item;
import com.procergs.model.StatusMessage;
import com.procergs.model.User;
import com.procergs.util.MongoDBSingleton;

@Path("/security") 
public class JWESecurity {
	static Logger logger = Logger.getLogger(JWESecurity.class);
	static JsonWebKey jwKey = null;
	
	static {		
		logger.info("Inside static initializer...");
		// Setting up Direct Symmetric Encryption and Decryption
		String jwkJson = "{\"kty\":\"oct\",\"k\":\"9d6722d6-b45c-4dcb-bd73-2e057c44eb93-928390\"}";
		try {
			new JsonWebKey.Factory();
			jwKey =  Factory.newJwk(jwkJson);
		} catch (JoseException e) {
			e.printStackTrace();
		}
	}
	
	@Path("/status")
	@GET
	@Produces(MediaType.TEXT_HTML)
	public String returnVersion() {
		return "JweSecurity Status is OK...";
	}

	@Path("/authenticate")
	@POST
	@Produces(MediaType.APPLICATION_JSON)
	public Response authenticateCredentials(@HeaderParam("username") String username,
			@HeaderParam("password") String password)
				throws JsonGenerationException, JsonMappingException, IOException {

		logger.info("Authenticating User Credentials...");

		if (username == null) {
			StatusMessage statusMessage = new StatusMessage();
			statusMessage.setStatus(Status.PRECONDITION_FAILED.getStatusCode());
			statusMessage.setMessage("Username value is missing!!!");
			return Response.status(Status.PRECONDITION_FAILED.getStatusCode())
					.entity(statusMessage).build();
		}
		
		if (password == null) {
			StatusMessage statusMessage = new StatusMessage();
			statusMessage.setStatus(Status.PRECONDITION_FAILED.getStatusCode());
			statusMessage.setMessage("Password value is missing!!!");
			return Response.status(Status.PRECONDITION_FAILED.getStatusCode())
					.entity(statusMessage).build();
		}

		User user = validateUser(username, password); 
		logger.info("User after validateUser => " + user);
		
		if (user == null) {	
			StatusMessage statusMessage = new StatusMessage();
      statusMessage.setStatus(Status.FORBIDDEN.getStatusCode());
      statusMessage.setMessage("Access Denied for this functionality !!!");
      logger.info("statusMessage ==> " + statusMessage);
      return Response.status(Status.FORBIDDEN.getStatusCode())
          .entity(statusMessage).build();
		}
 
		logger.info("User Information => " + user);
		
    // Create the Claims, which will be the content of the JWT
    JwtClaims claims = new JwtClaims();
    claims.setIssuer("procergs.com");
    claims.setExpirationTimeMinutesInTheFuture(5);
    claims.setGeneratedJwtId();
    claims.setIssuedAtToNow();
    claims.setNotBeforeMinutesInThePast(2);
    claims.setSubject(user.getUsername());
    claims.setStringListClaim("roles", user.getRolesList()); 
 
    JsonWebSignature jws = new JsonWebSignature();

    logger.info("Claims => " + claims.toJson());
    // The payload of the JWS is JSON content of the JWT Claims
    jws.setPayload(claims.toJson());
    jws.setKeyIdHeaderValue(jwKey.getKeyId());
    jws.setKey(jwKey.getKey());
    
    jws.setAlgorithmHeaderValue(AlgorithmIdentifiers.HMAC_SHA256); 

    String jwt = null;
		try {
			jwt = jws.getCompactSerialization();
		} catch (JoseException e) {
			e.printStackTrace();
		}
		 
		JsonWebEncryption jwe = new JsonWebEncryption();
		jwe.setAlgorithmHeaderValue(KeyManagementAlgorithmIdentifiers.DIRECT);
		jwe.setEncryptionMethodHeaderParameter(ContentEncryptionAlgorithmIdentifiers.AES_128_CBC_HMAC_SHA_256);
		jwe.setKey(jwKey.getKey());
		jwe.setKeyIdHeaderValue(jwKey.getKeyId());
		jwe.setContentTypeHeaderValue("JWT");
		jwe.setPayload(jwt);
		
		String jweSerialization = null;
		try {
			jweSerialization = jwe.getCompactSerialization();
		} catch (JoseException e) {
			e.printStackTrace();
		}
		
		StatusMessage statusMessage = new StatusMessage();
    statusMessage.setStatus(Status.OK.getStatusCode());
    statusMessage.setMessage(jweSerialization);
    logger.info("statusMessage ==> " + statusMessage);
    return Response.status(Status.OK.getStatusCode())
        .entity(statusMessage).build();
	}
	
	//--- Protected resource using JWT/JWE Token ---
	@Path("/getallroles")
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public Response getAllRoles(@HeaderParam("token") String token) 
			throws JsonGenerationException,
		JsonMappingException, IOException {

		logger.info("Inside getAllRoles...");

		List<String> allRoles = null;
		
		if (token == null) {
			StatusMessage statusMessage = new StatusMessage();
			statusMessage.setStatus(Status.FORBIDDEN.getStatusCode());
			statusMessage.setMessage("Access Denied for this functionality !!!");
			return Response.status(Status.FORBIDDEN.getStatusCode())
					.entity(statusMessage).build();
		}

		logger.info("JWK (1) ===> " + jwKey.toJson());
		
		// Validate Token's authenticity and check claims
		JwtConsumer jwtConsumer = new JwtConsumerBuilder()
	    .setRequireExpirationTime() // the JWT must have an expiration time
	    .setAllowedClockSkewInSeconds(30) // allow for a 30 second difference to account for clock skew
	    .setRequireSubject() 	// the JWT must have a subject claim
	    .setExpectedIssuer("procergs.com") // whom the JWT needs to have been issued by
	    .setDecryptionKey(jwKey.getKey())
	    .setVerificationKey(jwKey.getKey())
	    .build(); // create the JwtConsumer instance

		try	{
			//  Validate the JWT and process it to the Claims
			JwtClaims jwtClaims = jwtConsumer.processToClaims(token);
			logger.info("JWT validation succeeded! " + jwtClaims);
			try {
				allRoles = jwtClaims.getStringListClaimValue("roles");
			} catch (MalformedClaimException e) {
				e.printStackTrace();
			}
		} catch (InvalidJwtException e) {
			logger.error("JWT is Invalid: " + e);
			StatusMessage statusMessage = new StatusMessage();
			statusMessage.setStatus(Status.FORBIDDEN.getStatusCode());
			statusMessage.setMessage("Access Denied for this functionality !!!");
			return Response.status(Status.FORBIDDEN.getStatusCode())
					.entity(statusMessage).build();
		}
		
		return Response.status(200).entity(allRoles).build();
	}
	
	//--- Protected resource using JWT/JWE Token ---
	@Path("/showallitems")
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public Response showAllItems(@HeaderParam("token") String token) 
			throws JsonGenerationException,
		JsonMappingException, IOException {

		Item item = null;

		logger.info("Inside showAllItems...");

		if (token == null) {
			StatusMessage statusMessage = new StatusMessage();
			statusMessage.setStatus(Status.FORBIDDEN.getStatusCode());
			statusMessage.setMessage("Access Denied for this functionality !!!");
			return Response.status(Status.FORBIDDEN.getStatusCode())
					.entity(statusMessage).build();
		}

		logger.info("JWK (1) ===> " + jwKey.toJson());
		
		// Validate Token's authenticity and check claims
		JwtConsumer jwtConsumer = new JwtConsumerBuilder()
	    .setRequireExpirationTime() // the JWT must have an expiration time
	    .setAllowedClockSkewInSeconds(30) // allow for a 30 second difference to account for clock skew
	    .setRequireSubject() 	// the JWT must have a subject claim
	    .setExpectedIssuer("procergs.com") // whom the JWT needs to have been issued by
	    .setDecryptionKey(jwKey.getKey())
	    .setVerificationKey(jwKey.getKey())
	    .build(); // create the JwtConsumer instance

		try	{
			//  Validate the JWT and process it to the Claims
			JwtClaims jwtClaims = jwtConsumer.processToClaims(token);
			logger.info("JWT validation succeeded! " + jwtClaims);
		} catch (InvalidJwtException e) {
			logger.error("JWT is Invalid: " + e);
			StatusMessage statusMessage = new StatusMessage();
			statusMessage.setStatus(Status.FORBIDDEN.getStatusCode());
			statusMessage.setMessage("Access Denied for this functionality !!!");
			return Response.status(Status.FORBIDDEN.getStatusCode())
					.entity(statusMessage).build();
		}
		
		MongoDBSingleton mongoDB = MongoDBSingleton.getInstance();
		MongoDatabase db = mongoDB.getDatabase();

		List<Document> results = db.getCollection("items").find()
				.into(new ArrayList<Document>());
		int size = results.size();

		if (size == 0) {
			StatusMessage statusMessage = new StatusMessage();
			statusMessage.setStatus(Status.PRECONDITION_FAILED.getStatusCode());
			statusMessage.setMessage("There are no Items to display !!!");
			return Response.status(Status.PRECONDITION_FAILED.getStatusCode())
					.entity(statusMessage).build();
		}

		List<Item> allItems = new ArrayList<Item>();
		for (Document current : results) {
			ObjectMapper mapper = new ObjectMapper();
			try {
				logger.info(current.toJson());
				item = mapper.readValue(current.toJson(), Item.class);
				allItems.add(item);
			} catch (JsonParseException e) {
				e.printStackTrace();
			} catch (JsonMappingException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		return Response.status(200).entity(allItems).build();
	}
	
	private User validateUser(String username, String password) {
		MongoDBSingleton mongoDB = MongoDBSingleton.getInstance();
		MongoDatabase db = mongoDB.getDatabase();
		List<Document> results = null;

		logger.info("Inside of validateUser...");
		results = db.getCollection("users").find(new Document("username", username))
				.limit(1).into(new ArrayList<Document>());
		
		int size = results.size();
		logger.info("size of results==> " + size);
		
		if (size > 0) {
			for (Document current : results) {
				ObjectMapper mapper = new ObjectMapper();
				User user = null;
				try {
					logger.info(current.toJson());
					user = mapper.readValue(current.toJson(), User.class);
				} catch (JsonParseException e) {
					e.printStackTrace();
				} catch (JsonMappingException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
				if (user != null && username.equals(user.getUsername())
						&& password.equals(user.getPassword())) {
					return user;
				} else {
					return null;
				}
			}
			return null;
		} else {
			return null;
		}
	}
}
