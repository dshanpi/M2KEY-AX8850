# ax8850-hg4xh08g-ddr-config

AX8850 M.2 算力卡 HG4XH08G-H4JA DDR 适配配置，基于 AX650 SDK V3.16.0，支持单颗 8GB 和双颗 16GB。

这里保存当前已适配 SDK 中的完整文件副本。`8GB/` 和 `16GB/` 内部的路径均与 SDK 根目录下的路径一致，每个版本各 12 个文件。

## 版本对应

| 仓库目录 | 对应 SDK 目录 | DDR 连接 | DDR_NUM | 当前速率 | OS 内存 | CMM 内存 |
| --- | --- | --- | --- | --- | --- | --- |
| `8GB/` | `[AX650_SDK_V3.16.0_20260904151204](https://huggingface.co/AXERA-TECH/AX650-Community-Hub/resolve/main/sdk/edge-computing-AX650_SDK_V3.16.0/02.SDK/AX650_SDK_V3.16.0_8G/AX650_SDK_V3.16.0_20260904151204.tgz?download=true)` | 单颗，DDR0 | 1 | 3200 MT/s | 1152 MiB | 7040 MiB |
| `16GB/` | `[AX650_SDK_V3.16.0_20260901150323](https://huggingface.co/AXERA-TECH/AX650-Community-Hub/resolve/main/sdk/edge-computing-AX650_SDK_V3.16.0/02.SDK/AX650_SDK_V3.16.0_16G/AX650_SDK_V3.16.0_20260901150323.tgz?download=true)` | 双颗，DDR0 + DDR1 | 2 | 3200 MT/s | 1152 MiB | 15232 MiB |

两套配置当前均使用 LPDDR4X、`curr_rank_num = 2`。这里记录的是 SDK 实际采用的配置值，原样保留源码，便于复现当前版本。

## 目录结构

以下结构在 `8GB/` 和 `16GB/` 中各保存一份：

```text
8GB/ 或 16GB/
├── build/
│   └── projects/
│       └── AX650_card.mak
├── boot/
│   ├── bl1/
│   │   ├── spl/
│   │   │   └── Makefile
│   │   └── driver/
│   │       ├── ddr/
│   │       │   └── ax650x_lpddr4x.c
│   │       └── include/
│   │           ├── hg4xh08g_h4ja.h
│   │           ├── ax650x_lpddr4x.h
│   │           ├── ddrc_init.h
│   │           └── ddrphy_init.h
│   └── uboot/
│       ├── Makefile
│       └── u-boot-2020.04/
│           └── drivers/ddr/axera/
│               ├── hg4xh08g_h4ja.h
│               ├── ax650x_lpddr4x.h
│               └── ddrc_init.h
└── kernel/
    └── linux/linux-5.15.73/arch/arm64/boot/dts/axera/
        └── AX650_card.dts
```

## 配置入口

`build/projects/AX650_card.mak` 设置适配宏：

```makefile
# 8GB 目录中的值
AX650_HG4XH08G_H4JA_CHIPS := 1

# 16GB 目录中的值
AX650_HG4XH08G_H4JA_CHIPS := 2
```

`boot/bl1/spl/Makefile` 和 `boot/uboot/Makefile` 将这个宏传给编译器。SPL 与 U-Boot 各自的 `ax650x_lpddr4x.h` 包含适配头文件 `hg4xh08g_h4ja.h`，由其覆盖默认颗数和速率：

```c
#undef DDR_NUM
#define DDR_NUM AX650_HG4XH08G_H4JA_CHIPS

#define DDR_CFG_2133 0
#define DDR_CFG_3200 1
#define DDR_CFG_3733 0
#define DDR_CFG_4266 0
```

因此，应通过项目配置中的 `AX650_HG4XH08G_H4JA_CHIPS` 查看和设置颗数。`ax650x_lpddr4x.h` 前面的默认 `DDR_NUM` 会被适配头文件覆盖。

`ddrc_init.h` 保存控制器参数与地址映射；SPL 的 `ddrphy_init.h` 保存 PHY 适配修改；`ax650x_lpddr4x.c` 选择适配参数、执行训练并设置交织模式。单颗使用模式 0，双颗使用模式 3。

`AX650_card.mak` 同时保留当前 SDK 的 OS/CMM 内存及打包选项。设备树 `AX650_card.dts` 分别配置 8GB 和 16GB 内存范围；16GB 设备树沿用该 SDK 已有配置，一并收录以方便对照和恢复。

## 放回对应 SDK

先保存目标 SDK 中需要保留的本地修改，再选择与板卡容量、SDK 版本一致的一组覆盖。目标 SDK 应已完成源码解包，包含 U-Boot 和 Linux 源码目录。

8GB：

```bash
repo="$HOME/AX650/push/ax8850-hg4xh08g-ddr-config"
sdk="$HOME/AX650/AX650_SDK_V3.16.0_20260904151204"
cp -a "$repo/8GB/." "$sdk/"
```

16GB：

```bash
repo="$HOME/AX650/push/ax8850-hg4xh08g-ddr-config"
sdk="$HOME/AX650/AX650_SDK_V3.16.0_20260901150323"
cp -a "$repo/16GB/." "$sdk/"
```

覆盖后按 SDK 编译流程重建 `AX650_card`，使 SPL、U-Boot、设备树和固件包使用同一套配置。本仓库收录 DDR 相关源文件，编译环境与其余 SDK 文件由对应 SDK 提供。

## 文件校验

在仓库根目录执行，可校验全部 24 个 SDK 文件：

```bash
sha256sum -c SHA256SUMS
```

SDK 文件保留各自原有的版权与许可声明。
