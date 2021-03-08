![Banner](https://raw.githubusercontent.com/MatthewYork/Resources/master/DateTools/DateToolsHeader.png)

## DateTools

DateTools was written to streamline date and time handling in Objective-C. Classes and concepts from other languages served as an inspiration for DateTools, especially the [DateTime](http://msdn.microsoft.com/en-us/library/system.datetime(v=vs.110).aspx) structure and [Time Period Library](Time Period Library) for .NET. Through these classes and others, DateTools removes the boilerplate required to access date components, handles more nuanced date comparisons, and serves as the foundation for entirely new concepts like Time Periods and their collections.

[![Build Status](https://travis-ci.org/MatthewYork/DateTools.svg?branch=master)](https://travis-ci.org/MatthewYork/DateTools)
[![Cocoapods](https://cocoapod-badges.herokuapp.com/v/DateTools/badge.png)](http://cocoapods.org/?q=datetools)

####Featured In
<table>
 <tr>
  <td align="center">
  <a href="https://itunes.apple.com/hk/app/yahoo-livetext-video-messenger/id995121875?mt=8"><img src="http://a4.mzstatic.com/us/r30/Purple2/v4/7c/1b/11/7c1b11f3-2a73-b655-751e-b21b2e8bc6f7/icon100x100.png" /></a>
  </td>
  <td align="center">
  <a href="https://itunes.apple.com/app/id547436543"><img src="http://a5.mzstatic.com/us/r30/Purple5/v4/1f/7b/a5/1f7ba545-038e-353e-18a0-b6472eef1913/icon100x100.jpeg" /></a>
  </td>
  <td align="center">
  <a href="https://itunes.apple.com/us/app/aldi-usa/id429396645?mt=8"><img src="http://a4.mzstatic.com/us/r30/Purple7/v4/a7/63/20/a76320db-2de4-62ad-b620-efaab8a179dc/icon100x100.jpeg" /></a>
  </td>
  <td align="center">
  <a href="https://itunes.apple.com/us/app/guidebook/id428713847?mt=8"><img src="http://a5.mzstatic.com/us/r30/Purple7/v4/e4/af/db/e4afdbc1-9ceb-c403-4d06-299e7e693120/icon100x100.png" /></a>
  </td>
  <td align="center">
  <a href="https://itunes.apple.com/us/app/pitch-locator-pro/id964965940?mt=8"><img src="http://a2.mzstatic.com/us/r30/Purple7/v4/39/ed/24/39ed248b-afab-ce8d-4276-35ba0459ac60/icon100x100.png" /></a>
  </td>
  <tr>
   <td align="center">Yahoo! Livetext</td>
   <td align="center">My Disney Experience</td>
   <td align="center">ALDI</td>
   <td align="center">Guidebook</td>
   <td align="center">Pitch Locator Pro</td>
  </tr>
 </tr>
</table>

## Installation

**Cocoapods**

<code>pod 'DateTools'</code>

**Manual Installation**

All the classes required for DateTools are located in the DateTools folder in the root of this repository. They are listed below:

* <code>DateTools.h</code>
* <code>NSDate+DateTools.{h,m}</code>
* <code>DTConstants.h</code>
* <code>DTError.{h,m}</code>
* <code>DTTimePeriod.{h,m}</code>
* <code>DTTimePeriodGroup.{h,m}</code>
* <code>DTTimePeriodCollection.{h,m}</code>
* <code>DTTimePeriodChain.{h,m}</code>

The following bundle is necessary if you would like to support internationalization or would like to use the "Time Ago" functionality. You can add localizations at the `Localizations` subheading under `Info` in the `Project` menu.

* <code>DateTools.bundle</code>

<code>DateTools.h</code> contains the headers for all the other files. Import this if you want to link to the entire framework.

## Table of Contents

* [**NSDate+DateTools**](#nsdate-datetools)
  * [Time Ago](#time-ago)
  * [Date Components](#date-components)
  * [Date Editing](#date-editing)
  * [Date Comparison](#date-comparison)
  * [Formatted Date Strings](#formatted-date-strings)
* [**Time Periods**](#time-periods)
  * [Initialization](#initialization)
  * [Time Period Info](#time-period-info)
  * [Manipulation](#manipulation)
  * [Relationships](#relationships) 
* [**Time Period Groups**](#time-period-groups)
  * [Time Period Collections](#time-period-collections)
  * [Time Period Chains](#time-period-chains)
* [**Unit Tests**](#unit-tests)
* [**Credits**](#credits)
* [**License**](#license)

##NSDate+DateTools

One of the missions of DateTools was to make NSDate feel more complete. There are many other languages that allow direct access to information about dates from their date classes, but NSDate (sadly) does not. It safely works only in the Unix time offsets through the <code>timeIntervalSince...</code> methods for building dates and remains calendar agnostic. But that's not <i>always</i> what we want to do. Sometimes, we want to work with dates based on their date components (like year, month, day, etc) at a more abstract level. This is where DateTools comes in.

####Time Ago

No date library would be complete without the ability to quickly make an NSString based on how much earlier a date is than now. DateTools has you covered. These "time ago" strings come in a long and short form, with the latter closely resembling Twitter. You can get these strings like so:

```objc
NSDate *timeAgoDate = [NSDate dateWithTimeIntervalSinceNow:-4];
NSLog(@"Time Ago: %@", timeAgoDate.timeAgoSinceNow);
NSLog(@"Time Ago: %@", timeAgoDate.shortTimeAgoSinceNow);

//Output:
//Time Ago: 4 seconds ago
//Time Ago: 4s
```

Assuming you have added the localization to your project, `DateTools` currently supports the following languages: 

- ar (Arabic)
- bg (Bulgarian)
- ca (Catalan)
- zh_Hans (Chinese Simplified)
- zh_Hant (Chinese Traditional)
- cs (Czech)
- da (Danish)
- nl (Dutch)
- en (English)
- fi (Finnish)
- fr (French)
- de (German)
- gre (Greek)
- gu (Gujarati)
- he (Hebrew)
- hi (Hindi)
- hu (Hungarian)
- is (Icelandic)
- id (Indonesian)
- it (Italian)
- ja (Japanese)
- ko (Korean)
- lv (Latvian)
- ms (Malay)
- nb (Norwegian)
- pl (Polish)
- pt (Portuguese)
- ro (Romanian)
- ru (Russian)
- sl (Slovenian)
- es (Spanish)
- sv (Swedish)
- th (Thai)
- tr (Turkish)
- uk (Ukrainian)
- vi (Vietnamese)
- cy (Welsh)
- hr (Croatian)

If you know a language not listed here, please consider submitting a translation. [Localization codes by language](http://stackoverflow.com/questions/3040677/locale-codes-for-iphone-lproj-folders).

This project is user driven (by people like you). Pull requests close faster than issues (merged or rejected).

Thanks to Kevin Lawler for his work on [NSDate+TimeAgo](https://github.com/kevinlawler/NSDate-TimeAgo), which has been officially merged into this library.

####Date Components

There is a lot of boilerplate associated with getting date components from an NSDate. You have to set up a calendar, use the desired flags for the components you want, and finally extract them out of the calendar. 

With DateTools, this:

```objc
//Create calendar
NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];

//Get components
NSInteger year = dateComponents.year;
NSInteger month = dateComponents.month;
```

...becomes this:
```objc
NSInteger year = date.year;
NSInteger month = date.month;
```

And if you would like to use a non-Gregorian calendar, that option is available as well.
```objc
NSInteger day = [date dayWithCalendar:calendar];
```

If you would like to override the default calendar that DateTools uses, simply change it in the <code>defaultCalendar</code> method of <code>NSDate+DateTools.m</code>.

####Date Editing

The date editing methods in NSDate+DateTools makes it easy to shift a date earlier or later by adding and subtracting date components. For instance, if you would like a date that is 1 year later from a given date, simply call the method <code>dateByAddingYears</code>.

With DateTools, this:
```objc
//Create calendar
NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:[NSDate defaultCalendar]];
NSDateComponents *components = [[NSDateComponents alloc] init];

//Make changes
[components setYear:1];

//Get new date with updated year
NSDate *newDate = [calendar dateByAddingComponents:components toDate:date options:0];
```

...becomes this:
```objc
NSDate *newDate = [date dateByAddingYears:1];
```

Subtraction of date components is also fully supported through the <code>dateBySubtractingYears</code>

####Date Comparison

Another mission of the DateTools category is to greatly increase the flexibility of date comparisons. NSDate gives you four basic methods:
* isEqualToDate:
* earlierDate:
* laterDate:
* compare:

<code>earlierDate:</code> and <code>laterDate:</code> are great, but it would be nice to have a boolean response to help when building logic in code; to easily ask "is this date earlier than that one?". DateTools has a set of proxy methods that do just that as well as a few other methods for extended flexibility. The new methods are:
* isEarlierThan
* isEarlierThanOrEqualTo
* isLaterThan
* isLaterThanOrEqualTo

These methods are great for comparing dates in a boolean fashion, but what if we want to compare the dates and return some meaningful information about how far they are apart? NSDate comes with two methods <code>timeIntervalSinceDate:</code> and <code>timeIntervalSinceNow</code> which gives you a <code>double</code> offset representing the number of seconds between the two dates. This is great and all, but there are times when one wants to know how many years or days are between two dates. For this, DateTools goes back to the ever-trusty NSCalendar and abstracts out all the necessary code for you.

With Date Tools, this:
```objc
NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:[NSDate defaultCalendar]];
NSDate *earliest = [firstDate earlierDate:secondDate];
NSDate *latest = (secondDate == firstDate) ? secondDate : firstDate;
NSInteger multiplier = (secondDate == firstDate) ? -1 : 1;
NSDateComponents *components = [calendar components:allCalendarUnitFlags fromDate:earliest toDate:latest options:0];
NSInteger yearsApart = multiplier*(components.month + 12*components.year);
```
..becomes this:
```objc
NSInteger yearsApart = [firstDate yearsFrom:secondDate];
```
Methods for comparison in this category include:
* <code>yearsFrom:</code>, <code>yearsUntil</code>, <code>yearsAgo</code>, <code>yearsEarlierThan:</code>, <code>yearsLaterThan:</code>
* <code>monthsFrom:</code>, <code>monthsUntil</code>, <code>monthsAgo</code>, <code>monthsEarlierThan:</code>, <code>monthsLaterThan:</code>
* <code>weeksFrom:</code>, <code>weeksUntil</code>, <code>weeksAgo</code>, <code>weeksEarlierThan:</code>, <code>weeksLaterThan:</code>
* <code>daysFrom:</code>, <code>daysUntil</code>, <code>daysAgo</code>, <code>daysEarlierThan:</code>, <code>daysLaterThan:</code>
* <code>hoursFrom:</code>, <code>hoursUntil</code>, <code>hoursAgo</code>, <code>hoursEarlierThan:</code>, <code>hoursLaterThan:</code>
* <code>minutesFrom:</code>, <code>minutesUntil</code>, <code>minutesAgo</code>, <code>minutesEarlierThan:</code>, <code>minutesLaterThan:</code>
* <code>secondsFrom:</code>, <code>secondsUntil</code>, <code>secondsAgo</code>, <code>secondsEarlierThan:</code>, <code>secondsLaterThan:</code>

####Formatted Date Strings

Just for kicks, DateTools has a few convenience methods for quickly creating strings from dates. Those two methods are <code>formattedDateWithStyle:</code> and <code>formattedDateWithFormat:</code>. The current locale is used unless otherwise specified by additional method parameters. Again, just for kicks, really.

##Time Periods

Dates are important, but the real world is a little less discrete than that. Life is made up of spans of time, like an afternoon appointment or a weeklong vacation. In DateTools, time periods are represented by the DTTimePeriod class and come with a suite of initializaiton, manipulation, and comparison methods to make working with them a breeze.

####Initialization

Time peroids consist of an NSDate start date and end date. To initialize a time period, call the init function.

```objc
DTTimePeriod *timePeriod = [[DTTimePeriod alloc] initWithStartDate:startDate endDate:endDate];
```
or, if you would like to create a time period of a known length that starts or ends at a certain time, try out a few other init methods. The method below, for example, creates a time period starting at the current time that is exactly 5 hours long.
```objc
DTTimePeriod *timePeriod = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeHour amount:5 startingAt:[NSDate date]];
```

####Time Period Info

A host of methods have been extended to give information about an instance of DTTimePeriod. A few are listed below
* <code>hasStartDate</code> - Returns true if the period has a start date
* <code>hasEndDate</code> - Returns true if the period has an end date
* <code>isMoment</code> - Returns true if the period has the same start and end date
* <code>durationIn....</code> - Returns the length of the time period in the requested units

####Manipulation

Time periods may also be manipulated. They may be shifted earlier or later as well as expanded and contracted. 

**Shifting**

When a time period is shifted, the start dates and end dates are both moved earlier or later by the amounts requested.
To shift a time period earlier, call <code>shiftEarlierWithSize:amount:</code> and to shift it later, call <code>shiftLaterWithSize:amount:</code>. The amount field serves as a multipler, just like in the above initializaion method.

**Lengthening/Shortening**

When a time periods is lengthened or shortened, it does so anchoring one date of the time period and then changing the other one. There is also an option to anchor the centerpoint of the time period, changing both the start and end dates.

An example of lengthening a time period is shown below:
```objc
DTTimePeriod *timePeriod  = [DTTimePeriod timePeriodWithSize:DTTimePeriodSizeMinute endingAt:[NSDate date]];
[timePeriod lengthenWithAnchorDate:DTTimePeriodAnchorEnd size:DTTimePeriodSizeMinute amount:1];
```
This doubles a time period of duration 1 minute to duration 2 minutes. The end date of "now" is retained and only the start date is shifted 1 minute earlier.

####Relationships

There may come a need, say when you are making a scheduling app, when it might be good to know how two time periods relate to one another. Are they the same? Is one inside of another? All these questions may be asked using the relationship methods of DTTimePeriod.

**The Basics**

Below is a chart of all the possible relationships between two time periods:
![TimePeriods](https://raw.githubusercontent.com/MatthewYork/Resources/master/DateTools/PeriodRelations.png)

A suite of methods have been extended to check for the basic relationships. They are listed below:
* isEqualToPeriod:
* isInside:
* contains:
* overlapsWith:
* intersects:

You can also check for the official relationship (like those shown in the chart) with the following method:
```objc
-(DTTimePeriodRelation)relationToPeriod:(DTTimePeriod *)period;
```
All of the possible relationships have been enumerated in the DTTimePeriodRelation enum. 

**For a better grasp on how time periods relate to one another, check out the "Time Periods" tab in the example application. Here you can slide a few time periods around and watch their relationships change.**

![TimePeriods](https://raw.githubusercontent.com/MatthewYork/Resources/master/DateTools/TimePeriodsDemo.gif)

##Time Period Groups

Time period groups are the final abstraction of date and time in DateTools. Here, time periods are gathered and organized into something useful. There are two main types of time period groups,  <code>DTTimePeriodCollection</code> and <code>DTTimePeriodChain</code>. At a high level, think about a collection as a loose group where overlaps may occur and a chain a more linear, tight group where overlaps are not allowed.

Both collections and chains operate like an NSArray. You may add,insert and remove DTTimePeriod objects from them just as you would objects in an array. The difference is how these periods are handled under the hood.

###Time Period Collections
Time period collections serve as loose sets of time periods. They are unorganized unless you decide to sort them, and have their own characteristics like a StartDate and EndDate that are extrapolated from the time periods within. Time period collections allow overlaps within their set of time periods. 

![TimePeriodCollections](https://raw.githubusercontent.com/MatthewYork/Resources/master/DateTools/TimePeriodCollection.png)

To make a new collection, call the class method like so:

```objc
//Create collection
DTTimePeriodCollection *collection = [DTTimePeriodCollection collection];

//Create a few time periods
 DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[dateFormatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[dateFormatter dateFromString:@"2015 11 05 18:15:12.000"]];
    DTTimePeriod *secondPeriod = [DTTimePeriod timePeriodWithStartDate:[dateFormatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[dateFormatter dateFromString:@"2016 11 05 18:15:12.000"]];

//Add time periods to the colleciton
[collection addTimePeriod:firstPeriod];
[collection addTimePeriod:secondPeriod];

//Retreive collection items
DTTimePeriod *firstPeriod = collection[0];
```
**Sorting**
Sorting time periods in a collection is easy, just call one of the sort methods. There are a total of three sort options, listed below:
* **Start Date** - <code>sortByStartAscending</code>, <code>sortByStartDescending</code>
* **End Date** - <code>sortByEndAscending</code>, <code>sortByEndDescending</code>
* **Time Period Duration** - <code>sortByDurationAscending</code>, <code>sortByDurationDescending</code>

**Operations**
It is also possible to check an NSDate's or DTTimePeriod's relationship to the collection. For instance, if you would like to see all the time periods that intersect with a certain date, you can call the <cdoe>periodsIntersectedByDate:</code> method. The result is a new DTTimePeriodCollection with all those periods that intersect the provided date. There are a host of other methods to try out as well, including a full equality check between two collections.

![TimePeriodCollectionOperations](https://raw.githubusercontent.com/MatthewYork/Resources/master/DateTools/TimePeriodCollectionOperations.png)

###Time Period Chains
Time period chains serve as a tightly coupled set of time periods. They are always organized by start and end date, and have their own characteristics like a StartDate and EndDate that are extrapolated from the time periods within. Time period chains do not allow overlaps within their set of time periods. This type of group is ideal for modeling schedules like sequential meetings or appointments.

![TimePeriodChains](https://raw.githubusercontent.com/MatthewYork/Resources/master/DateTools/TimePeriodChain.png)

To make a new chain, call the class method like so:
```objc
//Create chain
DTTimePeriodChain *chain = [DTTimePeriodChain chain];

//Create a few time periods
 DTTimePeriod *firstPeriod = [DTTimePeriod timePeriodWithStartDate:[dateFormatter dateFromString:@"2014 11 05 18:15:12.000"] endDate:[dateFormatter dateFromString:@"2015 11 05 18:15:12.000"]];
DTTimePeriod *secondPeriod = [DTTimePeriod timePeriodWithStartDate:[dateFormatter dateFromString:@"2015 11 05 18:15:12.000"] endDate:[dateFormatter dateFromString:@"2016 11 05 18:15:12.000"]];

//Add test periods
[chain addTimePeriod:firstPeriod];
[chain addTimePeriod:secondPeriod];

//Retreive chain items
DTTimePeriod *firstPeriod = chain[0];
```

Any time a date is added to the time chain, it retains its duration, but is modified to have its StartDate be the same as the latest period in the chain's EndDate. This helps keep the tightly coupled structure of the chain's time periods. Inserts (besides those at index 0) shift dates after insertion index by the duration of the new time period while leaving those at indexes before untouched. Insertions at index 0 shift the start date of the collection by the duration of the new time period. A full list of operations can be seen below.

**Operations**
Like collections, chains have an equality check and the ability to be shifted earlier and later. Here is a short list of other operations.

![TimePeriodChainOperations](https://raw.githubusercontent.com/MatthewYork/Resources/master/DateTools/TimePeriodChainOperations.png)

##Documentation
All methods and variables have been documented and are available for option+click inspection, just like the SDK classes. This includes an explanation of the methods as well as what their input and output parameters are for. Please raise an issue if you ever feel documentation is confusing or misleading and we will get it fixed up!

##Unit Tests

Unit tests were performed on all the major classes in the library for quality assurance. You can find theses under the "Tests" folder at the top of the library. There are over 300 test cases in all!

If you ever find a test case that is incomplete, please open an issue so we can get it fixed.

Continuous integration testing is performed by Travis CI: [![Build Status](https://travis-ci.org/MatthewYork/DateTools.svg?branch=master)](https://travis-ci.org/MatthewYork/DateTools)

##Credits

Thanks to [Kevin Lawler](https://github.com/kevinlawler) for his initial work on NSDate+TimeAgo. It laid the foundation for DateTools' timeAgo methods. You can find this great project [here](https://github.com/kevinlawler/NSDate-TimeAgo).

Many thanks to the .NET team for their DateTime class and a major thank you to [Jani Giannoudis](http://www.codeproject.com/Members/Jani-Giannoudis) for his work on ITimePeriod.

Images were first published through itenso.com through [Code Project](http://www.codeproject.com/Articles/168662/Time-Period-Library-for-NET)

I would also like to thank **God** through whom all things live and move and have their being. [Acts 17:28](http://www.biblegateway.com/passage/?search=Acts+17%3A16-34&version=NIV)

##License

The MIT License (MIT)

Copyright (c) 2014 Matthew York

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
