import {
  Callout,
  Card,
  CardBody,
  CardHeader,
  Divider,
  Grid,
  H1,
  H2,
  H3,
  Pill,
  Row,
  Stack,
  Stat,
  Table,
  Text,
  useHostTheme,
} from "cursor/canvas";

export default function HdmiPassthroughArchitecture() {
  const theme = useHostTheme();

  return (
    <Stack gap={24} style={{ maxWidth: 980 }}>
      <Stack gap={8}>
        <H1>HDMI 音频透传方案</H1>
        <Text tone="secondary">
          给老板评估用。对方给的是 SPDIF 透传补丁；HDMI 是仿照同一条
          nNeedDirect 分支，只换最后一公里 sink。对照备份：透传/ 补丁 +
          成功但卡顿快照。当前工程树未合入。
        </Text>
      </Stack>

      <Grid columns={3} gap={12}>
        <Stat value="nNeedDirect" label="透传总开关，Player 按 codec 置位" />
        <Stat value="5 层" label="Parser → Player → 假解码 → IEC61937 → Sink" />
        <Stat value="HDMI 只换 sink" label="打包层与 SPDIF 共用，不另做解码" />
      </Grid>

      <Callout tone="warning" title="评估时先看这个分支，不要只看 HDMI 设备名">
        透传不是 HDMI 驱动旁路。PlayerSetAudioStreamInfo 把 AC3/EAC3/DTS 标成
        nNeedDirect=1 之后，解码器不再 dlopen libadecoder.so，改挂
        adecoderPassthough（原样排队）。这个开关错了，AAC/MP4 也会走假解码，声音会低沉或怪。
      </Callout>

      <H2>端到端链路</H2>
      <PipelineSvg />

      <H2>nNeedDirect 分叉（方案关键）</H2>
      <Grid columns={2} gap={12}>
        <Card>
          <CardHeader trailing={<Pill tone="neutral" size="sm">nNeedDirect = 0</Pill>}>
            PCM 正常路
          </CardHeader>
          <CardBody>
            <Stack gap={6}>
              <Text>AudioDecCompCreate 打开 libadecoder.so，真解码成 PCM</Text>
              <Text>EQ / 增益 / surround / amix 全开</Text>
              <Text>HDMI 走 PlaybackHDMI，mixer 保持 PCM</Text>
              <Text>AAC、MP3、普通 MP4 必须走这条</Text>
            </Stack>
          </CardBody>
        </Card>
        <Card>
          <CardHeader trailing={<Pill tone="info" size="sm">nNeedDirect = 1</Pill>}>
            Raw 透传路
          </CardHeader>
          <CardBody>
            <Stack gap={6}>
              <Text>AudioDecCompCreate 挂 adec_passth，不解码</Text>
              <Text>跳过 EQ / 增益 / amix（direct_mode）</Text>
              <Text>sunxi_passthough 打 IEC61937 burst</Text>
              <Text>HDMI：mixer 设 AC3/DTS/DDP，写 hw:sndi2s2</Text>
            </Stack>
          </CardBody>
        </Card>
      </Grid>

      <H2>五层各自干什么</H2>
      <Table
        headers={["层", "文件 / 补丁", "做什么", "谁加的"]}
        columnAlign={["left", "left", "left", "left"]}
        rows={[
          [
            "1 Parser",
            "cedarx.diff：mkv / mov / ts",
            "EAC3 必须识别成 EAC3，不能再并到 AC3。否则后面 nDataType 会错，IEC 打包和 HDMI mixer 都会跟错。",
            "对方补丁",
          ],
          [
            "2 Player 置位",
            "player.c PlayerSetAudioStreamInfo",
            "AC3→raw AC3；EAC3→DDP；DTS→DTS；并置 nNeedDirect=1。PlayerInitialAudio 把这个值传给 AudioDecCompCreate。",
            "对方补丁",
          ],
          [
            "3 假解码器",
            "adecoderPassthough.c",
            "接口形状和真解码器一样，但 Decode 只是把 bitstream 排队交给 Render。Create 时 isNeedDirect==1 走 memcpy(&AlibItf, &adec_passth)。",
            "对方补丁",
          ],
          [
            "4 IEC61937",
            "SunxiPassthough + SPDIFEncoder",
            "扫 AC3/DTS 帧，加 Pa/Pb 前导，打成 IEC burst。HDMI 和 SPDIF 共用这一层——HDMI 透传也是 IEC 60958/61937。",
            "对方补丁",
          ],
          [
            "5 Sink",
            "tsound_ctrl.c + libaudioroute.diff",
            "SPDIF：PlaybackSPDIF。HDMI（仿写）：读 /etc/audio_output.mode，setHdmiRawFlag，开 hw:sndi2s2/sndhdmi，按 period 切片写。关设备时 mixer 拉回 PCM。",
            "HDMI 是仿写",
          ],
        ]}
      />

      <H2>codec → 输出参数</H2>
      <Table
        headers={["容器 codec", "nDataType", "IEC 采样率", "period_size", "HDMI mixer"]}
        columnAlign={["left", "left", "right", "right", "left"]}
        rows={[
          ["AC3", "AUDIO_RAW_DATA_AC3", "48000", "1536", "AC3"],
          ["EAC3", "AUDIO_RAW_DATA_DOLBY_DIGITAL_PLUS", "192000", "1536", "DOLBY_DIGITAL_PLUS"],
          ["EAC3_JOC", "AUDIO_RAW_DATA_EAC3_JOC", "192000", "1536", "DOLBY_DIGITAL_PLUS"],
          ["DTS / DTS_HD", "AUDIO_RAW_DATA_DTS / DTS_HD", "48000", "512", "DTS"],
          ["AAC 等其它", "不置位，保持 PCM", "片源采样率", "默认", "PCM"],
        ]}
      />

      <H2>HDMI 相对 SPDIF，只多了什么</H2>
      <Text tone="secondary">
        前四层不动。仿写集中在 tsound_ctrl 的 ALSALIB 路径。
      </Text>
      <Table
        headers={["点", "对方 SPDIF", "仿写 HDMI"]}
        rows={[
          ["路由", "PlaybackSPDIF", "/etc/audio_output.mode：spdif / hdmi / dual"],
          ["设备", "PlaybackSPDIF", "hw:sndi2s2,0，失败再 hw:sndhdmi,0"],
          ["硬件格式", "SPDIF 口默认吃 IEC", "setHdmiRawFlag：audio data format = AC3/DTS/DDP"],
          ["写数据", "IEC burst 一次写", "HDMI 按 period_size 切片写"],
          ["退出", "关 passth", "mixer 强制拉回 PCM，防下一首 AAC 还走 raw"],
        ]}
      />

      <Divider />

      <H2>给老板的判断点</H2>
      <Grid columns={2} gap={12}>
        <Card>
          <CardHeader>方向对</CardHeader>
          <CardBody>
            <Stack gap={6}>
              <Text>原厂头文件已预留 nRoutine：0=PCM，1=HDMI raw，2=SPDIF raw。方案对齐这个语义。</Text>
              <Text>HDMI 音频透传行业惯例就是 IEC61937 over HDMI，不必另做一套打包。</Text>
              <Text>PCM 和 raw 在 Player 入口就分叉，后面各层只读 nNeedDirect，链路清楚。</Text>
            </Stack>
          </CardBody>
        </Card>
        <Card>
          <CardHeader>这版快照的风险</CardHeader>
          <CardBody>
            <Stack gap={6}>
              <Text>能出声，但卡顿；MP4 声音低沉。优先查 PCM 回退是否干净：mixer 残留 raw、period/start_threshold 污染 PCM 路。</Text>
              <Text>nNeedDirect 误置 = 假解码器吃 AAC，听感就是闷、低、不同步。</Text>
              <Text>EAC3 走 192 kHz。Parser 若仍把 A_EAC3 并成 AC3，HDMI mixer 和 IEC 会各说各话。</Text>
            </Stack>
          </CardBody>
        </Card>
      </Grid>

      <H3>合入范围（评估用，未改当前工程）</H3>
      <Text tone="secondary">
        对方：cedarx.diff、adecoderPassthough.c、tsound_ctrl.diff、libaudioroute.diff、spdif/。
        仿写：tsound_ctrl.c 的 HDMI 路由、mixer、hw:sndi2s2、IEC 切片写。
      </Text>
    </Stack>
  );
}

