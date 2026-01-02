@echo off
echo Made by @dalked (Dalk21/TWCDalk/Dalk). By using this script, you are abiding by the terms of the AGPL license attached to this toolkit.

set /p song_name=Enter the song filename (ex. Really Cool Wig.mp3): 
set /p duration=Enter duration in seconds (optional, default is 65): 
if "%duration%"=="" set duration=65

set "input_wav=%song_name%"
for %%F in ("%song_name%") do set "clean_name=%%~nF"
set "output_ts=OUT_LOT8_%clean_name%.ts"
set "input_image=LOT8_HD.png"
set "logo_wav=LOT8_SonicLogo.wav"
set "combined_wav=combined_audio.wav"

ffmpeg -y -i "%logo_wav%" -i "%input_wav%" -filter_complex "[0:0][1:0]concat=n=2:v=0:a=1[outa]" -map "[outa]" "%combined_wav%"

ffmpeg -err_detect aggressive -loop 1 -i "%input_image%" -re -f lavfi -i anullsrc=r=48000:cl=stereo -i "%combined_wav%" ^
-streamid 0:7680 -streamid 2:4128 ^
-filter_complex "[2:a]volume=0.3[aud]; [0:v]scale=720:480[b]; [b]fps=30000/1001,fieldorder=tff[outv]" ^
-map "[outv]" -map "[aud]" ^
-c:v libx264 -profile:v main -level 3.1 -b:v 5M -maxrate 5M -bufsize 1M -aspect 4:3 -pix_fmt yuv420p ^
-flags +ilme+ildct -bsf:v h264_mp4toannexb -flush_packets 0 -fflags +genpts ^
-c:a ac3 -b:a 256k -ac 2 -ar 48000 ^
-t %duration% -f mpegts -muxrate 10M -pcr_period 20 -pat_period 0.10 -sdt_period 0.25 ^
-metadata service_provider="GitHub" -metadata service_name="i2LOT8sMusic" -metadata title="LOT8s Music Script" -metadata:s:a:0 language=eng ^
-preset superfast -mpegts_flags +pat_pmt_at_frames "%output_ts%"

del "%combined_wav%" >nul 2>&1

echo Process completed!
pause
