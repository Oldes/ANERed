Basic AIR native extension to Red language
============================================

What is Red
-----------
*Red* is a computer programming language. ... Introduced in 2011 by *Nenad Rakocevic*, Red is both an imperative and functional programming language. Its syntax and general usage overlaps that of the interpreted *Rebol* language (which was introduced in 1997). More info available at: http://red-lang.org

What is AIR
-----------
*Adobe AIR* is a cross-operating-system runtime that lets developers combine HTML, JavaScript, Adobe Flash® and Flex technologies,and ActionScript® to deploy rich Internet applications (RIAs) on a broad range of devices including desktop computers, netbooks, tablets, smartphones, and TVs.

What is ANERed
--------------
*ANERed* is experiment with embedding Red library into AIR context using [AIR Native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html).

This repository contains sources and script for building the [ANERed extension](https://github.com/Oldes/ANERed/blob/master/03-ANERed-ane/ANERed.ane) and also example test AIR app which contains very simple console for testing Red commands directly from AIR. Here is how it can look like:

![Screenshot](https://raw.githubusercontent.com/Oldes/ANERed/master/Test-app-screenshot.png)

It is still having some issues.. like the values returned from Red are always just a string and also as the output from Red's ```print``` is passed using async call, which is the only way probably.. so the output may be out off sync with input. There may be problems with Red ```ask``` function, ```View``` blocking and similar cases, but that is probably ok.. I don't expect someone would be using the library as real console in AIR. 

To build ANERed and the test app, you must download [AIR SDK](http://www.adobe.com/devnet/air/air-sdk-download.html) and modify the ```setup.bat``` script.

_Using Red directly is imho more fun!_
Follow Red development at _GitHub_: https://github.com/red/red and or discuss it at _Gitter_: https://gitter.im/red/red

- - - - - - - - - - - - -
Copyright (c) 2017, Oldes
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.