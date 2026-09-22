/* HG4XH08G-H4JA bring-up profile; board validation is still required.
 * Each package: 8 GiB, two x16 channels, two ranks per channel.
 * Use the SDK 3200 MT/s training set until the datasheet timing errata
 * and refresh parameters have been confirmed by the memory supplier.
 */
#ifdef AX650_HG4XH08G_H4JA_CHIPS
#if AX650_HG4XH08G_H4JA_CHIPS != 1 && AX650_HG4XH08G_H4JA_CHIPS != 2
#error "HG4XH08G-H4JA requires one DDR0 package or DDR0 plus DDR1"
#endif
#if defined(CFG_DDR_NUM_CMDLINE) || defined(CFG_DDR_CLK_CMDLINE)
#error "Do not combine the HG4X profile with ddr_num/ddr_clk overrides"
#endif
#undef DDR_NUM
#define DDR_NUM AX650_HG4XH08G_H4JA_CHIPS
#undef DDR_CFG_2133
#undef DDR_CFG_3200
#undef DDR_CFG_3733
#undef DDR_CFG_4266
#define DDR_CFG_2133 0
#define DDR_CFG_3200 1
#define DDR_CFG_3733 0
#define DDR_CFG_4266 0
#endif
