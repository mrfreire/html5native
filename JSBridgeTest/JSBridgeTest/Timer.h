// Based on http://developer.apple.com/library/mac/#qa/qa1398/_index.html

#pragma once

#include <stdint.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

inline uint64_t StartTimer(void)
{
	return mach_absolute_time();
}

inline uint64_t GetElapsedNanoseconds(uint64_t start)
{
	uint64_t        end;
	uint64_t        elapsed;
	uint64_t        elapsedNano;
	static mach_timebase_info_data_t    sTimebaseInfo;
		
	end = mach_absolute_time();
	
	// Calculate the duration.
	
	elapsed = end - start;
	
	// Convert to nanoseconds.
	
	// If this is the first time we've run, get the timebase.
	// We can use denom == 0 to indicate that sTimebaseInfo is
	// uninitialised because it makes no sense to have a zero
	// denominator is a fraction.
	
	if ( sTimebaseInfo.denom == 0 ) {
		(void) mach_timebase_info(&sTimebaseInfo);
	}
	
	// Do the maths. We hope that the multiplication doesn't
	// overflow; the price you pay for working in fixed point.
	
	elapsedNano = elapsed * sTimebaseInfo.numer / sTimebaseInfo.denom;
	
	return elapsedNano;
}
