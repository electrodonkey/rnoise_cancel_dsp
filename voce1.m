%Title: Proiect PSB -Eliminarea zgomotului random dintr-un sample vocal
%Description: In cadrul acestui proiect dorim sa eliminam zgomotul random
%introdus in sistem de componentele electronice(zgomot alb)
%Vom incerca sa vedem cu aceasta ocazie daca proprietatile FTB IIR si FTB
%FIR sunt mai apropiate pentru rezolvarea acestei probleme.
%Author: Dan Chirciu
%Email: dan.chirciu@gmail.com

clc
clear all

%preiau semnalul vocal
[voce,Fs] = audioread ('all_systems_go.wav');

%preiau parametrii semnalului citit
t = (1/Fs:1/Fs:length(voce)/Fs);
N1=length(voce);
fv = (Fs/N1.*(0:N1-1));

%generam un zgomot random, pe care il vom adauga la semnal
amp_zg = 0.85;
zgomot = amp_zg*rand(N1,1);

%compun semnalul de voce cu zgomotul
voce_zg = zgomot + voce;

%analiza fft a semnalului cu zgomot
fft_sig=fftshift(abs(fft(voce)));
fft_sigzg=fftshift(abs(fft(voce_zg)));

%prelucrare semnal - FTB IIR
Fe1 = Fs;
W0 = 2*1500*pi;
BW = 2*2000*pi;
[z,p,k] = buttap(6);
[b,a] = zp2tf(z,p,k);
[B1,A] = lp2bp(b,a,W0,BW);
[Ha, Wa] = freqs(B1,A,100);
[Bz,Az] = impinvar(B1,A,Fe1);
[H1, W1] = freqz(Bz,Az,[],Fe1);

%prelucrare semnal - FTB FIR
Fe2 = Fs;
F = [0.0 0.28 0.3 0.5 0.52 1];
M = [0 0 1 1 0 0];
B2 = fir2(30, F,M);
[H2,W2] = freqz(B2,1,100,Fe2);

%afisare caracteristici filtru IIR
figure
subplot(211),plot(W1,abs(H1)),title('Modulul FTB-IIR proiectat'),xlabel('Frecventa (Hz)');
subplot(212),plot(W1,unwrap(angle(H1))),title('Faza FTB-IIR proiectat'),xlabel('Frecventa (Hz)');

%afisare caracteristici filtru FIR
figure
subplot(211),plot(W2,abs(H2)),title('Modulul FTB-FIR proiectat'),xlabel('Frecventa (Hz)');
subplot(212),plot(W2,unwrap(angle(H2))),title('Faza FTB-FIR proiectat'),xlabel('Frecventa (Hz)');

%afisare semnal
figure
subplot(2,1,1) 
plot (t,voce)
title('Voce fara zgomot'), xlabel('Timp (s)')
subplot(2,1,2) 
plot (t,voce_zg)
title('Voce cu zgomot'), xlabel('Timp (s)')
fig2plotly()

%afisare FFT
figure
subplot(2,1,1)
stem (fv,fft_sig)
title('FFT semnal voce')
subplot(2,1,2)
stem (fv,fft_sigzg)
title('FFT semnal zgomot')

%redau semnalul vocal original
%sound(voce,Fs);