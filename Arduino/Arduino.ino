#include <WiFiNINA.h>
#include <ArduinoHttpClient.h>
#include <Arduino_JSON.h>
#include <Arduino_MKRIoTCarrier.h>
#include "secrets.h"

MKRIoTCarrier carrier;
WiFiSSLClient secureClient;
HttpClient http(secureClient, BASE_URL, 443);

bool connectWifi() {
  if (WiFi.status() == WL_CONNECTED) return true;
  Serial.println("Forbinder til WiFi...");
  WiFi.begin(SECRET_SSID, SECRET_PASS);
  unsigned long started = millis();
  while (WiFi.status() != WL_CONNECTED &&
  millis() - started < 20000UL) {
    delay(250);
    Serial.print(".");
  }
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\nWiFi fejlede. Tjek navn og kode.");
    return false;
  }
  Serial.print("\nIP: ");
  Serial.println(WiFi.localIP());
  return true;
}

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
  pokemonSpriteUrl = textValue(obj["spriteUrl"]);
  Serial.println(pokemonSpriteUrl);

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

void showScreen(String title, String row1, String row2) {
  carrier.display.fillScreen(ST77XX_BLACK);
  carrier.display.setTextSize(2);
  carrier.display.setTextColor(ST77XX_WHITE);
  printLine(title, 60);
  printLine(row1, 100);
  printLine(row2, 135);
}

bool fetchPokemonBody(String& body) {
  if (!connectWifi()) return false;

  String path = "/go/pokemon/1";

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
    showScreen("Vent lidt", "Mindst 5 sek.", "mellem kald");
    return;
  }
  lastPokemonAt = millis();
  gettingPokemon = true;
  hasPokemon = false;
  showScreen("Henter data", "Vent...", "");
  String body;
  if (fetchPokemonBody(body) && parsePokemonData(body)) {
    gettingPokemon = false;
    showPokemon();
  } else {
    showScreen("Hentning fejlet", "Se Serial", "Tryk 0 igen");
  }
}

bool likeOrDislikePokemon(bool likeOrDislike) {
  if (!connectWifi()) return false;

  // /like-or-dislike/{id}
  String path = "/";
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

  // status = 400;

  if (status == 200) {
    return true;
  } else {
    return false;
  }
}

void showPokemon() {
  showScreen((String) pokemonId, pokemonName, "Like or Dislike");
}

String textValue(JSONVar value) {
 if (JSON.typeof(value) != "string") return "Ikke oplyst";
 String text = (const char*) value;
 return text.length() ? text : "Ikke oplyst";
}

void printLine(String text, int y) {
  text = text.substring(0, 14);
  int16_t x1, y1;
  uint16_t w, h;
  carrier.display.getTextBounds(text, 0, y, &x1, &y1, &w, &h);
  carrier.display.setCursor((240 - (int)w) / 2 - x1, y);
  carrier.display.print(text);
}

bool sendingLikeOrDislike = false;
void likesPokemon() {
  showScreen(
    "Sending like",
    pokemonName,
    (String) pokemonId
  );
  
  sendingLikeOrDislike = true;

  bool status = likeOrDislikePokemon(true);
  if (!status) {
    showScreen(
      "Fejl for like",
      pokemonName,
      (String) pokemonId
    );
  } else {
    showScreen("Pokemon", "Liked", "");
  }
  delay(2000);
  sendingLikeOrDislike = false;
  removePokemon();
}

void dislikesPokemon() {
  showScreen(
    "Sending dislike",
    pokemonName,
    (String) pokemonId
  );
  
  sendingLikeOrDislike = true;

  bool status = likeOrDislikePokemon(true);
  if (!status) {
    showScreen(
      "Fejl for dislike",
      pokemonName,
      (String) pokemonId
    );
  } else {
    showScreen("Pokemon", "Disliked", "");
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
  showScreen("Get pokemon", "press 00", "");
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

  bool connected = connectWifi();
  carrier.display.setRotation(0);
  carrier.display.setTextWrap(false);
  showScreen("Get pokemon", "press 00", "");
}

void loop() {
  carrier.Buttons.update();
  if (carrier.Buttons.onTouchDown(TOUCH0)) loadPokemon();

  if (!hasPokemon && !sendingLikeOrDislike) return;
  if (carrier.Buttons.onTouchDown(TOUCH3)) dislikesPokemon();
  if (carrier.Buttons.onTouchDown(TOUCH4)) likesPokemon();
}
