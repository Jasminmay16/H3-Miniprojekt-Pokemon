#include <Arduino_MKRIoTCarrier.h>
#include "Arduino.h"

#include "ScreenManager.h"

// Putting the function inside of an anonymous namepsace makes it only available to this file. Kinda making it private.
namespace {
  void printLine(MKRIoTCarrier& carrier, String text, int y) {
    text = text.substring(0, 14);
    int16_t x1, y1;
    uint16_t w, h;
    carrier.display.getTextBounds(text, 0, y, &x1, &y1, &w, &h);
    carrier.display.setCursor((240 - (int)w) / 2 - x1, y);
    carrier.display.print(text);
  }
}

void ScreenManager::showScreen(MKRIoTCarrier& carrier, String title, String row1, String row2) {
  carrier.display.fillScreen(ST77XX_BLACK);
  carrier.display.setTextSize(2);
  carrier.display.setTextColor(ST77XX_WHITE);
  printLine(carrier, title, 60);
  printLine(carrier, row1, 100);
  printLine(carrier, row2, 135);
}