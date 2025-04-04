#include <windows.h>
#include <iostream>

void EnvUpdate() {
    LPARAM lParam = reinterpret_cast<LPARAM>(TEXT("Environment"));
    DWORD_PTR result;
    SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0, lParam, SMTO_ABORTIFHUNG, 5000, &result);
}

int main() {
    EnvUpdate();
    return 0;
}
