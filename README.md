# ffmpeg-mini

Stripped-down, minimal static build of FFmpeg and ffprobe container image. Designed specifically for [Vidme](https://github.com/computindo/vidme) to minimize image footprint (<25MB) and reduce idle overhead.

## Enabled Capabilities
- **Decoders:** H.264, HEVC, AAC, MJPEG
- **Encoders:** H.264 (`libx264`), MJPEG
- **Demuxers:** MP4/MOV (`mov,mp4,m4a,3gp,3g2,mj2`), WebM/MKV (`matroska,webm`), Image2, Concat
- **Muxers:** MP4, WebM, Matroska, Image2
- **Filters:** `scale`, `crop`, `split`, `select`, `xstack` (2x2 storyboard), `fps`, `format`, `setsar`, `setpts`, `concat` (montage preview)
- **Protocols:** `file`, `pipe`

## Usage in Dockerfile
```dockerfile
FROM ghcr.io/computindo/ffmpeg-mini:latest AS ffmpeg-bin

FROM alpine:3.20
COPY --from=ffmpeg-bin /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ffmpeg-bin /usr/local/bin/ffprobe /usr/local/bin/ffprobe
```