function PipelineSvg() {
  const theme = useHostTheme();
  const box = theme.fill.secondary;
  const line = theme.stroke.primary;
  const accent = theme.accent.primary;
  const ink = theme.text.primary;
  const mute = theme.text.secondary;

  return (
    <svg
      viewBox="0 0 920 220"
      width="100%"
      role="img"
      aria-label="HDMI audio passthrough pipeline"
      style={{ display: "block" }}
    >
      <text x="0" y="16" fill={mute} fontSize="11">
        同一条主干；HDMI / SPDIF 只在最后分叉
      </text>

      <PipeBox x={0} y={40} w={150} h={70} fill={box} stroke={line} title="Parser" sub="mkv / mov / ts" ink={ink} mute={mute} />
      <Arrow x1={150} x2={178} y={75} stroke={line} />
      <PipeBox x={178} y={40} w={168} h={70} fill={box} stroke={accent} title="Player 置位" sub="nNeedDirect + nDataType" ink={ink} mute={mute} />
      <Arrow x1={346} x2={374} y={75} stroke={line} />
      <PipeBox x={374} y={40} w={168} h={70} fill={box} stroke={line} title="假解码器" sub="adecoderPassthough" ink={ink} mute={mute} />
      <Arrow x1={542} x2={570} y={75} stroke={line} />
      <PipeBox x={570} y={40} w={150} h={70} fill={box} stroke={line} title="IEC61937" sub="SPDIFEncoder 共用" ink={ink} mute={mute} />
      <Arrow x1={720} x2={748} y={75} stroke={line} />
      <PipeBox x={748} y={18} w={168} h={52} fill={box} stroke={accent} title="HDMI sink" sub="mixer + hw:sndi2s2" ink={ink} mute={mute} />
      <PipeBox x={748} y={80} w={168} h={52} fill={box} stroke={line} title="SPDIF sink" sub="PlaybackSPDIF" ink={ink} mute={mute} />

      <path d="M720 75 L734 75 L734 44 L748 44" fill="none" stroke={line} strokeWidth="1.5" />
      <path d="M720 75 L734 75 L734 106 L748 106" fill="none" stroke={line} strokeWidth="1.5" />

      <text x={178} y={140} fill={accent} fontSize="11">
        关键分叉在这里，不在 HDMI 驱动
      </text>
      <text x={0} y={180} fill={mute} fontSize="11">
        nNeedDirect=0 时第 3 层改走 libadecoder.so，第 4 层不打 IEC，第 5 层走 PCM 设备
      </text>
    </svg>
  );
}

function PipeBox({
  x,
  y,
  w,
  h,
  fill,
  stroke,
  title,
  sub,
  ink,
  mute,
}: {
  x: number;
  y: number;
  w: number;
  h: number;
  fill: string;
  stroke: string;
  title: string;
  sub: string;
  ink: string;
  mute: string;
}) {
  return (
    <g>
      <rect x={x} y={y} width={w} height={h} rx={4} fill={fill} stroke={stroke} />
      <text x={x + 10} y={y + 28} fill={ink} fontSize="13" fontWeight={600}>
        {title}
      </text>
      <text x={x + 10} y={y + 48} fill={mute} fontSize="11">
        {sub}
      </text>
    </g>
  );
}

function Arrow({
  x1,
  x2,
  y,
  stroke,
}: {
  x1: number;
  x2: number;
  y: number;
  stroke: string;
}) {
  return (
    <line x1={x1} y1={y} x2={x2} y2={y} stroke={stroke} strokeWidth="1.5" />
  );
}
