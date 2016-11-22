package com.procergs.model;

import org.codehaus.jackson.annotate.JsonProperty;
import org.codehaus.jackson.annotate.JsonPropertyOrder;

@JsonPropertyOrder({"kty", "k"})
public class JWebKey {
	
	@JsonProperty("kty")
	private String keyType;
	
	@JsonProperty("k")
	private String key;

	public String getKeyType() {
		return keyType;
	}

	public void setKeyType(String keyType) {
		this.keyType = keyType;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	@Override
	public String toString() {
		return "JsonWebKey [keyType=" + keyType + ", key=" + key + "]";
	}
}
