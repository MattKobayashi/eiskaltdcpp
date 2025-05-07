# Changelog

## [2.4.2+devel](https://github.com/MattKobayashi/eiskaltdcpp/compare/v2.4.1+devel...v2.4.2+devel) (2025-05-07)


### Bug Fixes

* **file:** cache stat() results in FileFindIter::DirData on non-Windows ([edf81c3](https://github.com/MattKobayashi/eiskaltdcpp/commit/edf81c39815a9d2ca6ec6ad67228552bb6520f8b))
* **security:** Incorrect return-value check for a 'scanf'-like function ([#11](https://github.com/MattKobayashi/eiskaltdcpp/issues/11)) ([f758780](https://github.com/MattKobayashi/eiskaltdcpp/commit/f758780bddb7470bb2d98496bba659d60ae972e1))
* **security:** Potentially overflowing call to snprintf ([#5](https://github.com/MattKobayashi/eiskaltdcpp/issues/5)) ([68caede](https://github.com/MattKobayashi/eiskaltdcpp/commit/68caedee26713e5656bd1ec698b8d36c26971569))
* **security:** Potentially overflowing call to snprintf ([#8](https://github.com/MattKobayashi/eiskaltdcpp/issues/8)) ([beac007](https://github.com/MattKobayashi/eiskaltdcpp/commit/beac0078750c683d0ca1db04633dafe34b721315))
* **security:** Time-of-check time-of-use filesystem race condition ([#10](https://github.com/MattKobayashi/eiskaltdcpp/issues/10)) ([a3eef57](https://github.com/MattKobayashi/eiskaltdcpp/commit/a3eef57886054ca57b59f4e54063106724a55a9d))
* **security:** Time-of-check time-of-use filesystem race condition ([#9](https://github.com/MattKobayashi/eiskaltdcpp/issues/9)) ([dcc0306](https://github.com/MattKobayashi/eiskaltdcpp/commit/dcc03064b5754bf14da61e08032c21123ed6d300))
* **security:** Wrong type of arguments to formatting function ([#6](https://github.com/MattKobayashi/eiskaltdcpp/issues/6)) ([157e98f](https://github.com/MattKobayashi/eiskaltdcpp/commit/157e98f8c844a12339886070d879d92267489319))
* **security:** Wrong type of arguments to formatting function ([#7](https://github.com/MattKobayashi/eiskaltdcpp/issues/7)) ([7284706](https://github.com/MattKobayashi/eiskaltdcpp/commit/728470626c08f3a35ca8979e04390f7043cae8cc))
* **text:** skip iconv if encodings match on non-Windows ([d5de873](https://github.com/MattKobayashi/eiskaltdcpp/commit/d5de873066870a2e0f8b10994124ac135dff6afa))
