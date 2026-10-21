#include <WiFiNINA.h>
#include <ArduinoHttpClient.h>
#include <Arduino_JSON.h>
#include <Arduino_MKRIoTCarrier.h>
#include "secrets.h"

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

bool hasPokemon = false;
bool gettingPokemon = false;
int pokemonId = 0;
char* pokemonName = "";
char* pokemonSpriteUrl = "";
void getPokemon() {
  if (!connectWifi()) return false;

  String path = BASE_URL;

  http.stop();
  http.setHttpResponseTimeout(10000);
  http.beginRequest();

  http.sendHeader("Accept", "application/json");
  http.sendHeader("Accept-Encoding", "identity");
  http.endRequest();

  int status = http.responseStatusCode();
  Serial.print("HTTP-status: ");
  Serial.println(status);
}

void showScreen(String title, String row1, String row2) {
  carrier.display.fillScreen(ST77XX_BLACK);
  carrier.display.setTextSize(2);
  carrier.display.setTextColor(ST77XX_WHITE);
  printLine(title, 50);
  printLine(row1, 100);
  printLine(row2, 135);
  carrier.display.setTextColor(ST77XX_CYAN);
  printLine("0: nye data", 185);
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
  showScreen("Pokemon API",
  connected ? "WiFi klar" : "WiFi fejlede", "Tryk TOUCH0");
}

void loop() {
  carrier.Buttons.update();
  if (carrier.Buttons.onTouchDown(TOUCH0)) getPokemon();
  if (carrier.Buttons.onTouchDown(TOUCH3)) dislikesPokemon();
  if (carrier.Buttons.onTouchDown(TOUCH4)) likesPokemon();
}
