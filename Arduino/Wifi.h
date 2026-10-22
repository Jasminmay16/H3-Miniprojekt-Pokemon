// Wifi.h
#pragma once
#include <WiFiNINA.h>

namespace WifiManager {

inline bool connectWifi() {
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

}  // namespace Wifi