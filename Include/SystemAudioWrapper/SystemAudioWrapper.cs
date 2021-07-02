using System;
//using System.Numerics;
using System.Runtime.InteropServices;
//using Accord.Math;
using NAudio.Wave;
using NAudio.Dsp;
using System.IO;
using NAudio.Wave.SampleProviders;

namespace SystemAudioWrapper
{
    [ComVisible(true)]
    public class SystemAudioBassLevel
    {
        private WasapiLoopbackCapture capture;
        private WaveFormat waveFormat;
        private BufferedWaveProvider buffer;
        private int bufferSize;
        private int startPoint;
        private int endPoint;
        private int lastBassLevel;

        public SystemAudioBassLevel() { }

        public void Start(int bufferSize, int startPoint, int endPoint)
        {
            this.bufferSize = bufferSize;
            this.startPoint = startPoint;
            this.endPoint = endPoint;
            capture = new WasapiLoopbackCapture();
            capture.DataAvailable += OnDataAvailable;
            waveFormat = capture.WaveFormat;
            buffer = new BufferedWaveProvider(waveFormat)
            {
                BufferLength = bufferSize * 2,
                DiscardOnBufferOverflow = true
            };
            capture.StartRecording();
        }

        private void OnDataAvailable(object sender, WaveInEventArgs e)
        {
            buffer.AddSamples(e.Buffer, 0, e.BytesRecorded);
        }

        public int GetBassLevel()
        {
            double[] fft = GetFFTArray();
            if (fft == null)
                return lastBassLevel;

            double sum = 0.0;

            for (int i = startPoint - 1; i < endPoint; i++)
                sum += fft[i];
            sum /= endPoint - (startPoint - 1);

            lastBassLevel = (int)sum;
            return (int)sum;
        }

        public double[] GetFFTArray()
        {
            int frameSize = bufferSize;
            byte[] audioBytes = new byte[frameSize];
            buffer.Read(audioBytes, 0, frameSize);

            if (audioBytes.Length == 0)
                return null;
            if (audioBytes[frameSize - 2] == 0)
                return null;

            audioBytes = ToPCM16(audioBytes, frameSize, waveFormat);

            // incoming data is 16-bit (2 bytes per audio point)
            int BYTES_PER_POINT = 2;
            int pointCount = audioBytes.Length / BYTES_PER_POINT;

            double[] pcm = new double[pointCount];

            Complex[] fft = new Complex[pointCount];

            // populate Xs and Ys with double data
            for (int i = 0; i < pointCount; i++)
            {
                // read the int16 from the two bytes
                Int16 val = BitConverter.ToInt16(audioBytes, i * 2);
                // store the value in Ys as a percent (+/- 100% = 200%)
                pcm[i] = (double)val / Math.Pow(2, 16) * 200.0;
                fft[i].X = (float)(pcm[i] * FastFourierTransform.HannWindow(i, pointCount));
                fft[i].Y = 0;
            }

            // transform/calculate the full FFT
            FastFourierTransform.FFT(true, (int)Math.Log(pointCount, 2.0), fft);

            double[] spectrum = new double[pointCount / 2];

            for (int i = 0; i < pointCount / 2; i++)
            {
                double magnitude = Math.Sqrt(fft[i].X * fft[i].X + fft[i].Y * fft[i].Y);
                spectrum[i] = magnitude;
            }

            return spectrum;
        }

        public byte[] ToPCM16(byte[] inputBuffer, int length, WaveFormat format)
        {
            if (length == 0)
                return null; // No bytes recorded

            // Create a WaveStream from the input buffer.
            using (var memStream = new MemoryStream(inputBuffer, 0, length))
            {
                using (var inputStream = new RawSourceWaveStream(memStream, format))
                {
                    // Convert the input stream to a WaveProvider in 16bit PCM format with sample rate of 48000 Hz.
                    SampleToWaveProvider16 convertedPCM = new SampleToWaveProvider16(new WdlResamplingSampleProvider(new WaveToSampleProvider(inputStream), 48000));

                    byte[] convertedBuffer = new byte[length];

                    using (var stream = new MemoryStream())
                    {
                        int read;

                        // Read the converted WaveProvider into a buffer and turn it into a Stream.
                        while ((read = convertedPCM.Read(convertedBuffer, 0, length)) > 0)
                            stream.Write(convertedBuffer, 0, read);

                        // Return the converted Stream as a byte array.
                        return stream.ToArray();
                    }
                }
            }
        }
    }
}