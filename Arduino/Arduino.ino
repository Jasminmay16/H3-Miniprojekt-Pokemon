#include <ArduinoHttpClient.h>
#include <Arduino_JSON.h>
#include <Arduino_MKRIoTCarrier.h>

#include "secrets.h"
#include "Wifi.h"
#include "ScreenManager.h"

MKRIoTCarrier carrier;
WiFiSSLClient secureClient;
HttpClient http(secureClient, BASE_URL, 443);

int pokemonId = 0;
bool hasPokemon = false;
String pokemonName = "";
String pokemonSpriteUrl = "";
bool parsePokemonData(const String& body) {
  JSONVar obj = JSON.parse(body);
  Serial.print("obj test: ");
  Serial.println(obj["name"]);

  if (JSON.typeof(obj) != "object") {
    Serial.println("Svaret er ikke et JSON-objekt.");
    return false;
  }

  pokemonName = textValue(obj["name"]);
  Serial.println(pokemonName);
/*   pokemonSpriteUrl = textValue(obj["spriteUrl"]);
  Serial.println(pokemonSpriteUrl); */

  bool hasIdNumber = JSON.typeof(obj["id"]) == "number";
  if (hasIdNumber) {
    pokemonId = obj["id"];
  } else {
    Serial.println("ID mangler");
    return false;
  }

  Serial.println(pokemonId);

  hasPokemon = true;
  return true;
}

bool fetchPokemonBody(String& body) {
  if (!WifiManager::connectWifi()) return false;

  String path = "/api/pokemon/random";

  http.stop();
  http.setHttpResponseTimeout(10000);
  http.beginRequest();
  int result = http.get(path);
  if (result != 0) {
    Serial.print("Forbindelsesfejl: ");
    Serial.println(result);
    http.stop();
    return false;
  }

  http.sendHeader("Accept", "application/json");
  http.sendHeader("Accept-Encoding", "identity");
  http.endRequest();

  int status = http.responseStatusCode();
  Serial.print("HTTP-status: ");
  Serial.println(status);
  if (status != 200) {
    if (status == 500) {
      ScreenManager::showScreen(carrier, "Error: 500", "Contact support", "");
    } else if (status == 400) {
      ScreenManager::showScreen(carrier, "Error: 400", "Bad request", "Check parameters");
    } else if (status == 401) {
      ScreenManager::showScreen(carrier, "Error: 401", "Unauthorized", "Not allowed");
    } else if (status == 403) {
      ScreenManager::showScreen(carrier, "Error: 403", "Forbidden", "Not allowed");
    } else if (status == 404) {
      ScreenManager::showScreen(carrier, "Error: 404", "Not Found", "");
    }
    delay(2000);
    return false;
  }

  if (http.contentLength() > 4096) {
    Serial.println("Svar for stort. Tjek data-filter.");
    http.stop();
    return false;
  }
  
  body = http.responseBody();
  http.stop();
  if (body.length() == 0) {
    Serial.println("Tomt");
    return false;
  }
  if (body.length() > 4096) {
    Serial.println("Tomt, afbrudt eller for stort svar.");
    return false;
  }
  return true;
}

bool gettingPokemon = false;
unsigned long lastPokemonAt = 0;
void loadPokemon() {
  if (gettingPokemon && millis() - lastPokemonAt < 5000UL) {
    ScreenManager::showScreen(carrier, "Vent lidt", "Mindst 5 sek.", "mellem kald");
    return;
  }
  lastPokemonAt = millis();
  gettingPokemon = true;
  hasPokemon = false;
  ScreenManager::showScreen(carrier, "Henter data", "Vent...", "");
  String body;
  if (fetchPokemonBody(body) && parsePokemonData(body)) {
    gettingPokemon = false;
    showPokemon();
  } else {
    ScreenManager::showScreen(carrier, "Hentning fejlet", "Se Serial", "Tryk 0 igen");
  }
}

