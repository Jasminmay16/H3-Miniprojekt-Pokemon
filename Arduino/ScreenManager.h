#ifndef SCREEN_MANAGER_H
#define SCREEN_MANAGER_H

#include <Arduino.h>

class MKRIoTCarrier;

// Wrapping it around a namespace makes it easier to know where we are calling a function from.
namespace ScreenManager {
  void showScreen(MKRIoTCarrier& carrier, String title, String row1, String row2);
}

#endif