WebApp
======

**WebApp is currently in development**. When completed, the WebApp framework will provide a simple interface for serving HTTP content directly from Objective-C.  Features will be added for session management, SSL encryption, and potentially MySQL.

Using WebApp will allow you to eliminate the need for a web-based scripting language such as PHP, or even an interface like CGI.  By incorporating the HTTP server into your server code, you will essentially be able to make a single-process HTTP server.

Efficiency
==========

The current plans for the WebApp framework include those for managing threads.  It is planned that the user of the framework will be able to set a *max thread count*.  If the number of threads exceeds this *max thread count*, new HTTP requests will be queued on existing server threads.  On a system like Mach, creating a thread is much less costly than creating a task, and is therefore more efficient than spawning a new process for every request like Apache does.

GNUstep Compatibility
=====================

WebApp is being developed specifically under the notion that it will be able to run on Linux servers via GNUstep.  GNUstep includes a set of classes that mirror the Foundation framework, but does not include some commonly used features of Objective-C.  When developing for GNUstep, one cannot use ```@property```, fast enumeration, or ```#pragma mark```.  This being said, if you contribute code to the WebApp project, be sure not to use any of these features.

License
=======

Currently, WebApp is under the BSD license.

	Copyright (c) 2011-2012 Ryan (NULL) and Alex Nichol
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:
	1. Redistributions of source code must retain the above copyright
	   notice, this list of conditions and the following disclaimer.
	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.
	3. The name of the author may not be used to endorse or promote products
	   derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
	IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
	IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.