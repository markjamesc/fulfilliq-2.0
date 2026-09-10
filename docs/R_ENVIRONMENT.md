# Reported R environment

Recorded from owner-provided R console screenshots on September 10, 2026.

## R session

| Item | Reported value |
|---|---|
| R version | 4.0.3 (2020-10-10) |
| Platform | i386-w64-mingw32/i386 (32-bit) |
| Operating system reported by R | Windows 10 x64 (build 26200) |

## Installed packages

| Package | Installed version |
|---|---|
| dplyr | 1.0.8 |
| janitor | 2.1.0 |
| lubridate | 1.8.0 |
| purrr | 0.3.4 |
| readr | 2.1.2 |
| tidyr | 1.2.0 |
| tidyverse | 2.0.0 |

These versions were listed by `installed.packages()`. The separate `sessionInfo()` screenshot showed only base packages attached and the compiler namespace loaded.

## Interpretation and remaining verification

This is a record of the reported current installation, not a complete dependency lock or proof of the original execution environment. Installed-package metadata does not show that these packages can load together or that the committed R(B) script has successfully run in this installation.

A fresh reproduction should record `sessionInfo()` after loading the project packages and completing the run, together with its output comparison. Additional dependency versions and a successful run remain to be captured.

See [the reproduction guide](REPRODUCING.md) for the frozen-input and execution steps.

## Separate successful reproduction

A fresh run on September 10, 2026 used R 4.3.3 on 64-bit Ubuntu and reproduced the published R(B) CSV byte-for-byte. The [execution evidence](../validation/reproduction-2026-09-10/README.md), [loaded session](../validation/reproduction-2026-09-10/sessionInfo.txt), and [installed package inventory](../validation/reproduction-2026-09-10/installed_packages.csv) record that environment separately from the owner-reported installation above. The historical Windows environment has not been recreated.
