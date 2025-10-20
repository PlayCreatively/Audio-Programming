/*~audio_address = ".\Audio files\";
~vocal = Buffer.read(s, ~audio_address+"vocal.wav");*/


~vocal = Buffer.read(s, "/Users/up2544706/Documents/Audio-Programming/Week 4/Audio files/vocal.wav");

(
{
	var speed = MouseX.kr(-1,1);

	PlayBuf.ar(
		2,
		~vocal.bufnum,
		BufRateScale.kr(~vocal.bufnum)*speed,
		loop:1
	)
}.play
)