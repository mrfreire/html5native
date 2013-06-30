//
//  ViewController.m
//  JSBridgeTest
//
//  Created by Manuel Freire on 30/06/2013.
//  Copyright (c) 2013 Mediatonic. All rights reserved.
//

#import "ViewController.h"

#import "Timer.h"

#import "float.h"

#define TRIES 50

@implementation ViewController

- (id)init
{
	self = [super init];
	if (self)
	{
		m_webView = [[[UIWebView alloc] init] autorelease];
		[self.view addSubview:m_webView];
		m_webView.frame = self.view.frame;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	m_webView.delegate = self;

    NSString* path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    [m_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);

	if ([request.URL.scheme isEqualToString:@"jsb"])
	{
		//NSLog(@"Execute %@", request.URL.host);
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

void testPolling(UIWebView* webView, int bytes, int tries)
{
	NSString* str;
	uint64_t t0 = StartTimer();
	for (int i=0; i<tries; ++i)
	{
		str = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"testPolling(%d)", bytes]];
	}
	uint64_t elapsed = GetElapsedNanoseconds(t0);
	NSLog(@"Polling JS data from native passing %d bytes: %.03f ms on average (%d tries)", bytes, elapsed/(float)tries/1000000, tries);
}

void testPushDataToJS(UIWebView* webView, const char* data, int bytes, int tries)
{
	// Build data string
	const int maxbytes = 64*1024;
	assert(bytes <= maxbytes);
	char str[maxbytes+1];
	memcpy(str, data, bytes);
	str[bytes] = '\0';
	
	uint64_t t0 = StartTimer();
	for (int i=0; i<tries; ++i)
	{
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"testPushData('%s')", str]];
	}
	uint64_t elapsed = GetElapsedNanoseconds(t0);

	NSLog(@"Pushing %d bytes to JS from native: %.03f ms on average (%d tries)", bytes, elapsed/(float)tries/1000000, tries);
}

int fibo(int n)
{
	if (n < 2)
		return n;
	return fibo(n-1) + fibo(n-2);
}

- (void)testFibonacci
{
	const int fib = 20;
	uint64_t t0 = StartTimer();
	NSString* str = [m_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"fibonacci(%d)", fib]];
	uint64_t elapsed = GetElapsedNanoseconds(t0);
	NSLog(@"Fibonacci(%d): %@", fib, str);
	NSLog(@"elapsed: %.03f ms", elapsed/(double)1000000);
	t0 = StartTimer();
	str = [NSString stringWithFormat:@"%d", fibo(fib)];
	elapsed = GetElapsedNanoseconds(t0);
	NSLog(@"Fibonacci-native(%d): %@", fib, str);
	NSLog(@"elapsed: %.03f ms", elapsed/(double)1000000);
}

- (void)runTests:(UIWebView *)webView
{
	char data[1024*64];
	for (int i=0; i<1024*64; ++i)
	{
		data[i] = 'a' + (random() % ('z'-'a'));
	}
	
	int datapoints[] = { 1024, 2048, 4096, 8192, 16384, 32768, 65536 };
	for (int i=0; i<sizeof(datapoints)/sizeof(datapoints[0]); ++i)
	{
		testPolling(webView, datapoints[i], TRIES);
		testPushDataToJS(webView, data, datapoints[i], TRIES);
		NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"testCallNative(%d, %d)", datapoints[i], TRIES]]);
	}
	
	NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"testCallNative(2048, TRIES)"]);
	NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"testCallNative(4096, TRIES)"]);
	NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"testCallNative(8192, TRIES)"]);
	NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"testCallNative(16384, TRIES)"]);
	NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"testCallNative(32768, TRIES)"]);
	NSLog(@"%@", [webView stringByEvaluatingJavaScriptFromString:@"testCallNative(65536, TRIES)"]);
	
	//[self testFibonacci];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self performSelector:@selector(runTests:) withObject:webView afterDelay:0.005];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
