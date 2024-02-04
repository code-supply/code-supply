+++
title = "The passing of time, and all of its crimes."
date = 2013-06-16
+++

**Originally published on pivotallabs.com, available with comments on
[archive.org](https://web.archive.org/web/20150225163229/http://pivotallabs.com/the-passing-of-time-and-all-of-its-crimes/)**.

Programmers are constantly implementing time-related features, and accidentally
including time-related bugs. I’m one of those programmers, and I would like to
reduce the number of time-related bugs that I write. Some of them are small
mistakes: time zone issues arise when running a test suite on a machine in a
different time zone. These bugs are often fixed with consistent use of the time
zone feature of a given time library. Others are more sinister, and lurk deep
within the design of a system. They manifest in places where it’s tricky to get
the system into a certain state because it is so heavily dependent on the
current time. I propose that designing for the ability to set the current time
from the outside of the system reduces the prevalence of timing related bugs,
and has the happy accident of making code more reusable and testable.

## How testing exposes this problem

Testing has many forms in the world of software. There are automated acceptance
tests, unit tests, functional tests, enemy tests and so on. There are also
tests carried out by humans. Sometimes referred to as ‘click testing’ or
Quality Assurance, this kind of testing is an essential part of the process of
delivering working software. At Pivotal Labs, it’s usually the Product Manager
who has the final say about whether a feature is complete, or a bug is fixed.
In order to evaluate whether a feature is ready, the PM exercises the area of
the application in question, using the interface that a customer or stakeholder
has been provided with.

When testing software with a mouse and keyboard becomes difficult, however, it
often doesn’t get done. When it doesn’t get done, bugs introduced by diligent
programmers, who test-drive their code, are missed and end up making their way
into production.

After a few cycles of missing bugs like this, a team will look for ways to ease
the pain of click testing their app. The programmers on the team might come up
with clever, easy-to-implement solutions to this problem:

- “We can manipulate the Time library to give us the time we want”
- “We can change all of the data for a given account to pretend that it was created in the past”

When these sorts of techniques dig in, new problems arise. In the former case,
you can end up with code that works when the fake Time library is used, but not
when the real one is used. In the latter, you are committed to a maintenance
chore: when a timestamp field is added, it needs to change along with the rest,
and when the code that changes those fields gets out of sync with how things
really change over time, more bugs arise. It becomes difficult to tell which
bugs are genuine and which are a consequence of artificially shifting time
data.

It’s usually programmers who propose the above solutions. We often think in
low-level terms like libraries and direct data manipulation. From a Product
Manager’s perspective, however, what’s really needed is a design change. One
could imagine the user story presented to the team like this:

As a Product Manager  
I want to travel in time  
So that I can test, for example, that an account gets billed each month

Time travel sounds like science fiction. How could a user of your system
possibly travel in time? It turns out that there are low-level solutions to
this. For example, Timecop, which
[many](https://github.com/travisjeffery/timecop/commit/6942d0eed940ea9a4e06d4dd9658f97bd7c14c8b)
[of](https://github.com/travisjeffery/timecop/commit/7c41d86343225ccb9ccf58701424674d9f0f851b)
[us](https://web.archive.org/web/20150225163229/https://github.com/travisjeffery/timecop/commit/f105e15482fa2629693aee95d400c6428025b788)
at Pivotal have contributed to. If depending on the passing of time is your
addiction, then Timecop is enabling you. It lets you easily manipulate time,
usually for automated testing purposes. For example:

```ruby
Timecop.freeze(1.month.from_now) do
  future_time = Time.now
  sleep 10
  future_time == Time.now # this is true
end
```

Here we’ve frozen time to pretend that it’s one month in the future. I can
imagine some cases where this would be useful (not least in existing systems
that are infected with code coupled to the current time), but in a lot of cases
this is just wrong. Under what circumstance do you actually expect your code to
be frozen in time? What are the consequences of testing code under these
conditions?

Perhaps most importantly to the topic of this post, Timecop lets you forget
about managing time at the unit level, and doesn’t encourage you to build time
controls into your application.

I think there are better ways to get a grip on time that we should all consider
before reaching for the magic wand. Let’s look at some real-world problems that
can occur and then look at ways of building time control into an app’s design.

## Examining the moment

Let’s think about the properties of the current time:

- There is only one current time, unless you’re modelling multiple realities e.g. storylines about time travel.
- Its value is always changing.
- Everything is potentially affected by it.

So, the current time is a global, constantly mutating singleton. We know that
the presence of global singletons is undesirable, because they are polluting.
We also know that mutation ought to be contained, because mutable state makes
our programs less predictable and harder to reason about. If a function deals
with mutable state, then it might have different results each time it is
called, even when it apparently has the same inputs.

Let’s look at a timing bug that can result from the fact that the current time
has these undesirable properties:

```ruby
policy = Policy.find(1)

if policy.current_state == :active
  notify_customer("You are still insured!")
end
# more code goes here
if policy.current_state == :inactive
  notify_customer("You are not insured. Hope you weren't planning on driving anywhere today.")
end
```

Imagine that the above code is within a web request. The request comes in at a
certain time, and the customer wants to know whether their insurance policy is
current. The code above is deep in the guts of a model somewhere, and gets
called after the customer has been authenticated, their request has been
authorized, and their account record has been pulled out of the database. Now
it’s time to see what the state of the policy is, so we use a method someone
wrote (current_state) that fetches the current time and returns a state based
on whether the policy’s end date was before or after that time.

The customer sees this on their screen:

<pre>
You are still insured!
You are not insured. Hope you weren't planning on driving anywhere today.
</pre>

The policy could potentially be active on one line and inactive the next. This
kind of bug gets worse when one line makes an external call if the object were
in one state, and the next makes a conflicting call if it were in another.

I recently ran into a real bug similar to this on my current project, which was
caught when an acceptance test I was writing would fail on one run and pass on
the next. The temporary workaround was to memoize the method that checked the
current state (current_state above). Unfortunately, this introduced even more
mutable state, because memoization requires changing the state of an instance
variable. The next programmer might wonder why fetching the current state works
the first time he asks, but stays the same with consecutive calls.

## current_nothing

The current_state method is guilty here. But what of? It has a hidden input,
which is the current time. It’s not explicit, and that’s where the confusion
lies. It wouldn’t make sense to have a method called current_something and have
it take the time as an argument, because the prefix “current_” implies that
it’s supposed to know what the current state is.

The internal functions of a program shouldn’t know this stuff. In most web
apps, a request is made at a certain point in time, but it’s not important that
the request takes some time. With most scheduled jobs, the job is run at a
certain time, but it’s not important that the job takes some time (or if it is,
it’s stored as metadata).

A name less prone to attracting this kind of bug might be state_as_of(time). If
we force ourselves to pass the time as a parameter to all of our low-level
functions, then we can:

1. More easily unit test the basic correctness of the method without resorting
   to stubbing out the time with Timecop.
1. Force out a decision to be made about what moment the lower-level methods
   should be operating on. Ideally the control would move as high as possible:
   to the controller level, or in the case of jobs, to the job itself, or to an
   environment variable.

## A word about scheduling

Scheduled jobs are often concerned with when they think they’re being run, but
a PM doesn’t want to wait for a month to see if, for example, the billing
system is working. It’s important to give control over when a job thinks it’s
being run to the PM or other person evaluating whether a system works. This
might mean dropping your out-of-the-box scheduling interface for the purposes
of feature acceptance.

[Resque-scheduler](https://github.com/resque/resque-scheduler) has become very
popular amongst developers as it’s easy to install and provides a cron-like
syntax for declaring when jobs are run. It also provides a GUI for triggering
scheduled jobs immediately. Unfortunately, there’s no way to set parameters for
the jobs, so the time can’t be set. If you choose to heed the advice in this
post and parameterize time, you’ll need to provide your own interface for
passing the current time into the system. This is a good idea anyway. See
[GOOS](http://growing-object-oriented-software.com/) for a good treatment of
externalizing event sources, which goes even further than the suggestions in
this post in many ways.

Making time a parameter to your jobs can often make the jobs more reusable. For
example, I might want to invalidate all sessions in a particular time range
because there was a system fault at those times.

## A word about external dependencies

What happens if your external dependencies are dependent on the current time?
Well, you’re going to have problems with that no matter how much control you
build into your system. I would argue that the services should be wrapped, and
the wrappers should allow the time to be passed in to fake responses if
necessary. The acceptance (as in story acceptance in Pivotal Tracker) of your
system doesn’t have to depend on the state of the other systems.

## A word about customer-facing status pages

What if your customer needs to be shown what’s happening right now? I think the
trick here is to depend on the order of time, and not the passing of time. To
move into the future, we should be reacting to events by adding data, not
mutating it. A database can easily figure out what the latest order is, or what
the latest billing cycle is. It doesn’t have to be a function of the current
time.

If, however, it’s just too difficult to implement the functionality without
checking the current time, it could be argued that the current time be a
parameter passed in through the browser, available only in certain testing
environments. I would resist this as far as possible, but think that it would
be a preferable solution to mutating the state of the database.