bool likeOrDislikePokemon(bool likeOrDislike) {
  if (!WifiManager::connectWifi()) return false;

  // /like-or-dislike/{id}
  String path = "/api/pokemon/";
  path += likeOrDislike ? "like" : "dislike";
  path += "/";
  path += (String) pokemonId;

  http.stop();
  http.setHttpResponseTimeout(10000);
  http.beginRequest();
  int result = http.get(path);
  if (result != 0) {
    Serial.print("Forbindelsesfejl: ");
    Serial.println(result);
    http.stop();
    return false;
  }

  http.sendHeader("Accept", "application/json");
  http.sendHeader("Accept-Encoding", "identity");
  http.endRequest();

  int status = http.responseStatusCode();
  Serial.print("HTTP-status: ");
  Serial.println(status);

  if (status != 200) {
    if (status == 500) {
      ScreenManager::showScreen(carrier, "Error: 500", "Contact support", "");
    } else if (status == 400) {
      ScreenManager::showScreen(carrier, "Error: 400", "Bad request", "Check parameters");
    } else if (status == 401) {
      ScreenManager::showScreen(carrier, "Error: 401", "Unauthorized", "Not allowed");
    } else if (status == 403) {
      ScreenManager::showScreen(carrier, "Error: 403", "Forbidden", "Not allowed");
    } else if (status == 404) {
      ScreenManager::showScreen(carrier, "Error: 404", "Not Found", "");
    }
    return false;
  } else {
    return true;
  }
}

void showPokemon() {
  ScreenManager::showScreen(carrier, (String) pokemonId, pokemonName, "Like or Dislike");
}

String textValue(JSONVar value) {
 if (JSON.typeof(value) != "string") return "Ikke oplyst";
 String text = (const char*) value;
 return text.length() ? text : "Ikke oplyst";
}

bool sendingLikeOrDislike = false;
void likesPokemon() {
  ScreenManager::showScreen(
    carrier,
    "Sending like",
    pokemonName,
    (String) pokemonId
  );
  
  sendingLikeOrDislike = true;

  bool status = likeOrDislikePokemon(true);
  if (status) {
    ScreenManager::showScreen(carrier, "Pokemon", "Liked", "");
  }
  delay(2000);
  sendingLikeOrDislike = false;
  removePokemon();
}

void dislikesPokemon() {
  ScreenManager::showScreen(
    carrier,
    "Sending dislike",
    pokemonName,
    (String) pokemonId
  );
  
  sendingLikeOrDislike = true;

  bool status = likeOrDislikePokemon(false);
  if (status) {
    ScreenManager::showScreen(carrier, "Pokemon", "Disliked", "");
  }
  delay(2000);
  sendingLikeOrDislike = false;
  removePokemon();
}

void removePokemon() {
  pokemonId = 0;
  pokemonName = "";
  pokemonSpriteUrl = "";
  hasPokemon = false;
  ScreenManager::showScreen(carrier, "Get pokemon", "press 00", "");
}

void setup() {
  Serial.begin(9600);
  unsigned long started = millis();
  while (!Serial && millis() - started < 3000UL) {}

  carrier.noCase();
  if (!carrier.begin()) {
    Serial.println("Carrier kunne ikke starte.");
    while (true) { delay(100); }
  }

  bool connected = WifiManager::connectWifi();
  carrier.display.setRotation(0);
  carrier.display.setTextWrap(false);
  if (connected) {
    ScreenManager::showScreen(carrier, "Get pokemon", "press 00", "");
  }
}

void loop() {
  carrier.Buttons.update();
  if (!hasPokemon && carrier.Buttons.onTouchDown(TOUCH0)) loadPokemon();

  if (!hasPokemon && !sendingLikeOrDislike) return;
  if (carrier.Buttons.onTouchDown(TOUCH3)) dislikesPokemon();
  if (carrier.Buttons.onTouchDown(TOUCH4)) likesPokemon();
}
