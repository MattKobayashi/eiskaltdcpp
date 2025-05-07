# Changelog

## [2.4.2+devel](https://github.com/MattKobayashi/eiskaltdcpp/compare/v2.4.1+devel...v2.4.2+devel) (2025-05-07)


### Bug Fixes

* **file:** cache stat() results in FileFindIter::DirData on non-Windows ([edf81c3](https://github.com/MattKobayashi/eiskaltdcpp/commit/edf81c39815a9d2ca6ec6ad67228552bb6520f8b))
* **security:** Incorrect return-value check for a 'scanf'-like function ([#11](https://github.com/MattKobayashi/eiskaltdcpp/issues/11)) ([5adb12c](https://github.com/MattKobayashi/eiskaltdcpp/commit/5adb12c80c47366aae63645b52930149904615df))
* **security:** Potentially overflowing call to snprintf ([#5](https://github.com/MattKobayashi/eiskaltdcpp/issues/5)) ([f48b116](https://github.com/MattKobayashi/eiskaltdcpp/commit/f48b11612e535aed17b71358319406ff6803a130))
* **security:** Potentially overflowing call to snprintf ([#8](https://github.com/MattKobayashi/eiskaltdcpp/issues/8)) ([b3b8ac6](https://github.com/MattKobayashi/eiskaltdcpp/commit/b3b8ac69f4f69ef0e6708e5a2a98ea46869ce787))
* **security:** Time-of-check time-of-use filesystem race condition ([#10](https://github.com/MattKobayashi/eiskaltdcpp/issues/10)) ([0da8e23](https://github.com/MattKobayashi/eiskaltdcpp/commit/0da8e23dc1b013d8291481fce88cac72070d4909))
* **security:** Time-of-check time-of-use filesystem race condition ([#9](https://github.com/MattKobayashi/eiskaltdcpp/issues/9)) ([3fb5d9b](https://github.com/MattKobayashi/eiskaltdcpp/commit/3fb5d9ba5ab1b6ce5257dd80bc9861b540fa2b00))
* **security:** Wrong type of arguments to formatting function ([#6](https://github.com/MattKobayashi/eiskaltdcpp/issues/6)) ([23f1990](https://github.com/MattKobayashi/eiskaltdcpp/commit/23f199074ad3d36a964a422af6da2ce01d16326a))
* **security:** Wrong type of arguments to formatting function ([#7](https://github.com/MattKobayashi/eiskaltdcpp/issues/7)) ([0a950a0](https://github.com/MattKobayashi/eiskaltdcpp/commit/0a950a0d37711c4419d0f6e1245be6c10f61715d))
* **text:** skip iconv if encodings match on non-Windows ([d5de873](https://github.com/MattKobayashi/eiskaltdcpp/commit/d5de873066870a2e0f8b10994124ac135dff6afa))
