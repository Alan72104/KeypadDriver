using System;
using System.Numerics;
using System.Runtime.InteropServices;
using Accord.Math;
using NAudio.Wave;

namespace SystemAudioWrapper
{
    [ComVisible(true)]
    public class SystemAudioBassLevel
    {
        private WasapiLoopbackCapture capture;
        private BufferedWaveProvider buffer;
        private int bufferSize;
        private int startPoint;
        private int endPoint;

        public SystemAudioBassLevel() { }

        public void Start(int bufferSize, int startPoint, int endPoint)
        {
            this.bufferSize = bufferSize;
            this.startPoint = startPoint;
            this.endPoint = endPoint;
            capture = new WasapiLoopbackCapture();
            capture.DataAvailable += OnDataAvailable;
            buffer = new BufferedWaveProvider(capture.WaveFormat)
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
            int frameSize = bufferSize;
            byte[] audioBytes = new byte[frameSize];
            buffer.Read(audioBytes, 0, frameSize);

            if (audioBytes.Length == 0)
                return 0;
            if (audioBytes[frameSize - 2] == 0)
                return 0;

            // incoming data is 16-bit (2 bytes per audio point)
            int BYTES_PER_POINT = 2;
            // create a (32-bit) int array ready to fill with the 16-bit data
            int graphPointCount = audioBytes.Length / BYTES_PER_POINT;

            double[] pcm = new double[graphPointCount];
            double[] fft;
            double[] realFft = new double[graphPointCount / 2];

            // populate Xs and Ys with double data
            for (int i = 0; i < graphPointCount; i++)
            {
                // read the int16 from the two bytes
                Int16 val = BitConverter.ToInt16(audioBytes, i * 2);

                // store the value in Ys as a percent (+/- 100% = 200%)
                pcm[i] = (double)(val) / Math.Pow(2, 16) * 200.0;
            }

            // calculate the full FFT
            fft = FFT(pcm);
            Array.Copy(fft, realFft, realFft.Length);

            double sumBass = 0.0;
            for (int i = startPoint - 1; i < endPoint; i++)
                sumBass += realFft[i];
            sumBass /= endPoint - (startPoint - 1);

            return (int)sumBass;
        }

        private double[] FFT(double[] data)
        {
            double[] fft = new double[data.Length];
            Complex[] fftComplex = new Complex[data.Length];
            for (int i = 0; i < data.Length; i++)
                fftComplex[i] = new Complex(data[i], 0.0);
            FourierTransform.FFT(fftComplex, FourierTransform.Direction.Forward);
            for (int i = 0; i < data.Length; i++)
                fft[i] = fftComplex[i].Magnitude;
            return fft;
        }
    }
}