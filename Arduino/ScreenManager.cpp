#include "ScreenManager.h"
#include <Arduino_MKRIoTCarrier.h>

void printLine(MKRIoTCarrier& carrier, String text, int y) {
  text = text.substring(0, 14);
  int16_t x1, y1;
  uint16_t w, h;
  carrier.display.getTextBounds(text, 0, y, &x1, &y1, &w, &h);
  carrier.display.setCursor((240 - (int)w) / 2 - x1, y);
  carrier.display.print(text);
}

void showScreen(MKRIoTCarrier& carrier, String title, String row1, String row2) {
  carrier.display.fillScreen(ST77XX_BLACK);
  carrier.display.setTextSize(2);
  carrier.display.setTextColor(ST77XX_WHITE);
  printLine(title, 60);
  printLine(row1, 100);
  printLine(row2, 135);
}